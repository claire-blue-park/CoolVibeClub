//
//  ActivityInfoData.swift
//  CoolVibeClub
//
//  Created by Claire on 7/14/25.
//

import Foundation

struct ActivityInfoData: Identifiable {
  let id = UUID()
  let imageName: String
  let price: String
  let isLiked: Bool
  let title: String
  let country: String
  let category: String
}
