//
//  LoginView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/10/25.
//

import SwiftUI

struct LoginView: View {
    var onLoginSuccess: () -> Void = {}
    @State private var isSignIn: Bool = true
    @State private var email: String = ""
    @State private var isEmailValid: Bool = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            // 타이틀
            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(.system(size: 32, weight: .bold))
                Text("Welcome Back , Please enter Your details")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            // Sign In / Signup 토글
            HStack(spacing: 0) {
                Button(action: { isSignIn = true }) {
                    Text("Sign In")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSignIn ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isSignIn ? Color.white : Color(UIColor.systemGray6))
                        .cornerRadius(12)
                }
                Button(action: { isSignIn = false }) {
                    Text("Signup")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(!isSignIn ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(!isSignIn ? Color.white : Color(UIColor.systemGray6))
                        .cornerRadius(12)
                }
            }
            .background(Color(UIColor.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            // 이메일 입력
            HStack {
                Image(systemName: "envelope")
                    .foregroundColor(.gray)
                Divider().frame(height: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Email Address")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField(
                        "", text: $email, onEditingChanged: { _ in validateEmail() },
                        onCommit: validateEmail
                    )
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .font(.system(size: 16, weight: .semibold))
                }
                if isEmailValid {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal)
            // Continue 버튼
            Button(action: { handleLogin() }) {
                Text("Continue")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            // Or Continue With
            HStack {
                Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
                Text("Or Continue With")
                    .font(.caption)
                    .foregroundColor(.gray)
                Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
            }
            .padding(.horizontal)
            // 소셜 로그인 버튼
            HStack(spacing: 24) {
                KakaoLoginButton()
                AppleLoginButton()
            }
            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }

    private func validateEmail() {
        // 간단한 이메일 유효성 검사
        isEmailValid = email.contains("@") && email.contains(".") && email.count > 5
    }

    private func handleLogin() {
        // 실제 로그인 로직 구현 후 성공 시 아래 호출
        onLoginSuccess()
    }
}

struct SocialButton: View {
    let icon: String
    var body: some View {
        Button(action: {}) {
            ZStack {
                Circle()
                    .fill(Color(UIColor.systemGray6))
                    .frame(width: 48, height: 48)
                if icon == "google" {
                    Image(systemName: "g.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                } else if icon == "apple" {
                    Image(systemName: "applelogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                } else if icon == "facebook" {
                    Image(systemName: "f.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

// 코너 radius 확장 및 RoundedCorner Shape 관련 extension, struct 제거

#Preview {
    LoginView()
}
