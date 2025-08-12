//
//  CommonError.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

/// 서버 공통 에러 코드
enum CommonError: LocalizedError, Equatable {
  case unauthorized  // 401
  case forbidden  // 403
  case tokenExpired  // 419
  case invalidKey  // 420
  case tooManyRequests  // 429
  case invalidAPI  // 444
  case serverError  // 500
  case custom(message: String)
  case unknown

  var errorDescription: String? {
    switch self {
    case .unauthorized:
      return "인증할 수 없는 액세스 토큰입니다."
    case .forbidden:
      return "접근이 거부되었습니다."
    case .tokenExpired:
      return "액세스 토큰이 만료되었습니다."
    case .invalidKey:
      return "서비스 키가 유효하지 않습니다."
    case .tooManyRequests:
      return "API 호출 횟수를 초과했습니다."
    case .invalidAPI:
      return "비정상적인 API 호출입니다."
    case .serverError:
      return "서버 내부 오류가 발생했습니다."
    case .custom(let message):
      return message
    case .unknown:
      return "알 수 없는 오류가 발생했습니다."
    }
  }

  static func map(statusCode: Int, message: String?) -> CommonError {
    switch statusCode {
    case 401:
      return .unauthorized
    case 403:
      return .forbidden
    case 419:
      return .tokenExpired
    case 420:
      return .invalidKey
    case 429:
      return .tooManyRequests
    case 444:
      return .invalidAPI
    case 500:
      return .serverError
    default:
      if let msg = message {
        return .custom(message: msg)
      } else {
        return .unknown
      }
    }
  }
}
