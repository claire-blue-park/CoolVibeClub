//
//  LoginView.swift
//  CoolVibeClub
//
//

import SwiftUI

struct LoginView: View {
  
  @StateObject private var store: LoginStore
  
  init(onLoginSuccess: @escaping () -> Void = {}) {
    _store = StateObject(wrappedValue: LoginStore(onLoginSuccess: onLoginSuccess))
  }
  
  var body: some View {
    VStack(spacing: 32) {
      
      Spacer()
      // MARK: - 🧩 타이틀
      LoginTitleView()
      
      // MARK: - 🧩 이메일 로그인 영역
      VStack(spacing: 20) {
        TextInputField(
          title: "이메일",
          placeholder: "이메일을 입력해주세요",
          text: Binding(
            get: { store.state.email },
            set: { store.send(.emailChanged($0)) }
          ),
          isValid: store.state.isEmailValid,
          keyboardType: .emailAddress
        )
        
        TextInputField(
          title: "비밀번호",
          placeholder: "비밀번호를 입력해주세요",
          text: Binding(
            get: { store.state.password },
            set: { store.send(.passwordChanged($0)) }
          ),
          isValid: store.state.isPasswordValid,
          isSecure: true
        )
        
        CTAButton(
          title: "계속하기",
          isEnabled: store.state.isEmailValid && store.state.isPasswordValid
        ) {
          store.send(.emailLoginButtonTapped)
        }
      }
      
      // MARK: - 🧩 소셜로그인 및 회원가입
      SocialLoginView(onLoginSuccess: store.onLoginSuccess)
      
      SignupPromptView {
        store.send(.signupButtonTapped)
      }
  
      Spacer()
    }
    .background(Color.white.ignoresSafeArea())
    .fullScreenCover(isPresented: Binding(
      get: { store.state.showSignupView },
      set: { store.send(.toggleSignupView($0)) }
    )) {
      JoinView(
        onSignupSuccess: {
          store.send(.toggleSignupView(false))
          store.send(.setError(nil))
          store.onLoginSuccess()
        },
        onBackToLogin: {
          store.send(.toggleSignupView(false))
        }
      )
    }
  }
}


#Preview {
  LoginView()
}
