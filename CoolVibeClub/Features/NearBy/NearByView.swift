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
  
  @State private var showLocationAlert = false
  @State private var showEditView = false
  
  // MARK: - Location Methods
  private func requestLocationPermission() {
    if locationService.authorizationStatus == .denied {
      // 설정 앱으로 이동
      if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(settingsUrl)
      }
    } else {
      locationService.requestLocationPermission()
    }
  }
  
  private func handleLocationAuthorizationChange() {
    switch locationService.authorizationStatus {
    case .authorized:
      print("📍 위치 권한 승인됨")
      let coordinates = locationService.getCurrentCoordinates()
      print("📍 현재 위치: \(coordinates.latitude), \(coordinates.longitude)")
      
      // 위치 권한 승인되면 포스트 로드
      intent.send(.loadPosts(location: locationService.currentLocation))
      
    case .denied:
      showLocationAlert = true
    case .restricted:
      print("⚠️ 위치 권한이 제한됨")
    case .notDetermined:
      break
    }
  }

  var body: some View {
    NavigationStack {
      ZStack {
        VStack(spacing: 0) {
          // MARK: - 내비바
//          NavBarView(title: "MAP", rightItems: [.alert(action: {}), .search(action: {})])
//            .frame(maxWidth: .infinity)
//            .background(CVCColor.grayScale0)
          
          // MARK: - 위치 상태 표시
          LocationStatusView(
            authorizationStatus: locationService.authorizationStatus,
            currentLocation: locationService.currentLocation,
            onRequestPermission: requestLocationPermission
          )
          
          ScrollView(.vertical) {
            VStack(spacing: 32) {
              // MARK: - 액티비티 포스트 섹션
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
              .padding(.top, 20)
              
              // 플로팅 버튼을 위한 하단 여백
              Spacer()
                .frame(height: 80)
            }
          }
          .background(CVCColor.grayScale0)
        }
        
        // MARK: - 플로팅 글쓰기 버튼
        GeometryReader { geometry in
          VStack {
            Spacer()
            HStack {
              Spacer()
              Button(action: {
                showEditView = true
              }) {
                HStack(spacing: 8) {
                  Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                  Text("글쓰기")
                    .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(CVCColor.grayScale0)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(CVCColor.primary)
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
              }
              .padding(.trailing, 20)
              .padding(.bottom, geometry.safeAreaInsets.bottom + (tabVisibilityStore.isVisible ? 60 : 30))
            }
          }
        }

      }
      .task {
        // 디버깅용 로그
        print("🗺️ NearByView task - LocationService 권한 상태: \(locationService.authorizationStatus)")
        
        // 위치 권한이 이미 승인되어 있다면 자동으로 위치 업데이트 시작
        if locationService.authorizationStatus == .authorized {
          locationService.startLocationUpdates()
          
          // 초기 포스트 로드
          intent.send(.loadPosts(location: locationService.currentLocation))
        }
      }
      .onAppear {
        tabVisibilityStore.setVisibility(true)
      }
      .onChange(of: locationService.authorizationStatus) { newStatus in
        handleLocationAuthorizationChange()
      }
      .alert("위치 권한 필요", isPresented: $showLocationAlert) {
        Button("설정으로 이동") {
          if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
          }
        }
        Button("취소", role: .cancel) { }
      } message: {
        Text("위치 기반 서비스를 이용하려면 설정에서 위치 권한을 허용해 주세요.")
      }
      .sheet(isPresented: $showEditView) {
        EditView()
      }
    }
  }
}

#Preview {
  NearByView()
    .environmentObject(TabVisibilityStore())
}
