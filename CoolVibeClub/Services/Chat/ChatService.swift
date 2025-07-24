//
//  ChatService.swift
//  CoolVibeClub
//
//  Created by Claire on 8/1/25.
//

import Foundation

final class ChatService {
  static let shared = ChatService()
  private let networkManager = NetworkManager.shared
  private let socketManager = SocketManager.shared
  
  private init() { }
  
  // MARK: - Socket Setup
  
  private func setupSocket(roomId: String) {
    // 특정 채팅방에 연결
    socketManager.connect(roomId: roomId)
  }
  
  // 1. 채팅방 생성 / 조회
  func createOrFindChatRoom(opponentId: String) async throws -> ChatRoom {
      let endpoint = ChatEndpoint(requestType: .createChatRoom(opponentId: opponentId))
      return try await networkManager.fetch(
          from: endpoint,
          errorMapper: { status, error in
            ChatRoomError.map(statusCode: status, message: error.message)
          }
      )
  }
  
  // 2. 채팅방 목록 조회
  func fetchRoooms() async throws -> ChatRoomsResponse {
    let endpoint = ChatEndpoint(requestType: .fetchChatRooms)
    return try await networkManager.fetch(
      from: endpoint,
      errorMapper: { status, error in
        CommonError.map(statusCode: status, message: error.message)
      })
  }
  
  
  // 3. 메시지 전송
  func sendMessage(roomId: String, content: String, files:[String] = []) async throws -> SendChatResponse {
    print("🌐 ChatService.sendMessage 호출")
    print("🔍 roomId: \(roomId)")
    print("🔍 content: \(content)")
    print("🔍 files: \(files)")
    
    let endpoint = ChatEndpoint(requestType: .sendMessage(roomId: roomId, content: content, files: files))
    return try await networkManager.fetch(
      from: endpoint,
      errorMapper: { status, error in
        ChatMessageError.map(statusCode: status, message: error.message)
      })
  }
  
  // 4. 채팅 내역 조회
  func fetchMessages(roomId: String, next: String? = nil) async throws -> ChatHistoryResponse {
    let endpoint = ChatEndpoint(requestType: .fetchMessages(roomId: roomId, next: next))
    return try await networkManager.fetch(
      from: endpoint,
      errorMapper: { status, error in
        ChatMessageError.map(statusCode: status, message: error.message)
      })
  }
  
  // 5. 파일 업로드 (기존)
  func uploadFiles(roomId: String, files: [String]) async throws -> ChatFileUploadResponse {
    let endpoint = ChatEndpoint(requestType: .uploadFile(roomId: roomId, files: files))
    return try await networkManager.fetch(
      from: endpoint,
      errorMapper: { status, error in
        ChatMessageError.map(statusCode: status, message: error.message)
      })
  }
  
  // 5-1. 파일 업로드 + 메시지 전송
  func uploadFiles(roomId: String, fileURLs: [URL]) async throws -> SendChatResponse {
    return try await networkManager.uploadFiles(
      roomId: roomId,
      fileURLs: fileURLs,
      errorMapper: { status, error in
        ChatMessageError.map(statusCode: status, message: error.message)
      }
    )
  }
  
  // MARK: - Socket Methods
  
  func connectToRoom(_ roomId: String) {
    setupSocket(roomId: roomId)
  }
  
  func joinChatRoom(_ roomId: String) {
    socketManager.joinChatRoom(roomId)
  }
  
  func leaveChatRoom(_ roomId: String) {
    socketManager.leaveChatRoom(roomId)
  }
  
  func sendMessageViaSocket(roomId: String, content: String, completion: @escaping (Bool) -> Void) {
    socketManager.sendMessage(roomId: roomId, content: content, completion: completion)
  }
  
  func onMessageReceived(completion: @escaping (ChatMessage) -> Void) {
    socketManager.onMessageReceived { messageData in
      // 서버에서 받은 데이터를 ChatMessage로 변환
      if let chatMessage = self.parseChatMessage(from: messageData) {
        completion(chatMessage)
      }
    }
  }
  
  func disconnectSocket() {
    socketManager.disconnect()
  }
  
  // MARK: - Helper Methods
  
  private func parseChatMessage(from data: [String: Any]) -> ChatMessage? {
    guard 
      let chatId = data["chat_id"] as? String,
      let roomId = data["room_id"] as? String,
      let content = data["content"] as? String,
      let createdAt = data["createdAt"] as? String,
      let updatedAt = data["updatedAt"] as? String,
      let senderData = data["sender"] as? [String: Any],
      let userId = senderData["user_id"] as? String,
      let nick = senderData["nick"] as? String
    else {
      print("❌ 메시지 데이터 파싱 실패: \(data)")
      return nil
    }
    
    let profileImage = senderData["profileImage"] as? String
    let introduction = senderData["introduction"] as? String
    let files = data["files"] as? [String]
    
    let sender = ChatParticipant(
      userId: userId,
      nick: nick,
      profileImage: profileImage,
      introduction: introduction
    )
    
    return ChatMessage(
      chatId: chatId,
      roomId: roomId,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      sender: sender,
      files: files
    )
  }
  
}
