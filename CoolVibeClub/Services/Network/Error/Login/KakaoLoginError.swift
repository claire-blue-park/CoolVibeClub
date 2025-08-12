//
//  KakaoLoginError.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

enum KakaoLoginError: LocalizedError, Equatable {
  case requiredField  // 400
  case checkAccount  // 401
  case alreadyJoined  // 409
  case common(CommonError)  // 공통 에러로 위임

  var errorDescription: String? {
    switch self {
    case .requiredField: return "필수값을 채워주세요."
    case .checkAccount: return "계정을 확인해주세요."
    case .alreadyJoined: return "이미 가입된 유저입니다."
    case .common(let error): return error.errorDescription
    }
  }

  static func map(statusCode: Int, error: ErrorResponse) -> KakaoLoginError {
    switch statusCode {
    case 400: return .requiredField
    case 401: return .checkAccount
    case 409: return .alreadyJoined
    default: return .common(CommonError.map(statusCode: statusCode, message: error.message))
    }
  }
}
