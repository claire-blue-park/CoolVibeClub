//
//  PostImageGrid.swift
//  CoolVibeClub
//
//  Created by Claire on 8/15/25.
//

import SwiftUI

// MARK: - PostImageGrid
struct PostImageGrid: View {
  let images: [String]
  
  var body: some View {
    if images.count == 1 {
      makeSingleImageView()
    } else if images.count == 2 {
      makeTwoImagesView()
    } else if images.count >= 3 {
      makeMultipleImagesView()
    }
  }
}

extension PostImageGrid {
  // MARK: - 1
  func makeSingleImageView() -> some View {
    makeImageView(path: images[0], height: 200, cornerRadius: 12, progressScale: 0.8)
  }
  
  // MARK: - 2
  func makeTwoImagesView() -> some View {
    HStack(spacing: 4) {
      makeImageView(path: images[0], isSecond: true, height: 160, cornerRadius: 12, progressScale: 0.8)
        .frame(maxWidth: .infinity)
      makeImageView(path: images[1], isSecond: true, height: 160, cornerRadius: 12, progressScale: 0.8)
        .frame(maxWidth: .infinity)
    }
    .frame(maxWidth: .infinity)
  }
  
  // MARK: - 3+
  func makeMultipleImagesView() -> some View {
    HStack(spacing: 4) {
      // 좌측 큰 이미지
      makeImageView(path: images[0], height: 160, cornerRadius: 8, progressScale: 0.8)
      
      // 우측 작은 이미지들
      VStack(spacing: 4) {
        makeImageView(path: images[1], height: 78, cornerRadius: 8, progressScale: 0.6)
        
        if images.count >= 3 {
          ZStack {
            makeImageView(path: images[2], height: 78, cornerRadius: 8, progressScale: 0.6)
            
            if images.count > 3 {
              makeOverlay(images.count)
            }
          }
        }
      }
    }
  }
  
  func makeImageView(path: String, isSecond: Bool = false, height: CGFloat, cornerRadius: CGFloat, progressScale: CGFloat) -> some View {
    ZStack {
      CachedAsyncImage(
        urlString: path,
        endpoint: ActivityPostEndpoint(requestType: .fetchPostsByGeolocation(
          country: nil, category: nil, longitude: nil, latitude: nil,
          maxDistance: nil, limit: nil, next: nil, orderBy: nil
        )),
        contentMode: .fit
      ) {
        makePlaceholder(progressScale: progressScale)
      }
    }
    .frame(height: height)
    .frame(maxWidth: .infinity)
    .clipped()
    .cornerRadius(cornerRadius)
  }
  
  // MARK: - Placeholder
  func makePlaceholder(progressScale: CGFloat) -> some View {
    Rectangle()
      .fill(CVCColor.grayScale30)
      .overlay(
        ProgressView()
          .scaleEffect(progressScale)
      )
  }
  
  // MARK: - Overlay
  func makeOverlay(_ count: Int) -> some View {
    Rectangle()
      .fill(Color.black.opacity(0.5))
      .frame(height: 78)
      .frame(maxWidth: .infinity)
      .cornerRadius(8)
      .overlay(
        Text("+\(count - 3)")
          .font(.system(size: 15, weight: .semibold))
          .foregroundStyle(CVCColor.grayScale0)
      )
  }
}
