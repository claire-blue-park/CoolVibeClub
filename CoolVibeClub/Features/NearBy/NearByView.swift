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
  
  @State private var showLocationAlert = false
  
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
      VStack(spacing: 0) {
        // MARK: - 내비바
//        NavBarView(title: "MAP", rightItems: [.alert(action: {}), .search(action: {})])
//          .frame(maxWidth: .infinity)
//          .background(CVCColor.grayScale0)
        
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
              currentLocation: locationService.currentLocation.map { 
                (latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) 
              }
            )
            .padding(.top, 20)
          }
        }
        .background(CVCColor.grayScale0)
      }
      .task {
        // 디버깅용 로그
        print("🗺️ NearByView task - LocationService 권한 상태: \(locationService.authorizationStatus)")
        
        // 위치 권한이 이미 승인되어 있다면 자동으로 위치 업데이트 시작
        if locationService.authorizationStatus == .authorized {
          locationService.startLocationUpdates()
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
    }
  }
}

#Preview {
  NearByView()
    .environmentObject(TabVisibilityStore())
}
