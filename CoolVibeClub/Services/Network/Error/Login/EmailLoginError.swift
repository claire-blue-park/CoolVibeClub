//
//  EmailLoginError.swift
//  CoolVibeClub
//
//  Created by Claire on 8/17/25.
//

import Foundation

enum EmailLoginError: LocalizedError, Equatable {
  case requiredField  // 400
  case checkAccount  // 401
  case common(CommonError)  // 공통 에러로 위임

  var errorDescription: String? {
    switch self {
    case .requiredField: return "필수값을 채워주세요."
    case .checkAccount: return "계정을 확인해주세요."
    case .common(let error): return error.errorDescription
    }
  }

  static func map(statusCode: Int, error: ErrorResponse) -> EmailLoginError {
    switch statusCode {
    case 400: return .requiredField
    case 401: return .checkAccount
    default: return .common(CommonError.map(statusCode: statusCode, message: error.message))
    }
  }
}

