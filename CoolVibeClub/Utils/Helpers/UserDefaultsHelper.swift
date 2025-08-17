//
//  UserDefaultsHelper.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation
import FirebaseMessaging

final class UserDefaultsHelper {
  static let shared = UserDefaultsHelper()
  private init() {}
  
  private let deviceTokenKey = "deviceToken"
  private let isLoggedInKey = "isLoggedIn"
  private let userIDKey = "userID"
  private let accessTokenKey = "accessToken"
  private let refreshTokenKey = "refreshToken"
  
  // MARK: - 디바이스 토큰 (KeyChain 사용)
  func saveDeviceToken(_ token: String) {
    print("📱 디바이스 토큰 UserDefaults → KeyChain 위임")
    KeyChainHelper.shared.saveDeviceToken(token)
  }
  
  func getDeviceToken() -> String? {
    print("📱 디바이스 토큰 UserDefaults → KeyChain 위임")
    return KeyChainHelper.shared.loadDeviceToken()
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
  
  // MARK: - 디바이스 토큰 요청
  func requestDeviceTokenIfNeeded() async -> String? {
    // 이미 저장된 토큰이 있으면 반환 (KeyChain에서 확인)
    if let existingToken = getDeviceToken() {
      print("📱 기존 디바이스 토큰 사용: \(existingToken.prefix(20))...")
      return existingToken
    }
    
    // FCM 토큰 요청
    print("🔄 FCM 토큰 요청 중...")
    return await withCheckedContinuation { continuation in
      Messaging.messaging().token { token, error in
        if let error = error {
          print("❌ FCM 토큰 요청 실패: \(error)")
          
          // FCM 토큰 실패 시 임시 토큰 생성
          let fallbackToken = self.generateFallbackToken()
          print("🔄 임시 토큰 생성: \(fallbackToken.prefix(20))...")
          self.saveDeviceToken(fallbackToken)  // KeyChain에 저장
          continuation.resume(returning: fallbackToken)
          
        } else if let token = token {
          print("✅ FCM 토큰 요청 성공: \(token.prefix(20))...")
          self.saveDeviceToken(token)  // KeyChain에 저장
          continuation.resume(returning: token)
        } else {
          print("❌ FCM 토큰이 nil")
          
          // FCM 토큰 nil인 경우 임시 토큰 생성
          let fallbackToken = self.generateFallbackToken()
          print("🔄 임시 토큰 생성: \(fallbackToken.prefix(20))...")
          self.saveDeviceToken(fallbackToken)  // KeyChain에 저장
          continuation.resume(returning: fallbackToken)
        }
      }
    }
  }
  
  // MARK: - 임시 토큰 생성
  private func generateFallbackToken() -> String {
    // UUID 기반 임시 토큰 생성
    let uuid = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    let timestamp = String(Int(Date().timeIntervalSince1970))
    return "temp_\(uuid)_\(timestamp)"
  }

}

