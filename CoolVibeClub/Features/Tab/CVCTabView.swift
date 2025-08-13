//
//  CVCTabView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct CVCTabView: View {
  @State private var selected: Tab = .tab1
  @EnvironmentObject private var tabVisibilityStore: TabVisibilityStore
  
//  init() {
//    FontHelper().checkFont()
//  }
  
  var body: some View {
    ZStack {
      TabView(selection: $selected) {
        Group {
          InsightNavigationView()
            .safeAreaInset(edge: .bottom, spacing: 0) {
              Color.clear
                .frame(height: tabVisibilityStore.isVisible ? 100 : 0)
            }
            .environmentObject(tabVisibilityStore)
            .tag(Tab.tab1)
          
          NearByView()
            .safeAreaInset(edge: .bottom, spacing: 0) {
              Color.clear
                .frame(height: tabVisibilityStore.isVisible ? 100 : 0)
            }
            .environmentObject(tabVisibilityStore)
            .tag(Tab.tab2)
          
          NavigationStack {
            ChatListView()
              .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                  .frame(height: tabVisibilityStore.isVisible ? 100 : 0)
              }
              .onAppear {
                tabVisibilityStore.setVisibility(true)
              }
          }
          .environmentObject(tabVisibilityStore)
          .tag(Tab.tab3)
          
          NavigationStack {
            ProfileView()
              .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                  .frame(height: tabVisibilityStore.isVisible ? 100 : 0)
              }
              .onAppear {
                tabVisibilityStore.setVisibility(true)
              }
          }
          .environmentObject(tabVisibilityStore)
          .tag(Tab.tab4)
        }
        .toolbar(.hidden, for: .tabBar)
      }
      
      // 커스텀 탭바
      VStack {
        Spacer()
        TabBarView(selected: $selected)
          .offset(y: tabVisibilityStore.isVisible ? 0 : 150)
          .opacity(tabVisibilityStore.isVisible ? 1.0 : 0.0)
          .animation(.easeInOut(duration: 0.3), value: tabVisibilityStore.isVisible)
          .onChange(of: tabVisibilityStore.isVisible) { newValue in
            print("🎯 TabBar visibility changed to: \(newValue)")
            print("🎯 TabBar offset: \(newValue ? 0 : 150), opacity: \(newValue ? 1.0 : 0.0)")
          }
      }
    }
    .withGlobalAlert() // 글로벌 알림 연결
  }
}

#Preview {
  CVCTabView()
}
