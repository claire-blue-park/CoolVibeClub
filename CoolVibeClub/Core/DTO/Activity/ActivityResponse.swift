//
//  ActivityResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

// MARK: - ActivityResponse
struct ActivityResponse: Decodable {
    let data: [Activity]
}

// MARK: - Activity
struct Activity: Decodable, Identifiable {
    let activityId: String
    let title: String
    let country: String
    let category: String
    let thumbnails: [String]
    let geolocation: Geolocation
    let price: Price
    let tags: [String]
    let pointReward: Int
    let isAdvertisement: Bool
    let isKeep: Bool
    let keepCount: Int
    
    var id: String { activityId }
    
    enum CodingKeys: String, CodingKey {
        case activityId = "activity_id"
        case title, country, category, thumbnails, geolocation, price, tags
        case pointReward = "point_reward"
        case isAdvertisement = "is_advertisement"
        case isKeep = "is_keep"
        case keepCount = "keep_count"
    }
}

// MARK: - Geolocation
struct Geolocation: Decodable {
    let longitude: Double
    let latitude: Double
}

// MARK: - Price
struct Price: Decodable {
    let original: Int
    let final: Int
    
    var discountRate: Int {
        guard original > 0 else { return 0 }
        return Int(100 - (Double(final) / Double(original) * 100))
    }
}
