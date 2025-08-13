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
  @StateObject private var intent = InsightIntent()
  
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
          // MARK: - 국가
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
              ForEach(ActivityState.countries) { country in
                CountryIconView(
                  country: country,
                  isSelected: country.name == intent.state.activityState.selectedCountry.name
                )
                .onTapGesture {
                  intent.send(.selectCountry(country))
                }
              }
            }
            .padding(.horizontal, 16)
          }
          
          // MARK: - 카테고리
          ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
              HStack(spacing: 12) {
                ForEach(Array(ActivityState.activityCategories.enumerated()), id: \.element) { index, category in
                  ActivityCategoryView(
                    category: category,
                    isSelected: intent.state.activityState.selectedCategory == category
                  )
                  .id(category)
                  .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                      proxy.scrollTo(category, anchor: .center)
                    }
                    intent.send(.selectCategory(category))
                  }
                }
              }
              .padding(.horizontal, 16)
              .padding(.vertical, 8)
            }
            .onChange(of: intent.state.activityState.selectedCategory) { newValue in
              withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(newValue, anchor: .center)
              }
            }
          }
          
          // MARK: - 액티비티
          //          HStack {
          //            Text("NEW 액티비티")
          //              .foregroundStyle(CVCColor.grayScale90)
          //              .font(.system(size: 14, weight: .bold))
          //            Spacer()
          //            Button {
          //              handleIntent(.navigateToAllActivities)
          //              navigation.push(.activities)
          //            } label: {
          //              Text("View All")
          //                .foregroundStyle(CVCColor.primary)
          //                .font(.system(size: 12, weight: .bold))
          //            }
          //          }
          //          .padding(.vertical, 16)
          //          .padding(.horizontal, 16)
          
          if intent.state.activityState.isLoading {
            Spacer()
            ProgressView()
            Spacer()
          } else if let errorMessage = intent.state.activityState.errorMessage {
            VStack(spacing: 16) {
              Text("오류 발생")
                .font(.headline)
                .foregroundColor(.red)
              Text(errorMessage)
                .font(.caption)
                .foregroundColor(.gray)
              Button("다시 시도") {
                intent.send(.clearError)
                intent.send(.refreshActivities)
              }
              .padding()
              .background(CVCColor.primary)
              .foregroundColor(.white)
              .cornerRadius(8)
            }
            .padding()
            Spacer()
          } else if !intent.state.activityState.activities.isEmpty {
            ActivitiesView(newActivities: intent.state.newActivities, excitingActivities: intent.state.activityState.activities)
          } else {
            Spacer()
          }
        }
        .padding(.bottom, 200) // 하단 여백 추가하여 탭바와 겹치지 않게 함
      }
      .task {
        intent.send(.loadActivities)
      }
      .onAppear {
        tabVisibilityStore.setVisibility(true)
      }
    }
  }
}
