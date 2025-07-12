//
//  JoinResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 7/10/25.
//

import Foundation

struct JoinResponse: Decodable {
    let user_id: String
    let email: String
    let nick: String
    let accessToken: String
    let refreshToken: String
}
