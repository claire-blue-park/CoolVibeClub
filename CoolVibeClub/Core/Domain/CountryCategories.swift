//
//  CountryCategories.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

// MARK: - 국가 Enum
enum Country: String, CaseIterable {
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

// MARK: - 카테고리 Enum
enum ActivityCategory: String, CaseIterable {
    case all = "전체"
    case tour = "투어"
    case sightseeing = "관광"
    case package = "패키지"
    case exciting = "익사이팅"
    case experience = "체험"
    
    var serverParam: String? {
        switch self {
        case .all:
            return nil
        case .tour:
            return "투어"
        case .sightseeing:
            return "관광"
        case .package:
            return "패키지"
        case .exciting:
            return "익사이팅"
        case .experience:
            return "체험"
        }
    }
}

// MARK: - Legacy 구조체 (기존 코드 호환성을 위해 유지)
struct CountryCategories: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let imageName: String
    
    init(country: Country) {
        self.name = country.rawValue
        self.imageName = country.imageName
    }
    
    // 기존 생성자 유지
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}
