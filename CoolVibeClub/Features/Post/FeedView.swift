//
//  FeedView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct FeedView: View {
    let profileImage: Image
    let nickname: String
    let timeAgo: String
    let images: [Image]
    let isVideo: Bool
    let isLiked: Bool
    let title: String
    let description: String
    let tags: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 프로필 영역
            HStack(spacing: 12) {
                profileImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(nickname)
                        .font(.system(size: 16, weight: .semibold))
                    Text(timeAgo)
                        .font(.system(size: 13))
                        .foregroundColor(Color(UIColor.systemGray3))
                }
                Spacer()
            }
            // 이미지 3분할 영역
            ZStack(alignment: .topLeading) {
                HStack(spacing: 8) {
                    ZStack {
                        images[0]
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: 200, height: 140)
                            .clipped()
                            .cornerRadius(12)
                        if isVideo {
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .frame(width: 48, height: 48)
                                .foregroundColor(.white)
                                .opacity(0.85)
                        }
                    }
                    VStack(spacing: 8) {
                        images[1]
                            .resizable()
                            .aspectRatio(1.5, contentMode: .fill)
                            .frame(width: 90, height: 66)
                            .clipped()
                            .cornerRadius(10)
                        images[2]
                            .resizable()
                            .aspectRatio(1.5, contentMode: .fill)
                            .frame(width: 90, height: 66)
                            .clipped()
                            .cornerRadius(10)
                    }
                }
                // 하트 아이콘
                Button(action: {}) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(isLiked ? .red : .white)
                        .shadow(radius: 2)
                        .padding(10)
                }
            }
            // 제목
            Text(title)
                .font(.system(size: 18, weight: .bold))
            // 본문
            Text(description)
                .font(.system(size: 15))
                .foregroundColor(Color(UIColor.systemGray3))
            // 태그 버튼
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    HStack(spacing: 4) {
                        if tag.contains("대만") {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 13))
                        }
                        Text(tag)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(UIColor.systemGray6))
                    .foregroundColor(Color(UIColor.systemBlue))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color(UIColor.systemGray4).opacity(0.2), radius: 8, x: 0, y: 2)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView(
            profileImage: Image(systemName: "person.crop.circle"),
            nickname: "씩씩한 새싹이",
            timeAgo: "1시간 34분 전",
            images: [Image("feed_main"), Image("feed_sub1"), Image("feed_sub2")],
            isVideo: true,
            isLiked: false,
            title: "타이페이 스노쿨링 여행",
            description: "끝없이 펼쳐진 바다를 바라보며, 모든 고민이 잠시 멀어지는 느낌이었다. 잔잔한 파도 소리에 마음까지 편안해졌던 시간.",
            tags: ["대만 타이페이", "타이페이 스노쿨링 초보자 스쿨 2기"]
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
}
