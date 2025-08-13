//
//  JoinView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct JoinView: View {
  // MARK: - Properties
  var onSignupSuccess: () -> Void = {}
  var onBackToLogin: () -> Void = {}
  
  @StateObject private var intent: JoinIntent
  
  // MARK: - Init
  init(onSignupSuccess: @escaping () -> Void = {}, onBackToLogin: @escaping () -> Void = {}) {
    self.onSignupSuccess = onSignupSuccess
    self.onBackToLogin = onBackToLogin
    _intent = StateObject(wrappedValue: JoinIntent(onSignupSuccess: onSignupSuccess))
  }
  
  // MARK: - Body
  var body: some View {
    VStack(spacing: 24) {
      // 헤더
      HStack {
        Button(action: onBackToLogin) {
          CVCImage.Navigation.arrowLeft.template
            .foregroundStyle(CVCColor.grayScale90)
            .frame(width: 24, height: 24)
        }
        Spacer()
        Text("회원가입")
          .font(.system(size: 18, weight: .bold))
          .foregroundColor(CVCColor.grayScale90)
        Spacer()
        // 빈 공간으로 중앙 정렬
        Color.clear.frame(width: 24, height: 24)
      }
      .padding(.horizontal)
      
      ScrollView {
        VStack(spacing: 20) {
          // 이메일 입력
          formField(
            title: "이메일 주소",
            placeholder: "이메일을 입력해주세요",
            text: Binding(
              get: { intent.state.email },
              set: { intent.send(.setEmail($0)); intent.send(.validateEmail) }
            ),
            isValid: intent.state.isEmailValid,
            keyboardType: .emailAddress,
            onChanged: { intent.send(.validateEmail) }
          )
          
          // 비밀번호 입력
          formField(
            title: "비밀번호",
            placeholder: "비밀번호를 입력해주세요 (최소 8자, 영문, 숫자, 특수문자 포함)",
            text: Binding(
              get: { intent.state.password },
              set: { intent.send(.setPassword($0)); intent.send(.validatePassword) }
            ),
            isValid: intent.state.isPasswordValid,
            isSecure: true,
            onChanged: { intent.send(.validatePassword) }
          )
          
          // 비밀번호 확인
          formField(
            title: "비밀번호 확인",
            placeholder: "비밀번호를 다시 입력해주세요",
            text: Binding(
              get: { intent.state.confirmPassword },
              set: { intent.send(.setConfirmPassword($0)); intent.send(.validatePasswordMatch) }
            ),
            isValid: intent.state.isPasswordMatching,
            isSecure: true,
            onChanged: { intent.send(.validatePasswordMatch) }
          )
          
          // 닉네임 입력
          formField(
            title: "닉네임",
            placeholder: "닉네임을 입력해주세요 (2-10자)",
            text: Binding(
              get: { intent.state.nickname },
              set: { intent.send(.setNickname($0)); intent.send(.validateNickname) }
            ),
            isValid: intent.state.isNicknameValid,
            onChanged: { intent.send(.validateNickname) }
          )
          
          // 전화번호 입력
          formField(
            title: "전화번호",
            placeholder: "전화번호를 입력해주세요",
            text: Binding(
              get: { intent.state.phoneNumber },
              set: { intent.send(.setPhone($0)); intent.send(.validatePhone) }
            ),
            isValid: intent.state.isPhoneValid,
            keyboardType: .phonePad,
            onChanged: { intent.send(.validatePhone) }
          )
          
          // 자기소개 입력
          VStack(alignment: .leading, spacing: 8) {
            Text("자기소개")
              .font(.system(size: 14, weight: .medium))
              .foregroundColor(CVCColor.grayScale75)
            
            TextEditor(text: Binding(
              get: { intent.state.introduction },
              set: { intent.send(.setIntroduction($0)) }
            ))
            .font(.system(size: 16))
            .frame(minHeight: 80)
            .padding(12)
            .background(
              RoundedRectangle(cornerRadius: 12)
                .stroke(CVCColor.grayScale30, lineWidth: 1)
            )
            .onChange(of: intent.state.introduction) { _ in }
            
            HStack {
              Spacer()
              Text("\(intent.state.introduction.count)/100")
                .font(.caption)
                .foregroundColor(CVCColor.grayScale45)
            }
          }
          .padding(.horizontal)
        }
      }
      
      Spacer()
      
      // 회원가입 버튼
      Button(action: { intent.send(.tapSignup) }) {
        if intent.state.isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
          Text("회원가입")
            .font(.system(size: 18, weight: .semibold))
        }
      }
      .foregroundColor(.white)
      .frame(maxWidth: .infinity)
      .padding()
      .background(
        intent.isSignupEnabled ? Color.blue : CVCColor.grayScale45
      )
      .cornerRadius(12)
      .disabled(!intent.isSignupEnabled)
      .padding(.horizontal)
    }
    .background(Color.white.ignoresSafeArea())
    .alert("오류", isPresented: Binding(
      get: { intent.state.showError },
      set: { intent.send(.setShowError($0)) }
    )) {
      Button("확인", role: .cancel) { }
    } message: {
      Text(intent.state.errorMessage ?? "알 수 없는 오류")
    }
  }
  
  // MARK: - Helper Views
  @ViewBuilder
  private func formField(
    title: String,
    placeholder: String,
    text: Binding<String>,
    isValid: Bool,
    isSecure: Bool = false,
    keyboardType: UIKeyboardType = .default,
    onChanged: @escaping () -> Void
  ) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(CVCColor.grayScale75)
      
      HStack {
        Group {
          if isSecure {
            SecureField(placeholder, text: text)
          } else {
            TextField(placeholder, text: text)
              .keyboardType(keyboardType)
              .autocapitalization(.none)
          }
        }
        .font(.system(size: 16))
        .onChange(of: text.wrappedValue) { _ in onChanged() }
        
        if !text.wrappedValue.isEmpty {
          Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
            .foregroundColor(isValid ? .green : .red)
        }
      }
      .padding(12)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .stroke(
            text.wrappedValue.isEmpty ? CVCColor.grayScale30 :
              isValid ? .green : .red,
            lineWidth: 1
          )
      )
    }
    .padding(.horizontal)
  }
  
}

//#Preview {
//    EmailSignupView()
//}
