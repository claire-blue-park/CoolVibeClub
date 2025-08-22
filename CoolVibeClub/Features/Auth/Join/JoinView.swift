//
//  JoinView.swift
//  CoolVibeClub
//

//

import SwiftUI

struct JoinView: View {

  @StateObject private var store: JoinStore
  
  init(
    onSignupSuccess: @escaping () -> Void = {},
    onBackToLogin: @escaping () -> Void = {}
  ) {
    _store = StateObject(wrappedValue: JoinStore(
      onSignupSuccess: onSignupSuccess,
      onBackToLogin: onBackToLogin
    ))
  }
  
  var body: some View {
    VStack(spacing: 24) {
      // MARK: - 🧩 내비게이션바
      NavBarView(
        title: "회원가입",
        leftItems: [.backArrow(action: { store.send(.backButtonTapped) })],
        isCenterTitle: true
      )
      
      // MARK: - 🧩 회원 정보 입력
      ScrollView {
        VStack(spacing: 20) {
          TextInputField(
            title: "이메일 주소",
            placeholder: "이메일을 입력해주세요",
            text: Binding(
              get: { store.state.email },
              set: { store.send(.emailChanged($0)) }
            ),
            isValid: store.state.isEmailValid,
            keyboardType: .emailAddress
          )
          
          /// 비밀번호
          TextInputField(
            title: "비밀번호",
            placeholder: "비밀번호를 입력해주세요 (최소 8자, 영문, 숫자, 특수문자 포함)",
            text: Binding(
              get: { store.state.password },
              set: { store.send(.passwordChanged($0)) }
            ),
            isValid: store.state.isPasswordValid,
            isSecure: true
          )
          
          /// 비밀번호 확인
          TextInputField(
            title: "비밀번호 확인",
            placeholder: "비밀번호를 다시 입력해주세요",
            text: Binding(
              get: { store.state.confirmPassword },
              set: { store.send(.confirmPasswordChanged($0)) }
            ),
            isValid: store.state.isPasswordMatching,
            isSecure: true
          )
          
          /// 닉네임
          TextInputField(
            title: "닉네임",
            placeholder: "닉네임을 입력해주세요 (2-10자)",
            text: Binding(
              get: { store.state.nickname },
              set: { store.send(.nicknameChanged($0)) }
            ),
            isValid: store.state.isNicknameValid
          )
  
        }
      }
      
      Spacer()
      
      // MARK: - 🧩 회원가입 버튼
      CTAButton(
        title: "회원가입",
        isEnabled: store.state.isSignupEnabled
      ) {
        store.send(.signupButtonTapped)
      }
    }
    .background(Color.white.ignoresSafeArea())
    .alert("오류", isPresented: Binding(
      get: { store.state.showError },
      set: { _ in store.send(.dismissError) }
    )) {
      Button("확인", role: .cancel) { }
    } message: {
      Text(store.state.errorMessage ?? "알 수 없는 오류")
    }
  }
}

#Preview {
  JoinView()
}
