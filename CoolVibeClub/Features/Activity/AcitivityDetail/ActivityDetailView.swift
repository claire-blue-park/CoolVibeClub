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
  
  @StateObject private var store: ActivityDetailStore
  
  init(activityData: ActivityInfoData, activityDetailClient: ActivityDetailClient = .live) {
    self.activityData = activityData
    _store = StateObject(wrappedValue: ActivityDetailStore(activityDetailClient: activityDetailClient))
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
            if let detail = store.state.activityDetail, !detail.thumbnails.isEmpty {
              TabView(selection: Binding(
                get: { store.state.selectedImageIndex },
                set: { store.send(.setSelectedImageIndex($0)) }
              )) {
                ForEach(Array(detail.thumbnails.enumerated()), id: \.offset) { index, thumbnail in
                  ActivityCardMediaView(
                    url: thumbnail,
                    endpoint: ActivityEndpoint(requestType: .newActivity())
                  )
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
              Text(store.state.activityDetail?.title ?? activityData.title)
                .activityTitleStyle(CVCColor.grayScale90)
              
              /// 2. 국가
              Text(store.state.activityDetail?.country ?? activityData.country)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(CVCColor.grayScale60)
            }
            
            /// 3. 태그
            if let tags = store.state.activityDetail?.tags, !tags.isEmpty {
              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                  ForEach(tags, id: \.self) { tag in
                    TagView(text: tag)
                  }
                }
              }
            }
            
            /// 4. 설명
            if let description = store.state.activityDetail?.description {
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
                Text("누적 구매 \(store.state.activityDetail?.totalOrderCount ?? 0)회")
                  .font(.system(size: 12))
              }
              .foregroundStyle(CVCColor.grayScale60)
              
              HStack(spacing: 2) {
                CVCImage.Action.keep.template
                  .frame(width: 14, height: 14)
                  .foregroundStyle(CVCColor.grayScale60)
                Text("KEEP \(store.state.activityDetail?.keepCount ?? 0)회")
                  .font(.system(size: 12))
              }
              .foregroundStyle(CVCColor.grayScale60)
            }
            
            ActivityLimitView(
              ageLimit: store.state.activityDetail?.restrictions?.minAge,
              heightLimit: store.state.activityDetail?.restrictions?.minHeight,
              maxParticipants: store.state.activityDetail?.restrictions?.maxParticipants
            )
            
            // MARK: - 가격 정보
            VStack(alignment: .leading, spacing: 12) {
              let original = store.state.activityDetail?.price.original ?? 0
              let final = store.state.activityDetail?.price.final ?? 0
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
            if let schedule = store.state.activityDetail?.schedule {
              ActivityCurriculumView(
                items: schedule.map { detailSchedule in
                  CurriculumItem(
                    time: detailSchedule.duration,
                    title: detailSchedule.description,
                    description: nil
                  )
                },
                location: store.state.activityDetail?.geolocation.map { geo in
                  CurriculumLocation(
                    name: "\(store.state.activityDetail?.country ?? ""), \(store.state.activityDetail?.title ?? "")",
                    address: "위치: \(geo.latitude), \(geo.longitude)",
                    mapImage: nil
                  )
                }
              )
            }
            
            // MARK: - 예약
            if let reservationList = store.state.activityDetail?.reservationList {
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
                  store.send(.setSelectedDate(date.id))
                  store.send(.setSelectedTime(timeSlot?.displayTime))
                  print("선택된 예약: 날짜=\(store.state.selectedDate ?? "없음"), 시간=\(store.state.selectedTime ?? "없음")")
                }
              )
              .id(store.state.refreshTrigger) // refreshTrigger 변경 시 뷰 재생성
            } else {
              Text("예약 가능한 날짜가 없습니다.")
                .foregroundColor(CVCColor.grayScale45)
                .padding()
            }
            
            // MARK: - 크리에이터 정보
            if let creator = store.state.activityDetail?.creator {
              ActivityCreatorView(
                creator: CreatorInfo(
                  userId: creator.userId,
                  nickname: creator.nick,
                  profileImage: creator.profileImage,
                  introduction: creator.introduction
                ),
                onContactTap: {
                  store.send(.navigateToChat(userId: creator.userId, nickname: creator.nick))
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
        store.send(.setScrollOffset(offset))
        withAnimation(.easeInOut(duration: 0.2)) {
          store.send(.setShowNavBarTitle(offset < -200))
        }
      }
      
      // MARK: - 결제 버튼
      VStack {
        Spacer()
        HStack {
          if let detail = store.state.activityDetail {
            Text("\(detail.price.final)원")
              .priceStyle()
              .foregroundColor(CVCColor.grayScale90)
          } else {
            Text(activityData.price)
              .font(.system(size: 20, weight: .bold))
              .foregroundColor(.black)
          }
          
          Spacer()
          
          Button(store.state.isOrderInProgress ? "주문 중..." : "결제하기") {
            store.send(.submitOrder)
          }
          .disabled(store.state.isOrderInProgress || store.state.selectedDate == nil || store.state.selectedTime == nil)
          .padding(.horizontal, 32)
          .padding(.vertical, 12)
          .background(
            (store.state.selectedDate != nil && store.state.selectedTime != nil && !store.state.isOrderInProgress) 
            ? CVCColor.primary 
            : CVCColor.grayScale30
          )
          .foregroundColor(
            (store.state.selectedDate != nil && store.state.selectedTime != nil && !store.state.isOrderInProgress) 
            ? CVCColor.grayScale0 
            : CVCColor.grayScale60
          )
          .cornerRadius(25)
          .font(.system(size: 16, weight: .semibold))
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .background(Color.white)
      }
      .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 6)
      .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
      
      
      // MARK: - 고정 네비게이션 바 (ScrollView 바깥)
      VStack {
        HStack {
          navBarButtonView(for: .back(action: {
            dismiss()
          }))
          
          Spacer()
          
          navBarButtonView(for: .like(isLiked: store.state.isLiked, action: {
            store.send(.setIsLiked(!store.state.isLiked))
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
      store.send(.loadActivityDetail(activityData.activityId))
    }
    .navigationDestination(isPresented: Binding(
      get: { store.state.showChatView },
      set: { _ in store.send(.clearNavigation) }
    )) {
      ChatView(roomId: "temp_\(store.state.chatUserId)", opponentNick: store.state.chatNickname)
        .environmentObject(tabVisibilityStore)
        .toolbar(.hidden, for: .tabBar)
        .navigationBarHidden(true) // ChatView에서도 네비게이션 바 숨김
    }
    .sheet(isPresented: Binding(
      get: { store.state.showPaymentView },
      set: { store.send(.setShowPaymentView($0)) }
    )) {
      if let orderResponse = store.state.currentOrderResponse {
        IamportPaymentView(
          orderResponse: orderResponse,
          activityTitle: activityData.title,
          onPaymentResult: { response in
            store.send(.handlePaymentResult(response))
          }
        )
      }
    }
    .alert("결제 결과", isPresented: Binding(
      get: { store.state.showPaymentSuccessAlert },
      set: { store.send(.setShowPaymentSuccessAlert($0)) }
    )) {
      Button("확인", role: .cancel) {
        store.send(.setShowPaymentSuccessAlert(false))
      }
    } message: {
      Text(store.state.paymentSuccessMessage)
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
      ),
      activityDetailClient: .mock
    )
  }
}
