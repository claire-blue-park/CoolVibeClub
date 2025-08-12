//
//  ActivityListError.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

enum ActivityDetailError: LocalizedError, Equatable {
  case forbidden  // 404
  case common(CommonError)  // 공통 에러로 위임

  var errorDescription: String? {
    switch self {
    case .forbidden: return "액티비티를 찾을 수 없습니다."
    case .common(let error): return error.errorDescription
    }
  }

  static func map(statusCode: Int, message: String?) -> ActivityListError {
    switch statusCode {
    case 404: return .forbidden
    default: return .common(CommonError.map(statusCode: statusCode, message: message))
    }
  }
}
