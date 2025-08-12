//
//  ChatHistoryResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct ChatHistoryResponse: Decodable {
    let data: [ChatMessage]
}

struct ChatMessage: Decodable {
    let chatId: String
    let roomId: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let sender: ChatParticipant
    let files: [String]?
    
    enum CodingKeys: String, CodingKey {
        case chatId = "chat_id"
        case roomId = "room_id"
        case content
        case createdAt
        case updatedAt
        case sender
        case files
    }
}

struct ChatParticipant: Decodable {
    let userId: String
    let nick: String
    let profileImage: String?
    let introduction: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nick
        case profileImage
        case introduction
    }
}