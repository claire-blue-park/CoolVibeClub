//
//  ChatListFeature.swift
//  CoolVibeClub
//
//  TCA(The Composable Architecture) 스타일 구조
//  🔥 이해 필수: Action(액션), State(상태), Reducer(로직) 패턴
//

import SwiftUI
import Foundation
import Alamofire

// MARK: - 🔥 State (상태 관리)
/// ChatList 화면의 모든 상태를 담는 구조체
/// 🔥 중요: 화면에 보여지는 모든 데이터와 상태가 여기에 모임
struct ChatListState {
  // 채팅방 관련 상태
  var chatRooms: [ChatRoom] = []
  var allChatRooms: [ChatRoom] = []
  var searchText: String = ""
  
  // UI 상태
  var isLoading: Bool = false
  var errorMessage: String? = nil
}

// MARK: - 🔥 Action (액션 정의)
/// 사용자가 할 수 있는 모든 행동을 열거형으로 정의
/// 🔥 중요: 버튼 클릭, 검색, 새로고침 등 모든 사용자 행동이 Action이 됨
enum ChatListAction {
  // 데이터 로딩 액션
  case loadChatRooms                       // 채팅방 목록 로드
  case refreshChatRooms                    // 채팅방 목록 새로고침
  
  // 검색 관련 액션
  case searchTextChanged(String)           // 검색어 변경
  case clearSearch                         // 검색어 초기화
  
  // 에러 처리 액션
  case clearError                          // 에러 메시지 클리어
  case setError(String?)                   // 에러 메시지 설정
  
  // 로딩 상태 액션
  case setLoading(Bool)                    // 로딩 상태 변경
  
  // 내부 액션 (Private)
  case _chatRoomsLoaded([ChatRoom])        // 채팅방 로드 완료 (내부용)
  case _searchResultsUpdated([ChatRoom])   // 검색 결과 업데이트 (내부용)
}

// MARK: - 🔥 Store (상태 저장소)
/// State와 Action을 연결하고 관리하는 클래스
/// 🔥 중요: 이 클래스가 모든 상태 변화를 처리함
@MainActor
final class ChatListStore: ObservableObject {
  // 현재 상태 (Published로 UI 자동 업데이트)
  @Published var state = ChatListState()
  
  init() {}
  
  // MARK: - 🔥 Reducer (액션 처리 로직)
  /// Action이 들어왔을 때 State를 어떻게 변경할지 정의
  /// 🔥 중요: 모든 비즈니스 로직이 여기에 집중됨
  func send(_ action: ChatListAction) {
    switch action {
      
    // 데이터 로딩 처리
    case .loadChatRooms, .refreshChatRooms:
      performChatRoomsLoading()
      
    // 검색 관련 처리
    case .searchTextChanged(let searchText):
      state.searchText = searchText
      send(._searchResultsUpdated(filterChatRooms(searchText: searchText, allRooms: state.allChatRooms)))
      
    case .clearSearch:
      state.searchText = ""
      send(._searchResultsUpdated(state.allChatRooms))
      
    // 에러 처리
    case .clearError:
      state.errorMessage = nil
      
    case .setError(let message):
      state.errorMessage = message
      
    // 로딩 상태 처리
    case .setLoading(let isLoading):
      state.isLoading = isLoading
      
    // 내부 액션 처리
    case ._chatRoomsLoaded(let chatRooms):
      state.allChatRooms = chatRooms
      state.chatRooms = filterChatRooms(searchText: state.searchText, allRooms: chatRooms)
      
    case ._searchResultsUpdated(let filteredRooms):
      state.chatRooms = filteredRooms
    }
  }
  
  // MARK: - 🔥 비동기 작업 함수들
  
  /// 채팅방 목록 로딩 수행
  private func performChatRoomsLoading() {
    Task {
      await loadChatRooms()
    }
  }
  
  /// 채팅방 목록을 서버에서 로딩
  private func loadChatRooms() async {
    await MainActor.run {
      send(.setLoading(true))
      send(.setError(nil))
    }
    
    do {
      let response: ChatRoomsResponse = try await NetworkManager.shared.fetch(
        from: ChatEndpoint(requestType: .fetchChatRooms)
      ) { statusCode, errorResponse in
        return ChatRoomError.map(statusCode: statusCode, message: errorResponse.message)
      }
      
      await MainActor.run {
        send(._chatRoomsLoaded(response.data))
        send(.setLoading(false))
      }
      
      print("✅ 채팅방 목록 로딩 성공: \(response.data.count)개")
      
    } catch {
      print("❌ 채팅방 목록 로딩 실패: \(error)")
      
      await MainActor.run {
        send(.setError("채팅방 목록을 불러오지 못했습니다: \(error.localizedDescription)"))
        send(.setLoading(false))
      }
    }
  }
  
  // MARK: - 🔥 Helper Functions
  
  /// 채팅방 필터링 (검색 기능)
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
  
  /// 상대방 찾기 (현재 사용자가 아닌 참가자)
  private func getOpponent(from room: ChatRoom) -> Participant {
    let currentUserId = UserDefaultsHelper.shared.getUserId()
    
    let opponent = room.participants.first { participant in
      participant.userId != currentUserId
    }
    
    return opponent ?? room.participants.first ?? Participant(userId: "", nick: "Unknown", profileImage: nil, introduction: nil)
  }
}