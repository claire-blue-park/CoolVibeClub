//
//  ActivityDetailFeature.swift
//  CoolVibeClub
//
//

import SwiftUI
import Foundation
import iamport_ios

struct ActivityDetailState {
  // 액티비티 상세 정보
  var activityDetail: ActivityDetailResponse?
  var selectedImageIndex: Int = 0
  var isLiked: Bool = false
  
  // UI 상태
  var isLoading: Bool = false
  var errorMessage: String?
  
  // 네비게이션 상태
  var showChatView: Bool = false
  var chatUserId: String = ""
  var chatNickname: String = ""
  
  // 스크롤 상태
  var scrollOffset: CGFloat = 0
  var showNavBarTitle: Bool = false
  
  // 예약 상태
  var selectedDate: String?
  var selectedTime: String?
  var participantCount: Int = 1
  var isOrderInProgress: Bool = false
  var showPaymentView: Bool = false
  var currentOrderResponse: OrderResponse?
  var showPaymentSuccessAlert: Bool = false
  var paymentSuccessMessage: String = ""
  var refreshTrigger: Int = 0
}

enum ActivityDetailAction {
  // 데이터 로딩 액션
  case loadActivityDetail(String)              // 액티비티 상세 정보 로드
  case refreshActivityDetail(String)           // 액티비티 상세 정보 새로고침
  
  // UI 상태 액션
  case setSelectedImageIndex(Int)              // 선택된 이미지 인덱스 설정
  case setIsLiked(Bool)                        // 좋아요 상태 설정
  case setScrollOffset(CGFloat)                // 스크롤 오프셋 설정
  case setShowNavBarTitle(Bool)                // 네비바 타이틀 표시 여부 설정
  case setLoading(Bool)                        // 로딩 상태 설정
  case setError(String?)                       // 에러 메시지 설정
  case clearError                              // 에러 메시지 클리어
  
  // 네비게이션 액션
  case navigateToChat(userId: String, nickname: String) // 채팅방으로 이동
  case clearNavigation                         // 네비게이션 상태 클리어
  
  // 예약 관련 액션
  case setSelectedDate(String?)                // 예약 날짜 설정
  case setSelectedTime(String?)                // 예약 시간 설정
  case setParticipantCount(Int)                // 참가자 수 설정
  case submitOrder                             // 주문 제출
  case setOrderInProgress(Bool)                // 주문 진행 상태 설정
  
  // 결제 관련 액션
  case setShowPaymentView(Bool)                // 결제 화면 표시 여부 설정
  case setCurrentOrderResponse(OrderResponse?) // 현재 주문 응답 설정
  case handlePaymentResult(IamportResponse?)   // 결제 결과 처리
  case setShowPaymentSuccessAlert(Bool)        // 결제 성공 알림 표시 여부 설정
  case setPaymentSuccessMessage(String)        // 결제 성공 메시지 설정
  case incrementRefreshTrigger                 // 새로고침 트리거 증가
  
  // 내부 액션 (Private)
  case _activityDetailLoaded(ActivityDetailResponse) // 액티비티 상세 정보 로드 완료 (내부용)
  case _orderResponseReceived(OrderResponse)   // 주문 응답 수신 완료 (내부용)
  case _paymentCompleted                       // 결제 완료 (내부용)
}

@MainActor
final class ActivityDetailStore: ObservableObject {
  // 현재 상태 (Published로 UI 자동 업데이트)
  @Published var state = ActivityDetailState()
  
  // Dependencies
  private let activityDetailClient: ActivityDetailClient
  
  init(activityDetailClient: ActivityDetailClient = .live) {
    self.activityDetailClient = activityDetailClient
  }
  
  func send(_ action: ActivityDetailAction) {
    switch action {
      
    // 데이터 로딩 처리
    case .loadActivityDetail(let activityId):
      performActivityDetailLoading(activityId)
      
    case .refreshActivityDetail(let activityId):
      performActivityDetailLoading(activityId)
      
    // UI 상태 처리
    case .setSelectedImageIndex(let index):
      state.selectedImageIndex = index
      
    case .setIsLiked(let isLiked):
      state.isLiked = isLiked
      
    case .setScrollOffset(let offset):
      state.scrollOffset = offset
      
    case .setShowNavBarTitle(let show):
      state.showNavBarTitle = show
      
    case .setLoading(let isLoading):
      state.isLoading = isLoading
      
    case .setError(let message):
      state.errorMessage = message
      
    case .clearError:
      state.errorMessage = nil
      
    // 네비게이션 처리
    case .navigateToChat(let userId, let nickname):
      state.chatUserId = userId
      state.chatNickname = nickname
      state.showChatView = true
      
    case .clearNavigation:
      state.showChatView = false
      
    // 예약 관련 처리
    case .setSelectedDate(let date):
      state.selectedDate = date
      
    case .setSelectedTime(let time):
      state.selectedTime = time
      
    case .setParticipantCount(let count):
      state.participantCount = count
      
    case .submitOrder:
      performOrderSubmission()
      
    case .setOrderInProgress(let inProgress):
      state.isOrderInProgress = inProgress
      
    // 결제 관련 처리
    case .setShowPaymentView(let show):
      state.showPaymentView = show
      
    case .setCurrentOrderResponse(let response):
      state.currentOrderResponse = response
      
    case .handlePaymentResult(let response):
      performPaymentResultHandling(response)
      
    case .setShowPaymentSuccessAlert(let show):
      state.showPaymentSuccessAlert = show
      
    case .setPaymentSuccessMessage(let message):
      state.paymentSuccessMessage = message
      
    case .incrementRefreshTrigger:
      state.refreshTrigger += 1
      
    // 내부 액션 처리
    case ._activityDetailLoaded(let detail):
      state.activityDetail = detail
      state.isLiked = detail.isKeep
      send(.setLoading(false))
      
    case ._orderResponseReceived(let orderResponse):
      state.currentOrderResponse = orderResponse
      send(.setShowPaymentView(true))
      send(.setOrderInProgress(false))
      
    case ._paymentCompleted:
      performPaymentCompletionTasks()
    }
  }
}

extension ActivityDetailStore {
  
  /// 액티비티 상세 정보 로딩 수행
  private func performActivityDetailLoading(_ activityId: String) {
    Task {
      await loadActivityDetail(activityId)
    }
  }
  
  /// 주문 제출 수행
  private func performOrderSubmission() {
    Task {
      await handleOrderSubmission()
    }
  }
  
  /// 결제 결과 처리 수행
  private func performPaymentResultHandling(_ response: IamportResponse?) {
    Task {
      await handlePaymentResult(response)
    }
  }
  
  /// 결제 완료 후 작업 수행
  private func performPaymentCompletionTasks() {
    Task {
      await refreshActivityDetailAfterPayment()
    }
  }
  
  /// 액티비티 상세 정보를 서버에서 로딩
  private func loadActivityDetail(_ activityId: String) async {
    await MainActor.run {
      send(.setLoading(true))
      send(.setError(nil))
    }
    
    do {
      let detail = try await activityDetailClient.fetchActivityDetail(activityId)
      await MainActor.run {
        send(._activityDetailLoaded(detail))
      }
    } catch {
      await MainActor.run {
        send(.setError("상세 정보를 불러오는데 실패했습니다: \(error.localizedDescription)"))
        send(.setLoading(false))
      }
    }
  }
  
  /// 주문 제출 처리
  private func handleOrderSubmission() async {
    guard let selectedDate = state.selectedDate,
          let selectedTime = state.selectedTime,
          let activityDetail = state.activityDetail else {
      print("❌ 주문에 필요한 정보가 부족합니다.")
      return
    }
    
    // 인증 토큰 확인
    let token = KeyChainHelper.shared.loadToken()
    guard token != nil else {
      await MainActor.run {
        send(.setError("로그인이 필요합니다."))
      }
      return
    }
    
    print("🛒 주문 시작!")
    print("  📋 주문 정보:")
    print("    - 액티비티 ID: '\(activityDetail.activityId)'")
    print("    - 선택 날짜: '\(selectedDate)'")
    print("    - 선택 시간: '\(selectedTime)'")
    print("    - 참가자 수: \(state.participantCount)")
    print("    - 총 가격: \(activityDetail.price.final)원")
    
    await MainActor.run {
      send(.setOrderInProgress(true))
    }
    
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
      
      await MainActor.run {
        send(._orderResponseReceived(orderResponse))
      }
      
    } catch {
      print("❌ 주문 실패!")
      print("  🚫 오류 정보: \(error.localizedDescription)")
      await MainActor.run {
        send(.setError("주문에 실패했습니다: \(error.localizedDescription)"))
        send(.setOrderInProgress(false))
      }
    }
  }
  
  /// 결제 결과 처리
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
        
        await MainActor.run {
          send(.setShowPaymentView(false))
          send(.setPaymentSuccessMessage("결제가 완료되었습니다!\n예약 정보가 업데이트되었습니다."))
          send(.setShowPaymentSuccessAlert(true))
          send(._paymentCompleted)
        }
        
      } catch {
        print("❌ 결제 검증 실패: \(error.localizedDescription)")
        
        var message = "결제가 완료되었습니다!\n예약 정보가 업데이트되었습니다."
        if let paymentError = error as? PaymentValidationError,
           case .tokenExpired = paymentError {
          print("⚠️ 토큰 만료로 인한 검증 실패 - 결제는 완료됨")
          message = "결제가 완료되었습니다!\n(세션 만료로 검증은 생략됨)"
        }
        
        await MainActor.run {
          send(.setShowPaymentView(false))
          send(.setPaymentSuccessMessage(message))
          send(.setShowPaymentSuccessAlert(true))
          send(._paymentCompleted)
        }
      }
      
    } else {
      print("❌ 결제 실패 또는 취소")
      var message = "결제가 취소되었습니다."
      
      if let response = iamportResponse,
         let errorMsg = response.error_msg, !errorMsg.isEmpty {
        message = "결제에 실패했습니다.\n\(errorMsg)"
      }
      
      await MainActor.run {
        send(.setShowPaymentView(false))
        send(.setPaymentSuccessMessage(message))
        send(.setShowPaymentSuccessAlert(true))
      }
    }
  }
  
  /// 결제 완료 후 액티비티 상세 정보 새로고침
  private func refreshActivityDetailAfterPayment() async {
    print("🔄 결제 완료 후 액티비티 상세 정보 새로고침 시작")
    
    await MainActor.run {
      // 선택된 예약 정보 초기화
      send(.setSelectedDate(nil))
      send(.setSelectedTime(nil))
    }
    
    // 잠시 대기 (서버 데이터 업데이트 처리 시간 고려)
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    
    // 액티비티 상세 정보 새로고침
    if let activityId = state.activityDetail?.activityId {
      await loadActivityDetail(activityId)
    }
    
    await MainActor.run {
      // UI 강제 새로고침 트리거
      send(.incrementRefreshTrigger)
      print("🔄 UI 강제 새로고침 트리거: \(state.refreshTrigger)")
    }
  }
}
