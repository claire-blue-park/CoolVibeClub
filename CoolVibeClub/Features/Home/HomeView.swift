//
//  WorldView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import Foundation

struct HomeView: View {
  @EnvironmentObject private var navigation: NavigationRouter<HomePath>
  @EnvironmentObject private var tabVisibilityStore: TabVisibilityStore
  @Environment(\.activityClient) private var activityClient
  @State private var state = ActivityState.initial
  @State private var newActivities: [ActivityInfoData] = []
  
  // MARK: - Intent Handlers (순수 함수형)
  private func handleIntent(_ intent: ActivityIntent) {
    switch intent {
    case .selectCountry(let country):
      activityReducer(state: &state, action: .setSelectedCountry(country))
      Task { 
        await loadNewActivities()
        await loadExcitingActivities() 
      }
      
    case .selectCategory(let category):
      activityReducer(state: &state, action: .setSelectedCategory(category))
      Task { 
        await loadNewActivities()
        await loadExcitingActivities() 
      }
      
    case .loadActivities, .refreshActivities:
      Task {
        await loadNewActivities()
        await loadExcitingActivities()
      }
      
    case .navigateToAllActivities:
      break // Navigation은 View에서 직접 처리
      
    case .navigateToActivityDetail:
      break // Navigation은 View에서 직접 처리
      
    case .clearError:
      activityReducer(state: &state, action: .setError(nil))
    }
  }
  
  // NEW 액티비티 로드 (나라/카테고리 필터링 적용)
  private func loadNewActivities() async {
    do {
      // 선택된 나라와 카테고리를 파라미터로 전달
      let countryParam: String? = {
        if let country = Country(rawValue: state.selectedCountry.name) {
          return country.serverParam
        }
        return nil
      }()
      
      let categoryParam: String? = {
        if let category = ActivityCategory(rawValue: state.selectedCategory) {
          return category.serverParam
        }
        return nil
      }()
      
      print("🏠 HomeView - New Activities - 선택된 국가: '\(state.selectedCountry.name)', 서버 파라미터: \(countryParam ?? "nil")")
      print("🏠 HomeView - New Activities - 선택된 카테고리: '\(state.selectedCategory)', 서버 파라미터: \(categoryParam ?? "nil")")
      
      let activities = try await fetchNewActivities(countryParam: countryParam, categoryParam: categoryParam)
      await MainActor.run {
        self.newActivities = activities
      }
    } catch {
      print("NEW 액티비티 로드 실패: \(error.localizedDescription)")
    }
  }
  
  // Exciting Activity 로드 (.activityList endpoint 사용, 국가/카테고리 파라미터 포함)
  private func loadExcitingActivities() async {
    activityReducer(state: &state, action: .setLoading(true))
    activityReducer(state: &state, action: .setError(nil))
    
    do {
      // Enum을 사용하여 안전하게 파라미터 매핑
      let countryParam: String? = {
        if let country = Country(rawValue: state.selectedCountry.name) {
          return country.serverParam
        }
        return nil
      }()
      
      let categoryParam: String? = {
        if let category = ActivityCategory(rawValue: state.selectedCategory) {
          return category.serverParam
        }
        return nil
      }()
      
      print("🏠 HomeView - Exciting Activities - 선택된 국가: '\(state.selectedCountry.name)', 서버 파라미터: \(countryParam ?? "nil")")
      print("🏠 HomeView - Exciting Activities - 선택된 카테고리: '\(state.selectedCategory)', 서버 파라미터: \(categoryParam ?? "nil")")
      
      let activities = try await activityClient.fetchActivities(countryParam, categoryParam)
      activityReducer(state: &state, action: .setActivities(activities))
    } catch {
      activityReducer(state: &state, action: .setError("네트워크 에러: \(error.localizedDescription)"))
    }
    
    activityReducer(state: &state, action: .setLoading(false))
  }
  
  // NEW 액티비티 API 호출 함수
  private func fetchNewActivities(countryParam: String?, categoryParam: String?) async throws -> [ActivityInfoData] {
    let endpoint = ActivityEndpoint(requestType: .newActivity(country: countryParam, category: categoryParam))
    
    let response: ActivityResponse = try await NetworkManager.shared.fetch(
      from: endpoint,
      errorMapper: { status, error in
        ActivityListError.map(statusCode: status, message: error.message)
      }
    )
    
    return response.data.map { item in
      let formatter = NumberFormatter()
      formatter.numberStyle = .decimal
      
      let finalPriceFormatted = formatter.string(from: NSNumber(value: item.price.final)) ?? "\(item.price.final)"
      let originalPriceFormatted = formatter.string(from: NSNumber(value: item.price.original)) ?? "\(item.price.original)"
      
      return ActivityInfoData(
        activityId: item.activityId,
        imageName: item.thumbnails.first ?? "sample_activity",
        price: "\(finalPriceFormatted)원",
        isLiked: item.isKeep,
        title: item.title,
        country: item.country,
        category: item.category,
        tags: item.tags,
        originalPrice: "\(originalPriceFormatted)원",
        discountRate: item.price.discountRate
      )
    }
  }
  

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
                  isSelected: country.name == state.selectedCountry.name
                )
                .onTapGesture {
                  handleIntent(.selectCountry(country))
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
                    isSelected: state.selectedCategory == category
                  )
                  .id(category)
                  .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                      proxy.scrollTo(category, anchor: .center)
                    }
                    handleIntent(.selectCategory(category))
                  }
                }
              }
              .padding(.horizontal, 16)
              .padding(.vertical, 8)
            }
            .onChange(of: state.selectedCategory) { newValue in
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
          
          if state.isLoading {
            Spacer()
            ProgressView()
            Spacer()
          } else if let errorMessage = state.errorMessage {
            VStack(spacing: 16) {
              Text("오류 발생")
                .font(.headline)
                .foregroundColor(.red)
              Text(errorMessage)
                .font(.caption)
                .foregroundColor(.gray)
              Button("다시 시도") {
                handleIntent(.clearError)
                handleIntent(.refreshActivities)
              }
              .padding()
              .background(CVCColor.primary)
              .foregroundColor(.white)
              .cornerRadius(8)
            }
            .padding()
            Spacer()
          } else if !state.activities.isEmpty {
            ActivitiesView(newActivities: newActivities, excitingActivities: state.activities)
          } else {
            Spacer()
          }
        }
        .padding(.bottom, 200) // 하단 여백 추가하여 탭바와 겹치지 않게 함
      }
      .task {
        handleIntent(.loadActivities)
      }
      .onAppear {
        tabVisibilityStore.setVisibility(true)
      }
    }
  }
}
