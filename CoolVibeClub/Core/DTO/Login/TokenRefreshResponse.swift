//
//  TokenRefreshResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct TokenRefreshResponse: Decodable {
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
    }
}

struct ProfileResponse: Decodable {
    let userId: String
    let nick: String?
    let email: String?
    let profileImage: String?

    enum CodingKeys: String, CodingKey {
        case userId
        case nick
        case email
        case profileImage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(String.self, forKey: .userId)
        nick = try container.decode(String.self, forKey: .nick)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        profileImage = try container.decodeIfPresent(String.self, forKey: .profileImage)
    }
}
