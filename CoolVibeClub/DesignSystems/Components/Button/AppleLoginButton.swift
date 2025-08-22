//
//  AppleLoginButton.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import AuthenticationServices
import SwiftUI

struct AppleLoginButton: View {
  var onLoginSuccess: () -> Void = {}
  @State var isLoggedIn: Bool = false
  @State var accessToken: String? = nil
  @State var refreshToken: String? = nil
  
  var body: some View {
    ZStack {
      SignInWithAppleButton(
        onRequest: { request in
          request.requestedScopes = [.fullName, .email]
        },
        onCompletion: { result in
          switch result {
          case .success(let authResults):
            print("애플 로그인 완료")
            switch authResults.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
              let fullName = appleIDCredential.fullName
              let name = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
              
              guard let identityTokenData = appleIDCredential.identityToken,
                    let identityToken = String(data: identityTokenData, encoding: .utf8)
              else {
                return
              }
              
              Task {
                print("서버 ㄱㄱ")
                
                // 디바이스 토큰 체크 및 요청
                if let deviceToken = await UserDefaultsHelper.shared.requestDeviceTokenIfNeeded() {
                  print("✅ 디바이스 토큰 확보: \(deviceToken.prefix(20))...")
                  await fetchAppleLogin(
                    idToken: identityToken, deviceToken: deviceToken, nick: name
                  )
                } else {
                  print("❌ 디바이스 토큰 요청 실패")
                }
              }
            default:
              break
            }
          case .failure(let error):
            print("Apple Login Error: \(error.localizedDescription)")
          }
        }
      )
      .frame(width: 60, height: 60)
      .clipShape(Circle())
      
      // 커스텀 디자인
      Circle()
        .fill(Color.black)
        .frame(width: 60, height: 60)
        .allowsHitTesting(false)  // 터치 이벤트 -> SignInWithAppleButton
      
      // Apple 로고
      Image(systemName: "applelogo")
        .resizable()
        .scaledToFit()
        .frame(width: 28, height: 28)
        .padding(.bottom, 2)
        .foregroundColor(.white)
        .allowsHitTesting(false)  // 터치 이벤트 -> SignInWithAppleButton
    }
  }
  
  private func fetchAppleLogin(idToken: String, deviceToken: String, nick: String) async {
    do {
      let response: AppleLoginResponse = try await NetworkManager.shared.fetch(
        from: UserEndpoint(
          requestType: .appleLogin(idToken: idToken, deviceToken: deviceToken, nick: nick)
        ),
        errorMapper: AppleLoginError.map
      )
      
      // 🍎 애플 로그인 서버 응답 로깅
      print("🍎 ===== 애플 로그인 서버 응답 =====")
      print("🍎 user_id: \(response.user_id)")
      print("🍎 email: \(response.email)")
      print("🍎 nick: \(response.nick)")
      print("🍎 accessToken: \(response.accessToken.prefix(50))...")
      print("🍎 refreshToken: \(response.refreshToken.prefix(50))...")
      print("🍎 accessToken 전체 길이: \(response.accessToken.count)")
      print("🍎 refreshToken 전체 길이: \(response.refreshToken.count)")
      print("🍎 =================================")
      
      // AuthSession을 통한 로그인 처리
      await AuthSession.shared.login(with: response)
      
      // 로그인 성공 시 상태 업데이트 및 화면 전환
      await MainActor.run {
        isLoggedIn = true
        accessToken = response.accessToken
        refreshToken = response.refreshToken
        
        // 로그인 성공 콜백 호출
        onLoginSuccess()
      }
      
      print("\(response)")
    } catch let error as AppleLoginError {
      print("애플 로그인 에러: \(error.localizedDescription)")
    } catch let error as CommonError {
      print("공통 에러: \(error.localizedDescription)")
    } catch {
      print("기타 에러: \(error)")
    }
  }
}
