//
//  ProfileView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/9/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                // 상단 프로필 카드
                VStack(spacing: 16) {
                    ZStack(alignment: .bottomTrailing) {
                        Image("profile_sample")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 6))
                            .shadow(radius: 4)
                        Button(action: {}) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 36, height: 36)
                                    .shadow(radius: 2)
                                Image(systemName: "camera.fill")
                                    .foregroundColor(Color(UIColor.systemBlue))
                            }
                        }
                        .offset(x: 8, y: 8)
                    }
                    HStack(alignment: .center, spacing: 8) {
                        Text("씩씩한 새싹이")
                            .font(.system(size: 26, weight: .heavy))
                        Button(action: {}) {
                            Text("수정")
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color(UIColor.systemGray6))
                                .foregroundColor(Color(UIColor.systemBlue))
                                .cornerRadius(12)
                        }
                    }
                    Text("액티비티를 즐기고 기록하는 것을 좋아하는 새싹이입니다.")
                        .font(.system(size: 15))
                        .foregroundColor(Color(UIColor.systemGray))
                        .multilineTextAlignment(.center)
                    // 태그 버튼
                    HStack(spacing: 10) {
                        ForEach(["1위 투어", "2위 액티비티", "3위 체험"], id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 14, weight: .semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(Color(UIColor.systemBlue).opacity(0.08))
                                .foregroundColor(Color(UIColor.systemBlue))
                                .cornerRadius(16)
                        }
                    }
                    // 사용 금액/포인트 카드
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("₩ 1,342,545원")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            Text("총 사용 금액")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(UIColor.systemGray))
                        }
                        .frame(maxWidth: .infinity)
                        VStack(spacing: 4) {
                            Text("148,400P")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            Text("누적 적립 포인트")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(UIColor.systemGray))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(18)
                    .shadow(color: Color(UIColor.systemGray4).opacity(0.15), radius: 8, x: 0, y: 2)
                }
                .padding(.top, 32)
                // 내 액티비티 섹션
                VStack(spacing: 0) {
                    HStack {
                        Text("내 액티비티")
                            .font(.system(size: 18, weight: .bold))
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
                    .padding(.horizontal, 4)
                    .padding(.bottom, 8)
                    // 검색창
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(UIColor.systemGray3))
                        TextField("내 액티비티를 검색해보세요.", text: .constant(""))
                            .font(.system(size: 15))
                    }
                    .padding(12)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(12)
                    .padding(.bottom, 16)
                    // 액티비티 카드 리스트
                    VStack(spacing: 18) {
                        // 첫 번째 카드
                      ActivityHistoryCardView(
                            image: Image("activity_ski"),
                            title: "겨울 새싹 스키 원정대",
                            date: "2025년 4월 21일 오후 3:00 (익사이팅)",
                            location: "스위스 융프라우",
                            price: "123,000원",
                            rating: 5.0
                        )
                        // 두 번째 카드
                      ActivityHistoryCardView(
                            image: Image("activity_skate"),
                            title: "새싹 스케이트 세션",
                            date: "2025년 3월 18일 오후 5:00 (체험)",
                            location: "캘리포니아 베니스 비치",
                            price: "209,000원",
                            rating: nil
                        )
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color(UIColor.systemGray4).opacity(0.08), radius: 8, x: 0, y: 2)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}

// 프로필 전용 액티비티 카드 뷰 컴포넌트
struct ProfileActivityCardView: View {
    let image: Image
    let title: String
    let date: String
    let location: String
    let price: String
    let rating: Double?
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            image
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(width: 64, height: 64)
                .cornerRadius(12)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Text(date)
                    .font(.system(size: 13))
                    .foregroundColor(Color(UIColor.systemGray))
                Text(location)
                    .font(.system(size: 13))
                    .foregroundColor(Color(UIColor.systemGray3))
                HStack(spacing: 8) {
                    Text(price)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(UIColor.systemBlue))
                    if let rating = rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.pink)
                                .font(.system(size: 15))
                            Text(String(format: "%.1f", rating))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.pink)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(12)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    ProfileView()
}
