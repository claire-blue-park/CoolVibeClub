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
                if let deviceToken = UserDefaultsHelper.shared.getDeviceToken() {
                  await fetchAppleLogin(
                    idToken: identityToken, deviceToken: deviceToken, nick: name
                  )
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
        from: LoginEndpoint(
          requestType: .appleLogin(idToken: idToken, deviceToken: deviceToken, nick: nick)
        ),
        errorMapper: AppleLoginError.map
      )
      
      // 토큰 저장 및 로그인 상태 업데이트
//      UserDefaultsHelper.shared.saveAccessToken(response.accessToken)
//      UserDefaultsHelper.shared.saveRefreshToken(response.refreshToken)
//      UserDefaultsHelper.shared.saveUserId(response.user_id)
      UserDefaultsHelper.shared.saveUserData(accessToken: response.accessToken, refreshToken: response.refreshToken, userID: response.user_id)
      UserDefaultsHelper.shared.setLoggedIn(true)
      
      // UserDefaults 강제 동기화
      UserDefaults.standard.synchronize()
      
      print("✅ 토큰 저장 완료 - 액세스 토큰: \(response.accessToken.prefix(20))...")
      print("✅ 토큰 저장 완료 - 리프레시 토큰: \(response.refreshToken.prefix(20))...")
      print("✅ UserDefaults 동기화 완료")
      
      // 로그인 성공 시 상태 업데이트 및 화면 전환
      DispatchQueue.main.async {
        isLoggedIn = true
        accessToken = response.accessToken
        refreshToken = response.refreshToken
        
        // 디바이스 토큰 서버 업데이트
        if let currentDeviceToken = UserDefaultsHelper.shared.getDeviceToken() {
          Task {
            do {
              try await DeviceTokenService.shared.updateDeviceToken(currentDeviceToken)
            } catch {
              print("❌ 애플 로그인 후 디바이스 토큰 업데이트 실패: \(error.localizedDescription)")
            }
          }
        }
        
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
