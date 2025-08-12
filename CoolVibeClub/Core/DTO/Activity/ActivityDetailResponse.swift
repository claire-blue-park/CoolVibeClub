//
//  ActivityDetailResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

// MARK: - ActivityDetailResponse
struct ActivityDetailResponse: Codable {
  let activityId: String
  let title: String
  let country: String
  let category: String
  let thumbnails: [String]
  let geolocation: DetailGeolocation?
  let startDate: String?
  let endDate: String?
  let price: DetailPrice
  let tags: [String]?
  let pointReward: Int?
  let restrictions: DetailRestrictions?
  let description: String?
  let isAdvertisement: Bool?
  let isKeep: Bool
  let keepCount: Int?
  let totalOrderCount: Int?
  let schedule: [DetailSchedule]?
  let reservationList: [DetailReservationList]?
  let creator: DetailCreator?
  let createdAt: String?
  let updatedAt: String?
  
  enum CodingKeys: String, CodingKey {
    case activityId = "activity_id"
    case title, country, category, thumbnails, geolocation
    case startDate = "start_date"
    case endDate = "end_date"
    case price, tags
    case pointReward = "point_reward"
    case restrictions, description
    case isAdvertisement = "is_advertisement"
    case isKeep = "is_keep"
    case keepCount = "keep_count"
    case totalOrderCount = "total_order_count"
    case schedule
    case reservationList = "reservation_list"
    case creator, createdAt, updatedAt
  }
}

// MARK: - DetailGeolocation
struct DetailGeolocation: Codable {
  let longitude: Double
  let latitude: Double
}

// MARK: - DetailPrice
struct DetailPrice: Codable {
  let original: Int
  let final: Int
}

// MARK: - DetailRestrictions
struct DetailRestrictions: Codable {
  let minHeight: Int
  let minAge: Int
  let maxParticipants: Int
  
  enum CodingKeys: String, CodingKey {
    case minHeight = "min_height"
    case minAge = "min_age"
    case maxParticipants = "max_participants"
  }
}

// MARK: - DetailSchedule
struct DetailSchedule: Codable {
  let duration: String
  let description: String
}

// MARK: - DetailReservationList
struct DetailReservationList: Codable {
  let itemName: String
  let times: [DetailTimeSlot]
  
  enum CodingKeys: String, CodingKey {
    case itemName = "item_name"
    case times
  }
}

// MARK: - DetailTimeSlot
struct DetailTimeSlot: Codable {
  let time: String
  let isReserved: Bool
  
  enum CodingKeys: String, CodingKey {
    case time
    case isReserved = "is_reserved"
  }
}

// MARK: - DetailCreator
struct DetailCreator: Codable {
  let userId: String
  let nick: String
  let profileImage: String?
  let introduction: String?
  
  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case nick, profileImage, introduction
  }
}