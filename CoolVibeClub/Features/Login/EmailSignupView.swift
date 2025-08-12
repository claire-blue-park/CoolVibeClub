//
//  EmailSignupView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct EmailSignupView: View {
    // MARK: - Properties
    var onSignupSuccess: () -> Void = {}
    var onBackToLogin: () -> Void = {}
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var nickname: String = ""
    @State private var phoneNumber: String = ""
    @State private var introduction: String = ""
    
    @State private var isEmailValid: Bool = false
    @State private var isPasswordValid: Bool = false
    @State private var isPasswordMatching: Bool = false
    @State private var isNicknameValid: Bool = false
    @State private var isPhoneValid: Bool = false
    
    @State private var isLoading: Bool = false
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    
    private let emailSignupClient = EmailSignupClient.live
    
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
                        text: $email,
                        isValid: isEmailValid,
                        keyboardType: .emailAddress,
                        onChanged: validateEmail
                    )
                    
                    // 비밀번호 입력
                    formField(
                        title: "비밀번호",
                        placeholder: "비밀번호를 입력해주세요 (최소 8자, 영문, 숫자, 특수문자 포함)",
                        text: $password,
                        isValid: isPasswordValid,
                        isSecure: true,
                        onChanged: validatePassword
                    )
                    
                    // 비밀번호 확인
                    formField(
                        title: "비밀번호 확인",
                        placeholder: "비밀번호를 다시 입력해주세요",
                        text: $confirmPassword,
                        isValid: isPasswordMatching,
                        isSecure: true,
                        onChanged: validatePasswordMatch
                    )
                    
                    // 닉네임 입력
                    formField(
                        title: "닉네임",
                        placeholder: "닉네임을 입력해주세요 (2-10자)",
                        text: $nickname,
                        isValid: isNicknameValid,
                        onChanged: validateNickname
                    )
                    
                    // 전화번호 입력
                    formField(
                        title: "전화번호",
                        placeholder: "전화번호를 입력해주세요",
                        text: $phoneNumber,
                        isValid: isPhoneValid,
                        keyboardType: .phonePad,
                        onChanged: validatePhone
                    )
                    
                    // 자기소개 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("자기소개")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(CVCColor.grayScale75)
                        
                        TextEditor(text: $introduction)
                            .font(.system(size: 16))
                            .frame(minHeight: 80)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(CVCColor.grayScale30, lineWidth: 1)
                            )
                            .onChange(of: introduction) { _ in
                                if introduction.count > 100 {
                                    introduction = String(introduction.prefix(100))
                                }
                            }
                        
                        HStack {
                            Spacer()
                            Text("\(introduction.count)/100")
                                .font(.caption)
                                .foregroundColor(CVCColor.grayScale45)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
            
            // 회원가입 버튼
            Button(action: handleSignup) {
                if isLoading {
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
              allFieldsValid ? Color.blue : CVCColor.grayScale45
            )
            .cornerRadius(12)
            .disabled(!allFieldsValid || isLoading)
            .padding(.horizontal)
        }
        .background(Color.white.ignoresSafeArea())
        .alert("오류", isPresented: $showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(errorMessage)
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
    
    // MARK: - Computed Properties
    private var allFieldsValid: Bool {
        isEmailValid && isPasswordValid && isPasswordMatching && 
        isNicknameValid && isPhoneValid && !introduction.isEmpty
    }
    
    // MARK: - Validation Methods
    private func validateEmail() {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        isEmailValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func validatePassword() {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$"
        isPasswordValid = NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
        
        // 비밀번호가 변경되면 확인 비밀번호도 다시 검증
        if !confirmPassword.isEmpty {
            validatePasswordMatch()
        }
    }
    
    private func validatePasswordMatch() {
        isPasswordMatching = !password.isEmpty && password == confirmPassword
    }
    
    private func validateNickname() {
        isNicknameValid = nickname.count >= 2 && nickname.count <= 10
    }
    
    private func validatePhone() {
        let phoneRegex = "^01[0-9]-?[0-9]{4}-?[0-9]{4}$"
        isPhoneValid = NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: phoneNumber)
    }
    
    // MARK: - Actions
    private func handleSignup() {
        Task {
            await performSignup()
        }
    }
    
    @MainActor
    private func performSignup() async {
        isLoading = true
        
        do {
            // 먼저 이메일 중복 검사
            let _ = try await emailSignupClient.validateEmail(email)
            
            // 회원가입 진행
            // 디바이스 토큰 확인
            let deviceToken = UserDefaultsHelper.shared.getDeviceToken() ?? "sample_device_token"
            print("📱 사용할 디바이스 토큰: \(deviceToken)")
            
            let userData = UserData(
                email: email,
                password: password,
                nick: nickname,
                phoneNum: phoneNumber,
                introduction: introduction,
                deviceToken: deviceToken
            )
            
            let response = try await emailSignupClient.signupUser(userData)
            
            // 토큰 저장 (KeyChain + UserDefaults 동기화)
            KeyChainHelper.shared.saveToken(response.accessToken)
            KeyChainHelper.shared.saveRefreshToken(response.refreshToken)
            UserDefaultsHelper.shared.saveUserData(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken,
                userID: response.user_id
            )
            UserDefaultsHelper.shared.setLoggedIn(true)
            
            // 디바이스 토큰 서버 업데이트
            if let currentDeviceToken = UserDefaultsHelper.shared.getDeviceToken() {
                Task {
                    do {
                        try await DeviceTokenService.shared.updateDeviceToken(currentDeviceToken)
                    } catch {
                        print("❌ 회원가입 후 디바이스 토큰 업데이트 실패: \(error.localizedDescription)")
                    }
                }
            }
            
            onSignupSuccess()
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
}

#Preview {
    EmailSignupView()
}
