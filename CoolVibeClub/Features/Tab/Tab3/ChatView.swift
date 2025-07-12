//
//  ChatView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/9/25.
//

import SwiftUI

struct ChatView: View {
    let room: ChatRoom
    @State private var messages: [Message] = Message.sampleData
    @State private var input: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 바
            HStack {
                Text(room.name)
                    .font(.system(size: 20, weight: .bold))
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            // 메시지 리스트
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(messages) { msg in
                        HStack {
                            if msg.isMe { Spacer() }
                            Text(msg.text)
                                .padding(12)
                                .background(msg.isMe ? Color.blue : Color(.systemGray5))
                                .foregroundColor(msg.isMe ? .white : .black)
                                .cornerRadius(16)
                            if !msg.isMe { Spacer() }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            // 입력창
            HStack {
                TextField("메시지를 입력하세요", text: $input)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    guard !input.isEmpty else { return }
                    messages.append(Message(text: input, isMe: true))
                    input = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .padding(8)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isMe: Bool
    static let sampleData: [Message] = [
        Message(text: "안녕하세요!", isMe: false),
        Message(text: "안녕하세요! 반가워요.", isMe: true),
        Message(text: "오늘 일정 괜찮으세요?", isMe: false),
        Message(text: "네! 좋아요.", isMe: true)
    ]
}

#Preview {
    ChatView(room: ChatRoom.sampleData[0])
}
