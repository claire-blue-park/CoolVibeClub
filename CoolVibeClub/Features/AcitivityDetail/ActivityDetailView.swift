//
//  ActivityDetailView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import Alamofire
import AVFoundation
import iamport_ios
import Lottie
import WebKit

struct ActivityDetailView: View {
  let activityData: ActivityInfoData
  @Environment(\.dismiss) private var dismiss
  @Environment(\.activityDetailClient) private var activityDetailClient
  @EnvironmentObject private var tabVisibilityStore: TabVisibilityStore
  
  // 네비게이션을 위한 상태
  @State private var showChatView = false
  @State private var chatUserId = ""
  @State private var chatNickname = ""
  
  // 스크롤 상태 관리
  @State private var scrollOffset: CGFloat = 0
  @State private var showNavBarTitle = false
  
  // 진짜 MVI: State만 있고 비즈니스 로직 없음
  @State private var state = ActivityDetailState.initial
  @State private var selectedImageIndex: Int = 0
  @State private var isLiked: Bool = false
  
  // 예약 선택 관련 상태
  @State private var selectedDate: String? = nil
  @State private var selectedTime: String? = nil
  @State private var participantCount: Int = 1
  @State private var isOrderInProgress: Bool = false
  @State private var showPaymentView: Bool = false
  @State private var currentOrderResponse: OrderResponse?
  @State private var showPaymentSuccessAlert: Bool = false
  @State private var paymentSuccessMessage: String = ""
  @State private var refreshTrigger: Int = 0 // UI 강제 새로고침용
  
  // MARK: - Intent Handlers (순수 함수형)
  private func handleIntent(_ intent: ActivityDetailIntent) {
    switch intent {
    case .loadActivityDetail(let activityId):
      Task { await loadActivityDetail(activityId) }
      
    case .refreshActivityDetail(let activityId):
      Task { await loadActivityDetail(activityId) }
      
    case .clearError:
      activityDetailReducer(state: &state, action: .setError(nil))
      
    case .navigateToChat(let userId, let nickname):
      chatUserId = userId
      chatNickname = nickname
      showChatView = true
      
    case .clearNavigation:
      showChatView = false
    }
  }
  
  private func loadActivityDetail(_ activityId: String) async {
    activityDetailReducer(state: &state, action: .setLoading(true))
    activityDetailReducer(state: &state, action: .setError(nil))
    
    do {
      let detail = try await activityDetailClient.fetchActivityDetail(activityId)
      activityDetailReducer(state: &state, action: .setActivityDetail(detail))
    } catch {
      activityDetailReducer(state: &state, action: .setError("상세 정보를 불러오는데 실패했습니다: \(error.localizedDescription)"))
    }
    
    activityDetailReducer(state: &state, action: .setLoading(false))
  }
  
  // MARK: - 주문 처리
  private func handleOrderSubmission() async {
    guard let selectedDate = selectedDate,
          let selectedTime = selectedTime,
          let activityDetail = state.activityDetail else {
      print("❌ 주문에 필요한 정보가 부족합니다.")
      return
    }
    
    print("🛒 주문 시작!")
    print("  📋 주문 정보:")
    print("    - 액티비티 ID: \(activityData.activityId)")
    print("    - 선택 날짜: \(selectedDate)")
    print("    - 선택 시간: \(selectedTime)")
    print("    - 참가자 수: \(participantCount)")
    print("    - 총 가격: \(activityDetail.price.final)원")
    
    isOrderInProgress = true
    
    do {
      print("🔄 서버로 주문 요청 전송 중...")
      
      let orderResponse = try await OrderService.shared.createOrder(
        activityId: activityData.activityId,
        reservationDate: selectedDate,
        reservationTime: selectedTime,
        participantCount: participantCount,
        totalPrice: Double(activityDetail.price.final)
      )
      
      print("✅ 주문 성공!")
      print("  📦 응답 데이터:")
      print("    - 주문 ID: \(orderResponse.orderId)")
      print("    - 주문 코드: \(orderResponse.orderCode)")
      print("    - 총 가격: \(orderResponse.totalPrice)원")
      print("    - 생성 시간: \(orderResponse.createdAt)")
      print("    - 수정 시간: \(orderResponse.updatedAt)")
      
      // 주문 성공 시 결제 화면 표시
      await MainActor.run {
        currentOrderResponse = orderResponse
        showPaymentView = true
      }
      
    } catch {
      print("❌ 주문 실패!")
      print("  🚫 오류 정보:")
      print("    - 오류: \(error)")
      print("    - 설명: \(error.localizedDescription)")
      if let orderError = error as? OrderError {
        print("    - 타입: \(orderError)")
      }
      // TODO: 에러 알림 표시
    }
    
    await MainActor.run {
      isOrderInProgress = false
      print("🔄 주문 프로세스 완료")
    }
  }
  
  // MARK: - 결제 결과 처리
  private func handlePaymentResult(_ iamportResponse: IamportResponse?) {
    print("🚀 =========================")
    print("🚀 handlePaymentResult 호출됨!")
    print("🚀 현재 스레드: \(Thread.current)")
    print("🚀 받은 응답: \(iamportResponse?.description ?? "nil")")
    print("🚀 현재 시간: \(Date())")
    print("🚀 =========================")
    
    // 결제 성공 시에만 검증 진행
    if let response = iamportResponse,
       let impUid = response.imp_uid,
       response.success == true {
      print("✅ 결제 성공! imp_uid: \(impUid)")
      
      // 서버에서 결제 검증 수행
      Task {
        do {
          let validationResponse = try await PaymentService.shared.validatePayment(impUid: impUid)
          print("🔐 결제 검증 완료!")
          print("  💰 검증된 결제 정보:")
          print("    - 결제 ID: \(validationResponse.paymentId)")
          print("    - 주문 코드: \(validationResponse.orderItem.orderCode)")
          print("    - 결제 금액: \(validationResponse.orderItem.totalPrice)원")
          print("    - 결제 시간: \(validationResponse.orderItem.paidAt)")
          print("    - 액티비티: \(validationResponse.orderItem.activity.title)")
          print("    - 예약 날짜: \(validationResponse.orderItem.reservationItemName)")
          print("    - 예약 시간: \(validationResponse.orderItem.reservationItemTime)")
          print("    - 참가자 수: \(validationResponse.orderItem.participantCount)명")
          
          await MainActor.run {
            print("🎉 결제 및 검증 완료! UI 업데이트 시작")
            
            // 결제 및 검증 완료 후 액티비티 상세 정보 새로고침
            Task {
              print("🔄 결제 및 검증 완료 후 액티비티 데이터 새로고침 중...")
              await refreshActivityDetailAfterPayment()
            }
            
            showPaymentView = false
            
            // 결제 성공 알림 표시
            paymentSuccessMessage = "결제가 완료되었습니다!\n예약 정보가 업데이트되었습니다."
            showPaymentSuccessAlert = true
            print("💰 결제가 성공적으로 완료되었습니다!")
          }
          
        } catch {
          print("❌ 결제 검증 실패: \(error.localizedDescription)")
          await MainActor.run {
            if let paymentError = error as? PaymentValidationError,
               case .tokenExpired = paymentError {
              print("⚠️ 토큰 만료로 인한 검증 실패 - 결제는 완료됨")
              
              // 결제는 완료되었으므로 데이터 새로고침
              Task {
                print("🔄 토큰 만료로 검증 실패했지만 결제는 완료됨 - 데이터 새로고침")
                await refreshActivityDetailAfterPayment()
              }
              
              // 토큰 만료 알림 표시
              paymentSuccessMessage = "결제가 완료되었습니다!\n(세션 만료로 검증은 생략됨)"
              showPaymentSuccessAlert = true
            } else {
              print("⚠️ 결제는 완료되었지만 검증에 실패했습니다.")
              
              // 결제 완료로 간주하고 데이터 새로고침
              Task {
                print("🔄 검증 실패했지만 결제는 완료됨 - 데이터 새로고침")
                await refreshActivityDetailAfterPayment()
              }
              
              // 일반 검증 실패 알림 표시
              paymentSuccessMessage = "결제가 완료되었습니다!\n예약 정보가 업데이트되었습니다."
              showPaymentSuccessAlert = true
            }
            showPaymentView = false
          }
        }
      }
      
    } else {
      print("❌ 결제 실패 또는 취소")
      if let response = iamportResponse {
        print("  📋 실패 정보:")
        print("    - success: \(response.success)")
        print("    - error_msg: \(response.error_msg ?? "없음")")
        print("    - error_code: \(response.error_code ?? "없음")")
        
        // 결제 실패 알림 표시
        if let errorMsg = response.error_msg, !errorMsg.isEmpty {
          paymentSuccessMessage = "결제에 실패했습니다.\n\(errorMsg)"
        } else {
          paymentSuccessMessage = "결제가 취소되었습니다."
        }
      } else {
        print("🚫 결제 응답 자체가 nil - 사용자가 취소했거나 오류 발생")
        paymentSuccessMessage = "결제가 취소되었습니다."
      }
      showPaymentSuccessAlert = true
      showPaymentView = false
    }
  }
  
  // MARK: - 결제 완료 후 데이터 새로고침
  private func refreshActivityDetailAfterPayment() async {
    print("🔄 결제 완료 후 액티비티 상세 정보 새로고침 시작")
    print("🔄 현재 스레드: \(Thread.current)")
    
    // 기존 선택된 예약 정보 초기화
    await MainActor.run {
      selectedDate = nil
      selectedTime = nil
      print("🔄 선택된 날짜/시간 초기화 완료")
    }
    
    // 잠시 대기 (서버에서 데이터 업데이트 처리 시간 고려)
    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
    
    print("🔄 서버에서 최신 액티비티 데이터 요청 중...")
    
    // 서버에서 최신 액티비티 데이터 가져오기
    await loadActivityDetail(activityData.activityId)
    
    await MainActor.run {
      print("✅ 액티비티 데이터 새로고침 완료")
      print("📋 예약 가능한 시간대가 업데이트되었습니다")
      print("📊 현재 state.activityDetail 상태: \(state.activityDetail != nil ? "존재함" : "없음")")
      if let reservationList = state.activityDetail?.reservationList {
        print("📊 예약 리스트 개수: \(reservationList.count)")
        for (index, reservation) in reservationList.enumerated() {
          print("📊 예약 \(index): \(reservation.itemName), 시간대 \(reservation.times.count)개")
          for time in reservation.times {
            print("📊   - \(time.time): \(time.isReserved ? "예약됨" : "예약가능")")
          }
        }
      }
      
      // UI 강제 새로고침 트리거
      refreshTrigger += 1
      print("🔄 UI 강제 새로고침 트리거: \(refreshTrigger)")
    }
  }
  
  var body: some View {
    ZStack(alignment: .top) {
      // 스크롤 뷰와 이미지 슬라이더
      ScrollView(showsIndicators: false) {
        // 스크롤 오프셋 추적을 위한 GeometryReader
        //        GeometryReader { geometry in
        //          Color.clear
        //            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
        //        }
        //        .frame(height: 0)
        
        LazyVStack(alignment: .leading, spacing: 0, pinnedViews: []) {
          // MARK: - 배경 이미지 (스테이터스 바까지 확장)
          ZStack(alignment: .bottom) {
            if let detail = state.activityDetail, !detail.thumbnails.isEmpty {
              TabView(selection: $selectedImageIndex) {
                ForEach(Array(detail.thumbnails.enumerated()), id: \.offset) { index, thumbnail in
                  ActivityCardMediaView(url: thumbnail)
                    .tag(index)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(16/9, contentMode: .fill)
                }
              }
              .frame(height: 400)
              .tabViewStyle(PageTabViewStyle())
              .ignoresSafeArea(edges: .top) // 스테이터스 바까지 확장
            } else {
              Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 400)
                .overlay(
                  Text("이미지 없음")
                    .foregroundColor(.gray)
                )
                .ignoresSafeArea(edges: .top) // 스테이터스 바까지 확장
            }
            
            
            // 그라데이션 오버레이
            LinearGradient(
              colors: [
                Color.clear,
                CVCColor.grayScale0.opacity(0.1),
                CVCColor.grayScale0.opacity(0.3),
                CVCColor.grayScale0.opacity(0.6),
                CVCColor.grayScale0.opacity(0.8),
                CVCColor.grayScale0.opacity(0.9),
                CVCColor.grayScale0
              ],
              startPoint: .top,
              endPoint: .bottom
            )
            .frame(height: 200)
            .allowsHitTesting(false)
          }
          
          // MARK: - 액티비티 내용
          VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 14) {
              /// 1. 제목
              Text(state.activityDetail?.title ?? activityData.title)
                .activityTitleStyle(CVCColor.grayScale90)
              
              /// 2. 국가
              Text(state.activityDetail?.country ?? activityData.country)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(CVCColor.grayScale60)
            }
            
            /// 3. 태그
            if let tags = state.activityDetail?.tags, !tags.isEmpty {
              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                  ForEach(tags, id: \.self) { tag in
                    TagView(text: tag)
                  }
                }
              }
            }
            
            /// 4. 설명
            if let description = state.activityDetail?.description {
              Text(description)
                .font(.system(size: 12))
                .foregroundColor(CVCColor.grayScale60)
                .lineSpacing(3)
            }
            
            /// 5. 누적
            HStack(spacing: 12) {
              HStack(spacing: 2) {
                CVCImage.Action.buy.template
                  .frame(width: 14, height: 14)
                Text("누적 구매 \(state.activityDetail?.totalOrderCount ?? 0)회")
                  .font(.system(size: 12))
              }
              .foregroundStyle(CVCColor.grayScale60)
              
              HStack(spacing: 2) {
                CVCImage.Action.keep.template
                  .frame(width: 14, height: 14)
                  .foregroundStyle(CVCColor.grayScale60)
                Text("KEEP \(state.activityDetail?.keepCount ?? 0)회")
                  .font(.system(size: 12))
              }
              .foregroundStyle(CVCColor.grayScale60)
            }
            
            ActivityLimitView(
              ageLimit: state.activityDetail?.restrictions?.minAge,
              heightLimit: state.activityDetail?.restrictions?.minHeight,
              maxParticipants: state.activityDetail?.restrictions?.maxParticipants
            )
            
            // MARK: - 가격 정보
            VStack(alignment: .leading, spacing: 12) {
              let original = state.activityDetail?.price.original ?? 0
              let final = state.activityDetail?.price.final ?? 0
              let percentage = original == 0 || final >= original ? 0 : Int(Double(original - final) / Double(original) * 100)
              if original != final {
                Text("\(original)원")
                  .priceOriginalStyle()
                  .strikethrough()
              }
              HStack(spacing: 12) {
                Text("판매가")
                  .activityTitleStyle(CVCColor.grayScale45)
                Text("\(final)원")
                  .priceFinalStyle(isPercentage: false)
                if original != final {
                  Text("\(percentage)%")
                    .priceFinalStyle(isPercentage: true)
                }
              }
            }
            
            // MARK: - 커리큘럼
            if let schedule = state.activityDetail?.schedule {
              ActivityCurriculumView(
                items: schedule.map { detailSchedule in
                  CurriculumItem(
                    time: detailSchedule.duration,
                    title: detailSchedule.description,
                    description: nil
                  )
                },
                location: state.activityDetail?.geolocation.map { geo in
                  CurriculumLocation(
                    name: "\(state.activityDetail?.country ?? ""), \(state.activityDetail?.title ?? "")",
                    address: "위치: \(geo.latitude), \(geo.longitude)",
                    mapImage: nil
                  )
                }
              )
            }
            
            // MARK: - 예약
            if let reservationList = state.activityDetail?.reservationList {
              ActivityReservationView(
                availableDates: reservationList.enumerated().map { index, reservation in
                  // 서버에서 받은 날짜 문자열 파싱 (예: "2025-08-05")
                  let dateFormatter = DateFormatter()
                  dateFormatter.dateFormat = "yyyy-MM-dd"
                  let date = dateFormatter.date(from: reservation.itemName) ?? Date()
                  
                  let calendar = Calendar.current
                  let month = calendar.component(.month, from: date)
                  let day = calendar.component(.day, from: date)
                  
                  let dayFormatter = DateFormatter()
                  dayFormatter.locale = Locale(identifier: "ko_KR")
                  dayFormatter.dateFormat = "E"
                  let dayOfWeek = dayFormatter.string(from: date)
                  
                  return ReservationDate(
                    id: reservation.itemName,
                    month: month,
                    day: day,
                    dayOfWeek: dayOfWeek,
                    timeSlots: reservation.times.enumerated().map { timeIndex, timeSlot in
                      let timeComponents = timeSlot.time.split(separator: ":").map { String($0) }
                      let hour = Int(timeComponents.first ?? "0") ?? 0
                      let minute = Int(timeComponents.last ?? "0") ?? 0
                      
                      return TimeSlot(
                        id: "\(reservation.itemName)-\(timeSlot.time)",
                        hour: hour,
                        minute: minute,
                        isAvailable: !timeSlot.isReserved,
                        isSelected: false
                      )
                    },
                    isAvailable: true
                  )
                },
                onReservationChanged: { date, timeSlot in
                  selectedDate = date.id  // 실제 날짜 문자열 (예: "2025-08-05")
                  selectedTime = timeSlot?.displayTime  // 시간 (예: "10:00")
                  print("선택된 예약: 날짜=\(selectedDate ?? "없음"), 시간=\(selectedTime ?? "없음")")
                }
              )
              .id(refreshTrigger) // refreshTrigger 변경 시 뷰 재생성
            } else {
              Text("예약 가능한 날짜가 없습니다.")
                .foregroundColor(CVCColor.grayScale45)
                .padding()
            }
            
            // MARK: - 크리에이터 정보
            if let creator = state.activityDetail?.creator {
              ActivityCreatorView(
                creator: CreatorInfo(
                  userId: creator.userId,
                  nickname: creator.nick,
                  profileImage: creator.profileImage,
                  introduction: creator.introduction
                ),
                onContactTap: {
                  handleIntent(.navigateToChat(userId: creator.userId, nickname: creator.nick))
                }
              )
            }
            
            Spacer(minLength: 100)
          }
          .padding(.horizontal, 16)
          .padding(.top, 0) // 상단 패딩 제거
        }
      }
      .coordinateSpace(name: "scroll")
      .ignoresSafeArea(edges: .top) // ScrollView 자체도 상단 safe area 무시
      .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
        scrollOffset = offset
        withAnimation(.easeInOut(duration: 0.2)) {
          showNavBarTitle = offset < -200
        }
      }
      
      // MARK: - 결제 버튼
      VStack {
        Spacer()
        HStack {
          if let detail = state.activityDetail {
            Text("\(detail.price.final)원")
              .priceStyle()
              .foregroundColor(CVCColor.grayScale90)
          } else {
            Text(activityData.price)
              .font(.system(size: 20, weight: .bold))
              .foregroundColor(.black)
          }
          
          Spacer()
          
          Button(isOrderInProgress ? "주문 중..." : "결제하기") {
            Task {
              await handleOrderSubmission()
            }
          }
          .disabled(isOrderInProgress || selectedDate == nil || selectedTime == nil)
          .padding(.horizontal, 32)
          .padding(.vertical, 12)
          .background(
            (selectedDate != nil && selectedTime != nil && !isOrderInProgress) 
            ? CVCColor.primary 
            : CVCColor.grayScale30
          )
          .foregroundColor(
            (selectedDate != nil && selectedTime != nil && !isOrderInProgress) 
            ? CVCColor.grayScale0 
            : CVCColor.grayScale60
          )
          .cornerRadius(25)
          .font(.system(size: 16, weight: .semibold))
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .background(Color.white)
//        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: -2)
      }
      
      
      // MARK: - 고정 네비게이션 바 (ScrollView 바깥)
      VStack {
        HStack {
          navBarButtonView(for: .back(action: {
            dismiss()
          }))
          
          Spacer()
          
          navBarButtonView(for: .like(isLiked: isLiked, action: {
            isLiked.toggle()
          }))
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        
        Spacer()
      }
    }
    //    .edgesIgnoringSafeArea(.all) // 모든 안전 영역 무시
    .navigationBarHidden(true)
    .onAppear {
      print("🎯 ActivityDetailView appeared!")
      print("🎯 Activity data: \(activityData.title)")
      print("🎯 Activity ID: \(activityData.activityId)")
      tabVisibilityStore.setVisibility(false)
      handleIntent(.loadActivityDetail(activityData.activityId))
    }
    .navigationDestination(isPresented: $showChatView) {
      ChatView(roomId: "temp_\(chatUserId)", opponentNick: chatNickname)
        .environmentObject(tabVisibilityStore)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarHidden(true) // ChatView에서도 네비게이션 바 숨김
    }
    .sheet(isPresented: $showPaymentView) {
      if let orderResponse = currentOrderResponse {
        IamportPaymentView(
          orderResponse: orderResponse,
          activityTitle: activityData.title,
          onPaymentResult: handlePaymentResult
        )
      }
    }
    .alert("결제 결과", isPresented: $showPaymentSuccessAlert) {
      Button("확인", role: .cancel) {
        showPaymentSuccessAlert = false
      }
    } message: {
      Text(paymentSuccessMessage)
    }
  }
}

// MARK: - ScrollOffsetPreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}


// MARK: - DetailPlayerView
class DetailPlayerView: UIView {
  override static var layerClass: AnyClass { AVPlayerLayer.self }
  
  var player: AVPlayer? {
    get { playerLayer.player }
    set {
      playerLayer.player = newValue
      if newValue != nil {
        setupVideoTransform()
      }
    }
  }
  
  private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
  private var gravity: PlayerGravity = .aspectFill
  
  convenience init(player: AVPlayer, gravity: PlayerGravity, showControls: Bool = true) {
    self.init()
    self.gravity = gravity
    self.player = player
    
    switch gravity {
    case .aspectFill:
      playerLayer.videoGravity = .resizeAspectFill
    case .resize:
      playerLayer.videoGravity = .resize
    case .customFit:
      playerLayer.videoGravity = .resizeAspect
    }
    
    clipsToBounds = true
    
    if showControls {
      setupCustomControls()
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if gravity == .customFit {
      setupVideoTransform()
    }
  }
  
  private func setupVideoTransform() {
    guard let player = player,
          let playerItem = player.currentItem,
          let videoTrack = playerItem.tracks.first(where: { $0.assetTrack?.mediaType == .video })?.assetTrack else {
      return
    }
    
    let targetSize = bounds.size
    
    // iOS 16.0에서 naturalSize와 preferredTransform deprecated, load() 사용
    if #available(iOS 16.0, *) {
      Task {
        do {
          let naturalSize = try await videoTrack.load(.naturalSize)
          let preferredTransform = try await videoTrack.load(.preferredTransform)
          let originalSize = naturalSize.applying(preferredTransform)
          let correctedSize = CGSize(width: abs(originalSize.width), height: abs(originalSize.height))
          
          let scale = max(targetSize.width / correctedSize.width, targetSize.height / correctedSize.height)
          let translateX = (targetSize.width - correctedSize.width * scale) / 2
          let translateY = (targetSize.height - correctedSize.height * scale) / 2
          
          let transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: translateX, y: translateY)
          
          DispatchQueue.main.async { [weak self] in
            self?.playerLayer.setAffineTransform(transform)
          }
        } catch {
          print("비디오 트랙 로드 실패: \(error)")
        }
      }
      return
    } else {
      let originalSize = videoTrack.naturalSize.applying(videoTrack.preferredTransform)
      let correctedSize = CGSize(width: abs(originalSize.width), height: abs(originalSize.height))
      
      let scale = max(targetSize.width / correctedSize.width, targetSize.height / correctedSize.height)
      let translateX = (targetSize.width - correctedSize.width * scale) / 2
      let translateY = (targetSize.height - correctedSize.height * scale) / 2
      
      let transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: translateX, y: translateY)
      
      DispatchQueue.main.async { [weak self] in
        self?.playerLayer.setAffineTransform(transform)
      }
    }
  }
  
  private func setupCustomControls() {
    // 재생/일시정지 버튼
    let playButton = UIButton(type: .system)
    playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    playButton.tintColor = .white
    playButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    playButton.layer.cornerRadius = 25
    playButton.translatesAutoresizingMaskIntoConstraints = false
    
    playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
    
    addSubview(playButton)
    
    NSLayoutConstraint.activate([
      playButton.centerXAnchor.constraint(equalTo: centerXAnchor),
      playButton.centerYAnchor.constraint(equalTo: centerYAnchor),
      playButton.widthAnchor.constraint(equalToConstant: 50),
      playButton.heightAnchor.constraint(equalToConstant: 50)
    ])
    
    // 탭 제스처로 컨트롤 토글
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    addGestureRecognizer(tapGesture)
  }
  
  @objc private func playButtonTapped() {
    guard let player = player else { return }
    
    if player.timeControlStatus == .playing {
      player.pause()
      updatePlayButton(isPlaying: false)
    } else {
      player.play()
      updatePlayButton(isPlaying: true)
    }
  }
  
  @objc private func handleTap() {
    // 탭으로 재생/일시정지 토글
    playButtonTapped()
  }
  
  func updatePlayButton(isPlaying: Bool) {
    if let playButton = subviews.first(where: { $0 is UIButton }) as? UIButton {
      let imageName = isPlaying ? "pause.fill" : "play.fill"
      playButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
  }
  
  deinit {
    player?.pause()
    player = nil
  }
}

// MARK: - DetailVideoPlayerView
struct DetailVideoPlayerView: UIViewRepresentable {
  let url: String
  
  func makeUIView(context: Context) -> UIView {
    // ImageLoadHelper와 정확히 동일한 방식으로 URL 변환
    let endpoint = ActivityEndpoint(requestType: .newActivity())
    let fullVideoURL: String
    if url.lowercased().hasPrefix("http") {
      fullVideoURL = url
    } else {
      let baseURLString = endpoint.baseURL.hasSuffix("/") ? String(endpoint.baseURL.dropLast()) : endpoint.baseURL
      fullVideoURL = "\(baseURLString)/v1\(url)"
    }
    
    print("🎬 비디오 URL 변환 시도:")
    print("   입력 URL: \(url)")
    print("   Base URL: \(endpoint.baseURL)")
    print("   최종 URL: \(fullVideoURL)")
    
    guard let videoURL = URL(string: fullVideoURL) else {
      let errorView = UIView()
      errorView.backgroundColor = UIColor.systemGray5
      
      let stackView = UIStackView()
      stackView.axis = .vertical
      stackView.alignment = .center
      stackView.spacing = 8
      
      let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
      imageView.tintColor = .orange
      imageView.contentMode = .scaleAspectFit
      
      let label = UILabel()
      label.text = "잘못된 비디오 URL"
      label.textColor = .gray
      
      stackView.addArrangedSubview(imageView)
      stackView.addArrangedSubview(label)
      
      errorView.addSubview(stackView)
      stackView.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        stackView.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
        stackView.centerYAnchor.constraint(equalTo: errorView.centerYAnchor)
      ])
      
      print("❌ 잘못된 비디오 URL: \(url) -> \(fullVideoURL)")
      return errorView
    }
    
    // AVPlayer 생성 전에 URL 유효성 검사
    print("🎬 AVPlayer 생성 시도: \(videoURL.absoluteString)")
    
    let player = AVPlayer(url: videoURL)
    let playerView = DetailPlayerView(player: player, gravity: .aspectFill, showControls: true)
    
    // 플레이어 상태 관찰
    player.currentItem?.addObserver(context.coordinator, forKeyPath: "status", options: [.new], context: nil)
    
    context.coordinator.player = player
    
    // 비디오 로드 시도 및 자동 재생
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      if let currentItem = player.currentItem {
        print("🎬 플레이어 아이템 상태: \(currentItem.status.rawValue)")
        if currentItem.status == .failed {
          if let error = currentItem.error {
            print("❌ 비디오 로드 실패: \(error.localizedDescription)")
          }
        } else if currentItem.status == .readyToPlay {
          print("✅ 비디오 로드 성공!")
          // 자동 재생 시작
          player.play()
          if let playerView = playerView as? DetailPlayerView {
            playerView.updatePlayButton(isPlaying: true)
          }
        }
      }
    }
    
    print("✅ AVFoundation 비디오 플레이어 설정: \(url) -> \(fullVideoURL)")
    
    return playerView
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  class Coordinator: NSObject {
    var player: AVPlayer?
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      if keyPath == "status" {
        if let playerItem = object as? AVPlayerItem {
          switch playerItem.status {
          case .readyToPlay:
            print("✅ 비디오 재생 준비 완료")
          case .failed:
            print("❌ 비디오 재생 실패: \(playerItem.error?.localizedDescription ?? "알 수 없는 오류")")
          case .unknown:
            print("🔄 비디오 상태 알 수 없음")
          @unknown default:
            break
          }
        }
      }
    }
    
    deinit {
      player?.currentItem?.removeObserver(self, forKeyPath: "status")
      player?.pause()
      player = nil
    }
  }
}


// MARK: - Preview
struct ActivityDetailView_Previews: PreviewProvider {
  static var previews: some View {
    ActivityDetailView(
      activityData: ActivityInfoData(
        activityId: "preview_activity_1",
        imageName: "mountain_activity",
        price: "89,000원",
        isLiked: false,
        title: "제주도 한라산 등반 체험",
        country: "대한민국",
        category: "등반",
        tags: ["등반", "제주도", "한라산", "가이드동행"],
        originalPrice: "100,000원",
        discountRate: 11
      )
    )
    .environment(\.activityDetailClient, .mock)
  }
}
