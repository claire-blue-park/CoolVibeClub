//
//  ChatRoomsResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

struct ChatRoomsResponse: Decodable {
    let data: [ChatRoom]
}

struct ChatRoom: Decodable {
    let roomId: String
    let createdAt: String
    let updatedAt: String
    let participants: [Participant]
    let lastChat: Chat?

    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case createdAt
        case updatedAt
        case participants
        case lastChat
    }
    
    // 편의 초기화자 - 새 채팅방 생성용
    init(roomId: String, createdAt: String, updatedAt: String, participants: [Participant], lastChat: Chat?) {
        self.roomId = roomId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.participants = participants
        self.lastChat = lastChat
    }
}

struct Participant: Decodable {
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
    
    // 편의 초기화자 - 새 채팅 참가자 생성용
    init(userId: String, nick: String, profileImage: String?, introduction: String?) {
        self.userId = userId
        self.nick = nick
        self.profileImage = profileImage
        self.introduction = introduction
    }
}

struct Chat: Decodable {
    let chatId: String
    let roomId: String
    let content: String
    let createdAt: String
    let updatedAt: String
    let sender: Participant
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