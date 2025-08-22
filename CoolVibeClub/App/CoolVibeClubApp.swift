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
  @StateObject private var authSession = AuthSession.shared

  init() {
    print("📱 앱 시작: CoolVibeClubApp 초기화")
    KakaoSDK.initSDK(appKey: APIKeys.KakaoAppKey)

    // 앱 시작 시 토큰 상태 확인
    print("🔧 토큰 상태 확인")
    // @AppStorage가 자동으로 UserDefaults와 동기화되므로 별도 설정 불필요
  }

  var body: some Scene {
    WindowGroup {
      Group {
        if authSession.isCheckingAuth {
          LoadingView()
        } else if authSession.isLoggedIn {
          CVCTabView()
            .environmentObject(tabVisibilityStore)
        } else {
          LoginView()
        }
      }
      .onAppear {
        // 앱 시작 시 자동 로그인 확인
        Task {
          await authSession.checkAutoLogin()
        }
      }
      .onReceive(NotificationCenter.default.publisher(for: .userDidLogout)) { _ in
        // AuthSession에서 자동으로 처리됨
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
