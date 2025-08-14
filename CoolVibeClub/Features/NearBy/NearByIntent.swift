//
//  NearByIntent.swift
//  CoolVibeClub
//
//  Created by Claire on 8/13/25.
//

import Foundation
import CoreLocation

@MainActor
final class NearByIntent: ObservableObject {
  struct NearByState {
    var isLoading: Bool = false
    var posts: [ActivityPost] = []
    var nextCursor: String? = nil
    var error: String? = nil
    var hasMorePosts: Bool = true
  }
  
  enum NearByAction {
    case loadPosts(location: CLLocation?)
    case loadMorePosts(location: CLLocation?)
    case refreshPosts(location: CLLocation?)
  }
  
  @Published var state = NearByState()
  
  // Dependencies
  private let activityPostClient = ActivityPostClient.live
  
  func send(_ action: NearByAction) {
    switch action {
    case .loadPosts(let location):
      Task { await loadPosts(location: location) }
      
    case .loadMorePosts(let location):
      Task { await loadMorePosts(location: location) }
      
    case .refreshPosts(let location):
      Task { await refreshPosts(location: location) }
    }
  }
  
  // MARK: - Private Methods
  
  private func loadPosts(location: CLLocation?) async {
    guard !state.isLoading else { return }
    
    state.isLoading = true
    state.error = nil
    
    do {
      let response = try await fetchPosts(location: location, next: nil)
      
      state.posts = response.data
      state.nextCursor = response.nextCursor
      state.hasMorePosts = response.nextCursor != nil
      
      print("✅ NearBy 포스트 로드 성공: \(response.data.count)개")
      
    } catch {
      print("❌ NearBy 포스트 로드 실패: \(error.localizedDescription)")
      state.error = "포스트를 불러올 수 없습니다."
    }
    
    state.isLoading = false
  }
  
  private func loadMorePosts(location: CLLocation?) async {
    guard !state.isLoading && state.hasMorePosts && state.nextCursor != nil else { return }
    
    state.isLoading = true
    
    do {
      let response = try await fetchPosts(location: location, next: state.nextCursor)
      
      state.posts.append(contentsOf: response.data)
      state.nextCursor = response.nextCursor
      state.hasMorePosts = response.nextCursor != nil
      
      print("✅ NearBy 포스트 추가 로드 성공: \(response.data.count)개")
      
    } catch {
      print("❌ NearBy 포스트 추가 로드 실패: \(error.localizedDescription)")
      state.error = "더 많은 포스트를 불러올 수 없습니다."
    }
    
    state.isLoading = false
  }
  
  private func refreshPosts(location: CLLocation?) async {
    state.nextCursor = nil
    state.hasMorePosts = true
    await loadPosts(location: location)
  }
  
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
