//
//  AppDelegate.swift
//  CoolVibeClub
//
//  Created by Claire on 7/12/25.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return false
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
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
        
        return true
    }

    
    // 디바이스 토큰을 등록 성공
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(tokenString)")
        
        // UserDefaults에 저장
        UserDefaultsHelper.shared.saveDeviceToken(tokenString)
    }
    
    // 디바이스 토큰 등록 실패
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    // 앱이 백그라운드로 전환될 때 호출
    func applicationDidEnterBackground(_ application: UIApplication) {
        // 앱이 백그라운드로 전환될 때 추가 작업이 필요하면 여기에 구현
    }
    
    // 앱이 포그라운드로 전환될 때 호출
    func applicationWillEnterForeground(_ application: UIApplication) {
        // 앱이 포그라운드로 전환될 때 추가 작업이 필요하면 여기에 구현
    }
}
