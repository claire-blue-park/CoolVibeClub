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
  @State private var posts: [ActivityPost] = []
  @State private var isLoading: Bool = false
  @State private var errorMessage: String?
  @State private var nextCursor: String?
  
  @Environment(\.activityPostClient) private var activityPostClient
  let currentLocation: (latitude: Double, longitude: Double)?
  
  // MARK: - Methods
  private func loadPosts() async {
    isLoading = true
    errorMessage = nil
    
    do {
      let response = try await activityPostClient.fetchPostsByGeolocation(
        nil, // country
        nil, // category
        currentLocation?.longitude.description,
        currentLocation?.latitude.description,
        "\(Int(selectedDistance * 1000))", // 킬로미터를 미터로 변환
        5, // limit
        nil, // next
        "createdAt" // orderBy
      )
      
      posts = response.data
      nextCursor = response.nextCursor
      
    } catch {
      errorMessage = "포스트를 불러오는데 실패했습니다: \(error.localizedDescription)"
      print("❌ ActivityPost 로딩 실패: \(error)")
    }
    
    isLoading = false
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      // MARK: - 섹션 헤더
      HStack {
        Text("액티비티 포스트")
          .foregroundStyle(CVCColor.grayScale90)
          .font(.system(size: 14, weight: .bold))
        Spacer()
        Button {
          // 최신순 정렬 액션
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
      
      if isLoading {
        HStack {
          Spacer()
          ProgressView("포스트를 불러오는 중...")
            .foregroundStyle(CVCColor.grayScale60)
          Spacer()
        }
        .padding(.vertical, 40)
      } else if let errorMessage = errorMessage {
        VStack(spacing: 16) {
          Text("오류 발생")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(CVCColor.grayScale90)
          Text(errorMessage)
            .font(.system(size: 14))
            .foregroundStyle(CVCColor.grayScale60)
            .multilineTextAlignment(.center)
          Button("다시 시도") {
            Task { await loadPosts() }
          }
          .padding(.horizontal, 20)
          .padding(.vertical, 8)
          .background(CVCColor.primary)
          .foregroundStyle(.white)
          .cornerRadius(8)
        }
        .padding(.horizontal, 16)
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
        LazyVStack(spacing: 20) {
          ForEach(posts) { post in
            ActivityPostCard(post: post)
          }
        }
        .padding(.horizontal, 16)
      }
      
      Spacer(minLength: 100)
    }
    .task {
      if currentLocation != nil {
        await loadPosts()
      }
    }
    .onChange(of: selectedDistance) { _ in
      if currentLocation != nil {
        Task { await loadPosts() }
      }
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
        CachedAsyncImage(
          url: URL(string: post.creator.profileImage ?? ""),
          contentMode: .fill
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
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(CVCColor.grayScale90)
          
          Text(post.formattedCreatedAt)
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(CVCColor.grayScale60)
        }
        
        Spacer()
      }
      
      // MARK: - 이미지 그리드
      PostImageGrid(images: post.files)
      
      // MARK: - 제목
      Text(post.title)
        .font(.system(size: 16, weight: .bold))
        .foregroundStyle(CVCColor.grayScale90)
        .multilineTextAlignment(.leading)
      
      // MARK: - 설명
      Text(post.content)
        .font(.system(size: 14, weight: .regular))
        .foregroundStyle(CVCColor.grayScale75)
        .multilineTextAlignment(.leading)
        .lineLimit(3)
      
      // MARK: - 태그
      if !post.hashTags.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(post.hashTags, id: \.self) { tag in
              Text("#\(tag)")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(CVCColor.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(CVCColor.primaryLight.opacity(0.1))
                .cornerRadius(16)
            }
          }
          .padding(.horizontal, 1)
        }
      }
    }
    .padding(.vertical, 16)
    .background(CVCColor.grayScale0)
    .cornerRadius(12)
    .shadow(color: CVCColor.grayScale30.opacity(0.1), radius: 4, x: 0, y: 2)
  }
}

// MARK: - PostImageGrid
struct PostImageGrid: View {
  let images: [String]
  
  var body: some View {
    if images.count == 1 {
      // 단일 이미지
      CachedAsyncImage(
        url: URL(string: images[0]),
        contentMode: .fill
      ) {
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
          CachedAsyncImage(
            url: URL(string: imageUrl),
            contentMode: .fill
          ) {
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
        CachedAsyncImage(
          url: URL(string: images[0]),
          contentMode: .fill
        ) {
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
          CachedAsyncImage(
            url: URL(string: images[1]),
            contentMode: .fill
          ) {
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
              CachedAsyncImage(
                url: URL(string: images[2]),
                contentMode: .fill
              ) {
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

#Preview {
  ActivityPostSection(currentLocation: (latitude: 37.5665, longitude: 126.9780))
    .environment(\.activityPostClient, .mock)
}
