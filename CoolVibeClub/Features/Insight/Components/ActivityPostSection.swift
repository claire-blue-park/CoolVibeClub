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
    VStack(alignment: .leading, spacing: 20) {
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
      
      // MARK: - 거리 필터
      VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 4) {
          Text("Distance")
            .foregroundStyle(CVCColor.grayScale60)
            .font(.system(size: 12, weight: .bold))
          
          Text("\(Int(selectedDistance))KM")
            .foregroundStyle(CVCColor.primary)
            .font(.system(size: 12, weight: .bold))
        }
        .padding(.leading, 16)
   
        
        // 거리 슬라이더
        HStack(spacing: 12) {
          GeometryReader { geometry in
            ZStack(alignment: .leading) {
              // 배경 Rectangle
              RoundedRectangle(cornerRadius: 12)
                .fill(CVCColor.grayScale15)
                .frame(height: 36)
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(CVCColor.grayScale30, lineWidth: 1)
                )
              
              // 배경 트랙
              Capsule()
                .fill(CVCColor.grayScale30)
                .frame(height: 10)
                .padding(.horizontal, 16)
              
              // 활성화된 트랙
              Capsule()
                .fill(CVCColor.primary)
                .frame(width: geometry.size.width * (selectedDistance / 10.0), height: 10)
                .padding(.horizontal, 16)
              
              // 슬라이더 핸들
              Circle()
                .fill(CVCColor.grayScale0)
                .frame(width: 4, height: 4)
                .offset(x: geometry.size.width * (selectedDistance / 10.0) - 8)
                .gesture(
                  DragGesture()
                    .onChanged { value in
                      let newValue = min(max(0, value.location.x / geometry.size.width * 10.0), 10.0)
                      selectedDistance = newValue
                    }
                )
                .padding(.horizontal, 16)
            }
          }
          .frame(height: 16)
          
        }
        .padding(.horizontal, 16)
      }
      
      // MARK: - 포스트 리스트
      
      if isLoading && posts.isEmpty {
        HStack {
          Spacer()
          ProgressView("포스트를 불러오는 중...")
            .foregroundStyle(CVCColor.grayScale60)
          Spacer()
        }
        .padding(.vertical, 40)
      } else if posts.isEmpty {
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
        LazyVStack(spacing: 0) {
          ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
            ActivityPostCard(post: post)
            
            // 마지막 포스트가 아니면 divider 추가
            if index < posts.count - 1 {
              Divider()
                .frame(height: 1)
                .background(CVCColor.grayScale15)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
          }
          
          // 더 보기 버튼 또는 로딩 인디케이터
//          if hasMorePosts {
//            if isLoading {
//              HStack {
//                Spacer()
//                ProgressView()
//                  .scaleEffect(0.8)
//                Spacer()
//              }
//              .padding(.vertical, 20)
//            } else {
//              Button(action: onLoadMore) {
//                Text("더 보기")
//                  .font(.system(size: 14, weight: .medium))
//                  .foregroundStyle(CVCColor.primary)
//                  .padding(.horizontal, 20)
//                  .padding(.vertical, 10)
//                  .background(CVCColor.primaryLight.opacity(0.1))
//                  .cornerRadius(20)
//              }
//              .frame(maxWidth: .infinity)
//              .padding(.vertical, 10)
//            }
//          }
        }
      }
      
      Spacer(minLength: 100)
    }
  }
}

// MARK: - ActivityPostCard
struct ActivityPostCard: View {
  let post: ActivityPost
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // MARK: - 유저 정보
      HStack(spacing: 12) {
        AsyncImageView(
          path: post.creator.profileImage ?? ""
        ) {
          Image(systemName: "person.circle.fill")
            .font(.system(size: 24))
            .foregroundStyle(CVCColor.grayScale60)
        }
        .frame(width: 40, height: 40)
        .background(CVCColor.grayScale15)
        .clipShape(Circle())
        
        VStack(alignment: .leading, spacing: 2) {
          Text(post.creator.nick)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(CVCColor.grayScale90)
          
          HStack(spacing: 2) {
            CVCImage.Action.time.template
              .frame(width: 12, height: 12)
              .foregroundStyle(CVCColor.grayScale60)
            
            Text(post.formattedCreatedAt)
              .font(.system(size: 11, weight: .regular))
              .foregroundStyle(CVCColor.grayScale60)
          }
        }
        
        Spacer()
        
        // MARK: - More Button
        Menu {
          Button(action: {
            // Handle edit action
            print("Edit post: \(post.title)")
          }) {
            Label("수정", systemImage: "pencil")
          }
          
          Button(role: .destructive, action: {
            // Handle delete action
            print("Delete post: \(post.title)")
          }) {
            Label("삭제", systemImage: "trash")
          }
        } label: {
          Image(systemName: "ellipsis")
            .font(.system(size: 16))
            .foregroundStyle(CVCColor.grayScale60)
            .padding(8)
            .contentShape(Rectangle()) // Ensures the entire area is tappable
        }
      }
      
      // MARK: - 이미지 그리드
      PostImageGrid(images: post.files)
      
      // MARK: - 제목
      Text(post.title)
        .font(.system(size: 16, weight: .bold))
        .foregroundStyle(CVCColor.grayScale90)
        .multilineTextAlignment(.leading)
        .padding(.horizontal, 8)
      
      // MARK: - 설명
      Text(post.content)
        .font(.system(size: 14, weight: .regular))
        .foregroundStyle(CVCColor.grayScale75)
        .multilineTextAlignment(.leading)
        .lineLimit(3)
        .padding(.horizontal, 8)
      
      // MARK: - 카테고리 태그
      HStack(spacing: 8) {
        TagView(text: post.category)
        TagView(text: post.country)
        
        Spacer()
      }
      .padding(.horizontal, 8)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 20)
    .background(CVCColor.grayScale0)
    .onAppear {
      print("ActivityPostCard rendered for post: \(post.title)")
    }
  }
}

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

//#Preview {
//  ActivityPostSection(currentLocation: (latitude: 37.5665, longitude: 126.9780))
//    .environment(\.activityPostClient, .mock)
//}
