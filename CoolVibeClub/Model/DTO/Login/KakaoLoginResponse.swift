//
//  KakaoLoginResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 7/10/25.
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
