//
//  CoolVibeClubApp.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import KakaoSDKAuth
import KakaoSDKCommon
import SwiftUI
import iamport_ios

@main
struct CoolVibeClubApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @StateObject private var tabVisibilityStore = TabVisibilityStore()

  @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
  @State private var isCheckingToken: Bool = false

  init() {
    print("📱 앱 시작: CoolVibeClubApp 초기화")
    KakaoSDK.initSDK(appKey: APIKeys.KakaoAppKey)

    // 앱 시작 시 토큰 상태 확인
    print("🔧 토큰 상태 확인")
    // @AppStorage가 자동으로 UserDefaults와 동기화되므로 별도 설정 불필요
  }

  // 자동 로그인 확인
  private func checkAutoLogin() {
    print("자동 로그인 확인: 토큰 검증 시작")
    isCheckingToken = true
    // 토큰 검증 로직을 직접 구현하거나, 필요시 네트워크 요청 후 isLoggedIn 갱신
    // 예시: isLoggedIn = true/false
    // 완료 후 isCheckingToken = false
    isCheckingToken = false
  }

  var body: some Scene {
    WindowGroup {
      Group {
        if isCheckingToken {
          LoadingView()
        } else if isLoggedIn {
          CVCTabView()
            .environmentObject(tabVisibilityStore)
        } else {
          LoginView(onLoginSuccess: {
            isLoggedIn = true
          })
        }
      }
      .onReceive(NotificationCenter.default.publisher(for: .userDidLogout)) { _ in
        isLoggedIn = false
      }
      .onOpenURL { url in
        print("📱 URL Scheme 수신: \(url)")
        
        // Kakao SDK URL 처리
        if AuthApi.isKakaoTalkLoginUrl(url) {
          print("📱 Kakao SDK URL 처리")
          _ = AuthController.handleOpenUrl(url: url)
        }
        
        // Iamport URL 처리
        if url.scheme == "cvc" {
          print("📱 Iamport URL 처리: \(url)")
          Iamport.shared.receivedURL(url)
        }
      }
    }
  }
}
