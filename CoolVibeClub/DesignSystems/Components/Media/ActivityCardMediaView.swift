//
//  ActivityCardMediaView.swift
//  CoolVibeClub
//
//  Created by Claire on 8/19/25.
//

import SwiftUI
import AVFoundation

struct ActivityCardMediaView: View {
  let url: String
  let endpoint: Endpoint
  @State private var mediaURL: URL?
  @State private var videoPlayer: AVPlayer?
  
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
          endpoint: endpoint,
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
          endpoint: endpoint
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
    .onDisappear {
      // 화면이 사라질 때 비디오 일시정지
      if isVideo {
        NotificationCenter.default.post(name: .pauseAllVideos, object: nil)
        print("⏸️ ActivityCardMediaView - 모든 비디오 일시정지 요청")
      }
    }
  }
}
