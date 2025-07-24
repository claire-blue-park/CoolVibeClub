//
//  EmailSignupRequest.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct EmailSignupRequest: Encodable {
    let email: String
    let password: String
    let nick: String
    let phoneNum: String
    let introduction: String
    let deviceToken: String
}