//
//  KakaoLoginButton.swift
//  CoolVibeClub
//
//  Created by Claire on 7/11/25.
//

import ComposableArchitecture
import KakaoSDKUser
import SwiftUI

struct KakaoLoginButton: View {
    @Dependency(\.appStore) var appStore

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
                        print(UserDefaultsHelper.shared.getDeviceToken())
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
                .foregroundColor(Color.brown)
                .frame(width: 60, height: 60)
                .background(Color.yellow)
                .cornerRadius(30)
        }
    }

    private func fetchKakaoLogin(oauthToken: String, deviceToken: String) async {
        do {
            let response: KakaoLoginResponse = try await NetworkManager.shared.fetch(
                from: LoginEndpoint(
                    requestType: .kakaoLogin(oauthToken: oauthToken, deviceToken: deviceToken)),
                responseError: LoginResponseError.self)
            print(response)
            // 서버 응답 보고
            appStore.send(
                .setLoggedIn(
                    true, accessToken: response.accessToken, refreshToken: response.refreshToken))

        } catch let error as NetworkError {
            print("❌ 네트워크 에러: \(error)")
        } catch {
            print("❌ 기타 에러: \(error)")
        }
    }
}

#Preview {
    KakaoLoginButton()
}
