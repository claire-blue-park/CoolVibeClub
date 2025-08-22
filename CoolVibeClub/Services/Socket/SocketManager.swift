//
//  SocketManager.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation
import SocketIO

final class SocketManager: ObservableObject {
  static let shared = SocketManager()
  
  private var manager: SocketIO.SocketManager?
  private var socket: SocketIOClient?
  
  @Published var isConnected = false
  
  private init() {}
  
  // MARK: - Connection Methods
  
  func connect(roomId: String) {
    guard let url = URL(string: "http://activity.sesac.kr:34501") else {
      print("❌ Invalid socket URL")
      return
    }
    
    // 인증 토큰 가져오기 (UserDefaults -> KeyChain 순으로 시도)
    let accessToken = UserDefaultsHelper.shared.getAccessToken() ?? KeyChainHelper.shared.loadToken()
    print("🔑 Socket 연결용 액세스 토큰: \(accessToken?.prefix(20) ?? "없음")...")
    
    var headers = ["SeSACKey": APIKeys.SesacKey]
    if let token = accessToken {
      headers["Authorization"] = "Bearer \(token)"
    }
    
    // Socket.IO 매니저 생성
    manager = SocketIO.SocketManager(socketURL: url, config: [
      .log(true),
      .compress,
      .extraHeaders(headers)
    ])
    
    socket = manager?.socket(forNamespace: "/chats-\(roomId)")
    
    // 연결 이벤트 리스너
    socket?.on(clientEvent: .connect) { [weak self] data, ack in
      print("✅ Socket 연결됨")
      DispatchQueue.main.async {
        self?.isConnected = true
      }
    }
    
    socket?.on(clientEvent: .disconnect) { [weak self] data, ack in
      print("❌ Socket 연결 해제됨")
      DispatchQueue.main.async {
        self?.isConnected = false
      }
    }
    
    socket?.on(clientEvent: .error) { data, ack in
      print("❌ Socket 에러: \(data)")
    }
    
    // 연결 시작
    socket?.connect()
  }
  
  func disconnect() {
    socket?.disconnect()
    socket = nil
    manager = nil
    
    DispatchQueue.main.async {
      self.isConnected = false
    }
  }
  
  // MARK: - Chat Methods
  
  func joinChatRoom(_ roomId: String) {
    guard let socket = socket, socket.status == .connected else {
      print("❌ Socket이 연결되지 않음 - 상태: \(socket?.status.rawValue ?? -1)")
      return
    }
    
    socket.emit("joinRoom", roomId)
    print("🔗 채팅방 참여 요청: \(roomId)")
  }
  
  func leaveChatRoom(_ roomId: String) {
    guard let socket = socket, socket.status == .connected else { return }
    
    socket.emit("leaveRoom", roomId)
    print("🚪 채팅방 나가기: \(roomId)")
  }
  
  func sendMessage(roomId: String, content: String, completion: @escaping (Bool) -> Void) {
    guard let socket = socket, socket.status == .connected else {
      print("❌ 메시지 전송 실패: Socket 연결되지 않음 - 상태: \(socket?.status.rawValue ?? -1)")
      completion(false)
      return
    }
    
    let messageData: [String: Any] = [
      "roomId": roomId,
      "content": content
    ]
    
    print("📤 메시지 전송 시도: \(content) to room: \(roomId)")
    socket.emit("sendMessage", messageData) {
      completion(true)
      print("✅ 메시지 전송 완료: \(content)")
    }
  }
  
  // MARK: - Event Listeners
  
  func onMessageReceived(completion: @escaping ([String: Any]) -> Void) {
    socket?.on("messageReceived") { data, ack in
      if let messageData = data.first as? [String: Any] {
        completion(messageData)
      }
    }
  }
  
  func onUserJoined(completion: @escaping ([String: Any]) -> Void) {
    socket?.on("userJoined") { data, ack in
      if let userData = data.first as? [String: Any] {
        completion(userData)
      }
    }
  }
  
  func onUserLeft(completion: @escaping ([String: Any]) -> Void) {
    socket?.on("userLeft") { data, ack in
      if let userData = data.first as? [String: Any] {
        completion(userData)
      }
    }
  }
  
  // 이벤트 리스너 제거
  func removeAllListeners() {
    socket?.removeAllHandlers()
  }
}
