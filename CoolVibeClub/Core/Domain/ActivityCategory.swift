//
//  ActivityCategory.swift
//  CoolVibeClub
//
//  Created by Claire on 8/18/25.
//

import Foundation

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

