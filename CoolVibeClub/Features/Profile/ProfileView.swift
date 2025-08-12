//
//  ProfileView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
  
  @State var nick = "씩씩한 새싹이"
  @State var bio = "액티비티를 즐기고 기록하는 것을 좋아합니다."
  @State var tags = ["투어", "액티비티", "체험"]
  @State var totalPointEarned = 147400
  @State var totalAmountSpent = 2342545
  @State var searchText = ""
  
    var body: some View {
      NavigationStack {
        ScrollView(.vertical, showsIndicators: false) {
          VStack(spacing: 24) {
            ProfileImageView()
              .padding(.vertical, 20)
            ProfileContentView(nick: $nick,
                               bio: $bio,
                               tags: $tags,
                               totalPointEarned: $totalPointEarned,
                               totalAmountSpent: $totalAmountSpent)
            MyActivityView(searchText: $searchText)
          }
          .padding(.horizontal, 16)
          .padding(.top, 0)
        }
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            // 설정
            Button {
              print("clicked")
            } label: {
              CVCImage.setting.template
                .frame(width: 24, height: 24)
                .foregroundColor(CVCColor.grayScale75)
                .padding(.trailing, 4)
            }
          }
        }
      }
    }
}

#Preview {
    ProfileView()
}
