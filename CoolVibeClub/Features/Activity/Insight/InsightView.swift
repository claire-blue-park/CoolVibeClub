//
//  InsightView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import Foundation

struct InsightView: View {
  @EnvironmentObject private var navigation: NavigationRouter<HomePath>
  @EnvironmentObject private var tabVisibilityStore: TabVisibilityStore
  @StateObject private var store = InsightStore()
  
  var body: some View {
    NavigationStack {
      // MARK: - 내비바
      VStack(spacing: 0) {
        NavBarView(title: "Cool Vibe Club", rightItems: [.alert(action: {}), .search(action: {})])
          .frame(maxWidth: .infinity)
          .background(CVCColor.grayScale0)
      }
      
      ScrollView(.vertical) {
        VStack {
          // MARK: - 🧩 국가
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
              ForEach(ActivityStaticData.countries) { country in
                CountryIconView(
                  country: country,
                  isSelected: country == store.state.selectedCountry
                )
                .onTapGesture {
                  store.send(.selectCountry(country))
                }
              }
            }
            .padding(.horizontal, 16)
          }
          
          // MARK: - 🧩 카테고리
          ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 12) {
                ForEach(Array(ActivityStaticData.activityCategories.enumerated()), id: \.element) { index, category in
                  ActivityCategoryView(
                    category: category,
                    isSelected: store.state.selectedCategory == category
                  )
                  .id(category)
                  .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                      proxy.scrollTo(category, anchor: .center)
                    }
                    store.send(.selectCategory(category))
                  }
                }
              }
              .padding(.horizontal, 16)
              .padding(.vertical, 8)
            }
            .onChange(of: store.state.selectedCategory) { newValue in
              withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(newValue, anchor: .center)
              }
            }
          }

          if store.state.isLoading {
            ProgressView()
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          } else if let errorMessage = store.state.errorMessage {
            RetryView(errorMessage: errorMessage) {
              store.send(.clearError)
              store.send(.refreshActivities)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          } else if !store.state.activities.isEmpty {
            // MARK: - 🧩 액티비티 내용
            ActivitiesView(newActivities: store.state.newActivities, excitingActivities: store.state.activities)
          } else {
            Text("액티비티가 없습니다")
              .foregroundColor(CVCColor.grayScale45)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
        }
        .padding(.bottom, 200) // 탭바와 겹치지 않기 위한 여백
      }
      .task {
        store.send(.loadActivities)
      }
      .onAppear {
        tabVisibilityStore.setVisibility(true)
      }
    }
  }
}
