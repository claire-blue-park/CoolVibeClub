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
          
          // 디바이스 토큰 체크 및 요청
          Task {
            print("서버 ㄱㄱ")
            
            guard let accessToken = oauthToken?.accessToken else {
              print("❌ 카카오 액세스 토큰이 없음")
              return
            }
            
            // 디바이스 토큰 체크 및 요청
            if let deviceToken = await UserDefaultsHelper.shared.requestDeviceTokenIfNeeded() {
              print("✅ 디바이스 토큰 확보: \(deviceToken.prefix(20))...")
              await fetchKakaoLogin(oauthToken: accessToken, deviceToken: deviceToken)
            } else {
              print("❌ 디바이스 토큰 요청 실패")
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
        from: UserEndpoint(
          requestType: .kakaoLogin(oauthToken: oauthToken, deviceToken: deviceToken)
        ),
        errorMapper: KakaoLoginError.map
      )
      
      // 💛 카카오 로그인 서버 응답 로깅
      print("💛 ===== 카카오 로그인 서버 응답 =====")
      print("💛 user_id: \(response.user_id)")
      print("💛 email: \(response.email)")
      print("💛 nick: \(response.nick)")
      print("💛 profileImage: \(response.profileImage ?? "nil")")
      print("💛 accessToken: \(response.accessToken.prefix(50))...")
      print("💛 refreshToken: \(response.refreshToken.prefix(50))...")
      print("💛 accessToken 전체 길이: \(response.accessToken.count)")
      print("💛 refreshToken 전체 길이: \(response.refreshToken.count)")
      print("💛 =================================")
      
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
    } catch let error as KakaoLoginError {
      print("❌ 카카오 로그인 에러: \(error.localizedDescription)")
    } catch let error as CommonError {
      print("❌ 공통 에러: \(error.localizedDescription)")
    } catch {
      print("❌ 기타 에러: \(error)")
    }
  }
}
