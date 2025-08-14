//
//  LocationStatusView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import CoreLocation

struct LocationStatusView: View {
  let authorizationStatus: LocationAuthorizationStatus
  let currentLocation: CLLocation?
  let onRequestPermission: () -> Void
  
  @ObservedObject private var geoHelper = GeoHelper.shared
  
  var body: some View {
    // 디버깅용 로그
    let _ = print("🔍 LocationStatusView - 권한 상태: \(authorizationStatus), 위치: \(currentLocation?.description ?? "nil")")
    HStack(spacing: 16) {
      // 위치 아이콘
      iconImage
        .frame(width: 20, height: 20)
        .foregroundStyle(iconColor)
      
      // 위치 상태 텍스트
      VStack(alignment: .leading, spacing: 2) {
        Text(statusTitle)
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(CVCColor.grayScale90)
        
        if let subtitle = statusSubtitle {
          Text(subtitle)
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(CVCColor.grayScale60)
        }
      }
      
      Spacer()
      
      // 액션 버튼
      if authorizationStatus == .notDetermined || authorizationStatus == .denied {
        Button(action: onRequestPermission) {
          Text(authorizationStatus == .notDetermined ? "위치 권한 허용" : "설정")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(CVCColor.primary)
            .cornerRadius(16)
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(backgroundColor)
    .onChange(of: currentLocation) { newLocation in
      print("📍 LocationStatusView - currentLocation 변경: \(newLocation?.description ?? "nil")")
      geoHelper.updateLocation(newLocation)
    }
    .onAppear {
      print("📍 LocationStatusView - onAppear, currentLocation: \(currentLocation?.description ?? "nil")")
      // 초기 로드 시에도 geocoding 실행
      if let location = currentLocation {
        geoHelper.updateLocation(location)
      }
    }
  }
  
  // MARK: - Computed Properties
  private var iconImage: some View {
    switch authorizationStatus {
    case .authorized:
      return CVCImage.mapPin.template
    case .denied, .restricted:
      return CVCImage.mapPin.template
    case .notDetermined:
      return CVCImage.location.template
    }
  }
  
  private var iconColor: Color {
    switch authorizationStatus {
    case .authorized:
      return CVCColor.primary
    case .denied, .restricted:
      return CVCColor.grayScale60
    case .notDetermined:
      return CVCColor.grayScale75
    }
  }
  
  private var statusTitle: String {
    switch authorizationStatus {
    case .authorized:
      return currentLocation != nil ? "현재 위치" : "위치 검색 중..."
    case .denied:
      return "위치 권한 거부됨"
    case .restricted:
      return "위치 권한 제한됨"
    case .notDetermined:
      return "위치 권한 필요"
    }
  }
  
  private var statusSubtitle: String? {
    switch authorizationStatus {
    case .authorized:
      if currentLocation != nil {
        if geoHelper.isGeocodingInProgress {
          return "주소를 검색하는 중..."
        } else if !geoHelper.locationAddress.isEmpty {
          return geoHelper.locationAddress
        } else {
          return "주소를 가져올 수 없습니다"
        }
      } else {
        return "GPS 신호를 받는 중입니다"
      }
    case .denied:
      return "설정에서 위치 권한을 허용해 주세요"
    case .restricted:
      return "기기 설정에 의해 제한됨"
    case .notDetermined:
      return "주변 포스트 검색을 위해 사용됩니다"
    }
  }
  
  private var backgroundColor: Color {
    switch authorizationStatus {
    case .authorized:
      return .clear
    case .denied, .restricted:
      return CVCColor.grayScale15
    case .notDetermined:
      return CVCColor.grayScale15
    }
  }
  
}

