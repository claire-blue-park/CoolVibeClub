//
//  Country.swift
//  CoolVibeClub
//
//  Created by Claire on 8/18/25.
//

import Foundation

// MARK: - 국가 Enum
enum Country: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case all = "전체"
    case korea = "대한민국"
    case japan = "일본"
    case australia = "호주"
    case philippines = "필리핀"
    case thailand = "태국"
    case taiwan = "대만"
    case argentina = "아르헨티나"
    
    var serverParam: String? {
        switch self {
        case .all:
            return nil
        case .korea:
            return "대한민국"
        case .japan:
            return "일본"
        case .australia:
            return "호주"
        case .philippines:
            return "필리핀"
        case .thailand:
            return "태국"
        case .taiwan:
            return "대만"
        case .argentina:
            return "아르헨티나"
        }
    }
    
    var imageName: String {
        switch self {
        case .all:
            return "ic_globe"
        case .korea:
            return "country_korea"
        case .japan:
            return "country_japan"
        case .australia:
            return "country__australia"
        case .philippines:
            return "country_philippines"
        case .thailand:
            return "country_thailand"
        case .taiwan:
            return "country_taiwan"
        case .argentina:
            return "country_argentina"
        }
    }
}
