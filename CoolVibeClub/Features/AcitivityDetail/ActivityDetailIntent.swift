//
//  ActivityDetailIntent.swift
//  CoolVibeClub
//
//  Created by Claire on 8/13/25.
//

import Foundation
import SwiftUI
import iamport_ios

// MARK: - ActivityDetail Intent State
struct ActivityDetailIntentState: StateMarker {
    var isLoading: Bool = false
    var error: String? = nil
    var activityDetail: ActivityDetailResponse? = nil
    var selectedImageIndex: Int = 0
    var isLiked: Bool = false
    
    // Navigation
    var showChatView: Bool = false
    var chatUserId: String = ""
    var chatNickname: String = ""
    
    // Scroll
    var scrollOffset: CGFloat = 0
    var showNavBarTitle: Bool = false
    
    // Reservation
    var selectedDate: String? = nil
    var selectedTime: String? = nil
    var participantCount: Int = 1
    var isOrderInProgress: Bool = false
    var showPaymentView: Bool = false
    var currentOrderResponse: OrderResponse? = nil
    var showPaymentSuccessAlert: Bool = false
    var paymentSuccessMessage: String = ""
    var refreshTrigger: Int = 0
}

// MARK: - ActivityDetail Intent Actions
enum ActivityDetailIntentAction: ActionMarker {
    case loadActivityDetail(String)
    case refreshActivityDetail(String)
    case clearError
    
    // Navigation
    case navigateToChat(userId: String, nickname: String)
    case clearNavigation
    
    // UI State
    case setSelectedImageIndex(Int)
    case setIsLiked(Bool)
    case setScrollOffset(CGFloat)
    case setShowNavBarTitle(Bool)
    
    // Reservation
    case setSelectedDate(String?)
    case setSelectedTime(String?)
    case setParticipantCount(Int)
    case submitOrder
    case setOrderInProgress(Bool)
    case setShowPaymentView(Bool)
    case setCurrentOrderResponse(OrderResponse?)
    case setShowPaymentSuccessAlert(Bool)
    case setPaymentSuccessMessage(String)
    case incrementRefreshTrigger
    
    // Payment Result
    case handlePaymentResult(IamportResponse?)
}

// MARK: - ActivityDetail Intent
@MainActor
final class ActivityDetailIntent: Intent, ObservableObject {
    typealias State = ActivityDetailIntentState
    typealias ActionType = ActivityDetailIntentAction
    
    @Published var state = ActivityDetailIntentState()
    
    // Dependencies
    private let activityDetailClient: ActivityDetailClient
    
    init(activityDetailClient: ActivityDetailClient = .live) {
        self.activityDetailClient = activityDetailClient
    }
    
    func send(_ action: ActivityDetailIntentAction) {
        switch action {
        case .loadActivityDetail(let activityId):
            Task { await loadActivityDetail(activityId) }
            
        case .refreshActivityDetail(let activityId):
            Task { await loadActivityDetail(activityId) }
            
        case .clearError:
            self.state.error = nil
            
        case .navigateToChat(let userId, let nickname):
            self.state.chatUserId = userId
            self.state.chatNickname = nickname
            self.state.showChatView = true
            
        case .clearNavigation:
            self.state.showChatView = false
            
        case .setSelectedImageIndex(let index):
            self.state.selectedImageIndex = index
            
        case .setIsLiked(let isLiked):
            self.state.isLiked = isLiked
            
        case .setScrollOffset(let offset):
            self.state.scrollOffset = offset
            
        case .setShowNavBarTitle(let show):
            self.state.showNavBarTitle = show
            
        case .setSelectedDate(let date):
            self.state.selectedDate = date
            
        case .setSelectedTime(let time):
            self.state.selectedTime = time
            
        case .setParticipantCount(let count):
            self.state.participantCount = count
            
        case .submitOrder:
            Task { await handleOrderSubmission() }
            
        case .setOrderInProgress(let inProgress):
            self.state.isOrderInProgress = inProgress
            
        case .setShowPaymentView(let show):
            self.state.showPaymentView = show
            
        case .setCurrentOrderResponse(let response):
            self.state.currentOrderResponse = response
            
        case .setShowPaymentSuccessAlert(let show):
            self.state.showPaymentSuccessAlert = show
            
        case .setPaymentSuccessMessage(let message):
            self.state.paymentSuccessMessage = message
            
        case .incrementRefreshTrigger:
            self.state.refreshTrigger += 1
            
        case .handlePaymentResult(let response):
            Task { await handlePaymentResult(response) }
        }
    }
    
    // MARK: - Private Methods
    private func loadActivityDetail(_ activityId: String) async {
        self.state.isLoading = true
        self.state.error = nil
        
        do {
            let detail = try await activityDetailClient.fetchActivityDetail(activityId)
            self.state.activityDetail = detail
            self.state.isLiked = detail.isKeep
        } catch {
            self.state.error = "상세 정보를 불러오는데 실패했습니다: \(error.localizedDescription)"
        }
        
        self.state.isLoading = false
    }
    
    private func handleOrderSubmission() async {
        guard let selectedDate = state.selectedDate,
              let selectedTime = state.selectedTime,
              let activityDetail = state.activityDetail else {
            print("❌ 주문에 필요한 정보가 부족합니다.")
            print("  - selectedDate: \(state.selectedDate ?? "nil")")
            print("  - selectedTime: \(state.selectedTime ?? "nil")")
            print("  - activityDetail: \(state.activityDetail?.activityId ?? "nil")")
            return
        }
        
        // 인증 토큰 확인
        let token = KeyChainHelper.shared.loadToken()
        print("🔑 인증 토큰 상태: \(token != nil ? "존재함 (길이: \(token?.count ?? 0))" : "없음")")
        
        if token == nil {
            print("❌ 인증 토큰이 없습니다. 로그인이 필요합니다.")
            self.state.error = "로그인이 필요합니다."
            return
        }
        
        print("🛒 주문 시작!")
        print("  📋 주문 정보:")
        print("    - 액티비티 ID: '\(activityDetail.activityId)' (길이: \(activityDetail.activityId.count))")
        print("    - 선택 날짜: '\(selectedDate)' (길이: \(selectedDate.count))")
        print("    - 선택 시간: '\(selectedTime)' (길이: \(selectedTime.count))")
        print("    - 참가자 수: \(state.participantCount)")
        print("    - 총 가격: \(activityDetail.price.final)원")
        
        // 각 필드가 비어있지 않은지 확인
        if activityDetail.activityId.isEmpty {
            print("❌ 액티비티 ID가 비어있음!")
            return
        }
        if selectedDate.isEmpty {
            print("❌ 선택 날짜가 비어있음!")
            return
        }
        if selectedTime.isEmpty {
            print("❌ 선택 시간이 비어있음!")
            return
        }
        
        self.state.isOrderInProgress = true
        
        do {
            print("🔄 서버로 주문 요청 전송 중...")
            
            let orderResponse = try await OrderService.shared.createOrder(
                activityId: activityDetail.activityId,
                reservationDate: selectedDate,
                reservationTime: selectedTime,
                participantCount: state.participantCount,
                totalPrice: Double(activityDetail.price.final)
            )
            
            print("✅ 주문 성공!")
            print("  📦 응답 데이터:")
            print("    - 주문 ID: \(orderResponse.orderId)")
            print("    - 주문 코드: \(orderResponse.orderCode)")
            print("    - 총 가격: \(orderResponse.totalPrice)원")
            
            self.state.currentOrderResponse = orderResponse
            self.state.showPaymentView = true
            
        } catch {
            print("❌ 주문 실패!")
            print("  🚫 오류 정보: \(error.localizedDescription)")
        }
        
        self.state.isOrderInProgress = false
    }
    
    private func handlePaymentResult(_ iamportResponse: IamportResponse?) async {
        print("🚀 handlePaymentResult 호출됨!")
        print("🚀 받은 응답: \(iamportResponse?.description ?? "nil")")
        
        if let response = iamportResponse,
           let impUid = response.imp_uid,
           response.success == true {
            print("✅ 결제 성공! imp_uid: \(impUid)")
            
            do {
                let validationResponse = try await PaymentService.shared.validatePayment(impUid: impUid)
                print("🔐 결제 검증 완료!")
                print("  💰 검증된 결제 정보:")
                print("    - 결제 ID: \(validationResponse.paymentId)")
                print("    - 주문 코드: \(validationResponse.orderItem.orderCode)")
                print("    - 결제 금액: \(validationResponse.orderItem.totalPrice)원")
                
                // 결제 및 검증 완료 후 데이터 새로고침
                await refreshActivityDetailAfterPayment()
                
                self.state.showPaymentView = false
                self.state.paymentSuccessMessage = "결제가 완료되었습니다!\n예약 정보가 업데이트되었습니다."
                self.state.showPaymentSuccessAlert = true
                
            } catch {
                print("❌ 결제 검증 실패: \(error.localizedDescription)")
                
                if let paymentError = error as? PaymentValidationError,
                   case .tokenExpired = paymentError {
                    print("⚠️ 토큰 만료로 인한 검증 실패 - 결제는 완료됨")
                    self.state.paymentSuccessMessage = "결제가 완료되었습니다!\n(세션 만료로 검증은 생략됨)"
                } else {
                    self.state.paymentSuccessMessage = "결제가 완료되었습니다!\n예약 정보가 업데이트되었습니다."
                }
                
                await refreshActivityDetailAfterPayment()
                self.state.showPaymentView = false
                self.state.showPaymentSuccessAlert = true
            }
            
        } else {
            print("❌ 결제 실패 또는 취소")
            if let response = iamportResponse,
               let errorMsg = response.error_msg, !errorMsg.isEmpty {
                self.state.paymentSuccessMessage = "결제에 실패했습니다.\n\(errorMsg)"
            } else {
                self.state.paymentSuccessMessage = "결제가 취소되었습니다."
            }
            self.state.showPaymentSuccessAlert = true
            self.state.showPaymentView = false
        }
    }
    
    private func refreshActivityDetailAfterPayment() async {
        print("🔄 결제 완료 후 액티비티 상세 정보 새로고침 시작")
        
        // 선택된 예약 정보 초기화
        self.state.selectedDate = nil
        self.state.selectedTime = nil
        
        // 잠시 대기 (서버 데이터 업데이트 처리 시간 고려)
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // 액티비티 상세 정보 새로고침
        if let activityId = state.activityDetail?.activityId {
            await loadActivityDetail(activityId)
        }
        
        // UI 강제 새로고침 트리거
        self.state.refreshTrigger += 1
        print("🔄 UI 강제 새로고침 트리거: \(state.refreshTrigger)")
    }
}
