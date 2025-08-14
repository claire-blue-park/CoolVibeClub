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
      // 단일 이미지
      AsyncImageView(path: images[0]) {
        Rectangle()
          .fill(CVCColor.grayScale30)
          .overlay(
            ProgressView()
              .scaleEffect(0.8)
          )
      }
      .frame(height: 200)
      .clipped()
      .cornerRadius(12)
    } else if images.count == 2 {
      // 2개 이미지 - 좌우 분할
      HStack(spacing: 4) {
        ForEach(Array(images.enumerated()), id: \.offset) { index, imageUrl in
          AsyncImageView(path: imageUrl) {
            Rectangle()
              .fill(CVCColor.grayScale30)
              .overlay(
                ProgressView()
                  .scaleEffect(0.6)
              )
          }
          .frame(height: 160)
          .clipped()
          .cornerRadius(8)
        }
      }
    } else if images.count >= 3 {
      // 3개 이상 - 좌측 큰 이미지, 우측 2개 작은 이미지
      HStack(spacing: 4) {
        // 좌측 큰 이미지
        AsyncImageView(path: images[0]) {
          Rectangle()
            .fill(CVCColor.grayScale30)
            .overlay(
              ProgressView()
                .scaleEffect(0.8)
            )
        }
        .frame(height: 160)
        .clipped()
        .cornerRadius(8)
        
        // 우측 작은 이미지들
        VStack(spacing: 4) {
          AsyncImageView(path: images[1]) {
            Rectangle()
              .fill(CVCColor.grayScale30)
              .overlay(
                ProgressView()
                  .scaleEffect(0.6)
              )
          }
          .frame(height: 78)
          .clipped()
          .cornerRadius(8)
          
          if images.count >= 3 {
            ZStack {
              AsyncImageView(path: images[2]) {
                Rectangle()
                  .fill(CVCColor.grayScale30)
                  .overlay(
                    ProgressView()
                      .scaleEffect(0.6)
                  )
              }
              .frame(height: 78)
              .clipped()
              .cornerRadius(8)
              
              // 더 많은 이미지가 있을 때 오버레이
              if images.count > 3 {
                Rectangle()
                  .fill(Color.black.opacity(0.5))
                  .frame(height: 78)
                  .cornerRadius(8)
                  .overlay(
                    Text("+\(images.count - 3)")
                      .font(.system(size: 16, weight: .semibold))
                      .foregroundStyle(.white)
                  )
              }
            }
          }
        }
      }
    }
  }
}
