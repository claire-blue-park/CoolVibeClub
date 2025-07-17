//
//  ActivityHistoryCardView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/14/25.
//

import SwiftUI

struct ActivityHistoryCardView: View {
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
  ActivityHistoryCardView(
      image: Image("activity_ski"),
      title: "겨울 새싹 스키 원정대",
      date: "2025년 4월 21일 오후 3:00 (익사이팅)",
      location: "스위스 융프라우",
      price: "123,000원",
      rating: 5.0
  )
}
