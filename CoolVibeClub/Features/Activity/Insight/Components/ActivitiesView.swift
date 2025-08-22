//
//  ActivitiesView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct ActivitiesView: View {
  @EnvironmentObject private var navigation: NavigationRouter<HomePath>
  
  let newActivities: [ActivityInfoData]
  let excitingActivities: [ActivityInfoData]
  
  init(newActivities: [ActivityInfoData] = [], excitingActivities: [ActivityInfoData] = []) {
    self.newActivities = newActivities
    self.excitingActivities = excitingActivities
  }
  
  var body: some View {
    ScrollView {
      VStack(spacing: 4) {
        LazyVStack(spacing: 28) {
          // MARK: - 🧩 NEW
          NewSection(
            title: "NEW 액티비티",
            activities: newActivities,
            navigation: navigation
          )
          
          // MARK: - 🧩 배너
          SlideBanner()
          
          // MARK: - 🧩 EXCTING
          ExcitingSection(
            title: "익사이팅 액티비티",
            activities: excitingActivities,
            navigation: navigation
          )
        }
      }
      .background(CVCColor.grayScale0)
    }
  }
  
}
