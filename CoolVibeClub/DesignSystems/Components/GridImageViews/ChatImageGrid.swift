//
//  ChatImageGrid.swift
//  CoolVibeClub
//
//  Created by Claire on 8/16/25.
//

import SwiftUI

struct ChatImageGrid: View {
  let imageFiles: [String]
  private let maxWidth: CGFloat = 240
  private let spacing: CGFloat = 2
  
  var body: some View {
    switch imageFiles.count {
    case 1:
      // 1개일 때: 원본 비율 유지
      SingleImageView(filePath: imageFiles[0])
        .frame(maxWidth: maxWidth)
        .cornerRadius(12)
        .clipped()
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(CVCColor.grayScale15, lineWidth: 1)
        )
      
    case 2:
      // 2개일 때: 세로로 나란히
      HStack(spacing: spacing) {
        ForEach(imageFiles, id: \.self) { filePath in
          ChatAsyncImageView(filePath: filePath)
            .frame(width: (maxWidth - spacing) / 2, height: 120)
            .cornerRadius(8)
            .clipped()
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(CVCColor.grayScale15, lineWidth: 1)
            )
        }
      }
      
    case 3:
      // 3개일 때: 첫 번째는 큰 사진, 나머지 두 개는 작게
      HStack(spacing: spacing) {
        ChatAsyncImageView(filePath: imageFiles[0])
          .frame(width: maxWidth * 0.6, height: 160)
          .cornerRadius(8)
          .clipped()
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(CVCColor.grayScale15, lineWidth: 1)
          )
        
        VStack(spacing: spacing) {
          ChatAsyncImageView(filePath: imageFiles[1])
            .frame(width: maxWidth * 0.4 - spacing, height: 79)
            .cornerRadius(8)
            .clipped()
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(CVCColor.grayScale15, lineWidth: 1)
            )
          
          ChatAsyncImageView(filePath: imageFiles[2])
            .frame(width: maxWidth * 0.4 - spacing, height: 79)
            .cornerRadius(8)
            .clipped()
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(CVCColor.grayScale15, lineWidth: 1)
            )
        }
      }
      
    case 4:
      // 4개일 때: 2x2 그리드
      VStack(spacing: spacing) {
        HStack(spacing: spacing) {
          ChatAsyncImageView(filePath: imageFiles[0])
            .frame(width: (maxWidth - spacing) / 2, height: 80)
            .cornerRadius(8)
            .clipped()
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(CVCColor.grayScale15, lineWidth: 1)
            )
          
          ChatAsyncImageView(filePath: imageFiles[1])
            .frame(width: (maxWidth - spacing) / 2, height: 80)
            .cornerRadius(8)
            .clipped()
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(CVCColor.grayScale15, lineWidth: 1)
            )
        }
        
        HStack(spacing: spacing) {
          ChatAsyncImageView(filePath: imageFiles[2])
            .frame(width: (maxWidth - spacing) / 2, height: 80)
            .cornerRadius(8)
            .clipped()
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(CVCColor.grayScale15, lineWidth: 1)
            )
          
          ChatAsyncImageView(filePath: imageFiles[3])
            .frame(width: (maxWidth - spacing) / 2, height: 80)
            .cornerRadius(8)
            .clipped()
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(CVCColor.grayScale15, lineWidth: 1)
            )
        }
      }
      
    case 5:
      // 5개일 때: 첫 번째 줄에 2개, 두 번째 줄에 3개
      VStack(spacing: spacing) {
        HStack(spacing: spacing) {
          ChatAsyncImageView(filePath: imageFiles[0])
            .frame(width: (maxWidth - spacing) / 2, height: 80)
            .cornerRadius(8)
            .clipped()
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(CVCColor.grayScale15, lineWidth: 1)
            )
          
          ChatAsyncImageView(filePath: imageFiles[1])
            .frame(width: (maxWidth - spacing) / 2, height: 80)
            .cornerRadius(8)
            .clipped()
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(CVCColor.grayScale15, lineWidth: 1)
            )
        }
        
        HStack(spacing: spacing) {
          ForEach(imageFiles.suffix(3), id: \.self) { filePath in
            ChatAsyncImageView(filePath: filePath)
              .frame(width: (maxWidth - spacing * 2) / 3, height: 80)
              .cornerRadius(8)
              .clipped()
              .overlay(
                RoundedRectangle(cornerRadius: 8)
                  .stroke(CVCColor.grayScale15, lineWidth: 1)
              )
          }
        }
      }
      
    default:
      EmptyView()
    }
  }
}

// MARK: - 1. 싱글
struct SingleImageView: View {
  let filePath: String
  @State private var image: UIImage? = nil
  @State private var isLoading: Bool = true
  private let maxWidth: CGFloat = 240
  private let maxHeight: CGFloat = 300
  
  var body: some View {
    ZStack {
      if let image = image {
        let imageSize = calculateImageSize(image)
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: imageSize.width, height: imageSize.height)
      } else if isLoading {
        ProgressView()
          .frame(width: 160, height: 160)
          .background(CVCColor.grayScale30)
          .cornerRadius(12)
      } else {
        Image(systemName: "photo")
          .foregroundColor(CVCColor.grayScale60)
          .frame(width: 160, height: 160)
          .background(CVCColor.grayScale30)
          .cornerRadius(12)
      }
    }
    .onAppear {
      loadImage()
    }
  }
  
  private func loadImage() {
    let endpoint = ChatEndpoint(requestType: .fetchMessages(roomId: "", next: nil))
    ImageLoadHelper.shared.loadCachedImage(path: filePath, endpoint: endpoint) { loadedImage in
      DispatchQueue.main.async {
        self.image = loadedImage
        self.isLoading = false
      }
    }
  }
  
  private func calculateImageSize(_ image: UIImage) -> CGSize {
    let imageSize = image.size
    let aspectRatio = imageSize.width / imageSize.height
    
    // 고정 width는 240px (다른 이미지들과 동일)
    let width = maxWidth
    let height = width / aspectRatio
    
    // 최대 높이 제한
    let finalHeight = min(height, maxHeight)
    
    return CGSize(width: width, height: finalHeight)
  }
}

// MARK: - 2. 멀티
struct ChatAsyncImageView: View {
  let filePath: String
  @State private var image: UIImage? = nil
  @State private var isLoading: Bool = true
  
  var body: some View {
    ZStack {
      if let image = image {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 160, height: 160)
          .clipped()
      } else if isLoading {
        ProgressView()
          .frame(width: 160, height: 160)
          .background(CVCColor.grayScale30)
          .cornerRadius(12)
      } else {
        Image(systemName: "photo")
          .foregroundColor(CVCColor.grayScale60)
          .frame(width: 160, height: 160)
          .background(CVCColor.grayScale30)
          .cornerRadius(12)
      }
    }
    .background(CVCColor.grayScale30)
    .cornerRadius(12)
    .onAppear {
      loadImage()
    }
  }
  
  private func loadImage() {
    let endpoint = ChatEndpoint(requestType: .fetchMessages(roomId: "", next: nil))
    ImageLoadHelper.shared.loadCachedImage(path: filePath, endpoint: endpoint) { loadedImage in
      DispatchQueue.main.async {
        self.image = loadedImage
        self.isLoading = false
      }
    }
  }
}

