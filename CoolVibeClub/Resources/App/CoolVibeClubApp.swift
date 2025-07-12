//
//  CoolVibeClubApp.swift
//  CoolVibeClub
//
//  Created by Claire on 7/9/25.
//

import SwiftUI
import ComposableArchitecture
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct WavyApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  // 전역 스토어
  @Dependency(\.appStore) var appStore
  
  init() {
    print("📱 앱 시작: WavyApp 초기화")
    KakaoSDK.initSDK(appKey: APIKeys.KakaoAppKey)
    
    // 앱 시작 시 로그인 상태 확인
    if UserDefaultsHelper.shared.isLoggedIn() {
      // UserDefaults에 로그인 상태가 저장되어 있으면 토큰 검증 시작
      print("🔑 앱 시작: UserDefaults에 로그인 상태가 저장되어 있음. 토큰 검증 시작")
      checkAutoLogin()
    } else {
      // 로그인 상태가 아니면 명시적으로 로그아웃 처리
      print("🚪 앱 시작: UserDefaults에 로그인 상태가 저장되어 있지 않음. 로그아웃 처리")
      appStore.send(.logout)
    }
    
    // setupTokenExpiredNotification()
  }
  
  // 자동 로그인 확인
  private func checkAutoLogin() {
    // 저장된 토큰 확인 및 유효성 검증
    print("자동 로그인 확인: 토큰 검증 시작")
    appStore.send(.checkSavedToken)
  }
  
  // 토큰 만료 알림 설정
//   private func setupTokenExpiredNotification() {
//     NotificationCenter.default.addObserver(
//       forName: .tokenExpired,
//       object: nil,
//       queue: .main
//     ) { _ in
//       // 토큰 만료 시 로그아웃 처리
//       appStore.send(.logout)
//     }
//   }
  
  var body: some Scene {
    WindowGroup {
      WithViewStore(appStore, observe: { $0 }) { viewStore in
        if viewStore.isCheckingToken {
          // 토큰 검증 중일 때 로딩 화면 표시
          LoadingView()
        } else if viewStore.isLoggedIn {
          MainTabView()
        } else {
          LoginView()
          .onOpenURL { url in
            if AuthApi.isKakaoTalkLoginUrl(url) {
              _ = AuthController.handleOpenUrl(url: url)
            }
          }
        }
      }
    }
  }
}
