//
//  ChatRoomError.swift
//  CoolVibeClub
//
//  Created by Claire on 8/1/25.
//

import Foundation

enum ChatRoomError: LocalizedError, Equatable {
  case requiredField  // 400
  case forbidden  // 404
  case common(CommonError)  // 공통 에러로 위임

  var errorDescription: String? {
    switch self {
    case .requiredField: return "필수값을 채워주세요."
    case .forbidden: return "채팅방 찾을 수 없습니다." // 탈퇴 시: 알 수 없는 계정입니다.
    case .common(let error): return error.errorDescription
    }
  }

  static func map(statusCode: Int, message: String?) -> ChatRoomError {
    switch statusCode {
    case 400: return .requiredField
    case 404: return .forbidden
    default: return .common(CommonError.map(statusCode: statusCode, message: message))
    }
  }
}
