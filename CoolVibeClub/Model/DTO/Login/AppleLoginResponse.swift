//
//  AppleLoginResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 7/11/25.
//

import Foundation

struct AppleLoginResponse: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
}
