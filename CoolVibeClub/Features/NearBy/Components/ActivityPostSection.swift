//
//  ActivityPostSection.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct ActivityPostSection: View {
  @State private var selectedDistance: Double = 3.0
  
  let posts: [ActivityPost]
  let isLoading: Bool
  let hasMorePosts: Bool
  let onLoadMore: () -> Void
  let onRefresh: () -> Void
  
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // MARK: - 섹션 헤더
      HStack {
        Text("액티비티 포스트")
          .foregroundStyle(CVCColor.grayScale90)
          .font(.system(size: 14, weight: .bold))
        Spacer()
        Button {
          onRefresh()
        } label: {
          HStack(spacing: 4) {
            Text("최신순")
              .foregroundStyle(CVCColor.primary)
              .font(.system(size: 12, weight: .medium))
            CVCImage.sort.template
              .foregroundColor(CVCColor.primary)
              .frame(width: 14, height: 14)
          }
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.horizontal, 16)

      // MARK: - 포스트 리스트
      if isLoading && posts.isEmpty {
        /// 1. 포스트 로딩 중
        HStack {
          Spacer()
          ProgressView("포스트를 불러오는 중...")
            .foregroundStyle(CVCColor.grayScale60)
          Spacer()
        }
        .padding(.vertical, 40)
      } else if posts.isEmpty {
        /// 2. 포스트 없음
        HStack {
          Spacer()
          VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
              .font(.system(size: 24))
              .foregroundStyle(CVCColor.grayScale45)
            Text("근처에 포스트가 없습니다")
              .font(.system(size: 12, weight: .regular))
              .foregroundStyle(CVCColor.grayScale60)
          }
          .padding(.vertical, 40)
          Spacer()
        }
      } else {
        /// 3. 포스트 로드 완료
        LazyVStack(spacing: 0) {
          ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
            ActivityPostCell(post: post)
            
            // 마지막 포스트가 아니면 divider 추가
            if index < posts.count - 1 {
              Divider()
                .frame(height: 1)
                .background(CVCColor.grayScale15)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
          }
        }
      }
      Spacer(minLength: 100)
    }
  }
}



// MARK: - AsyncImageView (ImageLoadHelper 사용)
struct AsyncImageView<Placeholder: View>: View {
  let path: String
  let placeholder: Placeholder
  
  @State private var image: UIImage?
  @State private var isLoading = false
  
  init(path: String, @ViewBuilder placeholder: () -> Placeholder) {
    self.path = path
    self.placeholder = placeholder()
  }
  
  var body: some View {
    Group {
      if let image = image {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fill)
      } else {
        placeholder
          .onAppear {
            loadImage()
          }
      }
    }
  }
  
  private func loadImage() {
    guard !path.isEmpty && !isLoading else { return }
    
    isLoading = true
    let endpoint = ActivityPostEndpoint(requestType: .fetchPostsByGeolocation(
      country: nil, category: nil, longitude: nil, latitude: nil,
      maxDistance: nil, limit: nil, next: nil, orderBy: nil
    ))
    
    ImageLoadHelper.shared.loadCachedImage(
      path: path,
      endpoint: endpoint
    ) { loadedImage in
      self.image = loadedImage
      self.isLoading = false
    }
  }
}

