//
//  NetworkError.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case invalidStatusCode(Int)
    case decodingFailed
    case serverError(String)
    case noResponse
    case networkFailure(Error)
  case unknown
}
