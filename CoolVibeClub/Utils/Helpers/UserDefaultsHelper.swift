//
//  UserDefaultsHelper.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

final class UserDefaultsHelper {
  static let shared = UserDefaultsHelper()
  private init() {}
  
  private let deviceTokenKey = "deviceToken"
  private let isLoggedInKey = "isLoggedIn"
  private let userIDKey = "userID"
  private let accessTokenKey = "accessToken"
  private let refreshTokenKey = "refreshToken"
  
  // MARK: - 디바이스 토큰
  func saveDeviceToken(_ token: String) {
    print("📱 디바이스 토큰 저장 중: \(token.prefix(20))... (길이: \(token.count))")
    UserDefaults.standard.set(token, forKey: deviceTokenKey)
    UserDefaults.standard.synchronize()
    print("✅ 디바이스 토큰 저장 완료")
  }
  
  func getDeviceToken() -> String? {
    let token = UserDefaults.standard.string(forKey: deviceTokenKey)
    if let token = token {
      print("📱 디바이스 토큰 조회 성공: \(token.prefix(20))... (길이: \(token.count))")
    } else {
      print("❌ 저장된 디바이스 토큰이 없음")
    }
    return token
  }
  
  // MARK: - 로그인 상태
  func setLoggedIn(_ isLoggedIn: Bool) {
    UserDefaults.standard.set(isLoggedIn, forKey: isLoggedInKey)
    UserDefaults.standard.synchronize()
  }
  
  func isLoggedIn() -> Bool {
    return UserDefaults.standard.bool(forKey: isLoggedInKey)
  }
  
  // MARK: -  유저 아이디
  func saveUserId(_ id: String) {
    UserDefaults.standard.set(id, forKey: userIDKey)
    UserDefaults.standard.synchronize()
  }
  
  func getUserId() -> String? {
    return UserDefaults.standard.string(forKey: userIDKey)
  }
  
  
  // MARK: - 액세스 토큰
  func saveAccessToken(_ token: String) {
    print("🔑 액세스 토큰 저장 중: \(token.prefix(20))...")
    UserDefaults.standard.set(token, forKey: accessTokenKey)
    UserDefaults.standard.synchronize()
    print("✅ 액세스 토큰 저장 완료")
  }
  
  func getAccessToken() -> String? {
    let token = UserDefaults.standard.string(forKey: accessTokenKey)
    if let token = token {
      print("🔑 액세스 토큰 로드: \(token.prefix(20))...")
    } else {
      print("❌ 액세스 토큰이 없음")
    }
    return token
  }
  
  // MARK: - 리프레시 토큰
  func saveRefreshToken(_ token: String) {
    print("🔑 리프레시 토큰 저장 중: \(token.prefix(20))...")
    UserDefaults.standard.set(token, forKey: refreshTokenKey)
    UserDefaults.standard.synchronize()
    print("✅ 리프레시 토큰 저장 완료")
  }
  
  func getRefreshToken() -> String? {
    return UserDefaults.standard.string(forKey: refreshTokenKey)
  }
  
  // MARK: - 유저 데이터
  func saveUserData(accessToken: String? = nil, refreshToken: String? = nil, userID: String? = nil) {
    if let accessToken {
      saveAccessToken(accessToken)
    }
    if let refreshToken {
      saveRefreshToken(refreshToken)
    }
    if let userID {
      saveUserId(userID)
    }
  }
  
  // MARK: - 토큰 삭제
  func clearTokens() {
    UserDefaults.standard.removeObject(forKey: accessTokenKey)
    UserDefaults.standard.removeObject(forKey: refreshTokenKey)
    UserDefaults.standard.synchronize()
  }
  
  // MARK: - 유저 데이터 삭제
  func clearUserData() {
    clearTokens()
    UserDefaults.standard.removeObject(forKey: userIDKey)
    UserDefaults.standard.synchronize()
  }

}

