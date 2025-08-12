//
//  OrderService.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct OrderService {
    static let shared = OrderService()
    
    private init() {}
    
    func createOrder(
        activityId: String,
        reservationDate: String,
        reservationTime: String,
        participantCount: Int,
        totalPrice: Double
    ) async throws -> OrderResponse {
        print("🌐 OrderService: 주문 API 호출 준비")
        print("  🎯 엔드포인트: POST /v1/orders")
        
        let endpoint = OrderEndpoint(requestType: .makeOrder(
            activityId: activityId,
            reservationItemName: reservationDate,
            reservationItemTime: reservationTime,
            participantCount: participantCount,
            totalPrice: totalPrice
        ))
        
        print("  📤 요청 데이터:")
        print("    - activity_id: \(activityId) (타입: \(type(of: activityId)))")
        print("    - reservation_item_name: \(reservationDate) (타입: \(type(of: reservationDate)))")
        print("    - reservation_item_time: \(reservationTime) (타입: \(type(of: reservationTime)))")
        print("    - participant_count: \(participantCount) (타입: \(type(of: participantCount)))")
        print("    - total_price: \(totalPrice) -> Int(\(Int(totalPrice))) (타입: \(type(of: totalPrice)) -> \(type(of: Int(totalPrice))))")
        
        do {
            let response: OrderResponse = try await NetworkManager.shared.fetch(
                from: endpoint,
                errorMapper: { statusCode, error in
                    print("❌ 주문 API 에러: HTTP \(statusCode) - \(error.message)")
                  return OrderError.map(statusCode: statusCode, message: error.message ?? "")
                }
            )
            
            print("✅ OrderService: API 응답 수신 성공")
            return response
            
        } catch {
            print("❌ OrderService: API 호출 실패 - \(error)")
            throw error
        }
    }
}

// MARK: - Order Error
enum OrderError: LocalizedError {
    case invalidRequest
    case unauthorized
    case activityNotFound
    case reservationNotAvailable
    case networkError(String)
    
    static func map(statusCode: Int, message: String) -> OrderError {
        switch statusCode {
        case 400:
            return .invalidRequest
        case 401:
            return .unauthorized
        case 404:
            return .activityNotFound
        case 409:
            return .reservationNotAvailable
        default:
            return .networkError(message)
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "잘못된 요청입니다."
        case .unauthorized:
            return "로그인이 필요합니다."
        case .activityNotFound:
            return "액티비티를 찾을 수 없습니다."
        case .reservationNotAvailable:
            return "이미 예약된 시간입니다."
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        }
    }
}
