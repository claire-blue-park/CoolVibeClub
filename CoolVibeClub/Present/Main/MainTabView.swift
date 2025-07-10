//
//  MainTabView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/9/25.
//

import SwiftUI

struct MainTabView: View {
  
  @State private var selected: Tab = .tab1
  
  var body: some View {
    ZStack {
      TabView(selection: $selected) {
        Group {
          NavigationStack {
            WorldView()
              .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                  .frame(height: 100)
              }
          }
          .tag(Tab.tab1)
          
          NavigationStack {
            PostView()
              .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                  .frame(height: 100)
              }
          }
          .tag(Tab.tab2)
          
          NavigationStack {
            ChatView()
              .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                  .frame(height: 100)
              }
          }
          .tag(Tab.tab3)
          
          NavigationStack {
            ProfileView()
              .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                  .frame(height: 100)
              }
          }
          .tag(Tab.tab4)
        
        }
        .toolbar(.hidden, for: .tabBar)
      }
      
      // UI
      VStack {
        Spacer()
        TabBarView(selected: $selected)
      }
    }
  }
}

#Preview {
  MainTabView()
}
