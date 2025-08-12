//
//  ActivityPostClient.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - ActivityPostClient
struct ActivityPostClient {
  let fetchPostsByGeolocation: (String?, String?, String?, String?, String?, Int?, String?, String?) async throws -> ActivityPostsResponse
}

// MARK: - Live Implementation
extension ActivityPostClient {
  static let live = ActivityPostClient(
    fetchPostsByGeolocation: { country, category, longitude, latitude, maxDistance, limit, next, orderBy in
      let endpoint = ActivityPostEndpoint(
        requestType: .fetchPostsByGeolocation(
          country: country,
          category: category,
          longitude: longitude,
          latitude: latitude,
          maxDistance: maxDistance,
          limit: limit,
          next: next,
          orderBy: orderBy
        )
      )
      
      print("🌐 ActivityPost API 요청: \(endpoint.baseURL)\(endpoint.path)")
      print("📍 파라미터: country=\(country ?? "nil"), category=\(category ?? "nil"), lat=\(latitude ?? "nil"), lng=\(longitude ?? "nil"), maxDistance=\(maxDistance ?? "nil")")
      
      let interceptor = TokenRefreshInterceptor()
      let session = Session(interceptor: interceptor)
      
      let response = try await session.request(
        "\(endpoint.baseURL)\(endpoint.path)",
        method: endpoint.method,
        parameters: endpoint.parameters,
        headers: endpoint.headers
      )
      .validate()
      .serializingDecodable(ActivityPostsResponse.self)
      .value
      
      print("✅ ActivityPost API 응답: \(response.data.count)개 포스트")
      return response
    }
  )
}

// MARK: - Mock Implementation
extension ActivityPostClient {
  static let mock = ActivityPostClient(
    fetchPostsByGeolocation: { _, _, _, _, _, _, _, _ in
      // Mock 데이터 반환
      let mockPosts = [
        ActivityPost(
          id: "1",
          title: "서울 한강 러닝 모임",
          content: "오늘 한강에서 러닝했어요! 날씨가 너무 좋았습니다. 다음에도 같이 뛰실 분들 환영해요!",
          creator: PostCreator(
            userId: "user1",
            nick: "러닝러버",
            profileImage: nil
          ),
          files: [
            "https://example.com/hangang1.jpg",
            "https://example.com/hangang2.jpg"
          ],
          likes: ["user2", "user3", "user4"],
          comments: [],
          hashTags: ["러닝", "한강", "운동"],
          createdAt: "2025-01-28T08:30:00Z",
          updatedAt: "2025-01-28T08:30:00Z"
        ),
        ActivityPost(
          id: "2",
          title: "제주도 오름 등반 후기",
          content: "성산일출봉에 다녀왔습니다. 일출이 정말 아름다웠어요! 다들 제주도 오시면 꼭 가보세요.",
          creator: PostCreator(
            userId: "user2",
            nick: "산악인",
            profileImage: nil
          ),
          files: [
            "https://example.com/jeju1.jpg"
          ],
          likes: ["user1", "user3"],
          comments: [],
          hashTags: ["제주도", "등반", "성산일출봉"],
          createdAt: "2025-01-28T06:15:00Z",
          updatedAt: "2025-01-28T06:15:00Z"
        )
      ]
      
      return ActivityPostsResponse(data: mockPosts, nextCursor: nil)
    }
  )
}