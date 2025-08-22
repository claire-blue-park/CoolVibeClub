//
//  ExcitingSection.swift
//  CoolVibeClub
//
//  Created by Claire on 8/18/25.
//

import SwiftUI

struct ExcitingSection: View {
  let title: String
  let activities: [ActivityInfoData]
  let navigation: NavigationRouter<HomePath>
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // Section Title
      HStack {
        Text(title)
          .foregroundStyle(CVCColor.grayScale90)
          .font(.system(size: 14, weight: .bold))
        
        Spacer()
      }
      .padding(.horizontal, 16)
      
      // Activities Grid - 세로 스크롤
      LazyVStack(spacing: 28) {
        ForEach(activities, id: \.id) { activity in
          Button {
            navigation.push(.activityDetail(activity))
          } label: {
            ActivityCard(activity: activity)
              .padding(.horizontal, 16)
          }
        }
      }
    }
  }
}
