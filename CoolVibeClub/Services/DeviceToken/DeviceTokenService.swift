//
//  DeviceTokenService.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct DeviceTokenService {
    static let shared = DeviceTokenService()
    
    private init() {}
    
    func updateDeviceToken(_ deviceToken: String) async throws {
        print("🔄 디바이스 토큰 업데이트 시작: \(deviceToken.prefix(20))...")
        
        let endpoint = UserEndpoint(requestType: .updateDeviceToken(deviceToken: deviceToken))
        
        let _: EmptyResponse = try await NetworkManager.shared.fetch(
            from: endpoint,
            errorMapper: { status, error in
                CommonError.map(statusCode: status, message: error.message)
            }
        )
        
        print("✅ 디바이스 토큰 업데이트 성공")
    }
}

// MARK: - Empty Response for device token update
private struct EmptyResponse: Decodable {}
