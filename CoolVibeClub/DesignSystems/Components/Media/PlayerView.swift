//
//  PlayerView.swift
//  CoolVibeClub
//
//  Created by Claire on 8/19/25.
//

import SwiftUI
import AVFoundation

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
