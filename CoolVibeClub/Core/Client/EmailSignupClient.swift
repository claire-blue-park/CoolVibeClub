//
//  EmailSignupClient.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct EmailSignupClient {
    let signupUser: (UserData) async throws -> JoinResponse
    let validateEmail: (String) async throws -> Bool
}

extension EmailSignupClient {
    static let live = EmailSignupClient(
        signupUser: { userData in
            print("📧 EmailSignupClient - 회원가입 요청: \(userData.email)")
            
            let endpoint = LoginEndpoint(requestType: .join(userData: userData))
            
            let response: JoinResponse = try await NetworkManager.shared.fetch(
                from: endpoint,
                errorMapper: { status, error in
                    CommonError.map(statusCode: status, message: error.message)
                }
            )
            
            return response
        },
        
        validateEmail: { email in
            print("✅ EmailSignupClient - 이메일 검증 요청: \(email)")
            
            let endpoint = LoginEndpoint(requestType: .emailValidation(email: email))
            
            let _: EmptyResponse = try await NetworkManager.shared.fetch(
                from: endpoint,
                errorMapper: { status, error in
                    CommonError.map(statusCode: status, message: error.message)
                }
            )
            
            return true
        }
    )
}

extension EmailSignupClient {
    static let mock = EmailSignupClient(
        signupUser: { userData in
            // Mock response for testing
            return JoinResponse(
                user_id: "test_user_id",
                email: userData.email,
                nick: userData.nick,
                accessToken: "mock_access_token",
                refreshToken: "mock_refresh_token"
            )
        },
        validateEmail: { _ in
            return true
        }
    )
}

// MARK: - Empty Response for email validation
private struct EmptyResponse: Decodable {}