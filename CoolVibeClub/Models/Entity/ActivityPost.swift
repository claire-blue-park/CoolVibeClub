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
  let country: String
  let category: String
  let title: String
  let content: String
  let activity: PostActivity
  let geolocation: PostGeolocation
  let creator: PostCreator
  let files: [String]
  let isLike: Bool
  let likeCount: Int
  let createdAt: String
  let updatedAt: String
  
  enum CodingKeys: String, CodingKey {
    case id = "post_id"
    case country
    case category
    case title
    case content
    case activity
    case geolocation
    case creator
    case files
    case isLike = "is_like"
    case likeCount = "like_count"
    case createdAt
    case updatedAt
  }
}

struct PostActivity: Codable, Hashable {
  let id: String
  let title: String
  let country: String
  let category: String
  let thumbnails: [String]
  let geolocation: ActivityGeolocation
  let price: ActivityPrice
  let tags: [String]
  let pointReward: Int
  let isAdvertisement: Bool
  let isKeep: Bool
  let keepCount: Int
  
  enum CodingKeys: String, CodingKey {
    case id
    case title
    case country
    case category
    case thumbnails
    case geolocation
    case price
    case tags
    case pointReward = "point_reward"
    case isAdvertisement = "is_advertisement"
    case isKeep = "is_keep"
    case keepCount = "keep_count"
  }
}

struct ActivityGeolocation: Codable, Hashable {
  let longitude: Double
  let latitude: Double
}

struct PostGeolocation: Codable, Hashable {
  let longitude: Double
  let latitude: Double
}

struct ActivityPrice: Codable, Hashable {
  let original: Int
  let final: Int
}

struct PostCreator: Codable, Hashable {
  let userId: String
  let nick: String
  let profileImage: String?
  let introduction: String?
  
  init(userId: String, nick: String, profileImage: String? = nil, introduction: String? = nil) {
    self.userId = userId
    self.nick = nick
    self.profileImage = profileImage
    self.introduction = introduction
  }
  
  enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case nick
    case profileImage
    case introduction
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
    return isLike
  }
  
  var formattedCreatedAt: String {
    return DateHelper.formatToKorean(from: createdAt)
  }
  
  var relativeCreatedAt: String {
    return DateHelper.formatRelative(from: createdAt)
  }
}