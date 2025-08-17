//
//  KeyChainHelper.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation
import Security

// 키체인 에러 타입 정의
enum KeychainError: Error {
  case itemNotFound
  case duplicateItem
  case invalidData
  case unexpectedStatus(OSStatus)
  
  var localizedDescription: String {
    switch self {
    case .itemNotFound:
      return "키체인에서 항목을 찾을 수 없습니다"
    case .duplicateItem:
      return "키체인에 중복된 항목이 있습니다"
    case .invalidData:
      return "유효하지 않은 데이터입니다"
    case .unexpectedStatus(let status):
      return "예상치 못한 키체인 오류: \(status)"
    }
  }
}

struct KeyChainHelper {
  static let shared = KeyChainHelper()
  private init() { }
  
  private let accessTokenAccount = "accessToken"
  private let refreshTokenAccount = "refreshToken"
  private let deviceTokenAccount = "deviceToken"
  
  // MARK: - 액세스 토큰 관리
  
  func saveToken(_ token: String) {
    print("🔑 액세스 토큰 저장 시도: 길이 \(token.count)")
    
    do {
      try saveTokenToKeychain(token, account: accessTokenAccount)
      print("✅ 액세스 토큰이 성공적으로 저장되었습니다")
    } catch {
      print("❌ 액세스 토큰 저장 실패: \(error)")
    }
  }
  
  func loadToken() -> String? {
    do {
      let token = try loadTokenFromKeychain(account: accessTokenAccount)
      print("✅ 액세스 토큰 로드 성공")
      return token
    } catch {
      print("❌ 액세스 토큰 로드 실패: \(error.localizedDescription)")
      return nil
    }
  }
  
  func deleteToken() {
    do {
      try deleteTokenFromKeychain(account: accessTokenAccount)
      print("✅ 액세스 토큰이 성공적으로 삭제되었습니다")
    } catch {
      print("❌ 액세스 토큰 삭제 실패: \(error.localizedDescription)")
    }
  }
  
  // MARK: - 리프레시 토큰 관리
  
  func saveRefreshToken(_ token: String) {
    print("🔑 리프레시 토큰 저장 시도: 길이 \(token.count)")
    
    do {
      try saveTokenToKeychain(token, account: refreshTokenAccount)
      print("✅ 리프레시 토큰이 성공적으로 저장되었습니다")
    } catch {
      print("❌ 리프레시 토큰 저장 실패: \(error)")
    }
  }
  
  func loadRefreshToken() -> String? {
    do {
      let token = try loadTokenFromKeychain(account: refreshTokenAccount)
      print("✅ 리프레시 토큰 로드 성공: 토큰 길이 \(token.count)")
      return token
    } catch {
      print("❌ 리프레시 토큰 로드 실패: \(error.localizedDescription)")
      return nil
    }
  }
  
  func deleteRefreshToken() {
    do {
      try deleteTokenFromKeychain(account: refreshTokenAccount)
      print("✅ 리프레시 토큰이 성공적으로 삭제되었습니다")
    } catch {
      print("❌ 리프레시 토큰 삭제 실패: \(error.localizedDescription)")
    }
  }
  
  // MARK: - 디바이스 토큰 관리
  
  func saveDeviceToken(_ token: String) {
    print("📱 디바이스 토큰 저장 시도: 길이 \(token.count)")
    
    do {
      try saveTokenToKeychain(token, account: deviceTokenAccount)
      print("✅ 디바이스 토큰이 성공적으로 저장되었습니다")
    } catch {
      print("❌ 디바이스 토큰 저장 실패: \(error)")
    }
  }
  
  func loadDeviceToken() -> String? {
    do {
      let token = try loadTokenFromKeychain(account: deviceTokenAccount)
      print("✅ 디바이스 토큰 로드 성공: \(token.prefix(20))...")
      return token
    } catch {
      print("❌ 디바이스 토큰 로드 실패: \(error.localizedDescription)")
      return nil
    }
  }
  
  func deleteDeviceToken() {
    do {
      try deleteTokenFromKeychain(account: deviceTokenAccount)
      print("✅ 디바이스 토큰이 성공적으로 삭제되었습니다")
    } catch {
      print("❌ 디바이스 토큰 삭제 실패: \(error.localizedDescription)")
    }
  }
  
  // MARK: - 전체 토큰 관리
  
  func deleteAllTokens() {
    deleteToken()
    deleteRefreshToken()
    deleteDeviceToken()
    print("🗑️ 모든 토큰이 삭제되었습니다")
  }
  
  // 토큰 존재 여부 확인
  func hasValidTokens() -> Bool {
    guard let accessToken = loadToken(), !accessToken.isEmpty,
          let refreshToken = loadRefreshToken(), !refreshToken.isEmpty else {
      return false
    }
    return true
  }
  
  // MARK: - Private 헬퍼 메서드
  
  private func saveTokenToKeychain(_ token: String, account: String) throws {
    print("🔍 KeyChain: 토큰 저장 시도 - account: \(account)")
    
    guard let tokenData = token.data(using: .utf8) else {
      throw KeychainError.invalidData
    }
    
    let deleteQuery: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: account
    ]
    
    // 기존 항목 삭제 (에러 무시)
    let deleteStatus = SecItemDelete(deleteQuery as CFDictionary)
    print("🔍 KeyChain: 기존 항목 삭제 상태 - \(deleteStatus)")
    
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: account,
      kSecValueData as String: tokenData,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
    ]
    
    // 새 항목 추가
    let status = SecItemAdd(query as CFDictionary, nil)
    print("🔍 KeyChain: 새 항목 추가 상태 - \(status)")
    
    switch status {
    case errSecSuccess:
      print("✅ KeyChain: 토큰 저장 성공 - \(account)")
      break
    case errSecDuplicateItem:
      print("❌ KeyChain: 중복 항목 - \(account)")
      throw KeychainError.duplicateItem
    default:
      print("❌ KeyChain: 예상치 못한 저장 상태 - \(status)")
      throw KeychainError.unexpectedStatus(status)
    }
  }
  
  private func loadTokenFromKeychain(account: String) throws -> String {
    print("🔍 KeyChain: 토큰 로드 시도 - account: \(account)")
    
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    print("🔍 KeyChain: 조회 상태 - \(status)")
    
    switch status {
    case errSecSuccess:
      guard let tokenData = result as? Data,
            let token = String(data: tokenData, encoding: .utf8) else {
        print("❌ KeyChain: 데이터 변환 실패")
        throw KeychainError.invalidData
      }
      print("✅ KeyChain: 토큰 로드 성공 - \(token.prefix(20))...")
      return token
    case errSecItemNotFound:
      print("❌ KeyChain: 토큰 항목을 찾을 수 없음")
      throw KeychainError.itemNotFound
    default:
      print("❌ KeyChain: 예상치 못한 상태 - \(status)")
      throw KeychainError.unexpectedStatus(status)
    }
  }
  
  private func deleteTokenFromKeychain(account: String) throws {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: account
    ]
    
    let status = SecItemDelete(query as CFDictionary)
    
    switch status {
    case errSecSuccess, errSecItemNotFound:
      // 성공하거나 이미 없는 경우 모두 정상
      break
    default:
      throw KeychainError.unexpectedStatus(status)
    }
  }
}

