//
//  ChatRoomsResponse.swift
//  CoolVibeClub
//
//  Created by Claire on 7/12/25.
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