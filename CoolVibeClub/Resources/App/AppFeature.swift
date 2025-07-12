//
//  AppFeature.swift
//  CoolVibeClub
//
//  Created by Claire on 7/11/25.
//

import Foundation
import ComposableArchitecture
import Alamofire

struct AppFeature: Reducer {
  struct State: Equatable {
    var isLoggedIn = false
    var isCheckingToken = false
    var loginError: String?
  }
  
  enum Action {
    case setLoggedIn(Bool, accessToken: String, refreshToken: String)
    case checkSavedToken
    case tokenValidationResponse(TaskResult<Bool>)
    case logout
    case forceLogout
    case clearLoginError
  }
  
  private let lock = NSLock() // 동시성 제어를 위한 락 추가
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .setLoggedIn(let isLoggedIn, let accessToken, let refreshToken):
        KeyChainHelper.shared.saveToken(accessToken)
        KeyChainHelper.shared.saveRefreshToken(refreshToken)
        state.isLoggedIn = isLoggedIn
        state.loginError = nil
        UserDefaultsHelper.shared.setLoggedIn(isLoggedIn)
        return .none
        
      case .checkSavedToken:
        state.loginError = nil
        
        // 1. UserDefaults에서 로그인 상태 확인
        if !UserDefaultsHelper.shared.isLoggedIn() {
          print("❌ UserDefaults에 로그인 상태가 저장되어 있지 않음")
          state.isCheckingToken = false
          state.isLoggedIn = false
          return .none
        }
        
        state.isCheckingToken = true
        
        // 2. KeyChain에서 토큰 확인
        guard let accessToken = KeyChainHelper.shared.loadToken(), !accessToken.isEmpty,
              let refreshToken = KeyChainHelper.shared.loadRefreshToken(), !refreshToken.isEmpty else {
          print("❌ KeyChain에 토큰이 없거나 비어 있음")
          state.isCheckingToken = false
          state.isLoggedIn = false
          UserDefaultsHelper.shared.setLoggedIn(false)
          return .none
        }
        
        print("✅ 토큰 확인 완료: 토큰 유효성 검증 시작")
        
        // 3. 토큰 유효성 검증
        return .run { send in
          await send(.tokenValidationResponse(
            TaskResult {
              try await self.validateAndRefreshToken(accessToken: accessToken, refreshToken: refreshToken)
            }
          ))
        }
        
      case .tokenValidationResponse(.success(let isValid)):
        state.isCheckingToken = false
        state.isLoggedIn = isValid
        state.loginError = nil
        UserDefaultsHelper.shared.setLoggedIn(isValid)
        return .none
        
      case .tokenValidationResponse(.failure(let error)):
        state.isCheckingToken = false
        state.isLoggedIn = false
        state.loginError = "자동 로그인 실패: \(error.localizedDescription)"
        KeyChainHelper.shared.deleteAllTokens()
        UserDefaultsHelper.shared.setLoggedIn(false)
        return .none
        
      case .logout, .forceLogout:
        KeyChainHelper.shared.deleteAllTokens()
        UserDefaultsHelper.shared.setLoggedIn(false)
        state.isLoggedIn = false
        state.loginError = nil
        return .none
        
      case .clearLoginError:
        state.loginError = nil
        return .none
      }
    }
  }
  
  // 토큰 유효성 검증 및 리프레시 함수
  private func validateAndRefreshToken(accessToken: String, refreshToken: String) async throws -> Bool {
    lock.lock()
    defer { lock.unlock() }
    
    do {
      // 1. 액세스 토큰 유효성 검증
      let isAccessTokenValid = try await validateAccessToken(accessToken: accessToken)
      
      if isAccessTokenValid {
        print("✅ 액세스 토큰이 유효함")
        return true
      }
      
      print("⚠️ 액세스 토큰이 만료됨, 리프레시 토큰으로 갱신 시도")
      
      // 2. 리프레시 토큰으로 액세스 토큰 갱신 시도
      return try await withCheckedThrowingContinuation { continuation in
        let headers: HTTPHeaders = [
          "accept": "application/json",
          "SeSACKey": "\(APIKeys.SesacKey)"
        ]
        
        let parameters: Parameters = [
          "refreshToken": refreshToken
        ]
        
        print("🔄 토큰 갱신 요청: \(refreshToken.prefix(10))...")
        
        AF.request("http://activity.sesac.kr:34501/v1/auth/refresh",
                   method: .get,
                   parameters: parameters,
                   headers: headers)
          .responseDecodable(of: TokenRefreshResponse.self) { response in
            switch response.result {
            case .success(let tokenResponse):
              print("✅ 토큰 갱신 성공: 새 액세스 토큰 저장")
              // 새 액세스 토큰 저장
              KeyChainHelper.shared.saveToken(tokenResponse.accessToken)
              continuation.resume(returning: true)
              
            case .failure(let error):
              print("❌ 토큰 갱신 실패: \(error.localizedDescription)")
              continuation.resume(throwing: error)
            }
          }
      }
    } catch {
      print("❌ 토큰 검증 또는 갱신 실패: \(error)")
      throw error
    }
  }
  
  // 액세스 토큰 유효성 검증 함수
  private func validateAccessToken(accessToken: String) async throws -> Bool {
    do {
      // 사용자 프로필 조회로 토큰 유효성 검증
      let headers: HTTPHeaders = [
        "Authorization": accessToken, // Bearer 접두사 없이 토큰만 전송
        "accept": "application/json",
        "SeSACKey": "\(APIKeys.SesacKey)"
      ]
      
      let response = try await AF.request("http://activity.sesac.kr:34501/v1/users/me",
                                       method: .get,
                                       headers: headers)
        .serializingDecodable(ProfileResponse.self)
        .value
      
      print("✅ 프로필 조회 성공: \(response.nick)")
      return true
    } catch let afError as AFError {
      if let statusCode = afError.responseCode, statusCode == 401 {
        print("⚠️ 액세스 토큰 만료됨 (401 Unauthorized)")
        return false
      }
      print("❌ 액세스 토큰 검증 중 오류 발생: \(afError.localizedDescription)")
      throw afError
    } catch {
      print("❌ 액세스 토큰 검증 실패: \(error)")
      throw error
    }
  }
}

// 가정: 서버에서 반환하는 프로필 응답 구조체는 TokenRefreshResponse.swift로 이동했습니다
// struct ProfileResponse: Codable {
//   // 서버 응답에 맞게 필드 정의
//   let userId: String
//   let username: String
//   // 기타 필드
// }

// 전역 스토어
extension DependencyValues {
  var appStore: StoreOf<AppFeature> {
    get { self[AppStoreKey.self] }
    set { self[AppStoreKey.self] = newValue }
  }
}

private enum AppStoreKey: DependencyKey {
  static let liveValue = Store(initialState: AppFeature.State()) {
    AppFeature()
      ._printChanges() // 디버깅용 - 프로덕션에서는 제거
  }
}
