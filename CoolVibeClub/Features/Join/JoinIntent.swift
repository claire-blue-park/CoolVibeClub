//
//  JoinIntent.swift
//  CoolVibeClub
//
//  Created by Claire on 8/12/25.
//

import Foundation
import SwiftUI
 
@MainActor
final class JoinIntent: ObservableObject, Intent {
  // MARK: - State
  struct JoinState: StateMarker, Equatable {
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var nickname: String = ""
    var phoneNumber: String = ""
    var introduction: String = ""

    var isEmailValid: Bool = false
    var isPasswordValid: Bool = false
    var isPasswordMatching: Bool = false
    var isNicknameValid: Bool = false
    var isPhoneValid: Bool = false

    var isLoading: Bool = false
    var error: String? = nil
    var errorMessage: String? = nil
    var showError: Bool = false
  }

  enum JoinAction: ActionMarker {
    case setEmail(String)
    case validateEmail
    case setPassword(String)
    case validatePassword
    case setConfirmPassword(String)
    case validatePasswordMatch
    case setNickname(String)
    case validateNickname
    case setPhone(String)
    case validatePhone
    case setIntroduction(String)

    case tapSignup
    case setError(String?)
    case setShowError(Bool)
  }

  typealias ActionType = JoinAction

  // MARK: - Published State
  @Published private(set) var state: JoinState = .init()

  // MARK: - Derived
  var isSignupEnabled: Bool {
    state.isEmailValid && state.isPasswordValid && state.isPasswordMatching &&
    state.isNicknameValid && state.isPhoneValid && !state.introduction.isEmpty && !state.isLoading
  }

  // MARK: - Dependencies
  private let onSignupSuccess: () -> Void
  private let emailSignupClient: EmailSignupClient

  // MARK: - Init
  init(onSignupSuccess: @escaping () -> Void,
       emailSignupClient: EmailSignupClient = .live) {
    self.onSignupSuccess = onSignupSuccess
    self.emailSignupClient = emailSignupClient
  }

  // MARK: - Intent
  func send(_ action: JoinAction) {
    switch action {
    case .setEmail(let email):
      self.state.email = email
    case .validateEmail:
      self.state.isEmailValid = Self.validateEmail(self.state.email)

    case .setPassword(let password):
      self.state.password = password
    case .validatePassword:
      self.state.isPasswordValid = Self.validatePassword(self.state.password)
      if !self.state.confirmPassword.isEmpty {
        self.state.isPasswordMatching = Self.validatePasswordMatch(password: self.state.password, confirm: self.state.confirmPassword)
      }

    case .setConfirmPassword(let confirm):
      self.state.confirmPassword = confirm
    case .validatePasswordMatch:
      self.state.isPasswordMatching = Self.validatePasswordMatch(password: self.state.password, confirm: self.state.confirmPassword)

    case .setNickname(let nickname):
      self.state.nickname = nickname
    case .validateNickname:
      self.state.isNicknameValid = Self.validateNickname(self.state.nickname)

    case .setPhone(let phone):
      self.state.phoneNumber = phone
    case .validatePhone:
      self.state.isPhoneValid = Self.validatePhone(self.state.phoneNumber)

    case .setIntroduction(let intro):
      self.state.introduction = String(intro.prefix(100))

    case .tapSignup:
      guard isSignupEnabled else {
        self.state.errorMessage = "입력값을 다시 확인해주세요"
        self.state.showError = true
        return
      }
      Task { await performSignup() }

    case .setError(let message):
      self.state.errorMessage = message
    case .setShowError(let show):
      self.state.showError = show
    }
  }

  // MARK: - Private
  private func performSignup() async {
    self.state.isLoading = true
    defer { self.state.isLoading = false }

    do {
      // 이메일 중복 검사
      _ = try await emailSignupClient.validateEmail(self.state.email)

      let deviceToken = UserDefaultsHelper.shared.getDeviceToken() ?? "sample_device_token"

      let userData = UserData(
        email: self.state.email,
        password: self.state.password,
        nick: self.state.nickname,
        phoneNum: self.state.phoneNumber,
        introduction: self.state.introduction,
        deviceToken: deviceToken
      )

      let response = try await emailSignupClient.signupUser(userData)

      KeyChainHelper.shared.saveToken(response.accessToken)
      KeyChainHelper.shared.saveRefreshToken(response.refreshToken)
      UserDefaultsHelper.shared.saveUserData(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        userID: response.user_id
      )
      UserDefaultsHelper.shared.setLoggedIn(true)

      if let currentDeviceToken = UserDefaultsHelper.shared.getDeviceToken() {
        Task { try? await DeviceTokenService.shared.updateDeviceToken(currentDeviceToken) }
      }

      onSignupSuccess()
    } catch {
      self.state.errorMessage = error.localizedDescription
      self.state.showError = true
    }
  }

  // MARK: - Validators
  private static func validateEmail(_ email: String) -> Bool {
    let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
  }

  private static func validatePassword(_ password: String) -> Bool {
    let regex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*#?&])[A-Za-z\\d@$!%*#?&]{8,}$"
    return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
  }

  private static func validatePasswordMatch(password: String, confirm: String) -> Bool {
    !password.isEmpty && password == confirm
  }

  private static func validateNickname(_ nickname: String) -> Bool {
    nickname.count >= 2 && nickname.count <= 10
  }

  private static func validatePhone(_ phone: String) -> Bool {
    let regex = "^01[0-9]-?[0-9]{4}-?[0-9]{4}$"
    return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: phone)
  }
}
