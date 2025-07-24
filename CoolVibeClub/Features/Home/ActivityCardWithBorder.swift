//
//  ActivityCardWithBorder.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import AVFoundation
import AVKit

struct ActivityCardWithBorder: View {
  let activity: ActivityInfoData
  let image: UIImage?
  @State private var isLiked: Bool
  
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
            .frame(width: 233, height: 120)
            .clipped()
            .cornerRadius(16)
        } else {
          // URL 기반 미디어 표시
          ActivityCardMediaView(url: activity.imageName)
            .frame(width: 233, height: 120)
            .cornerRadius(16)
        }
        
        // Border overlay
        RoundedRectangle(cornerRadius: 16)
          .inset(by: 2)
          .stroke(CVCColor.primaryLight, lineWidth: 4)
          .frame(width: 233, height: 120)
        
        // MARK: - 하트 버튼 (좌상단)
        VStack {
          HStack {
            LikeButton()
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
        
        // MARK: - HOT/NEW 뱃지 (좌하단)
        if !activity.tags.isEmpty {
          VStack {
            Spacer()
            
            HStack {
              HStack(alignment: .center, spacing: 2) {
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
              .padding(.bottom, 12)
              .padding(.leading, 12)
              
              Spacer()
            }
          }
        }
      }
      .frame(width: 233, height: 120)
      
      // MARK: - 내용 영역
      VStack(alignment: .leading, spacing: 8) {
        // MARK: - 제목
        Text(activity.title)
          .font(.system(size: 16, weight: .black))
          .foregroundColor(CVCColor.grayScale90)
          .multilineTextAlignment(.leading)
        
        //        // MARK: - 설명
        //        Text("끝없이 펼쳐진 슬로프, 자유롭게 바람을 가르는 시간. 초보자 코스부터 짜릿한 파크존까지, 당신...")
        //          .font(.system(size: 12, weight: .regular))
        //          .foregroundColor(CVCColor.grayScale60)
        //          .multilineTextAlignment(.leading)
        //          .lineLimit(3)
        
        // MARK: - 가격 (취소선 자동 조정)
        HStack(alignment: .center, spacing: 8) {
          ZStack {
            Text("341,000원")
              .priceOriginalStyleInCard()
              .strikethrough()
            //              .overlay(
            //                Rectangle()
            //                  .frame(height: 1)
            //                  .foregroundColor(CVCColor.primaryDark)
            //                  .offset(y: 0.5)
            //              )
          }
          
          Text(activity.price)
            .priceFinalStyleInCard(isPercentage: false)
          
          Text("63%")
            .priceFinalStyleInCard(isPercentage: true)
          
          Spacer()
        }
      }
      .padding(.horizontal, 16)
      .frame(width: 263)
      
    }
    //    .padding(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 10))
    //    .frame(width: 263, height: 263)
    //    .background(CVCColor.grayScale0)
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

// MARK: - 디버깅용 ActivityCardMediaView
//struct ActivityCardMediaView: View {
//    let url: String
//    @State private var debugInfo: String = ""
//    
//    private var isVideo: Bool {
//        let videoExtensions = ["mp4", "mov", "avi", "mkv", "m4v", "webm", "m3u8"]
//        
//        if let urlObj = URL(string: url) {
//            let pathExtension = urlObj.pathExtension.lowercased()
//            let isVideoFile = videoExtensions.contains(pathExtension)
//            
//            // 디버그 정보 업데이트
//            DispatchQueue.main.async {
//                debugInfo = "Extension: \(pathExtension), IsVideo: \(isVideoFile)"
//            }
//            
//            return isVideoFile
//        }
//        
//        // URL 패턴으로도 체크
//        let hasVideoExtension = videoExtensions.contains { url.lowercased().hasSuffix(".\($0)") }
//        
//        DispatchQueue.main.async {
//            debugInfo = "URL Pattern Check, IsVideo: \(hasVideoExtension)"
//        }
//        
//        return hasVideoExtension
//    }
//    
//    var body: some View {
//        ZStack {
//            if isVideo {
//                // 비디오 처리
//                if let videoURL = URL(string: url) {
//                    AVFoundationVideoView(url: videoURL, autoPlay: true, showControls: false)
//                        .frame(width: 233, height: 120)
//                        .clipped()
//                        .background(Color.clear)
//                        .onAppear {
//                          
//                            print("🎬 비디오 재생 시도")
//                            print("📍 URL: \(url)")
//                            print("📍 Valid URL: \(videoURL)")
//                            print("📍 Debug Info: \(debugInfo)")
//
//                            
//                            // URL 유효성 체크
//                            checkVideoURL(videoURL)
//                        }
//                } else {
//                    // URL 파싱 실패
//                    VStack {
//                        Image(systemName: "exclamationmark.triangle.fill")
//                            .font(.title)
//                            .foregroundColor(.red)
//                        Text("잘못된 URL")
//                            .font(.caption)
//                        Text(url)
//                            .font(.caption2)
//                            .lineLimit(2)
//                    }
//                    .frame(width: 233, height: 120)
//                    .background(Color.gray.opacity(0.2))
//                }
//            } else {
//                // 이미지 처리
//                CachedAsyncImage(
//                    url: URL(string: url),
//                    endpoint: ActivityEndpoint(requestType: .newActivity),
//                    contentMode: .fill
//                ) {
//                    Rectangle()
//                        .fill(CVCColor.grayScale15)
//                        .overlay(
//                            ProgressView()
//                                .scaleEffect(0.8)
//                        )
//                }
//                .onAppear {
//                    print("🖼 이미지 로드: \(url)")
//                }
//            }
//            
//            // 디버그 오버레이 (개발 중에만 표시)
//            #if DEBUG
//            VStack {
//                Spacer()
//                Text(debugInfo)
//                    .font(.system(size: 8))
//                    .foregroundColor(.white)
//                    .padding(2)
//                    .background(Color.black.opacity(0.7))
//                    .cornerRadius(4)
//            }
//            #endif
//        }
//    }
//    
//    // URL 유효성 체크 함수
//    private func checkVideoURL(_ url: URL) {
//        // URLSession으로 헤더만 체크
//        var request = URLRequest(url: url)
//        request.httpMethod = "HEAD"
//        
//        URLSession.shared.dataTask(with: request) { _, response, error in
//            DispatchQueue.main.async {
//                if let error = error {
//                    print("❌ URL 체크 실패: \(error.localizedDescription)")
//                    return
//                }
//                
//                if let httpResponse = response as? HTTPURLResponse {
//                    print("📡 HTTP 상태 코드: \(httpResponse.statusCode)")
//                    
//                    if let contentType = httpResponse.allHeaderFields["Content-Type"] as? String {
//                        print("📡 Content-Type: \(contentType)")
//                    }
//                    
//                    if httpResponse.statusCode == 200 {
//                        print("✅ URL 유효함")
//                    } else {
//                        print("⚠️ URL 접근 불가: \(httpResponse.statusCode)")
//                    }
//                }
//            }
//        }.resume()
//    }
//}

struct ActivityCardMediaView: View {
  let url: String
  @State private var mediaURL: URL?
  
  private var isVideo: Bool {
    let mediaType = ImageLoadHelper.shared.getMediaType(for: url)
    let isVideo = mediaType == .video
    return isVideo
  }
  
  var body: some View {
    ZStack {
      if isVideo {
        if let videoURL = mediaURL {
          // MODIFIED: Removed the hardcoded .frame() modifier to allow the view to be flexible.
          AVFoundationVideoView(url: videoURL, autoPlay: true, showControls: false)
            .clipped()
            .background(Color.clear)
        } else {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Make progress view fill space
            .background(Color.gray.opacity(0.2))
        }
      } else {
        CachedAsyncImage(
          url: URL(string: url),
          endpoint: ActivityEndpoint(requestType: .newActivity()),
          contentMode: .fill
        ) {
          Rectangle()
            .fill(CVCColor.grayScale15)
            .overlay(
              ProgressView()
                .scaleEffect(0.8)
            )
        }
        .onAppear {
          print("🖼 이미지 로드: \(url)")
        }
      }
    }
    .onAppear {
      if isVideo {
        ImageLoadHelper.shared.loadMediaWithHeaders(
          path: url,
          endpoint: ActivityEndpoint(requestType: .newActivity())
        ) { result in
          switch result {
          case .video(let fileURL):
            DispatchQueue.main.async {
              self.mediaURL = fileURL
              print("✅ 비디오 URL 로드 성공: \(fileURL)")
            }
          case .image(_):
            print("⚠️ 예상치 못한 이미지 결과")
          case .failure(let error):
            print("❌ 비디오 로드 실패: \(error)")
          }
        }
      }
    }
  }
}

// MARK: - 테스트용 비디오 URL 목록
struct TestVideoURLs {
  static let samples = [
    // Apple 샘플 비디오 (HLS)
    "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8",
    
    // Big Buck Bunny (MP4)
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    
    // 짧은 테스트 비디오
    "https://www.w3schools.com/html/mov_bbb.mp4",
    
    // 로컬 테스트 (Bundle에 있는 경우)
    "sample_video.mp4"
  ]
  
  static func testAllURLs() {
    print("\n🧪 비디오 URL 테스트 시작")
    for urlString in samples {
      if let url = URL(string: urlString) {
        print("Testing: \(urlString)")
        testVideoPlayback(url: url)
      }
    }
  }
  
  static func testVideoPlayback(url: URL) {
    let asset = AVAsset(url: url)
    
    if #available(iOS 16.0, *) {
      Task {
        do {
          let isPlayable = try await asset.load(.isPlayable)
          let duration = try await asset.load(.duration)
          DispatchQueue.main.async {
            if isPlayable {
              print("✅ \(url.lastPathComponent): 재생 가능, 길이: \(duration.seconds)초")
            } else {
              print("❌ \(url.lastPathComponent): 재생 불가")
            }
          }
        } catch {
          print("❌ \(url.lastPathComponent): 로드 실패 - \(error)")
        }
      }
    } else {
      asset.loadValuesAsynchronously(forKeys: ["playable", "duration"]) {
        DispatchQueue.main.async {
          var error: NSError?
          let playableStatus = asset.statusOfValue(forKey: "playable", error: &error)
          
          switch playableStatus {
          case .loaded:
            if asset.isPlayable {
              print("✅ \(url.lastPathComponent): 재생 가능")
            } else {
              print("❌ \(url.lastPathComponent): 재생 불가")
            }
          case .failed:
            print("❌ \(url.lastPathComponent): 로드 실패 - \(error?.localizedDescription ?? "")")
          case .cancelled:
            print("⚠️ \(url.lastPathComponent): 로드 취소됨")
          default:
            print("⚠️ \(url.lastPathComponent): 알 수 없는 상태")
          }
        }
      }
    }
  }
}

// MARK: - PlayerView 개선
class PlayerView: UIView {
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
  
  convenience init(player: AVPlayer, gravity: PlayerGravity) {
    self.init(frame: .zero)
    self.gravity = gravity
    self.player = player
    
    // 비디오 레이어 설정
    playerLayer.videoGravity = .resizeAspectFill
    playerLayer.backgroundColor = UIColor.clear.cgColor
    
    // 뷰 설정
    clipsToBounds = true
    backgroundColor = .clear
    
    print("🎥 PlayerView 초기화 완료")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    playerLayer.frame = bounds
    print("📐 PlayerView 레이아웃 업데이트: \(bounds)")
  }
  
  func setupVideoTransform() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.playerLayer.frame = self.bounds
      self.playerLayer.videoGravity = .resizeAspectFill
      print("🎬 비디오 transform 적용 완료: \(self.bounds)")
    }
  }
  
  deinit {
    print("🗑 PlayerView 해제")
    player = nil
  }
}
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

// MARK: - PlayerGravity
enum PlayerGravity {
  case aspectFill  // 비율 유지하면서 뷰 전체 채우기 (기본)
  case resize      // 비율 무시하고 뷰에 맞게 늘리기
  case customFit   // 커스텀 transform으로 비율 유지하며 뷰에 꽉 차게
}

// MARK: - AVFoundation 기반 비디오 뷰 (개선된 버전)
struct AVFoundationVideoView: UIViewRepresentable {
  let url: URL
  let autoPlay: Bool
  let showControls: Bool
  
  func makeUIView(context: Context) -> PlayerView {
    print("🎬 비디오 뷰 생성 시작: \(url)")
    
    let playerItem = AVPlayerItem(url: url)
    let player = AVPlayer(playerItem: playerItem)
    let playerView = PlayerView(player: player, gravity: .aspectFill)
    
    // Coordinator에 플레이어와 뷰 저장
    context.coordinator.player = player
    context.coordinator.playerView = playerView
    context.coordinator.autoPlay = autoPlay
    
    // KVO 옵저버 추가 (playerItem이 확실히 존재하는 시점)
    playerItem.addObserver(
      context.coordinator,
      forKeyPath: #keyPath(AVPlayerItem.status),
      options: [.new, .initial],
      context: nil
    )
    
    // 재생 종료 시 루프 처리
    NotificationCenter.default.addObserver(
      context.coordinator,
      selector: #selector(Coordinator.playerDidFinishPlaying),
      name: .AVPlayerItemDidPlayToEndTime,
      object: playerItem
    )
    
    // 자동 재생을 위한 설정
    if autoPlay {
      // iOS에서 자동 재생을 위해 음소거 필수
      player.isMuted = true
      player.automaticallyWaitsToMinimizeStalling = false
      
      // AVAudioSession 설정 (백그라운드에서도 재생 가능하도록)
      try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
      try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    print("🎬 비디오 뷰 생성 완료")
    return playerView
  }
  
  func updateUIView(_ uiView: PlayerView, context: Context) {
    // 필요시 업데이트 로직 추가
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  class Coordinator: NSObject {
    var player: AVPlayer?
    weak var playerView: PlayerView?
    var autoPlay: Bool = false
    private var statusObservation: NSKeyValueObservation?
    
    @objc func playerDidFinishPlaying() {
      print("🔄 비디오 재생 완료, 루프 재생")
      if autoPlay {
        player?.seek(to: .zero) { [weak self] _ in
          self?.player?.play()
        }
      }
    }
    
    override func observeValue(
      forKeyPath keyPath: String?,
      of object: Any?,
      change: [NSKeyValueChangeKey : Any]?,
      context: UnsafeMutableRawPointer?
    ) {
      if keyPath == #keyPath(AVPlayerItem.status) {
        if let playerItem = object as? AVPlayerItem {
          DispatchQueue.main.async { [weak self] in
            switch playerItem.status {
            case .readyToPlay:
              print("✅ 비디오 재생 준비 완료")
              self?.playerView?.setupVideoTransform()
              
              if self?.autoPlay == true {
                print("▶️ 자동 재생 시작")
                self?.player?.play()
              }
              
            case .failed:
              if let error = playerItem.error {
                print("❌ 비디오 로드 실패: \(error.localizedDescription)")
                print("❌ 에러 상세: \(error)")
              }
              
            case .unknown:
              print("⚠️ 비디오 상태 알 수 없음")
              
            @unknown default:
              print("⚠️ 알 수 없는 비디오 상태")
            }
          }
        }
      }
    }
    
    deinit {
      print("🗑 Coordinator 해제")
      
      // 옵저버 제거
      if let playerItem = player?.currentItem {
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
      }
      
      // 노티피케이션 제거
      NotificationCenter.default.removeObserver(self)
      
      // 플레이어 정리
      player?.pause()
      player?.replaceCurrentItem(with: nil)
      player = nil
    }
  }
}

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

//#Preview {
//  ActivityCardWithBorder(
//    activity: ActivityInfoData(
//      imageName: "",
//      price: "123,000원",
//      isLiked: false,
//      title: "겨울 새싹 스키 원정대",
//      country: "스위스 융프라우",
//      category: "스키"
//    ),
//    image: nil
//  )
//  .padding()
//}
