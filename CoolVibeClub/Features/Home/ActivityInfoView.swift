//
//  ActivityInfoView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import AVKit

struct ActivityInfoView: View {
  @State private var currentIndex = 0
  @State private var dragOffset: CGFloat = 0
  @State var activities: [ActivityInfoData]
  @State private var isLoading = false
  @State private var errorMessage: String? = nil
  
  private let cardWidth: CGFloat = 344
  private let cardGap: CGFloat = 0
  
  private var infiniteActivities: [ActivityInfoData] {
    activities + activities + activities
  }

  var body: some View {
    VStack {
      // 2 - 2. 액티비티 스크롤 영역
      if isLoading {
        ProgressView()
          .frame(height: cardWidth)
      } else if activities.isEmpty {
        // 데이터가 없을 때는 아무것도 표시하지 않음
        EmptyView()
      } else {
        GeometryReader { geometry in
          let cardWidth: CGFloat = cardWidth
          let spacing: CGFloat = 0
          
          HStack(spacing: spacing) {
            ForEach(infiniteActivities.indices, id: \.self) { index in
              ActivityCardView(activity: infiniteActivities[index], cardWidth: cardWidth, cardGap: cardGap)
                .frame(width: cardWidth)
                .scaleEffect(getScale(for: index))
                .zIndex(getZIndex(for: index))
            }
          }
          .offset(x: calculateOffset(geometry: geometry, cardWidth: cardWidth, spacing: spacing))
          .gesture(
            DragGesture()
              .onChanged { value in
                dragOffset = value.translation.width
              }
              .onEnded { value in
                handleDragEnd(value: value, cardWidth: cardWidth, spacing: spacing)
              }
          )
        }
        .frame(height: cardWidth)
      }
    }
  }
  
  private func getScale(for index: Int) -> CGFloat {
    let cardWidthWithSpacing: CGFloat = cardWidth + cardGap // 카드 너비 + 간격
    let distance = abs(CGFloat(index - currentIndex) * cardWidthWithSpacing + dragOffset)
    
    let maxDistance: CGFloat = cardWidthWithSpacing * 10
    let scale = 1.0 - (min(distance, maxDistance) / maxDistance) * 0.8
    
    return max(0.7, min(1.1, scale))
  }
  
  private func getZIndex(for index: Int) -> CGFloat {
    let cardWidthWithSpacing: CGFloat = cardWidth + cardGap // 카드 너비 + 간격
    let distance = abs(CGFloat(index - currentIndex) * cardWidthWithSpacing + dragOffset)
    
    let maxDistance: CGFloat = cardWidthWithSpacing * 10
    let zIndex = 1.0 - (min(distance, maxDistance) / maxDistance) * 0.8
    
    return max(0.7, min(1.1, zIndex))
  }
  
  private func calculateOffset(geometry: GeometryProxy, cardWidth: CGFloat, spacing: CGFloat) -> CGFloat {
    let screenWidth = geometry.size.width
    let cardWidthWithSpacing = cardWidth + spacing
    let baseOffset = -CGFloat(currentIndex) * cardWidthWithSpacing
    let centeringOffset = (screenWidth - cardWidth) / 2
    
    return baseOffset + dragOffset + centeringOffset
  }
  
  private func handleDragEnd(value: DragGesture.Value, cardWidth: CGFloat, spacing: CGFloat) {
    let threshold: CGFloat = 50
    let velocity = value.predictedEndTranslation.width - value.translation.width
    
    withAnimation(.easeOut(duration: 0.3)) {
      // 속도를 고려한 스와이프 처리
      if value.translation.width > threshold || (abs(velocity) > 100 && velocity > 0) {
        currentIndex = max(0, currentIndex - 1)
      } else if value.translation.width < -threshold || (abs(velocity) > 100 && velocity < 0) {
        currentIndex = min(infiniteActivities.count - 1, currentIndex + 1)
      }
      
      dragOffset = 0
    }
  }
}

private struct ActivityCardView: View {
  let activity: ActivityInfoData
  @State private var mediaResult: MediaResult?
  @State private var isLoading = true
  @State private var navigateToDetail = false
  @State private var activityDetail: ActivityInfoData? = nil
  @State private var isLoadingDetail = false
  @State private var detailErrorMessage: String? = nil
  @State private var player: AVPlayer?
  
  let cardWidth: CGFloat
  let cardGap: CGFloat
  
  var body: some View {
    ZStack(alignment: .bottom) {
      // 배경 미디어
      if !activity.imageName.isEmpty {
        Group {
          if isLoading {
            Rectangle()
              .fill(CVCColor.grayScale30)
          } else if let media = mediaResult {
            switch media {
            case .image(let uiImage):
              Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
            case .video(let url):
              VideoPlayer(player: player)
                .scaledToFill()
                .disabled(true) // 비디오 클릭 비활성화 (탭은 상세 페이지로 이동)
            case .failure:
              Rectangle()
                .fill(CVCColor.grayScale30)
            }
          } else {
            Rectangle()
              .fill(CVCColor.grayScale30)
          }
        }
        .frame(width: cardWidth, height: cardWidth)
        .clipped()
        .onAppear {
          loadMedia()
        }
        .onDisappear {
          player?.pause()
          player = nil
        }
      } else {
        Rectangle()
          .fill(CVCColor.grayScale30)
          .frame(width: cardWidth, height: cardWidth)
      }
      
      // 그라데이션 오버레이 (텍스트 가독성 향상)
      LinearGradient(
        gradient: Gradient(colors: [
          Color.clear,
          CVCColor.grayScale100.opacity(0.1),
          CVCColor.grayScale100.opacity(0.6)
        ]),
        startPoint: .top,
        endPoint: .bottom
      )
      .frame(width: cardWidth, height: cardWidth)
      
      // 컨텐츠
      VStack(spacing: 8) {
        // 위치 태그
        HStack(spacing: 4) {
          CVCImage.location.template
            .frame(width: 12, height: 12)
          
          Text("\(activity.country) \(activity.category)")
            .font(.system(size: 11, weight: .medium))
        }
        .foregroundColor(CVCColor.grayScale15)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background {
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        Spacer()
        
        // 제목
        Text(activity.title)
          .activityTitleStyle()
          .foregroundStyle(CVCColor.grayScale0)
          .frame(maxWidth: .infinity, alignment: .leading)
        
        // 가격
        HStack {
          CVCImage.won.template
            .frame(width: 16, height: 16)
            .foregroundStyle(CVCColor.grayScale0)
          
          Text("\(activity.price)")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: 14))
            .foregroundStyle(Color.white)
            .fontWeight(.bold)
        }       
      }
      .padding(20)
      .frame(width: cardWidth, height: cardWidth, alignment: .bottom)
    }
    .frame(width: cardWidth, height: cardWidth)
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
    .transition(.scale)
    .onTapGesture {
      fetchActivityDetail()
    }
    .overlay {
      if isLoadingDetail {
        Color.black.opacity(0.3)
          .cornerRadius(24)
          .overlay {
            ProgressView()
              .tint(.white)
              .scaleEffect(1.5)
          }
      }
    }
    .navigationDestination(isPresented: $navigateToDetail) {
      if let detail = activityDetail {
        ActivityDetailView(activityData: detail)
      } else {
        Text("상세 정보를 불러올 수 없습니다.")
      }
    }
    .alert("오류", isPresented: Binding(
      get: { detailErrorMessage != nil },
      set: { if !$0 { detailErrorMessage = nil } }
    )) {
      Button("확인", role: .cancel) {}
    } message: {
      if let errorMessage = detailErrorMessage {
        Text(errorMessage)
      }
    }
  }
  
  // 액티비티 상세 정보 가져오기
  private func fetchActivityDetail() {
    activityDetail = activity
    navigateToDetail = true
  }
  
  // ImageLoadHelper를 사용한 미디어 로딩
  private func loadMedia() {
    guard !activity.imageName.isEmpty else {
      isLoading = false
      return
    }
    
    let endpoint = ActivityEndpoint(requestType: .newActivity())
    
    ImageLoadHelper.shared.loadMediaWithHeaders(
      path: activity.imageName,
      endpoint: endpoint
    ) { result in
      mediaResult = result
      isLoading = false
      if case .video(let videoURL) = result {
        let player = AVPlayer(url: videoURL)
        self.player = player
        player.isMuted = true // Optional: mute video by default
        player.play() // Autoplay the video
        // Loop the video
        NotificationCenter.default.addObserver(
          forName: .AVPlayerItemDidPlayToEndTime,
          object: player.currentItem,
          queue: .main
        ) { _ in
          player.seek(to: .zero)
          player.play()
        }
      }
    }
  }
}
