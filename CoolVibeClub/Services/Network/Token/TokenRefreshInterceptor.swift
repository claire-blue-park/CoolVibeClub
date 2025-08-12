//
//  TokenRefreshInterceptor.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Alamofire
import Foundation

final class TokenRefreshInterceptor: RequestInterceptor {
  private let retryLimit = 2
  private let lock = NSLock()
  
  // MARK: - RequestAdapter
  func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
    var adaptedRequest = urlRequest
    
    // 로그인 관련 요청은 Authorization 헤더를 추가하지 않음
    let isLoginRequest = adaptedRequest.url?.path.contains("/login") == true ||
    adaptedRequest.url?.path.contains("/join") == true ||
    adaptedRequest.url?.path.contains("/refresh") == true
    
    // 로그인 요청이 아니고 액세스 토큰이 있는 경우에만 헤더 추가
    if !isLoginRequest, let accessToken = UserDefaultsHelper.shared.getAccessToken() {
      print("🔑 요청에 토큰 추가: \(accessToken.prefix(20))... → \(adaptedRequest.url?.absoluteString ?? "unknown URL")")
      adaptedRequest.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
    } else if !isLoginRequest {
      print("❌ 액세스 토큰이 없음 - 헤더 추가 안함 → \(adaptedRequest.url?.absoluteString ?? "unknown URL")")
    } else {
      print("ℹ️ 로그인 요청이므로 토큰 추가하지 않음 → \(adaptedRequest.url?.absoluteString ?? "unknown URL")")
    }
    
    completion(.success(adaptedRequest))
  }
  
  // MARK: - RequestRetrier
  func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
    lock.lock()
    defer { lock.unlock() }
    
    guard let response = request.task?.response as? HTTPURLResponse else {
      completion(.doNotRetryWithError(error))
      return
    }
    
    // 401 또는 419 에러 (액세스 토큰 만료)인 경우에만 재시도
    if response.statusCode == 401 || response.statusCode == 419 {
      // 액세스 토큰이 있는 경우에만 갱신 시도 (로그인된 상태)
      if let accessToken = UserDefaultsHelper.shared.getAccessToken() {
        print("🔑 \(response.statusCode) 에러 발생 - \(accessToken.prefix(20))...")
        print("🔑 \(response.statusCode) 에러 발생 - 토큰 갱신 시도")
        print("🔄 갱신 대상 요청: \(request.request?.url?.absoluteString ?? "unknown URL")")
        refreshToken { [weak self] success in
          if success {
            print("✅ 토큰 갱신 성공 - 요청 재시도: \(request.request?.url?.absoluteString ?? "unknown URL")")
            completion(.retry)
          } else {
            print("❌ 토큰 갱신 실패 - 로그아웃 처리")
            // 리프레시 토큰도 만료된 경우 로그아웃 처리
            self?.handleLogout()
            completion(.doNotRetryWithError(error))
          }
        }
      } else {
        // 액세스 토큰이 없으면 갱신 시도하지 않음 (로그인하지 않은 상태)
        completion(.doNotRetryWithError(error))
      }
    } else {
      completion(.doNotRetryWithError(error))
    }
  }
  
  // MARK: - Token Refresh
  private func refreshToken(completion: @escaping (Bool) -> Void) {
    guard let refreshToken = UserDefaultsHelper.shared.getRefreshToken() else {
      print("❌ 리프레시 토큰이 없음")
      completion(false)
      return
    }
    
    // ShutterLink 방식으로 토큰 갱신 요청 구성
    let url = "http://activity.sesac.kr:34501/v1/auth/refresh"
    let headers: HTTPHeaders = [
      "SeSACKey": APIKeys.SesacKey,
      "RefreshToken": refreshToken,  // 헤더에 리프레시 토큰 전송
      "Content-Type": "application/json"
    ]
    
    print("🔄 토큰 갱신 시도:")
    print("🔄 URL: \(url)")
    print("🔄 Method: GET")
    print("🔄 Headers: \(headers)")
    print("🔄 리프레시 토큰: \(refreshToken.prefix(20))...")
    
    AF.request(
      url,
      method: .get,  // GET 요청으로 변경
      headers: headers
    )
    .response { response in
      print("🔄 토큰 갱신 요청 URL: \(url)")
      print("🔄 토큰 갱신 상태 코드: \(response.response?.statusCode ?? -1)")
      
      if let data = response.data {
        let responseString = String(data: data, encoding: .utf8) ?? "UTF8 변환 실패"
        print("🔄 토큰 갱신 응답: \(responseString)")
      }
    }
    .responseDecodable(of: TokenRefreshResponse.self) { response in
      switch response.result {
      case .success(let tokenResponse):
        // 새로운 액세스 토큰과 리프레시 토큰 저장
        //                UserDefaultsHelper.shared.saveAccessToken(tokenResponse.accessToken)
        //                UserDefaultsHelper.shared.saveRefreshToken(tokenResponse.refreshToken)
        UserDefaultsHelper.shared.saveUserData(accessToken: tokenResponse.accessToken, refreshToken: tokenResponse.refreshToken)
        
        // UserDefaults 강제 동기화
        UserDefaults.standard.synchronize()
        
        print("✅ 토큰 갱신 성공")
        print("✅ 새 액세스 토큰: \(tokenResponse.accessToken.prefix(20))...")
        print("✅ 새 리프레시 토큰: \(tokenResponse.refreshToken.prefix(20))...")
        print("✅ UserDefaults 동기화 완료")
        print("🔄 토큰 갱신 완료 - 원래 요청을 재시도합니다")
        completion(true)
        
      case .failure(let error):
        if let httpResponse = response.response {
          let statusCode = httpResponse.statusCode
          print("❌ 토큰 갱신 실패 - 상태코드: \(statusCode)")
          
          // 에러 응답 파싱
          if let data = response.data {
            do {
              if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                 let message = json["message"] as? String {
                print("🔑 토큰 갱신 에러 메시지: \(message)")
              }
            } catch {
              print("🔑 에러 응답 파싱 실패")
            }
          }
          
          // 403, 401, 444 에러 시 로그아웃 처리
          if statusCode == 403 || statusCode == 401 || statusCode == 444 {
            print("🔑 리프레시 토큰이 만료되었거나 유효하지 않음 (상태코드: \(statusCode))")
            DispatchQueue.main.async {
              self.handleLogout()
            }
          }
        }
        print("❌ 토큰 갱신 에러 상세: \(error)")
        completion(false)
      }
    }
  }
  
  // MARK: - Logout Handling
  private func handleLogout() {
    print("🚪 리프레시 토큰 만료 - 로그아웃 처리")
    
    // 저장된 토큰 정보 삭제
    UserDefaultsHelper.shared.clearTokens()
    UserDefaultsHelper.shared.setLoggedIn(false)
    
    // 메인 쓰레드에서 로그인 화면으로 이동
    DispatchQueue.main.async {
      // 앱 상태를 로그아웃으로 변경하는 노티피케이션 발송
      NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
  }
}

// MARK: - Sendable Conformance
extension TokenRefreshInterceptor: @unchecked Sendable {}

// MARK: - Notification Extension
extension Notification.Name {
  static let userDidLogout = Notification.Name("userDidLogout")
}
