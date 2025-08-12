//
//  AppleLoginResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct AppleLoginResponse: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
}
