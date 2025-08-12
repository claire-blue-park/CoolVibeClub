//
//  BannerResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation


struct BannerResponse: Decodable {
  let data: [Banner]
}

struct Banner: Decodable {
  let name: String
  let imageUrl: String
  let payload: Payload
}

struct Payload: Decodable {
  let type: String
  let value: String
}
