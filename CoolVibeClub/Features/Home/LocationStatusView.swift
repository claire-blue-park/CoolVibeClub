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
  
  @State private var locationAddress: String = ""
  @State private var isGeocodingInProgress: Bool = false
  
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
      if let location = newLocation {
        reverseGeocode(location: location)
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
        if isGeocodingInProgress {
          return "주소를 검색하는 중..."
        } else if !locationAddress.isEmpty {
          return locationAddress
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
//      return CVCColor.primary.opacity(0.05)
      return .clear
    case .denied, .restricted:
      return CVCColor.grayScale15
    case .notDetermined:
      return CVCColor.grayScale15
    }
  }
  
  // MARK: - Private Methods
  
  private func reverseGeocode(location: CLLocation) {
    isGeocodingInProgress = true
    
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { placemarks, error in
      DispatchQueue.main.async {
        self.isGeocodingInProgress = false
        
        if let error = error {
          print("❌ Reverse geocoding 실패: \(error.localizedDescription)")
          self.locationAddress = "주소를 가져올 수 없습니다"
          return
        }
        
        guard let placemark = placemarks?.first else {
          self.locationAddress = "주소를 가져올 수 없습니다"
          return
        }
        
        // 디버깅을 위해 모든 placemark 정보 출력
        print("🔍 Placemark 정보:")
        print("  - country: \(placemark.country ?? "nil")")
        print("  - administrativeArea: \(placemark.administrativeArea ?? "nil")")
        print("  - subAdministrativeArea: \(placemark.subAdministrativeArea ?? "nil")")
        print("  - locality: \(placemark.locality ?? "nil")")
        print("  - subLocality: \(placemark.subLocality ?? "nil")")
        print("  - thoroughfare: \(placemark.thoroughfare ?? "nil")")
        print("  - subThoroughfare: \(placemark.subThoroughfare ?? "nil")")
        print("  - name: \(placemark.name ?? "nil")")
        
        // 한국 주소 형식으로 조합 (중복 제거 + 상세주소 포함)
        var addressComponents: [String] = []
        
        // 시/도 (administrativeArea) - "서울특별시", "경기도" 등
        if let administrativeArea = placemark.administrativeArea {
          // "특별시", "광역시" 제거해서 짧게 표시
          let shortArea = administrativeArea
            .replacingOccurrences(of: "특별시", with: "")
            .replacingOccurrences(of: "광역시", with: "")
            .replacingOccurrences(of: "도", with: "")
          if !shortArea.isEmpty {
            addressComponents.append(shortArea)
          }
        }
        
        // 구/군 (subAdministrativeArea) - "강남구", "수원시" 등
        if let subAdministrativeArea = placemark.subAdministrativeArea {
          // 시/도와 중복되지 않도록 체크
          if !addressComponents.contains(where: { subAdministrativeArea.contains($0) }) {
            addressComponents.append(subAdministrativeArea)
          }
        }
        
        // 동/읍/면 (locality) - "역삼동", "신림동" 등
        if let locality = placemark.locality {
          // 이미 포함된 정보와 중복되지 않도록 체크
          if !addressComponents.contains(where: { locality.contains($0) || $0.contains(locality) }) {
            addressComponents.append(locality)
          }
        }
        
        // 세부 동/리 (subLocality) - "역삼1동", "신림2동" 등
        if let subLocality = placemark.subLocality {
          // locality와 다른 경우에만 추가
          if placemark.locality != subLocality && 
             !addressComponents.contains(where: { subLocality.contains($0) || $0.contains(subLocality) }) {
            addressComponents.append(subLocality)
          }
        }
        
        // 도로명 (thoroughfare) - "테헤란로", "강남대로" 등 (선택적)
        if let thoroughfare = placemark.thoroughfare,
           addressComponents.count < 3 { // 주소가 너무 길어지지 않도록 제한
          addressComponents.append(thoroughfare)
        }
        
        // 주소 조합
        if !addressComponents.isEmpty {
          self.locationAddress = addressComponents.joined(separator: " ")
        } else {
          // 대체 주소 정보 사용
          if let name = placemark.name {
            self.locationAddress = name
          } else {
            self.locationAddress = "주소를 가져올 수 없습니다"
          }
        }
        
        print("✅ 주소 변환 성공: \(self.locationAddress)")
      }
    }
  }
}

// MARK: - Preview
#Preview {
  VStack(spacing: 0) {
    LocationStatusView(
      authorizationStatus: .notDetermined,
      currentLocation: nil,
      onRequestPermission: {}
    )
    
    LocationStatusView(
      authorizationStatus: .authorized,
      currentLocation: CLLocation(latitude: 37.5665, longitude: 126.9780),
      onRequestPermission: {}
    )
    
    LocationStatusView(
      authorizationStatus: .denied,
      currentLocation: nil,
      onRequestPermission: {}
    )
  }
}
