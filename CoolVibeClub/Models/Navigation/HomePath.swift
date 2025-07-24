//
//  HomePath.swift
//  CoolVibeClub
//
//  Created by Claire on 7/26/25.
//

import Foundation

enum HomePath: Hashable, Sendable {
    case activities
    case activityDetail(ActivityInfoData)
    case chat(userId: String, nickname: String)
}
