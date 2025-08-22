//
//  InsightFeature.swift
//  CoolVibeClub
//
//

import SwiftUI
import Foundation
import Alamofire

struct InsightState {
  // 액티비티 관련
  var selectedCountry: Country = .all
  var selectedCategory: String = ActivityCategory.all.rawValue
  var activities: [ActivityInfoData] = []
  var newActivities: [ActivityInfoData] = []
  
  // UI
  var isLoading: Bool = false
  var errorMessage: String? = nil
  
  // 탭 관련
  var isTabBarVisible: Bool = true
}

enum InsightAction {
  // 선택 관련 액션
  case selectCountry(Country)    // 국가 선택
  case selectCategory(String)              // 카테고리 선택
  
  // 데이터 로딩 액션
  case loadActivities                      // 액티비티 로드
  case refreshActivities                   // 액티비티 새로고침
  case setNewActivities([ActivityInfoData]) // 새 액티비티 설정
  
  // 에러 처리 액션
  case clearError                          // 에러 메시지 클리어
  case setError(String?)                   // 에러 메시지 설정
  
  // 로딩 상태 액션
  case setLoading(Bool)                    // 로딩 상태 변경
  
  // 탭바 관련 액션
  case setTabBarVisibility(Bool)           // 탭바 표시/숨김
  
  // 내부 액션 (Private)
  case _activitiesLoaded([ActivityInfoData]) // 액티비티 로드 완료 (내부용)
  case _newActivitiesLoaded([ActivityInfoData]) // 새 액티비티 로드 완료 (내부용)
}

@MainActor
final class InsightStore: ObservableObject {

  @Published var state = InsightState()
  
  // Dependencies
  private let activityClient: ActivityClient
  
  init(activityClient: ActivityClient = ActivityClientKey.defaultValue) {
    self.activityClient = activityClient
  }
  
  func send(_ action: InsightAction) {
    switch action {
      
    // 선택 관련 처리
    case .selectCountry(let country):
      state.selectedCountry = country
      send(.refreshActivities)
      
    case .selectCategory(let category):
      state.selectedCategory = category
      send(.refreshActivities)
      
    // 데이터 로딩 처리
    case .loadActivities, .refreshActivities:
      performDataLoading()
      
    case .setNewActivities(let activities):
      state.newActivities = activities
      
    // 에러 처리
    case .clearError:
      state.errorMessage = nil
      
    case .setError(let message):
      state.errorMessage = message
      
    // 로딩 상태 처리
    case .setLoading(let isLoading):
      state.isLoading = isLoading
      
    // 탭바 처리
    case .setTabBarVisibility(let isVisible):
      state.isTabBarVisible = isVisible
      
    // 내부 액션 처리
    case ._activitiesLoaded(let activities):
      state.activities = activities
      
    case ._newActivitiesLoaded(let activities):
      state.newActivities = activities
    }
  }
}

extension InsightStore {
  // MARK: - 비동기 작업 함수
  
  /// 전체 데이터 로딩 수행
  private func performDataLoading() {
    Task {
      await loadAllData()
    }
  }
  
  /// 모든 데이터를 병렬로 로딩
  private func loadAllData() async {
    await MainActor.run {
      send(.setLoading(true))
      send(.setError(nil))
    }
    
    // 병렬 로딩
    async let excitingActivities = loadExcitingActivities()
    async let newActivities = loadNewActivities()
    
    do {
      let (exciting, new) = try await (excitingActivities, newActivities)
      
      await MainActor.run {
        send(._activitiesLoaded(exciting))
        send(._newActivitiesLoaded(new))
        send(.setLoading(false))
      }
    } catch {
      await MainActor.run {
        send(.setError("데이터 로딩 실패: \(error.localizedDescription)"))
        send(.setLoading(false))
      }
    }
  }
  
  /// Exciting 액티비티 로딩
  private func loadExcitingActivities() async throws -> [ActivityInfoData] {
    let countryParam = getCountryParam()
    let categoryParam = getCategoryParam()
    
    let activities = try await activityClient.fetchActivities(countryParam, categoryParam)
    return activities
  }
  
  /// 새로운 액티비티 로딩
  private func loadNewActivities() async throws -> [ActivityInfoData] {
    let countryParam = getCountryParam()
    let categoryParam = getCategoryParam()
    
    let endpoint = ActivityEndpoint(requestType: .newActivity(country: countryParam, category: categoryParam))
    let response: ActivityResponse = try await NetworkManager.shared.fetch(
      from: endpoint,
      errorMapper: { status, error in
        ActivityListError.map(statusCode: status, message: error.message)
      }
    )
    
    return formatActivityData(response.data)
  }
  
  // MARK: - Helper Functions
  
  /// 국가 파라미터 변환
  private func getCountryParam() -> String? {
    return state.selectedCountry.serverParam
  }
  
  /// 카테고리 파라미터 변환
  private func getCategoryParam() -> String? {
    guard let category = ActivityCategory(rawValue: state.selectedCategory) else {
      return nil
    }
    return category.serverParam
  }
  
  /// 액티비티 데이터 포맷팅
  private func formatActivityData(_ items: [Activity]) -> [ActivityInfoData] {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    
    return items.map { item in
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
  }}
