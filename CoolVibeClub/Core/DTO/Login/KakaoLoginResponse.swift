//
//  KakaoLoginResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct KakaoLoginResponse: Decodable {
    let user_id: String
    let email: String
    let nick: String
    var profileImage: String? = nil
    let accessToken: String
    let refreshToken: String
}
