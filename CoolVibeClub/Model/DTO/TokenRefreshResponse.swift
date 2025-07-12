//
//  TokenRefreshResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 7/11/25.
//

import Foundation

struct TokenRefreshResponse: Decodable {
    let accessToken: String
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

