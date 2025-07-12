//
//  ChatListView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/10/25.
//

import SwiftUI

struct ChatListView: View {
    @State private var chatRooms: [ChatRoom] = ChatRoom.sampleData

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                List(chatRooms) { room in
                    NavigationLink(destination: ChatView(room: room)) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 48, height: 48)
                                .overlay(Text(room.initials).font(.headline))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(room.name)
                                    .font(.system(size: 16, weight: .semibold))
                                Text(room.lastMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 6) {
                                Text(room.time)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                if room.unreadCount > 0 {
                                    Text("\(room.unreadCount)")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .padding(6)
                                        .background(Circle().fill(Color.blue))
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.top, 56)  // NavBarView 높이만큼 패딩
            }
            .frame(maxHeight: .infinity)
            .navigationBarHidden(true)
        }
    }
}

struct ChatRoom: Identifiable {
    let id = UUID()
    let name: String
    let lastMessage: String
    let time: String
    let unreadCount: Int
    var initials: String { String(name.prefix(2)) }

    static let sampleData: [ChatRoom] = [
        ChatRoom(name: "홍길동", lastMessage: "안녕하세요!", time: "오후 2:30", unreadCount: 2),
        ChatRoom(
            name: "CoolVibeClub", lastMessage: "새로운 소식이 있습니다.", time: "오전 11:10", unreadCount: 0),
        ChatRoom(name: "김철수", lastMessage: "사진 잘 받았어요.", time: "어제", unreadCount: 1),
        ChatRoom(name: "이영희", lastMessage: "감사합니다!", time: "어제", unreadCount: 0),
    ]
}

#Preview {
    ChatListView()
}
