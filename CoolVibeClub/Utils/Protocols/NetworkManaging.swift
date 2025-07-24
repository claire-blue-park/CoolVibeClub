//
//  NetworkManaging.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

protocol NetworkManaging {
  func fetch<T: Decodable>(
    from endpoint: Endpoint,
    errorMapper: @escaping (Int, ErrorResponse) -> Error
  ) async throws -> T
}
