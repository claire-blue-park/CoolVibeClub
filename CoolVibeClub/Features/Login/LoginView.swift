//
//  LoginView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct LoginView: View {
  // MARK: - Properties
  var onLoginSuccess: () -> Void = {}
  @StateObject private var intent: LoginIntent

  // MARK: - Init
  init(onLoginSuccess: @escaping () -> Void = {}) {
    self.onLoginSuccess = onLoginSuccess
    _intent = StateObject(wrappedValue: LoginIntent(onLoginSuccess: onLoginSuccess))
  }
  
  // MARK: - Body
  var body: some View {
    VStack(spacing: 24) {
      Spacer()
      // 타이틀
      VStack(spacing: 8) {
        Text("Cool Vibe Club")
          .loginTitleStyle()
      }
      
      Button(action: { intent.send(.toggleSignIn(true)) }) {
        Text("이메일 로그인")
          .font(.system(size: 16, weight: .bold))
          .foregroundColor(CVCColor.grayScale90)
          .frame(maxWidth: .infinity)
      }
   
      
      // 이메일 입력
      HStack {
        Image(systemName: "envelope")
          .foregroundColor(.gray)
        Divider().frame(height: 24)
        VStack(alignment: .leading, spacing: 2) {
          Text("이메일 주소")
            .font(.caption)
            .foregroundColor(.gray)
          TextField(
            "",
            text: Binding(
              get: { intent.state.email },
              set: { intent.send(.setEmail($0)); intent.send(.validateEmail) }
            ),
            onEditingChanged: { _ in intent.send(.validateEmail) },
            onCommit: { intent.send(.validateEmail) }
          )
          .autocapitalization(.none)
          .keyboardType(.emailAddress)
          .font(.system(size: 16, weight: .semibold))
        }
        if intent.state.isEmailValid {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.green)
        }
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 36).stroke(Color.gray.opacity(0.3), lineWidth: 1)
      )
      .padding(.horizontal)
      // Continue 버튼
      Button(action: { intent.send(.tapContinue) }) {
        Text("계속")
          .foregroundColor(.white)
          .font(.system(size: 18, weight: .semibold))
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .cornerRadius(36)
      }
      .padding(.horizontal)
      // Or Continue With
      HStack {
        Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
        Text("또는 소셜 로그인")
          .font(.caption)
          .foregroundColor(.gray)
        Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
      }
      .padding(.horizontal)
      // 소셜 로그인 버튼
      HStack(spacing: 24) {
        KakaoLoginButton(onLoginSuccess: onLoginSuccess)
        AppleLoginButton(onLoginSuccess: onLoginSuccess)
      }
      .padding(.bottom, 32)
      
      Button {
        intent.send(.showSignup(true))
      } label: {
        HStack(spacing: 0) {
          Text("아직 클럽 회원이 아니신가요?  회원가입 하기")
            .font(.system(size: 12))
            .foregroundStyle(CVCColor.grayScale60)
          
          CVCImage.Navigation.noTailArrow.template
            .rotationEffect(.degrees(180))
            .foregroundStyle(CVCColor.grayScale60)
            .frame(width: 12, height: 12)
        }
      }

      Spacer()
    }
    .background(Color.white.ignoresSafeArea())
    .fullScreenCover(isPresented: Binding(
      get: { intent.state.showSignupView },
      set: { intent.send(.showSignup($0)) }
    )) {
      JoinView(
        onSignupSuccess: {
          intent.send(.showSignup(false))
          intent.send(.setError(nil))
          onLoginSuccess()
        },
        onBackToLogin: {
          intent.send(.showSignup(false))
        }
      )
    }
  }
}


#Preview {
  LoginView()
}
