//
//  NewSection.swift
//  CoolVibeClub
//
//  Created by Claire on 8/18/25.
//

import SwiftUI

struct NewSection: View {
  let title: String
  let activities: [ActivityInfoData]
  let navigation: NavigationRouter<HomePath>
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      // Section Title
      Text(title)
        .foregroundStyle(CVCColor.grayScale90)
        .font(.system(size: 14, weight: .bold))
        .padding(16)
      
      // Activities Grid
      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 0) {
          ForEach(activities, id: \.id) { activity in
            Button {
              navigation.push(.activityDetail(activity))
            } label: {
              ActivityCardWithBorder(
                activity: activity,
                image: nil
              )
            }
          }
        }
      }
    }
  }
}
