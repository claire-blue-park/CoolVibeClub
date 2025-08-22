//
//  NearByFeature.swift
//  CoolVibeClub
//

import SwiftUI
import Foundation
import CoreLocation

struct NearByState {
  // 포스트 관련
  var posts: [ActivityPost] = []
  var nextCursor: String? = nil
  var hasMorePosts: Bool = true
  
  // UI 상태
  var isLoading: Bool = false
  var errorMessage: String? = nil
  
  // 설정
  var selectedDistance: Double = 5.0
  
  // UI 표시 상태
  var showEditView: Bool = false
  var isTabBarVisible: Bool = true
}

enum NearByAction {
  // 데이터 로딩 액션
  case loadPosts(location: CLLocation?)
  case loadMorePosts(location: CLLocation?)
  case refreshPosts(location: CLLocation?)
  
  // 에러 처리 액션
  case clearError
  case setError(String?)
  
  // 로딩 상태 액션
  case setLoading(Bool)
  
  // UI 액션
  case setShowEditView(Bool)
  case setSelectedDistance(Double)
  case setTabBarVisibility(Bool)
  
  // 내부 액션 (Private)
  case _postsLoaded([ActivityPost], nextCursor: String?, hasMore: Bool)
  case _morePostsLoaded([ActivityPost], nextCursor: String?, hasMore: Bool)
}

@MainActor
final class NearByStore: ObservableObject {
  
  @Published var state = NearByState()
  
  // Dependencies
  private let activityPostClient: ActivityPostClient
  
  init(activityPostClient: ActivityPostClient = ActivityPostClient.live) {
    self.activityPostClient = activityPostClient
  }
  
  func send(_ action: NearByAction) {
    switch action {
      
    // 데이터 로딩 처리
    case .loadPosts(let location):
      performPostsLoading(location: location, isRefresh: false)
      
    case .loadMorePosts(let location):
      performMorePostsLoading(location: location)
      
    case .refreshPosts(let location):
      performPostsLoading(location: location, isRefresh: true)
      
    // 에러 처리
    case .clearError:
      state.errorMessage = nil
      
    case .setError(let message):
      state.errorMessage = message
      
    // 로딩 상태 처리
    case .setLoading(let isLoading):
      state.isLoading = isLoading
      
    // UI 상태 처리
    case .setShowEditView(let show):
      state.showEditView = show
      
    case .setSelectedDistance(let distance):
      state.selectedDistance = distance
      
    case .setTabBarVisibility(let isVisible):
      state.isTabBarVisible = isVisible
      
    // 내부 액션 처리
    case ._postsLoaded(let posts, let nextCursor, let hasMore):
      state.posts = posts
      state.nextCursor = nextCursor
      state.hasMorePosts = hasMore
      
    case ._morePostsLoaded(let posts, let nextCursor, let hasMore):
      state.posts.append(contentsOf: posts)
      state.nextCursor = nextCursor
      state.hasMorePosts = hasMore
    }
  }
}

extension NearByStore {
  // MARK: - 비동기 작업 함수
  
  /// 포스트 로딩 수행
  private func performPostsLoading(location: CLLocation?, isRefresh: Bool) {
    Task {
      await loadPosts(location: location, isRefresh: isRefresh)
    }
  }
  
  /// 추가 포스트 로딩 수행
  private func performMorePostsLoading(location: CLLocation?) {
    guard !state.isLoading && state.hasMorePosts && state.nextCursor != nil else { return }
    
    Task {
      await loadMorePosts(location: location)
    }
  }
  
  /// 포스트 로딩 (초기 또는 새로고침)
  private func loadPosts(location: CLLocation?, isRefresh: Bool) async {
    guard !state.isLoading else { return }
    
    await MainActor.run {
      send(.setLoading(true))
      send(.setError(nil))
      if isRefresh {
        // 새로고침 시 페이징 초기화
        state.nextCursor = nil
        state.hasMorePosts = true
      }
    }
    
    do {
      let response = try await fetchPosts(location: location, next: nil)
      
      await MainActor.run {
        send(._postsLoaded(response.data, nextCursor: response.nextCursor, hasMore: response.nextCursor != nil))
        send(.setLoading(false))
      }
      
      print("✅ NearBy 포스트 로드 성공: \(response.data.count)개")
      
    } catch {
      await MainActor.run {
        send(.setError("포스트를 불러올 수 없습니다."))
        send(.setLoading(false))
      }
      
      print("❌ NearBy 포스트 로드 실패: \(error.localizedDescription)")
    }
  }
  
  /// 추가 포스트 로딩
  private func loadMorePosts(location: CLLocation?) async {
    await MainActor.run {
      send(.setLoading(true))
    }
    
    do {
      let response = try await fetchPosts(location: location, next: state.nextCursor)
      
      await MainActor.run {
        send(._morePostsLoaded(response.data, nextCursor: response.nextCursor, hasMore: response.nextCursor != nil))
        send(.setLoading(false))
      }
      
      print("✅ NearBy 포스트 추가 로드 성공: \(response.data.count)개")
      
    } catch {
      await MainActor.run {
        send(.setError("더 많은 포스트를 불러올 수 없습니다."))
        send(.setLoading(false))
      }
      
      print("❌ NearBy 포스트 추가 로드 실패: \(error.localizedDescription)")
    }
  }
  
  /// 서버에서 포스트 가져오기
  private func fetchPosts(location: CLLocation?, next: String?) async throws -> ActivityPostsResponse {
    let latitude = location?.coordinate.latitude.description
    let longitude = location?.coordinate.longitude.description
    
    return try await activityPostClient.fetchPostsByGeolocation(
      "한국", // country
      nil, // category - 전체 조회
      longitude,
      latitude,
      nil, // maxDistance - 기본값 사용
      5, // limit
      next, // next cursor
      "latest" // orderBy
    )
  }
}