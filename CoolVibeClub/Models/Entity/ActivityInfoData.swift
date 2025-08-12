//
//  ActivityInfoData.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct ActivityInfoData: Identifiable, Hashable, Equatable {
  let id = UUID()
  let activityId: String
  let imageName: String
  let price: String
  let isLiked: Bool
  let title: String
  let country: String
  let category: String
  let tags: [String]
  let originalPrice: String
  let discountRate: Int
  
  // Hashable 준수를 위한 hash 함수
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  // Equatable 준수를 위한 비교 함수
  static func == (lhs: ActivityInfoData, rhs: ActivityInfoData) -> Bool {
    return lhs.id == rhs.id
  }
}
