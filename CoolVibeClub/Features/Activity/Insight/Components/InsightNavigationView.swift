//
//  InsightNavigationView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/26/25.
//

import SwiftUI

struct InsightNavigationView: View {
  @StateObject private var navigation = NavigationRouter<HomePath>()
  
  var body: some View {
    NavigationStack(path: $navigation.path) {
      InsightView()
        .environmentObject(navigation)
        .navigationDestination(for: HomePath.self) { path in
          switch path {
          case .activities:
            ActivitiesView()
              .environmentObject(navigation)
          case .activityDetail(let activityData):
            ActivityDetailView(activityData: activityData)
              .environmentObject(navigation)
          case .chat(let userId, let nickname):
            ChatView(roomId: "temp_\(userId)", opponentNick: nickname)
            .environmentObject(navigation)
          }
        }
    }
  }
}
