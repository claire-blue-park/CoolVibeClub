//
//  ChatMessageError.swift
//  CoolVibeClub
//
//  Created by Claire on 8/1/25.
//

import Foundation

enum ChatMessageError: LocalizedError, Equatable {
  case requiredField  // 400
  case forbidden  // 404
  case notParticipant // 445
  case common(CommonError)  // 공통 에러로 위임

  var errorDescription: String? {
    return switch self {
    case .requiredField: "필수값을 채워주세요."
    case .forbidden: "채팅방 찾을 수 없습니다." // 탈퇴 시: 알 수 없는 계정입니다.
    case .notParticipant: "채팅방 참여자가 아닙니다."
    case .common(let error): error.errorDescription
    }
  }

  static func map(statusCode: Int, message: String?) -> ChatMessageError {
    switch statusCode {
    case 400: return .requiredField
    case 404: return .forbidden
    case 445: return .notParticipant
    default: return .common(CommonError.map(statusCode: statusCode, message: message))
    }
  }
}
