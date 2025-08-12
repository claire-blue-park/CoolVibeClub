//
//  ActivityListError.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

enum ActivityListError: LocalizedError, Equatable {
  case invalidType  // 400
  case forbidden  // 403
  case common(CommonError)  // 공통 에러로 위임

  var errorDescription: String? {
    switch self {
    case .invalidType: return "유효하지 않은 값 타입입니다."
    case .forbidden: return "권한이 없습니다."
    case .common(let error): return error.errorDescription
    }
  }

  static func map(statusCode: Int, message: String?) -> ActivityListError {
    switch statusCode {
    case 400: return .invalidType
    case 403: return .forbidden
    default: return .common(CommonError.map(statusCode: statusCode, message: message))
    }
  }
}
