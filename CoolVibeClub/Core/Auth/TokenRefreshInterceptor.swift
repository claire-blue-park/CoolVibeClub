//
//  TokenRefreshInterceptor.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation
import Alamofire

/// 🔄 토큰 자동 갱신 인터셉터
/// 토큰 만료 시 자동으로 리프레시 토큰을 사용해 갱신
final class TokenRefreshInterceptor: RequestInterceptor {
  private let keyChainHelper = KeyChainHelper.shared
  private let authSession = AuthSession.shared
  
  // MARK: - RequestAdapter
  
  func adapt(
    _ urlRequest: URLRequest,
    for session: Session,
    completion: @escaping (Result<URLRequest, Error>) -> Void
  ) {
    var request = urlRequest
    
    // Authorization 헤더가 이미 있는 경우 그대로 사용
    if request.value(forHTTPHeaderField: "Authorization") != nil {
      completion(.success(request))
      return
    }
    
    // 토큰이 필요 없는 엔드포인트인지 확인
    if isTokenNotRequiredEndpoint(request) {
      completion(.success(request))
      return
    }
    
    // 액세스 토큰 추가
    guard let accessToken = keyChainHelper.loadToken() else {
      print("❌ TokenInterceptor: 액세스 토큰이 없음 - \(request.url?.absoluteString ?? "unknown URL")")
      completion(.failure(TokenInterceptorError.accessTokenNotFound))
      return
    }
    
    print("✅ TokenInterceptor: 토큰 추가 - \(accessToken.prefix(20))...")
    request.setValue(accessToken, forHTTPHeaderField: "Authorization")
    completion(.success(request))
  }
  
  // MARK: - RequestRetrier
  
  func retry(
    _ request: Request,
    for session: Session,
    dueTo error: Error,
    completion: @escaping (RetryResult) -> Void
  ) {
    // RequestAdapter 실패인 경우
    if case let AFError.requestAdaptationFailed(adaptationError) = error {
      completion(.doNotRetryWithError(adaptationError))
      return
    }
    
    // RequestRetry 실패인 경우
    if case let AFError.requestRetryFailed(retryError: retryError, originalError: _) = error {
      completion(.doNotRetryWithError(retryError))
      return
    }
    
    // HTTP 응답 확인
    guard let response = request.task?.response as? HTTPURLResponse else {
      completion(.doNotRetryWithError(error))
      return
    }
    
    // 419: 토큰 만료 에러가 아닌 경우
    guard response.statusCode == 419 else {
      completion(.doNotRetryWithError(error))
      return
    }
    
    // 리프레시 토큰 확인
    guard keyChainHelper.loadRefreshToken() != nil else {
      print("❌ TokenInterceptor: 리프레시 토큰이 없음")
      
      // 로그아웃 처리
      Task { @MainActor in
        await authSession.logout()
      }
      
      completion(.doNotRetryWithError(TokenInterceptorError.refreshTokenNotFound))
      return
    }
    
    // 토큰 갱신 시도
    Task {
      do {
        try await authSession.refreshTokens()
        print("✅ TokenInterceptor: 토큰 갱신 성공 - 요청 재시도")
        completion(.retry)
      } catch {
        print("❌ TokenInterceptor: 토큰 갱신 실패 - \(error.localizedDescription)")
        
        // 토큰 갱신 실패 시 로그아웃
        await authSession.logout()
        completion(.doNotRetryWithError(error))
      }
    }
  }
  
  // MARK: - Helper Methods
  
  /// 토큰이 필요하지 않은 엔드포인트인지 확인
  private func isTokenNotRequiredEndpoint(_ request: URLRequest) -> Bool {
    guard let url = request.url?.absoluteString else { return false }
    
    let noTokenEndpoints = [
      "/v1/users/join",           // 회원가입
      "/v1/users/login",          // 이메일 로그인
      "/v1/users/login/kakao",    // 카카오 로그인
      "/v1/users/login/apple",    // 애플 로그인
      "/v1/users/validation/email" // 이메일 검증
    ]
    
    return noTokenEndpoints.contains { endpoint in
      url.contains(endpoint)
    }
  }
}

// MARK: - Errors

enum TokenInterceptorError: LocalizedError {
  case accessTokenNotFound
  case refreshTokenNotFound
  
  var errorDescription: String? {
    switch self {
    case .accessTokenNotFound:
      return "액세스 토큰을 찾을 수 없습니다."
    case .refreshTokenNotFound:
      return "리프레시 토큰을 찾을 수 없습니다."
    }
  }
}