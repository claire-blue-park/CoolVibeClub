//
//  UserDefaultsHelper.swift
//  CoolVibeClub
//
//  Created by Claire on 7/11/25.
//

import Foundation

class UserDefaultsHelper {
    static let shared = UserDefaultsHelper()
    private init() {}

    private let deviceTokenKey = "deviceToken"
    private let isLoggedInKey = "isLoggedIn"

    // MARK: - 디바이스 토큰
    func saveDeviceToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: deviceTokenKey)
    }

    func getDeviceToken() -> String? {
        return UserDefaults.standard.string(forKey: deviceTokenKey)
    }

    // MARK: - 로그인 상태
    func setLoggedIn(_ isLoggedIn: Bool) {
        UserDefaults.standard.set(isLoggedIn, forKey: isLoggedInKey)
        UserDefaults.standard.synchronize()
    }

    func isLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: isLoggedInKey)
    }
}
