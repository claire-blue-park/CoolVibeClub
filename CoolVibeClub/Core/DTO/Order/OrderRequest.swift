//
//  OrderRequest.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct OrderRequest: Codable {
  let activityId: String
  let reservationItemName: String  // "2025-07-01" 형태
  let reservationItemTime: String  // "10:00" 형태
  let participantCount: Int
  let totalPrice: Int
  
  enum CodingKeys: String, CodingKey {
    case activityId = "activity_id"
    case reservationItemName = "reservation_item_name"
    case reservationItemTime = "reservation_item_time"
    case participantCount = "participant_count"
    case totalPrice = "total_price"
  }
}

