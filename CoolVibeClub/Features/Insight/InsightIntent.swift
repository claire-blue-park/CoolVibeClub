//
//  InsightIntent.swift
//  CoolVibeClub
//
//  Created by Claire on 8/12/25.
//

import SwiftUI

@MainActor
final class InsightIntent: ObservableObject, Intent {
  struct InsightState: StateMarker {
    var isLoading: Bool = false
    var error: String? = nil
    var activityState: ActivityState = .initial
    var newActivities: [ActivityInfoData] = []
  }

  enum InsightAction: ActionMarker {
    case selectCountry(CountryCategories)
    case selectCategory(String)
    case loadActivities
    case refreshActivities
    case clearError

    // 내부 전용 업데이트
    case setNewActivities([ActivityInfoData])
  }

  typealias ActionType = InsightAction

  @Published private(set) var state: InsightState = .init()

  // Dependencies
  private let activityClient: ActivityClient

  init(activityClient: ActivityClient = ActivityClientKey.defaultValue) {
    self.activityClient = activityClient
  }

  func send(_ action: InsightAction) {
    switch action {
    case .selectCountry(let country):
      activityReducer(state: &self.state.activityState, action: .setSelectedCountry(country))
      Task { await reloadAll() }

    case .selectCategory(let category):
      activityReducer(state: &self.state.activityState, action: .setSelectedCategory(category))
      Task { await reloadAll() }

    case .loadActivities, .refreshActivities:
      Task { await reloadAll() }

    case .clearError:
      activityReducer(state: &self.state.activityState, action: .setError(nil))

    case .setNewActivities(let list):
      self.state.newActivities = list
    }
  }

  private func reloadAll() async {
    await loadNewActivities()
    await loadExcitingActivities()
  }

  private func loadExcitingActivities() async {
    activityReducer(state: &self.state.activityState, action: .setLoading(true))
    activityReducer(state: &self.state.activityState, action: .setError(nil))
    do {
      let countryParam: String? = {
        if let country = Country(rawValue: self.state.activityState.selectedCountry.name) { return country.serverParam }
        return nil
      }()
      let categoryParam: String? = {
        if let category = ActivityCategory(rawValue: self.state.activityState.selectedCategory) { return category.serverParam }
        return nil
      }()
      let activities = try await activityClient.fetchActivities(countryParam, categoryParam)
      activityReducer(state: &self.state.activityState, action: .setActivities(activities))
    } catch {
      activityReducer(state: &self.state.activityState, action: .setError("네트워크 에러: \(error.localizedDescription)"))
    }
    activityReducer(state: &self.state.activityState, action: .setLoading(false))
  }

  private func loadNewActivities() async {
    do {
      let countryParam: String? = {
        if let country = Country(rawValue: self.state.activityState.selectedCountry.name) { return country.serverParam }
        return nil
      }()
      let categoryParam: String? = {
        if let category = ActivityCategory(rawValue: self.state.activityState.selectedCategory) { return category.serverParam }
        return nil
      }()
      let activities = try await fetchNewActivities(countryParam: countryParam, categoryParam: categoryParam)
      send(.setNewActivities(activities))
    } catch {
      // 새 액티비티 실패는 치명적이지 않으므로 로깅만
      print("NEW 액티비티 로드 실패: \(error.localizedDescription)")
    }
  }

  private func fetchNewActivities(countryParam: String?, categoryParam: String?) async throws -> [ActivityInfoData] {
    let endpoint = ActivityEndpoint(requestType: .newActivity(country: countryParam, category: categoryParam))
    let response: ActivityResponse = try await NetworkManager.shared.fetch(
      from: endpoint,
      errorMapper: { status, error in
        ActivityListError.map(statusCode: status, message: error.message)
      }
    )
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return response.data.map { item in
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
}
