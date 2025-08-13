//
//  ChatListIntent.swift
//  CoolVibeClub
//
//  Created by Claire on 8/12/25.
//

import Foundation

// MARK: - ChatList State
struct ChatListState: StateMarker {
  var isLoading: Bool = false
  var error: String? = nil
  var chatRooms: [ChatRoom] = []
  var allChatRooms: [ChatRoom] = []
  var searchText: String = ""
}

// MARK: - ChatList Actions
enum ChatListAction: ActionMarker {
  case loadChatRooms
  case searchTextChanged(String)
  case refresh
  case clearError
}

// MARK: - ChatList Intent
final class ChatListIntent: Intent, ObservableObject {
  typealias State = ChatListState
  typealias ActionType = ChatListAction
  
  @Published var state = ChatListState()
  
  init() {}
  
  func send(_ action: ChatListAction) {
    switch action {
    case .loadChatRooms:
      loadChatRooms()
    case .searchTextChanged(let searchText):
      updateSearchText(searchText)
    case .refresh:
      refresh()
    case .clearError:
      DispatchQueue.main.async {
        self.state.error = nil
      }
    }
  }
  
  private func loadChatRooms() {
    DispatchQueue.main.async {
      self.state.isLoading = true
      self.state.error = nil
    }
    
    Task {
      do {
        let response: ChatRoomsResponse = try await NetworkManager.shared.fetch(
          from: ChatEndpoint(requestType: .fetchChatRooms)
        ) { statusCode, errorResponse in
          return ChatRoomError.map(statusCode: statusCode, message: errorResponse.message)
        }
        
        DispatchQueue.main.async {
          self.state.allChatRooms = response.data
          self.state.chatRooms = response.data
          self.state.isLoading = false
        }
        
        print("✅ 채팅방 목록 로딩 성공: \(response.data.count)개")
        
      } catch {
        print("❌ 채팅방 목록 로딩 실패: \(error)")
        
        DispatchQueue.main.async {
          self.state.error = "채팅방 목록을 불러오지 못했습니다: \(error.localizedDescription)"
          self.state.isLoading = false
        }
      }
    }
  }
  
  private func updateSearchText(_ searchText: String) {
    DispatchQueue.main.async {
      self.state.searchText = searchText
      self.state.chatRooms = self.filterChatRooms(searchText: searchText, allRooms: self.state.allChatRooms)
    }
  }
  
  private func refresh() {
    loadChatRooms()
  }
  
  private func filterChatRooms(searchText: String, allRooms: [ChatRoom]) -> [ChatRoom] {
    if searchText.isEmpty {
      return allRooms
    } else {
      return allRooms.filter { room in
        let opponent = getOpponent(from: room)
        let nicknameMatch = opponent.nick.localizedCaseInsensitiveContains(searchText)
        let lastChatMatch = room.lastChat?.content.localizedCaseInsensitiveContains(searchText) ?? false
        return nicknameMatch || lastChatMatch
      }
    }
  }
  
  private func getOpponent(from room: ChatRoom) -> Participant {
    let currentUserId = UserDefaultsHelper.shared.getUserId()
    
    let opponent = room.participants.first { participant in
      participant.userId != currentUserId
    }
    
    return opponent ?? room.participants.first ?? Participant(userId: "", nick: "Unknown", profileImage: nil, introduction: nil)
  }
}
