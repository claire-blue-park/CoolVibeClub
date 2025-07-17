//
//  ChatListView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/10/25.
//

import SwiftUI

// ChatRoomsResponse, ChatRoom 모델 import 필요

struct DefaultErrorResponse: Decodable {}

struct ChatListView: View {
    @State private var chatRooms: [ChatRoom] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                if isLoading {
                    ProgressView("채팅방 목록을 불러오는 중...")
                        .padding(.top, 100)
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 100)
                } else {
                    List(chatRooms, id: \.roomId) { room in
                        // NavigationLink(destination: ChatView(room: room)) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Text(room.participants.first?.nick.prefix(2) ?? "").font(
                                        .headline))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(room.participants.first?.nick ?? "")
                                    .font(.system(size: 16, weight: .semibold))
                                Text(room.lastChat?.content ?? "")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 6) {
                                Text(room.updatedAt)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                // TODO: 안읽은 메시지 뱃지 등 필요시 추가
                            }
                        }
                        .padding(.vertical, 8)
                        // }
                    }
                    .listStyle(PlainListStyle())
                    .padding(.top, 56)  // NavBarView 높이만큼 패딩
                }
            }
            .frame(maxHeight: .infinity)
            .navigationBarHidden(true)
        }
        .onAppear {
            fetchChatRooms()
        }
    }

    private func fetchChatRooms() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let response: ChatRoomsResponse = try await NetworkManager.shared.fetch(
                    from: ChatEndpoint(requestType: .fetchChatRooms),
                    responseError: ChatResponseError.self
                )
                chatRooms = response.data
                isLoading = false
            } catch {
                print("네트워크 에러:", error)
                errorMessage = "채팅방 목록을 불러오지 못했습니다."
                isLoading = false
            }
        }
    }
}
