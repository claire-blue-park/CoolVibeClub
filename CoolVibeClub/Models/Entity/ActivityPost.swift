//
//  ActivityPost.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

// MARK: - ActivityPost Models
struct ActivityPost: Codable, Identifiable, Hashable {
  let id: String
  let title: String
  let content: String
  let creator: PostCreator
  let files: [String]
  let likes: [String]
  let comments: [PostComment]
  let hashTags: [String]
  let createdAt: String
  let updatedAt: String
  
  enum CodingKeys: String, CodingKey {
    case id = "post_id"
    case title
    case content
    case creator
    case files
    case likes
    case comments
    case hashTags
    case createdAt
    case updatedAt
  }
}

struct PostCreator: Codable, Hashable {
  let userId: String
  let nick: String
  let profileImage: String?
  
  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case nick
    case profileImage
  }
}

struct PostComment: Codable, Hashable {
  let commentId: String
  let content: String
  let createdAt: String
  let creator: PostCreator
  
  enum CodingKeys: String, CodingKey {
    case commentId = "comment_id"
    case content
    case createdAt
    case creator
  }
}

struct ActivityPostsResponse: Codable {
  let data: [ActivityPost]
  let nextCursor: String?
  
  enum CodingKeys: String, CodingKey {
    case data
    case nextCursor = "next_cursor"
  }
}

// MARK: - Extension for UI
extension ActivityPost {
  var isLiked: Bool {
    // 현재 사용자 ID와 비교해서 좋아요 여부 확인
    // TODO: 실제 현재 사용자 ID와 비교
    return false
  }
  
  var likeCount: Int {
    return likes.count
  }
  
  var commentCount: Int {
    return comments.count
  }
  
  var formattedCreatedAt: String {
    // ISO 8601 날짜를 "n시간 전", "n일 전" 형식으로 변환
    let formatter = ISO8601DateFormatter()
    guard let date = formatter.date(from: createdAt) else {
      return createdAt
    }
    
    let now = Date()
    let timeInterval = now.timeIntervalSince(date)
    
    if timeInterval < 60 {
      return "방금 전"
    } else if timeInterval < 3600 {
      let minutes = Int(timeInterval / 60)
      return "\(minutes)분 전"
    } else if timeInterval < 86400 {
      let hours = Int(timeInterval / 3600)
      return "\(hours)시간 전"
    } else {
      let days = Int(timeInterval / 86400)
      return "\(days)일 전"
    }
  }
}