//
//  AppDelegate.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import iamport_ios
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    Iamport.shared.receivedURL(url)
    return true
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    
    print("🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩🧩")
    
    // Firebase 초기화
    FirebaseApp.configure()
    
    // 원격 알림 시스템을 앱에 등록
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })
    } else {
      let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
//    application.registerForRemoteNotifications()
    

    
    // 푸시 알림 권한 요청
    UNUserNotificationCenter.current().delegate = self
    
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if granted {
        print("푸시 알림 권한 허용")
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      } else {
        print("푸시 알림 권한 거부")
      }
    }
    
    // 메시지 대리자 설정
    Messaging.messaging().delegate = self
    
    // 현재 등록된 토큰 가져오기
    Messaging.messaging().token { token, error in
      if let error {
        print("❌ FCM 토큰 가져오기 실패: \(error)")
      } else if let token {
        print("🔥 앱 시작시 FCM 토큰: \(token)")
        print("🔥 FCM 토큰 길이: \(token.count) characters")
      } else {
        print("⚠️ FCM 토큰이 아직 생성되지 않음")
      }
    }
    
    return true
  }
  
}

// MARK: - 디바이스 토큰
extension AppDelegate: MessagingDelegate {
  // 토큰 갱신 모니터링
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔥 FCM registration token: \(fcmToken?.description ?? "nil")")
    if let fcmToken = fcmToken {
      print("🔥 FCM 토큰 길이: \(fcmToken.count) characters")
      
      // 로그인된 사용자인 경우 서버에 토큰 업데이트 (FCM 토큰 사용)
      if UserDefaultsHelper.shared.isLoggedIn() {
        Task {
          do {
            try await DeviceTokenService.shared.updateDeviceToken(fcmToken)
          } catch {
            print("❌ 서버 FCM 토큰 업데이트 실패: \(error.localizedDescription)")
          }
        }
      }
    }
    
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil,userInfo: dataDict)
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  // 디바이스 토큰을 등록 성공
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
    let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("📱 APNS Device Token: \(tokenString)")
    print("📱 Device Token 길이: \(tokenString.count) characters")
    
    // UserDefaults에 저장
    UserDefaultsHelper.shared.saveDeviceToken(tokenString)
    print("✅ 디바이스 토큰 저장 완료")
    
    // 로그인된 사용자인 경우 서버에 토큰 업데이트
    if UserDefaultsHelper.shared.isLoggedIn() {
      Task {
        do {
          try await DeviceTokenService.shared.updateDeviceToken(tokenString)
        } catch {
          print("❌ 서버 디바이스 토큰 업데이트 실패: \(error.localizedDescription)")
        }
      }
    }
    
    Messaging.messaging().apnsToken = deviceToken
    print("🔥 Firebase에 APNS 토큰 설정 완료")
  }
  
  // 디바이스 토큰 등록 실패
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error)")
  }
}

// MARK: - 백그라운드/포그라운드
extension AppDelegate {
  // 앱이 백그라운드로 전환될 때 호출
  func applicationDidEnterBackground(_ application: UIApplication) {
    // 앱이 백그라운드로 전환될 때 추가 작업이 필요하면 여기에 구현
  }
  
  // 앱이 포그라운드로 전환될 때 호출
  func applicationWillEnterForeground(_ application: UIApplication) {
    // 앱이 포그라운드로 전환될 때 추가 작업이 필요하면 여기에 구현
  }
}
