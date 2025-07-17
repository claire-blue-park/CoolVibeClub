//
//  PostView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/9/25.
//

import SwiftUI
import UIKit

struct PostView: View {
    var body: some View {
        VStack(spacing: 0) {
            // 상단 타이틀/정렬
            HStack {
                Text("액티비티 포스트")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Text("최신순")
                            .foregroundColor(Color(UIColor.systemBlue))
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(Color(UIColor.systemBlue))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            // 구분선
            Divider().padding(.top, 8)
            // 거리/슬라이더
            HStack {
                Text("Distance")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(UIColor.systemGray3))
                Text("3KM")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color(UIColor.systemBlue))
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 12)
            // 슬라이더
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(UIColor.systemGray4), lineWidth: 1)
                    .frame(height: 32)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(UIColor.systemGray5))
                            .frame(height: 8)
                        Capsule()
                            .fill(Color(UIColor.systemBlue))
                            .frame(width: geo.size.width * 0.7, height: 8)
                        Circle()
                            .fill(Color(UIColor.systemBlue))
                            .frame(width: 18, height: 18)
                            .offset(x: geo.size.width * 0.7 - 9)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 32)
                }
                .frame(height: 32)
            }
            .padding(.horizontal)
            .padding(.top, 4)
            .padding(.bottom, 12)
            // 피드 리스트
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // 첫 번째 피드
                    FeedView(
                        profileImage: Image(systemName: "person.crop.circle"),
                        nickname: "씩씩한 새싹이",
                        timeAgo: "1시간 34분 전",
                        images: [Image("feed_main"), Image("feed_sub1"), Image("feed_sub2")],
                        isVideo: true,
                        isLiked: false,
                        title: "타이페이 스노쿨링 여행",
                        description:
                            "끝없이 펼쳐진 바다를 바라보며, 모든 고민이 잠시 멀어지는 느낌이었다. 잔잔한 파도 소리에 마음까지 편안해졌던 시간.",
                        tags: ["대만 타이페이", "타이페이 스노쿨링 초보자 스쿨 2기"]
                    )
                    Divider()
                    // 두 번째 피드 (하트/이미지/닉네임 등 일부 값만 다르게)
                    FeedView(
                        profileImage: Image("profile2"),
                        nickname: "하늘색 새싹",
                        timeAgo: "3시간 50분 전",
                        images: [Image("feed2_main"), Image("feed2_sub1"), Image("feed2_sub2")],
                        isVideo: true,
                        isLiked: true,
                        title: "패러글라이딩 체험",
                        description: "하늘을 날며 세상을 내려다보는 짜릿한 경험! 두려움도 잠시, 자유로움이 가득했던 순간.",
                        tags: ["강원도 양양", "패러글라이딩 초보자 체험"]
                    )
                }
                .padding(.top, 8)
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    PostView()
}
