//
//  LoginFeature.swift
//  CoolVibeClub
//
//  TCA(The Composable Architecture) 스타일 구조
//  🔥 이해 필수: Action(액션), State(상태), Reducer(로직) 패턴
//

import SwiftUI
import FirebaseMessaging

// MARK: - 🔥 State (상태 관리)
/// 로그인 화면의 모든 상태를 담는 구조체
/// 🔥 중요: 화면에 보여지는 모든 데이터와 상태가 여기에 모임
struct LoginState {
  // 입력 필드 상태
  var email: String = ""           // 이메일 입력값
  var password: String = ""        // 비밀번호 입력값
  
  // 검증 상태
  var isEmailValid: Bool = false   // 이메일 유효성 검사 결과
  var isPasswordValid: Bool = false // 비밀번호 유효성 검사 결과
  
  // UI 상태
  var showSignupView: Bool = false // 회원가입 화면 표시 여부
  var isLoading: Bool = false      // 로딩 상태
  var errorMessage: String? = nil  // 에러 메시지
  
  // 자동 로그인 상태
  var isCheckingToken: Bool = false // 토큰 검증 중 상태
}

// MARK: - 🔥 Action (액션 정의)
/// 사용자가 할 수 있는 모든 행동을 열거형으로 정의
/// 🔥 중요: 버튼 클릭, 텍스트 입력 등 모든 사용자 행동이 Action이 됨
enum LoginAction {
  // 입력 관련 액션
  case emailChanged(String)        // 이메일 변경
  case passwordChanged(String)     // 비밀번호 변경
  case validateEmail              // 이메일 유효성 검사
  case validatePassword           // 비밀번호 유효성 검사
  
  // 버튼 클릭 액션
  case emailLoginButtonTapped       // 이메일 버튼 클릭
  case signupButtonTapped         // 회원가입 버튼 클릭
  case toggleSignupView(Bool)     // 회원가입 화면 토글
  
  // 로딩 및 에러 액션
  case setLoading(Bool)           // 로딩 상태 변경
  case setError(String?)          // 에러 메시지 설정
  
  // 자동 로그인 액션
  case checkAutoLogin             // 자동 로그인 확인
  case setCheckingToken(Bool)     // 토큰 검증 상태 변경
}

@MainActor
final class LoginStore: ObservableObject {
  
  // MARK: - 현재 상태
  @Published var state = LoginState()
  
  // MARK: - 콜백 함수
  var onLoginSuccess: () -> Void = {}
  
  init(onLoginSuccess: @escaping () -> Void = {}) {
    self.onLoginSuccess = onLoginSuccess
  }
  
  // MARK: - 액션
  func send(_ action: LoginAction) {
    switch action {
      
    case .emailChanged(let email):
      state.email = email
      send(.validateEmail)
      
    case .passwordChanged(let password):
      state.password = password
      send(.validatePassword)
      
      // MARK: - ▶️ 로컬 이메일, 비밀번호 검사
    case .validateEmail:
      state.isEmailValid = isValidEmail(state.email)
      
    case .validatePassword:
      state.isPasswordValid = isValidPassword(state.password)
      
      // MARK: - ▶️ 이메일 로그인
    case .emailLoginButtonTapped:
      performEmailLogin()
      
    case .signupButtonTapped:
      send(.toggleSignupView(true))
      
    case .toggleSignupView(let show):
      state.showSignupView = show
      
      // 상태 변경 처리
    case .setLoading(let isLoading):
      state.isLoading = isLoading
      
    case .setError(let message):
      state.errorMessage = message
      
      // 자동 로그인 처리
    case .checkAutoLogin:
      checkAutoLogin()
      
    case .setCheckingToken(let isChecking):
      state.isCheckingToken = isChecking
    }
  }
}

// MARK: - 내부 함수
extension LoginStore {
  // MARK: - Ⓜ️ 서버 이메일 검증
  private func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
  }
  
  private func isValidPassword(_ password: String) -> Bool {
    return password.count >= 6
  }
  
  private func mapErrorToMessage(_ error: Error) -> String {
    if let emailLoginError = error as? EmailLoginError {
      return emailLoginError.errorDescription ?? "이메일 로그인 오류가 발생했습니다."
    } else {
      return error.localizedDescription
    }
  }
  
  // MARK: - Ⓜ️ 서버로 이메일 로그인
  private func performEmailLogin() {
    Task {
      do {
        send(.setLoading(true))
        send(.setError(nil))
        
        let deviceToken = await UserDefaultsHelper.shared.requestDeviceTokenIfNeeded() ?? ""
        
        let endpoint = UserEndpoint(requestType: .emailLogin(
          email: state.email,
          password: state.password,
          deviceToken: deviceToken
        ))
        
        let response: EmailLoginResponse = try await NetworkManager.shared.fetch(
          from: endpoint,
          errorMapper: { statusCode, errorResponse in
            EmailLoginError.map(statusCode: statusCode, error: errorResponse)
          }
        )
        
        // AuthSession을 통한 로그인 처리
        await AuthSession.shared.login(with: response)
        
        await MainActor.run {
          send(.setLoading(false))
          onLoginSuccess()
        }
        
      } catch {
        await MainActor.run {
          send(.setLoading(false))
          let errorMessage = mapErrorToMessage(error)
          send(.setError(errorMessage))
        }
      }
    }
  }
  
  // MARK: - Ⓜ️ 자동 로그인 확인
  private func checkAutoLogin() {
    Task {
      await MainActor.run {
        send(.setCheckingToken(true))
        send(.setError(nil))
      }
      
      // AuthSession에 위임
      await AuthSession.shared.checkAutoLogin()
      
      await MainActor.run {
        send(.setCheckingToken(false))
        
        // AuthSession의 로그인 상태에 따라 처리
        if AuthSession.shared.isLoggedIn {
          onLoginSuccess()
        }
      }
    }
  }
}
