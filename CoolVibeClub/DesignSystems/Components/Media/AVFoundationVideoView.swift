//
//  AVFoundationVideoView.swift
//  CoolVibeClub
//
//  Created by Claire on 8/19/25.
//

import SwiftUI
import AVFoundation

extension Notification.Name {
  static let pauseAllVideos = Notification.Name("pauseAllVideos")
}

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
    
    // 모든 비디오 일시정지 notification 수신
    NotificationCenter.default.addObserver(
      context.coordinator,
      selector: #selector(Coordinator.pauseVideo),
      name: .pauseAllVideos,
      object: nil
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
  
  static func dismantleUIView(_ uiView: PlayerView, coordinator: Coordinator) {
    coordinator.pauseVideo()
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
    
    @objc func pauseVideo() {
      print("⏸️ 비디오 일시정지 (Notification)")
      player?.pause()
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

