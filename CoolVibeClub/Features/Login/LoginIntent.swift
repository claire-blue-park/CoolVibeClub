//
//  LoginIntent.swift
//  CoolVibeClub
//
//  Created by Claire on 8/12/25.
//

import Foundation
import SwiftUI

@MainActor
final class LoginIntent: ObservableObject, Intent {
  // MARK: - State
  struct LoginState: StateMarker, Equatable {
    var error: String?
  
    var isSignIn: Bool = true
    var email: String = ""
    var isEmailValid: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    var showSignupView: Bool = false
  }

  // MARK: - Action
  enum LoginAction: ActionMarker {
    case setEmail(String)
    case validateEmail
    case tapContinue
    case toggleSignIn(Bool)
    case showSignup(Bool)
    case setError(String?)
  }

  typealias ActionType = LoginAction

  // MARK: - Published State
  @Published private(set) var state: LoginState = .init()

  // MARK: - Dependencies
  private let onLoginSuccess: () -> Void

  // MARK: - Init
  init(onLoginSuccess: @escaping () -> Void) {
    self.onLoginSuccess = onLoginSuccess
  }

  // MARK: - Intent
  func send(_ action: LoginAction) {
    switch action {
    case .setEmail(let email):
      self.state.email = email
    case .validateEmail:
      self.state.isEmailValid = Self.validate(email: self.state.email)
    case .tapContinue:
      guard self.state.isEmailValid else {
        self.state.errorMessage = "유효한 이메일을 입력해주세요"
        return
      }
      Task { await performLogin() }
    case .toggleSignIn(let isSignIn):
      self.state.isSignIn = isSignIn
    case .showSignup(let show):
      self.state.showSignupView = show
    case .setError(let message):
      self.state.errorMessage = message
    }
  }

  // MARK: - Private
  private func performLogin() async {
    self.state.isLoading = true
    defer { self.state.isLoading = false }
    // TODO: 실제 로그인 API 연동 시 교체
    try? await Task.sleep(nanoseconds: 400_000_000)
    onLoginSuccess()
  }

  private static func validate(email: String) -> Bool {
    email.contains("@") && email.contains(".") && email.count > 5
  }
}
