//
//  ChatListView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

// ChatRoomsResponse, ChatRoom 모델 import 필요

struct DefaultErrorResponse: Decodable {}

struct ChatListView: View {
  @StateObject private var store = ChatListStore()
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {

        // MARK: - 검색창
        BorderLineSearchBar(
          searchText: Binding(
            get: { store.state.searchText },
            set: { store.send(.searchTextChanged($0)) }
          ),
          placeholder: "채팅방 검색",
          onSearchTextChanged: { searchText in
            store.send(.searchTextChanged(searchText))
          }
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
        
        ZStack(alignment: .top) {
          if store.state.isLoading {
            ProgressView("채팅방 목록을 불러오는 중...")
              .padding(.top, 100)
          } else if let errorMessage = store.state.errorMessage {
            VStack(spacing: 12) {
              Text(errorMessage)
                .foregroundColor(.red)
                .padding(.top, 100)
              Button("다시 시도") {
                store.send(.clearError)
                store.send(.refreshChatRooms)
              }
              .padding(.horizontal, 20)
              .padding(.vertical, 8)
              .background(CVCColor.primary)
              .foregroundColor(.white)
              .cornerRadius(8)
            }
          } else if store.state.chatRooms.isEmpty {
            VStack {
              Spacer()
              Text("아직 채팅내용이 없습니다")
                .font(.system(size: 13))
                .foregroundColor(.gray)
              Spacer()
            }
          } else {
            List(store.state.chatRooms, id: \.roomId) { room in
              let opponent = getOpponent(from: room)
              ZStack {
                NavigationLink(destination: ChatView(roomId: room.roomId, opponentNick: opponent.nick)) {
                  EmptyView()
                }
                .opacity(0)
                
                HStack(spacing: 16) {
                  Circle()
                    .fill(CVCColor.primaryLight)
                    .frame(width: 48, height: 48)
                    .overlay(
                      Text(opponent.nick.prefix(2))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(CVCColor.grayScale0)
                    )
                  
                  VStack(alignment: .leading, spacing: 4) {
                    Text(opponent.nick)
                      .font(.system(size: 16, weight: .semibold))
                      .foregroundStyle(CVCColor.grayScale90)
                      .lineLimit(1)
                    
                    Text(getLastChatDisplayText(from: room))
                      .font(.system(size: 12))
                      .foregroundStyle(CVCColor.grayScale60)
                      .lineLimit(1)
                  }
                  
                  Spacer()
                  
                  // 시간
                  Text(formatTime(room.updatedAt))
                    .font(.system(size: 11))
                    .foregroundStyle(CVCColor.grayScale60)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(CVCColor.grayScale0)
              }
              .listRowInsets(EdgeInsets())
              .listRowSeparator(.hidden)
            }
            .listStyle(PlainListStyle())
          }
        }
        .frame(maxHeight: .infinity)
      }
    }
    .onAppear {
      store.send(.loadChatRooms)
    }
  }
  
  // MARK: - 상대방 찾기
  private func getOpponent(from room: ChatRoom) -> Participant {
    let currentUserId = UserDefaultsHelper.shared.getUserId()
    
    // 현재 사용자가 아닌 참가자를 찾기
    let opponent = room.participants.first { participant in
      participant.userId != currentUserId
    }
    
    // 상대방을 찾지 못한 경우 (혹시 모를 상황) 첫 번째 참가자 반환
    return opponent ?? room.participants.first ?? Participant(userId: "", nick: "Unknown", profileImage: nil, introduction: nil)
  }
  
  // MARK: - 마지막 채팅 표시 텍스트
  private func getLastChatDisplayText(from room: ChatRoom) -> String {
    guard let lastChat = room.lastChat else {
      return "새로운 채팅방"
    }
    
    // 파일이 있고 내용이 비어있는 경우
    if let files = lastChat.files, !files.isEmpty, lastChat.content.isEmpty {
      return "📎 파일"
    }
    
    // 일반 텍스트 메시지
    return lastChat.content.isEmpty ? "새로운 채팅방" : lastChat.content
  }
  
  // MARK: - 시간 포맷팅
  private func formatTime(_ timeString: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    
    guard let date = formatter.date(from: timeString) else {
      return ""
    }
    
    let now = Date()
    let calendar = Calendar.current
    
    if calendar.isDate(date, inSameDayAs: now) {
      // 오늘이면 시간만 표시
      let timeFormatter = DateFormatter()
      timeFormatter.dateFormat = "HH:mm"
      return timeFormatter.string(from: date)
    } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now) ?? now) {
      return "어제"
    } else {
      // 그 외에는 날짜 표시
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "MM/dd"
      return dateFormatter.string(from: date)
    }
  }
  
}

#Preview {
  ChatListView()
}
