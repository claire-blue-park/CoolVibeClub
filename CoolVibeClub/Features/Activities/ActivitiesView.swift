//
//  ActivitiesView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct ActivitiesView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.activityClient) private var activityClient
  @EnvironmentObject private var navigation: NavigationRouter<HomePath>
  @EnvironmentObject private var tabVisibilityStore: TabVisibilityStore
  
  let newActivities: [ActivityInfoData]
  let excitingActivities: [ActivityInfoData]
  @State private var activities: [ActivityInfoData] = []
  @State private var isLoading: Bool = false
  @State private var errorMessage: String?
  
  init(newActivities: [ActivityInfoData] = [], excitingActivities: [ActivityInfoData] = []) {
    self.newActivities = newActivities
    self.excitingActivities = excitingActivities
  }
  
  var body: some View {
    VStack(spacing: 0) {

        // MARK: - 내용
        if isLoading {
          Spacer()
          ProgressView("액티비티를 불러오는 중...")
            .font(.system(size: 12))
            .foregroundColor(CVCColor.grayScale45)
          Spacer()
        } else if let errorMessage = errorMessage {
          Spacer()
          VStack(spacing: 16) {
            Text("오류 발생")
              .font(.headline)
              .foregroundColor(.red)
            Text(errorMessage)
              .font(.caption)
              .foregroundColor(.gray)
            Button("다시 시도") {
              loadActivities()
            }
            .padding()
            .background(CVCColor.primary)
            .foregroundColor(.white)
            .cornerRadius(8)
          }
          .padding()
          Spacer()
        } else if activities.isEmpty {
          Spacer()
          Text("표시할 액티비티가 없습니다")
            .foregroundColor(CVCColor.grayScale45)
          Spacer()
        } else {
          ScrollView {
            VStack(spacing: 4) {

              LazyVStack(spacing: 28) {
                // 추천 액티비티 섹션
                RecommandActivitySection(
                  title: "NEW 액티비티",
                  activities: newActivities,
                  navigation: navigation
                )
                
                // MARK: - 배너
                SlideBanner()
                
                // 익사이팅 액티비티 섹션 (세로 스크롤)
                ExcitingActivitySection(
                  title: "익사이팅 액티비티",
                  activities: excitingActivities,
                  navigation: navigation
                )
              } 
//              .padding(.top, 20)
            }
            .background(CVCColor.grayScale0)
          }
        }

      }
//    .navigationTitle("전체보기")
//    .navigationBarTitleDisplayMode(.inline)
//    .navigationBarBackButtonHidden(true)
//    .toolbar {
//      ToolbarItem(placement: .navigationBarLeading) {
//        BackButton(foregroundColor: CVCColor.grayScale90)
//      }
//    }
    .onAppear {
//      tabVisibilityStore.setVisibility(false)
      loadActivities()
    }
    .onDisappear {
//      tabVisibilityStore.setVisibility(true)
    }
  }
  
  private func loadActivities() {
    isLoading = true
    errorMessage = nil
    
    Task {
      do {
        // 모든 액티비티 가져오기 (필터 없이)
        let fetchedActivities = try await activityClient.fetchActivities(nil, nil)
        await MainActor.run {
          activities = fetchedActivities
          isLoading = false
        }
      } catch {
        await MainActor.run {
          errorMessage = "액티비티를 불러오는데 실패했습니다: \(error.localizedDescription)"
          isLoading = false
        }
      }
    }
  }
  
  struct ExcitingActivitySection: View {
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
  
  struct RecommandActivitySection: View {
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
}
