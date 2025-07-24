//
//  ActivityCard.swift
//  CoolVibeClub
//
//  Created by Claire on 8/6/25.
//

import SwiftUI
import AVFoundation
import AVKit
import UIKit

struct ActivityCard: View {
  let activity: ActivityInfoData
  let image: UIImage?
  @State private var isLiked: Bool
  
  private let imageSectionHeight: CGFloat = 200
  
  init(activity: ActivityInfoData, image: UIImage? = nil) {
    self.activity = activity
    self.image = image
    self._isLiked = State(initialValue: activity.isLiked)
  }
  
  var body: some View {
    VStack(spacing: 12) {
      // Image Section with overlays
      ZStack {
        // Background image or video
        if let image = image {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .frame(height: imageSectionHeight)
            .clipped()
            .cornerRadius(16)
        } else {
          // URL 기반 미디어 표시
          ActivityCardMediaView(url: activity.imageName)
            .frame(maxWidth: .infinity)
            .frame(height: imageSectionHeight)
            .cornerRadius(16)
        }
        
        
        // MARK: - 하트 버튼 (좌상단)
        VStack {
          HStack {
            LikeButton(isLiked: isLiked) { newIsLiked in
              isLiked = newIsLiked
            }
            .padding(.top, 12)
            .padding(.leading, 12)
            
            Spacer()
          }
          
          Spacer()
        }
        
        // MARK: - 위치 뱃지 (우측 최상단)
        VStack {
          HStack {
            Spacer()
            
            HStack(alignment: .center, spacing: 4) {
              Image(systemName: "location.fill")
                .font(.system(size: 8))
                .foregroundColor(CVCColor.grayScale0)
              
              Text(activity.country)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(CVCColor.grayScale0)
                .lineLimit(1)
            }
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .background(
              VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
            )
            .cornerRadius(10)
            .overlay(
              RoundedRectangle(cornerRadius: 10)
                .inset(by: 0.5)
                .stroke(CVCColor.translucent45, lineWidth: 1)
            )
          }
          .padding(.horizontal, 12)
          .padding(.top, 12)
          
          Spacer()
        }
        
        // MARK: - 하단 중앙 뷰 (이미지 하단에 걸리도록)
        //        if !activity.tags.isEmpty {
        //          VStack {
        //            Spacer()
        //            
        //            HStack {
        //              Spacer()
        //              
        //              // 하단 중앙에 위치할 뷰
        //              HStack(alignment: .center, spacing: 4) {
        //                CVCImage.flame.template
        //                  .frame(width: 12, height: 12)
        //                  .foregroundColor(CVCColor.grayScale0)
        //                
        //                Text(activity.tags.first ?? "")
        //                  .font(.system(size: 10, weight: .semibold))
        //                  .foregroundColor(CVCColor.grayScale0)
        //              }
        //              .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        //              .background(
        //                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        //                  .cornerRadius(8)
        //              )
        //              .overlay(
        //                RoundedRectangle(cornerRadius: 8)
        //                  .inset(by: 0.5)
        //                  .stroke(CVCColor.grayScale0, lineWidth: 1)
        //              )
        //              .offset(y: 10)
        //              
        //              Spacer()
        //            }
        //          }
        //        }
        //        
        
        
        
        // MARK: - HOT/NEW 뱃지 (좌하단)
        VStack {
          Spacer()
          
          HStack {
            if !activity.tags.isEmpty  {
              //              VStack {
              //                Spacer()
              //                
              //                HStack {
              //                  Spacer()
              
              // 하단 중앙에 위치할 뷰
              HStack(alignment: .center, spacing: 4) {
                CVCImage.flame.template
                  .frame(width: 12, height: 12)
                  .foregroundColor(CVCColor.grayScale0)
                
                Text(activity.tags.first ?? "")
                  .font(.system(size: 10, weight: .semibold))
                  .foregroundColor(CVCColor.grayScale0)
              }
              .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
              .background(
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
              )
              .cornerRadius(4)
              .overlay(
                RoundedRectangle(cornerRadius: 4)
                  .inset(by: 0.5)
                  .stroke(CVCColor.translucent45, lineWidth: 1)
              )
              //                  .offset(y: 10)
              
              //                  Spacer()
            }
            
            //              }
            //            }
            
            Spacer()
            
            // MARK: - 광고 뱃지 (우하단)
            
            HStack(spacing: 4) {
              CVCImage.info.template
                .frame(width: 12, height: 12)
                .foregroundColor(CVCColor.grayScale0)
              
              Text("AD")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(CVCColor.grayScale0)
              
            }
            .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
            .background(
              VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
              
            )
            .cornerRadius(10)
            .overlay(
              RoundedRectangle(cornerRadius: 10)
                .inset(by: 0.5)
                .stroke(CVCColor.translucent45, lineWidth: 1)
            )
          }
        }
        .padding(12)
      }
      .frame(maxWidth: .infinity)
      .frame(height: imageSectionHeight)
      
      // MARK: - 내용 영역
      VStack(alignment: .leading, spacing: 8) {
        // MARK: - 제목
        Text(activity.title)
          .font(.system(size: 16, weight: .bold))
          .foregroundColor(CVCColor.grayScale90)
          .multilineTextAlignment(.leading)
        
        // MARK: - 설명 (태그 기반)
        Text(activity.tags.isEmpty ? "\(activity.category) 액티비티입니다." : activity.tags.prefix(3).joined(separator: " • "))
          .font(.system(size: 12, weight: .regular))
          .foregroundColor(CVCColor.grayScale60)
          .multilineTextAlignment(.leading)
          .lineLimit(3)
        
        // MARK: - 가격 (취소선 자동 조정)
        HStack(alignment: .center, spacing: 8) {
          if activity.discountRate > 0 {
            ZStack {
              Text(activity.originalPrice)
                .priceOriginalStyleInCard()
                .strikethrough()
            }
          }
          
          Text(activity.price)
            .priceFinalStyleInCard(isPercentage: false)
          
          if activity.discountRate > 0 {
            Text("\(activity.discountRate)%")
              .priceFinalStyleInCard(isPercentage: true)
          }
          
          Spacer()
        }
      }
      //      .padding(.horizontal, 16)
    }
    //    .padding(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 10))
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    //        .frame(height: 310)
    //    .background(CVCColor.grayScale0)
  }
}

// MARK: - VisualEffectView for Blur Effect
struct VisualEffectView: UIViewRepresentable {
  let effect: UIVisualEffect
  
  func makeUIView(context: Context) -> UIVisualEffectView {
    UIVisualEffectView(effect: effect)
  }
  
  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    uiView.effect = effect
  }
}

// MARK: - ActivityCardMediaView
//struct ActivityCardMediaView: View {
//  let url: String
//
//  private var isVideo: Bool {
//    let videoExtensions = ["mp4", "mov", "avi", "mkv", "m4v", "webm", "m3u8"]
//
//    if let urlObj = URL(string: url) {
//      let pathExtension = urlObj.pathExtension.lowercased()
//      return videoExtensions.contains(pathExtension)
//    }
//
//    return videoExtensions.contains { url.lowercased().hasSuffix(".\($0)") }
//  }
//
//  var body: some View {
//    if isVideo {
//      // 비디오: AVFoundation 기반 커스텀 플레이어 (블로그 방식)
//      if let videoURL = URL(string: url) {
//        AVFoundationVideoView(url: videoURL, autoPlay: true, showControls: false)
//          .frame(width: 233, height: 120) // 정확한 크기 지정
//          .clipped() // 뷰 경계 넘어가는 부분 자르기
//          .background(Color.clear) // 배경 투명
//          .onAppear {
//            print("✅ 액티비티 카드 AVFoundation 비디오 설정: \(url)")
//          }
//      } else {
//        Rectangle()
//          .fill(CVCColor.grayScale15)
//          .overlay(
//            VStack(spacing: 4) {
//              Image(systemName: "video.slash")
//                .font(.title2)
//                .foregroundColor(.gray)
//              Text("비디오 오류")
//                .font(.caption2)
//                .foregroundColor(.gray)
//            }
//          )
//      }
//    } else {
//      // 이미지: 캐싱된 AsyncImage 사용
//      CachedAsyncImage(
//        url: URL(string: url),
//        endpoint: ActivityEndpoint(requestType: .newActivity),
//        contentMode: .fill
//      ) {
//        Rectangle()
//          .fill(CVCColor.grayScale15)
//          .overlay(
//            ProgressView()
//              .scaleEffect(0.8)
//          )
//      }
//    }
//  }
//}
//
//// MARK: - PlayerView
//class PlayerView: UIView {
//  override static var layerClass: AnyClass { AVPlayerLayer.self }
//
//  var player: AVPlayer? {
//    get { playerLayer.player }
//    set {
//      playerLayer.player = newValue
//      if let newValue = newValue {
//        setupVideoTransform()
//      }
//    }
//  }
//
//  private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
//  private var gravity: PlayerGravity = .aspectFill
//
//  convenience init(player: AVPlayer, gravity: PlayerGravity) {
//    self.init()
//    self.gravity = gravity
//    self.player = player
//
//    // 모든 경우에 resizeAspectFill 사용 (검은 테두리 방지)
//    playerLayer.videoGravity = .resizeAspectFill
//    playerLayer.backgroundColor = UIColor.clear.cgColor
//
//    clipsToBounds = true
//    backgroundColor = .clear
//  }
//
//  override func layoutSubviews() {
//    super.layoutSubviews()
//    playerLayer.frame = bounds
//  }
//
//  func setupVideoTransform() {
//    // customFit에서는 단순히 resizeAspectFill로 처리
//    DispatchQueue.main.async { [weak self] in
//      guard let self = self else { return }
//      self.playerLayer.frame = self.bounds
//      self.playerLayer.videoGravity = .resizeAspectFill
//      print("🎬 비디오 레이어 프레임 설정: \(self.bounds)")
//    }
//  }
//
//  deinit {
//    player = nil
//  }
//}
//
//// MARK: - PlayerGravity
//enum PlayerGravity {
//  case aspectFill  // 비율 유지하면서 뷰 전체 채우기 (기본)
//  case resize      // 비율 무시하고 뷰에 맞게 늘리기
//  case customFit   // 커스텀 transform으로 비율 유지하며 뷰에 꽉 차게
//}
//
//// MARK: - AVFoundation 기반 비디오 뷰 (블로그 방식 적용)
//struct AVFoundationVideoView: UIViewRepresentable {
//  let url: URL
//  let autoPlay: Bool
//  let showControls: Bool
//
//  func makeUIView(context: Context) -> PlayerView {
//    let player = AVPlayer(url: url)
//    let playerView = PlayerView(player: player, gravity: .aspectFill)
//
//    // 비디오 준비 완료 후 transform 적용
//    NotificationCenter.default.addObserver(
//      forName: .AVPlayerItemDidPlayToEndTime,
//      object: player.currentItem,
//      queue: .main
//    ) { [weak playerView] _ in
//      if autoPlay {
//        player.seek(to: .zero)
//        player.play()
//      }
//    }
//
//    // 비디오 상태 변경 관찰
//    player.currentItem?.addObserver(context.coordinator, forKeyPath: "status", options: [.new], context: nil)
//
//    // 자동 재생
//    if autoPlay {
//      // 음소거 상태로 자동 재생 (iOS에서 자동 재생 허용을 위함)
//      player.isMuted = true
//
//      // 비디오가 준비되면 재생 시작
//      if player.currentItem?.status == .readyToPlay {
//        player.play()
//      }
//    }
//
//    // Coordinator에 플레이어와 뷰 저장
//    context.coordinator.player = player
//    context.coordinator.playerView = playerView
//
//    return playerView
//  }
//
//  func updateUIView(_ uiView: PlayerView, context: Context) {
//    // 프레임은 자동으로 처리됨
//  }
//
//  func makeCoordinator() -> Coordinator {
//    Coordinator()
//  }
//
//  class Coordinator: NSObject {
//    var player: AVPlayer?
//    weak var playerView: PlayerView?
//
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//      if keyPath == "status" {
//        if let playerItem = object as? AVPlayerItem {
//          switch playerItem.status {
//          case .readyToPlay:
//            print("✅ 비디오 재생 준비 완료 - transform 적용")
//            DispatchQueue.main.async { [weak self] in
//              self?.playerView?.setupVideoTransform()
//              if self?.player?.timeControlStatus != .playing {
//                self?.player?.play()
//              }
//            }
//          case .failed:
//            print("❌ 비디오 재생 실패: \(playerItem.error?.localizedDescription ?? "알 수 없는 오류")")
//          case .unknown:
//            print("🔄 비디오 상태 알 수 없음")
//          @unknown default:
//            break
//          }
//        }
//      }
//    }
//
//    deinit {
//      player?.currentItem?.removeObserver(self, forKeyPath: "status")
//      player?.pause()
//      player = nil
//    }
//  }
//}
