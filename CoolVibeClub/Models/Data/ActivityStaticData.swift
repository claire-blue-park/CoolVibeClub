//
//  ActivityStaticData.swift
//  CoolVibeClub
//
//  정적 데이터 모음 - ActivityState에서 분리된 static 데이터
//

import Foundation

// MARK: - Activity Static Data
struct ActivityStaticData {
    // MARK: - Static Data
    static let countries: [Country] = Country.allCases
    
    static let activityCategories: [String] = ActivityCategory.allCases.map { $0.rawValue }
}