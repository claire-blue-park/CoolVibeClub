//
//  KakaoLoginButton.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import KakaoSDKUser
import SwiftUI

struct KakaoLoginButton: View {
  var onLoginSuccess: () -> Void = {}
  @State private var isLoggedIn: Bool = false
  @State private var accessToken: String? = nil
  @State private var refreshToken: String? = nil
  
  var body: some View {
    Button(action: {
      // 카카오 로그인 처리
      print("🔍 카카오 로그인 시작")
      UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
        if let error = error {
          print("❌ 카카오 로그인 에러: \(error)")
          print("❌ 에러 상세: \(error.localizedDescription)")
        } else {
          print("✅ 카카오 로그인 성공")
          print("🪐🪐🪐🪐", oauthToken?.idToken ?? "없네요?")
          
          // 디바이스 토큰
          Task {
            print("서버 ㄱㄱ")
            print("디바이스 토큰:", UserDefaultsHelper.shared.getDeviceToken() ?? "없음")
            if let deviceToken = UserDefaultsHelper.shared.getDeviceToken(),
               let accessToken = oauthToken?.accessToken
            {
              await fetchKakaoLogin(oauthToken: accessToken, deviceToken: deviceToken)
            } else {
              print("❌ 디바이스 토큰 또는 액세스 토큰이 없음")
            }
          }
        }
      }
    }) {
      // 원형 카카오 버튼
      CVCImage.kakao.template
        .scaledToFit()
        .frame(width: 28, height: 28)
        .foregroundColor(CVCColor.grayScale100)
        .frame(width: 60, height: 60)
        .background(Color(red: 0xFE / 255.0, green: 0xE5 / 255.0, blue: 0x00 / 255.0))
        .cornerRadius(30)
    }
  }
  
  private func fetchKakaoLogin(oauthToken: String, deviceToken: String) async {
    do {
      let response: KakaoLoginResponse = try await NetworkManager.shared.fetch(
        from: LoginEndpoint(
          requestType: .kakaoLogin(oauthToken: oauthToken, deviceToken: deviceToken)
        ),
        errorMapper: KakaoLoginError.map
      )
      // 토큰 저장 및 로그인 상태 업데이트
      //            UserDefaultsHelper.shared.saveAccessToken(response.accessToken)
      //            UserDefaultsHelper.shared.saveRefreshToken(response.refreshToken)
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
              print("❌ 카카오 로그인 후 디바이스 토큰 업데이트 실패: \(error.localizedDescription)")
            }
          }
        }
        
        // 로그인 성공 콜백 호출
        onLoginSuccess()
      }
    } catch let error as KakaoLoginError {
      print("❌ 카카오 로그인 에러: \(error.localizedDescription)")
    } catch let error as CommonError {
      print("❌ 공통 에러: \(error.localizedDescription)")
    } catch {
      print("❌ 기타 에러: \(error)")
    }
  }
}
