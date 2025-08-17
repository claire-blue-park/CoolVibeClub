//
//  AuthSession.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation
import Combine

/// 🔐 인증 상태 관리 세션
/// 자동 로그인, 토큰 만료 감지, 로그아웃 등을 담당
@MainActor
final class AuthSession: ObservableObject {
  static let shared = AuthSession()
  
  // MARK: - Published Properties
  @Published var isLoggedIn: Bool = false
  @Published var isCheckingAuth: Bool = false
  @Published var user: AuthUser?
  
  // MARK: - Private Properties
  private let keyChainHelper = KeyChainHelper.shared
  private let userDefaultsHelper = UserDefaultsHelper.shared
  private var cancellables = Set<AnyCancellable>()
  
  private init() {
    // 앱 시작 시 초기 상태 설정
    setupInitialState()
  }
  
  // MARK: - Public Methods
  
  /// 자동 로그인 확인
  func checkAutoLogin() async {
    print("🔐 AuthSession: 자동 로그인 확인 시작")
    
    await MainActor.run {
      isCheckingAuth = true
    }
    
    defer {
      Task { @MainActor in
        isCheckingAuth = false
      }
    }
    
    // 저장된 토큰 확인
    guard hasValidTokens() else {
      print("❌ AuthSession: 저장된 토큰이 없음")
      await logout()
      return
    }
    
    do {
      // 서버에 토큰 유효성 검증
      try await validateTokenWithServer()
      
      // 사용자 정보 로드
      await loadUserInfo()
      
      await MainActor.run {
        isLoggedIn = true
      }
      
      print("✅ AuthSession: 자동 로그인 성공")
      
    } catch {
      print("❌ AuthSession: 토큰 검증 실패 - \(error.localizedDescription)")
      await logout()
    }
  }
  
  /// 로그인 성공 후 토큰 저장 (이메일 로그인)
  func login(with response: EmailLoginResponse) async {
    print("🔐 AuthSession: 로그인 토큰 저장")
    
    // 토큰 저장
    keyChainHelper.saveToken(response.accessToken)
    keyChainHelper.saveRefreshToken(response.refreshToken)
    
    // 사용자 정보 저장
    userDefaultsHelper.saveUserData(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      userID: response.user_id
    )
    
    UserDefaults.standard.set(response.nick, forKey: "nick")
    UserDefaults.standard.set(response.email, forKey: "email")
    
    // 상태 업데이트
    await MainActor.run {
      user = AuthUser(
        id: response.user_id,
        email: response.email,
        nick: response.nick,
        profileImage: response.profileImage
      )
      isLoggedIn = true
    }
    
    // 디바이스 토큰 업데이트 (약간의 지연으로 키체인 동기화 대기)
    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초 대기
    await updateDeviceToken()
    
    print("✅ AuthSession: 로그인 완료")
  }
  
  /// 로그인 성공 후 토큰 저장 (애플 로그인)
  func login(with response: AppleLoginResponse) async {
    print("🔐 AuthSession: 애플 로그인 토큰 저장")
    
    // 토큰 저장
    keyChainHelper.saveToken(response.accessToken)
    keyChainHelper.saveRefreshToken(response.refreshToken)
    
    // 사용자 정보 저장
    userDefaultsHelper.saveUserData(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      userID: response.user_id
    )
    
    UserDefaults.standard.set(response.nick, forKey: "nick")
    UserDefaults.standard.set(response.email, forKey: "email")
    
    // 상태 업데이트
    await MainActor.run {
      user = AuthUser(
        id: response.user_id,
        email: response.email,
        nick: response.nick,
        profileImage: nil
      )
      isLoggedIn = true
    }
    
    // 디바이스 토큰 업데이트 (약간의 지연으로 키체인 동기화 대기)
    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초 대기
    await updateDeviceToken()
    
    print("✅ AuthSession: 애플 로그인 완료")
  }
  
  /// 로그인 성공 후 토큰 저장 (카카오 로그인)
  func login(with response: KakaoLoginResponse) async {
    print("🔐 AuthSession: 카카오 로그인 토큰 저장")
    
    // 토큰 저장
    keyChainHelper.saveToken(response.accessToken)
    keyChainHelper.saveRefreshToken(response.refreshToken)
    
    // 사용자 정보 저장
    userDefaultsHelper.saveUserData(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      userID: response.user_id
    )
    
    UserDefaults.standard.set(response.nick, forKey: "nick")
    UserDefaults.standard.set(response.email, forKey: "email")
    
    // 상태 업데이트
    await MainActor.run {
      user = AuthUser(
        id: response.user_id,
        email: response.email,
        nick: response.nick,
        profileImage: response.profileImage
      )
      isLoggedIn = true
    }
    
    // 디바이스 토큰 업데이트 (약간의 지연으로 키체인 동기화 대기)
    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초 대기
    await updateDeviceToken()
    
    print("✅ AuthSession: 카카오 로그인 완료")
  }
  
  /// 로그아웃
  func logout() async {
    print("🔐 AuthSession: 로그아웃 시작")
    
    // 서버에 로그아웃 요청
    do {
      let endpoint = UserEndpoint(requestType: .logout)
      let _: EmptyAuthResponse = try await NetworkManager.shared.fetch(
        from: endpoint,
        errorMapper: { statusCode, errorResponse in
          CommonError.map(statusCode: statusCode, message: errorResponse.message)
        }
      )
      print("✅ 서버 로그아웃 성공")
    } catch {
      print("⚠️ 서버 로그아웃 실패: \(error.localizedDescription)")
    }
    
    // 로컬 데이터 정리
    keyChainHelper.deleteAllTokens()
    userDefaultsHelper.clearUserData()
    userDefaultsHelper.setLoggedIn(false)
    
    // 상태 초기화
    await MainActor.run {
      isLoggedIn = false
      user = nil
    }
    
    // 로그아웃 알림 발송
    NotificationCenter.default.post(name: .userDidLogout, object: nil)
    
    print("✅ AuthSession: 로그아웃 완료")
  }
  
  /// 토큰 갱신
  func refreshTokens() async throws {
    print("🔄 AuthSession: 토큰 갱신 시작")
    
    guard let refreshToken = keyChainHelper.loadRefreshToken() else {
      throw AuthError.refreshTokenNotFound
    }
    
    // 토큰 갱신 요청
    let endpoint = UserEndpoint(requestType: .refreshToken(refreshToken: refreshToken))
    let response: TokenRefreshResponse = try await NetworkManager.shared.fetch(
      from: endpoint,
      errorMapper: { statusCode, errorResponse in
        CommonError.map(statusCode: statusCode, message: errorResponse.message)
      }
    )
    
    // 새 토큰 저장
    keyChainHelper.saveToken(response.accessToken)
    keyChainHelper.saveRefreshToken(response.refreshToken)
    userDefaultsHelper.saveUserData(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken
    )
    
    print("✅ AuthSession: 토큰 갱신 완료")
  }
  
  // MARK: - Private Methods
  
  private func setupInitialState() {
    // UserDefaults와 동기화
    isLoggedIn = userDefaultsHelper.isLoggedIn()
    
    // 저장된 사용자 정보 로드
    if isLoggedIn {
      loadUserInfoFromStorage()
    }
  }
  
  private func hasValidTokens() -> Bool {
    return keyChainHelper.hasValidTokens()
  }
  
  private func validateTokenWithServer() async throws {
    let deviceToken = await userDefaultsHelper.requestDeviceTokenIfNeeded() ?? ""
    let endpoint = UserEndpoint(requestType: .updateDeviceToken(deviceToken: deviceToken))
    
    let _: EmptyAuthResponse = try await NetworkManager.shared.fetch(
      from: endpoint,
      errorMapper: { statusCode, errorResponse in
        CommonError.map(statusCode: statusCode, message: errorResponse.message)
      }
    )
  }
  
  private func loadUserInfo() async {
    guard let userID = userDefaultsHelper.getUserId(),
          let email = UserDefaults.standard.string(forKey: "email"),
          let nick = UserDefaults.standard.string(forKey: "nick") else {
      return
    }
    
    await MainActor.run {
      user = AuthUser(
        id: userID,
        email: email,
        nick: nick,
        profileImage: nil
      )
    }
  }
  
  private func loadUserInfoFromStorage() {
    guard let userID = userDefaultsHelper.getUserId(),
          let email = UserDefaults.standard.string(forKey: "email"),
          let nick = UserDefaults.standard.string(forKey: "nick") else {
      return
    }
    
    user = AuthUser(
      id: userID,
      email: email,
      nick: nick,
      profileImage: nil
    )
  }
  
  private func updateDeviceToken() async {
    do {
      let deviceToken = await userDefaultsHelper.requestDeviceTokenIfNeeded() ?? ""
      try await DeviceTokenService.shared.updateDeviceToken(deviceToken)
    } catch {
      print("⚠️ 디바이스 토큰 업데이트 실패: \(error.localizedDescription)")
    }
  }
}

// MARK: - Models

struct AuthUser {
  let id: String
  let email: String
  let nick: String
  let profileImage: String?
}

enum AuthError: LocalizedError {
  case refreshTokenNotFound
  case tokenValidationFailed
  
  var errorDescription: String? {
    switch self {
    case .refreshTokenNotFound:
      return "리프레시 토큰을 찾을 수 없습니다."
    case .tokenValidationFailed:
      return "토큰 검증에 실패했습니다."
    }
  }
}

// MARK: - Response Models

private struct EmptyAuthResponse: Decodable {}

// MARK: - Notifications

extension Notification.Name {
  static let userDidLogout = Notification.Name("userDidLogout")
}