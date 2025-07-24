//
//  PaymentService.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct PaymentService {
    static let shared = PaymentService()
    
    private init() {}
    
    func validatePayment(impUid: String) async throws -> PaymentValidationResponse {
        print("🔐 PaymentService: 결제 검증 API 호출 준비")
        print("  🎯 엔드포인트: POST /v1/payments/validation")
        print("  📤 imp_uid: \(impUid)")
        
        let endpoint = PaymentEndpoint(requestType: .validateReceipt(impUid: impUid))
        
        do {
            print("🔍 결제 검증 API 호출 중...")
            
            // 바로 PaymentValidationResponse로 디코딩 시도 (NetworkManager에서 응답 로그가 이미 출력됨)
            let response: PaymentValidationResponse = try await NetworkManager.shared.fetch(
                from: endpoint,
                errorMapper: { statusCode, error in
                    print("❌ 결제 검증 API 에러: HTTP \(statusCode) - \(error.message)")
                    
                    // 토큰 관련 에러인 경우 특별 처리
                    if statusCode == 401 || statusCode == 419 {
                        print("⚠️ 토큰 만료로 인한 결제 검증 실패 - 사용자에게 알림 필요")
                        return PaymentValidationError.tokenExpired
                    }
                    
                    return PaymentValidationError.map(statusCode: statusCode, message: error.message ?? "")
                }
            )
            
            print("✅ PaymentService: 결제 검증 성공")
            print("  📦 응답 데이터:")
            print("    - payment_id: \(response.paymentId)")
            print("    - order_code: \(response.orderItem.orderCode)")
            print("    - total_price: \(response.orderItem.totalPrice)원")
            print("    - paid_at: \(response.orderItem.paidAt)")
            print("    - activity_id: \(response.orderItem.activity.id)")
            print("    - activity_title: \(response.orderItem.activity.title)")
            print("    - participant_count: \(response.orderItem.participantCount)")
            print("    - reservation_date: \(response.orderItem.reservationItemName)")
            print("    - reservation_time: \(response.orderItem.reservationItemTime)")
            
            return response
            
        } catch {
            print("❌ PaymentService: 결제 검증 실패 - \(error)")
            throw error
        }
    }
}

// MARK: - Payment Validation Error
enum PaymentValidationError: LocalizedError {
    case invalidPayment
    case unauthorized
    case paymentNotFound
    case validationFailed
    case tokenExpired
    case networkError(String)
    
    static func map(statusCode: Int, message: String) -> PaymentValidationError {
        switch statusCode {
        case 400:
            return .invalidPayment
        case 401:
            return .unauthorized
        case 404:
            return .paymentNotFound
        case 422:
            return .validationFailed
        default:
            return .networkError(message)
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidPayment:
            return "잘못된 결제 정보입니다."
        case .unauthorized:
            return "로그인이 필요합니다."
        case .paymentNotFound:
            return "결제 정보를 찾을 수 없습니다."
        case .validationFailed:
            return "결제 검증에 실패했습니다."
        case .tokenExpired:
            return "세션이 만료되었습니다. 결제는 완료되었으나 검증을 진행할 수 없습니다."
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        }
    }
}
