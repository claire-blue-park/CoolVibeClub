//
//  JoinFeature.swift
//  CoolVibeClub
//
//

import SwiftUI

struct JoinState {
  // 🔥 입력 필드 상태
  var email: String = ""
  var password: String = ""
  var confirmPassword: String = ""
  var nickname: String = ""
  
  // 🔥 검증 상태 (각 필드의 유효성 여부)
  var isEmailValid: Bool = false
  var isPasswordValid: Bool = false
  var isPasswordMatching: Bool = false
  var isNicknameValid: Bool = false
  
  // 🔥 UI 상태
  var isLoading: Bool = false
  var showError: Bool = false
  var errorMessage: String? = nil
  
  // 🔥 계산된 상태: 모든 필드가 유효한지 확인
  /// 회원가입 버튼 활성화 여부를 결정
  var isSignupEnabled: Bool {
    return isEmailValid && 
           isPasswordValid && 
           isPasswordMatching && 
           isNicknameValid &&
           !isLoading
  }
}


enum JoinAction {
  // 🔥 입력 관련 액션
  case emailChanged(String)
  case passwordChanged(String)
  case confirmPasswordChanged(String)
  case nicknameChanged(String)
  
  // 🔥 검증 관련 액션
  case validateEmail
  case validatePassword
  case validatePasswordMatch
  case validateNickname
  
  // 🔥 UI 액션
  case signupButtonTapped
  case backButtonTapped
  case setLoading(Bool)
  case setError(String?)
  case dismissError
}

@MainActor
class JoinStore: ObservableObject {
  @Published var state = JoinState()
  
  var onSignupSuccess: () -> Void = {}
  var onBackToLogin: () -> Void = {}
  
  init(
    onSignupSuccess: @escaping () -> Void = {},
    onBackToLogin: @escaping () -> Void = {}
  ) {
    self.onSignupSuccess = onSignupSuccess
    self.onBackToLogin = onBackToLogin
  }
  
  func send(_ action: JoinAction) {
    switch action {
      
    // 🔥 입력 필드 변경 처리
    case .emailChanged(let email):
      state.email = email
      send(.validateEmail)  // 입력 즉시 검증
      
    case .passwordChanged(let password):
      state.password = password
      send(.validatePassword)
      // 비밀번호가 변경되면 확인 비밀번호도 다시 검증
      if !state.confirmPassword.isEmpty {
        send(.validatePasswordMatch)
      }
      
    case .confirmPasswordChanged(let confirmPassword):
      state.confirmPassword = confirmPassword
      send(.validatePasswordMatch)
      
    case .nicknameChanged(let nickname):
      state.nickname = nickname
      send(.validateNickname)
      

    case .validateEmail:
      // 간단한 이메일 검증
      let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
      state.isEmailValid = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        .evaluate(with: state.email)
      
    case .validatePassword:
      // 비밀번호: 최소 8자, 영문, 숫자, 특수문자 포함
      let password = state.password
      state.isPasswordValid = password.count >= 8 &&
        password.range(of: "[A-Za-z]", options: .regularExpression) != nil &&
        password.range(of: "[0-9]", options: .regularExpression) != nil &&
        password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
      
    case .validatePasswordMatch:
      // 비밀번호 일치 확인
      state.isPasswordMatching = !state.confirmPassword.isEmpty &&
        state.password == state.confirmPassword
      
    case .validateNickname:
      // 닉네임: 2-10자
      let nickname = state.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
      state.isNicknameValid = nickname.count >= 2 && nickname.count <= 10
      
    // 🔥 버튼 액션 처리
    case .signupButtonTapped:
      guard state.isSignupEnabled else { return }
      
      print("✅ 회원가입 시도")
      print("이메일: \(state.email)")
      print("닉네임: \(state.nickname)")
      
      // TODO: 실제 회원가입 API 호출
      send(.setLoading(true))
      
      // 임시로 2초 후 성공 처리
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        self.send(.setLoading(false))
        self.onSignupSuccess()
      }
      
    case .backButtonTapped:
      onBackToLogin()
      
    // 🔥 상태 변경 처리
    case .setLoading(let isLoading):
      state.isLoading = isLoading
      
    case .setError(let message):
      state.errorMessage = message
      state.showError = message != nil
      
    case .dismissError:
      state.showError = false
      state.errorMessage = nil
    }
  }
}
