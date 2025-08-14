//
//  NearByView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import CoreLocation

struct NearByView: View {
  @EnvironmentObject private var tabVisibilityStore: TabVisibilityStore
  @StateObject private var locationService = LocationService.shared
  @StateObject private var intent = NearByIntent()
  
  @State private var showEditView = false
  @State private var selectedDistance: Double = 5.0
  
  var body: some View {
    NavigationStack {
      ZStack {
        VStack(spacing: 0) {
          
          // MARK: - 위치 상태 표시
          LocationStatusView(
            authorizationStatus: locationService.authorizationStatus,
            currentLocation: locationService.currentLocation,
            onRequestPermission: locationService.requestLocationPermission
          )
          
          // MARK: - 거리 슬라이더
          if locationService.authorizationStatus == .authorized {
            DistanceSliderView { _ in
              
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
          }
          
          // MARK: - 액티비티 포스트 섹션
          ScrollView(.vertical) {
            LazyVStack(spacing: 0) {
              ActivityPostSection(
                posts: intent.state.posts,
                isLoading: intent.state.isLoading,
                hasMorePosts: intent.state.hasMorePosts,
                onLoadMore: {
                  intent.send(.loadMorePosts(location: locationService.currentLocation))
                },
                onRefresh: {
                  intent.send(.refreshPosts(location: locationService.currentLocation))
                }
              )
              .padding(.top, 16)
            }
          }
        }
        
        // MARK: - 플로팅 글쓰기 버튼
        VStack {
          Spacer()
          HStack {
            Spacer()
            WritingButton {
              showEditView = true
            }
            .padding(.trailing, 20)
            .padding(.bottom, tabVisibilityStore.isVisible ? 100 : 30)
          }
        }
      
      }
      .task {
        // 위치 권한이 이미 승인되어 있다면 자동으로 위치 업데이트
        if locationService.authorizationStatus == .authorized {
          locationService.startLocationUpdates()
          // 초기 포스트 로드
          intent.send(.loadPosts(location: locationService.currentLocation))
        }
      }
      .onAppear {
        tabVisibilityStore.setVisibility(true)
        // LocationService에 포스트 로딩 클로저 설정
        locationService.onLocationAuthorized = { location in
          intent.send(.loadPosts(location: location))
        }
      }
      .onChange(of: locationService.authorizationStatus) { newStatus in
        locationService.handleLocationAuthorizationChange()
      }
      .locationPermissionAlert(isPresented: $locationService.showLocationAlert)
      .sheet(isPresented: $showEditView) {
        EditView()
      }
    }
  }
}

