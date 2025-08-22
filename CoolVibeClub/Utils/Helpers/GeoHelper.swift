//
//  GeoHelper.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import CoreLocation

class GeoHelper: ObservableObject {
  static let shared = GeoHelper()
  
  @Published var isGeocodingInProgress: Bool = false
  @Published var locationAddress: String = ""
  
  private init() {}
  
  func updateLocation(_ location: CLLocation?) {
    print("🔍 GeoHelper - updateLocation 호출: \(location?.description ?? "nil")")
    guard let location = location else {
      print("🔍 GeoHelper - location이 nil이므로 주소 초기화")
      locationAddress = ""
      return
    }
    
    print("🔍 GeoHelper - reverseGeocode 시작")
    reverseGeocode(location: location)
  }
  
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
        
        print("🔍 Placemark 정보:")
        print("  - country: \(placemark.country ?? "nil")")
        print("  - administrativeArea: \(placemark.administrativeArea ?? "nil")")
        print("  - subAdministrativeArea: \(placemark.subAdministrativeArea ?? "nil")")
        print("  - locality: \(placemark.locality ?? "nil")")
        print("  - subLocality: \(placemark.subLocality ?? "nil")")
        print("  - thoroughfare: \(placemark.thoroughfare ?? "nil")")
        print("  - subThoroughfare: \(placemark.subThoroughfare ?? "nil")")
        print("  - name: \(placemark.name ?? "nil")")
        
        self.locationAddress = self.formatKoreanAddress(from: placemark)
        print("✅ 주소 변환 성공: \(self.locationAddress)")
      }
    }
  }
  
  // MARK: - Legacy method for backward compatibility
  func reverseGeocode(
    location: CLLocation,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { placemarks, error in
      DispatchQueue.main.async {
        if let error = error {
          print("❌ Reverse geocoding 실패: \(error.localizedDescription)")
          completion(.failure(error))
          return
        }
        
        guard let placemark = placemarks?.first else {
          let error = NSError(domain: "GeoHelperError", code: 1, userInfo: [NSLocalizedDescriptionKey: "주소를 찾을 수 없습니다"])
          completion(.failure(error))
          return
        }
        
        print("🔍🔍 Placemark 정보:")
        print("  - country: \(placemark.country ?? "nil")")
        print("  - administrativeArea: \(placemark.administrativeArea ?? "nil")")
        print("  - subAdministrativeArea: \(placemark.subAdministrativeArea ?? "nil")")
        print("  - locality: \(placemark.locality ?? "nil")")
        print("  - subLocality: \(placemark.subLocality ?? "nil")")
        print("  - thoroughfare: \(placemark.thoroughfare ?? "nil")")
        print("  - subThoroughfare: \(placemark.subThoroughfare ?? "nil")")
        print("  - name: \(placemark.name ?? "nil")")
        
        let address = self.formatKoreanAddress(from: placemark)
        print("✅ 주소 변환 성공: \(address)")
        completion(.success(address))
      }
    }
  }
  
  // MARK: - LocationInfo 생성을 위한 메서드들
  
  /// 현재 위치를 LocationInfo로 변환 (async/await 버전)
  func getCurrentLocationInfo(from locationService: LocationService) async -> LocationInfo? {
    guard let currentLocation = locationService.currentLocation else {
      print("❌ 현재 위치를 가져올 수 없습니다.")
      return nil
    }
    
    print("📍 현재 위치 사용: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
    
    do {
      let geocoder = CLGeocoder()
      let placemarks = try await geocoder.reverseGeocodeLocation(currentLocation)
      
      if let placemark = placemarks.first {
        let addressComponents = buildAddressComponents(from: placemark)
        let fullAddress = buildFullAddress(from: addressComponents, placemark: placemark)
        let displayName = placemark.name ?? "현재 위치"
        
        let locationInfo = LocationInfo(
          name: displayName,
          address: fullAddress,
          latitude: currentLocation.coordinate.latitude,
          longitude: currentLocation.coordinate.longitude
        )
        
        print("📍 역지오코딩 성공 - 주소: \(fullAddress)")
        return locationInfo
        
      } else {
        // 역지오코딩 실패 시 좌표 정보로 대체
        return createLocationInfoWithCoordinates(currentLocation)
      }
    } catch {
      print("❌ 역지오코딩 실패: \(error.localizedDescription)")
      return createLocationInfoWithCoordinates(currentLocation)
    }
  }
  
  /// 좌표 기반 LocationInfo 생성
  func createLocationInfoWithCoordinates(_ location: CLLocation) -> LocationInfo {
    return LocationInfo(
      name: "현재 위치",
      address: "위도: \(String(format: "%.4f", location.coordinate.latitude)), 경도: \(String(format: "%.4f", location.coordinate.longitude))",
      latitude: location.coordinate.latitude,
      longitude: location.coordinate.longitude
    )
  }
  
  /// 주소 구성 요소 빌드 (EditFeature에서 분리)
  func buildAddressComponents(from placemark: CLPlacemark) -> [String] {
    var addressComponents: [String] = []
    
    // 시/도
    if let administrativeArea = placemark.administrativeArea {
      let shortArea = administrativeArea
        .replacingOccurrences(of: "특별시", with: "")
        .replacingOccurrences(of: "광역시", with: "")
        .replacingOccurrences(of: "도", with: "")
      if !shortArea.isEmpty {
        addressComponents.append(shortArea)
      }
    }
    
    // 구/군
    if let subAdministrativeArea = placemark.subAdministrativeArea {
      if !addressComponents.contains(where: { subAdministrativeArea.contains($0) }) {
        addressComponents.append(subAdministrativeArea)
      }
    }
    
    // 동/읍/면
    if let locality = placemark.locality {
      if !addressComponents.contains(where: { locality.contains($0) || $0.contains(locality) }) {
        addressComponents.append(locality)
      }
    }
    
    // 세부 동/리
    if let subLocality = placemark.subLocality {
      if placemark.locality != subLocality && 
         !addressComponents.contains(where: { subLocality.contains($0) || $0.contains(subLocality) }) {
        addressComponents.append(subLocality)
      }
    }
    
    // 도로명
    if let thoroughfare = placemark.thoroughfare, addressComponents.count < 3 {
      addressComponents.append(thoroughfare)
    }
    
    return addressComponents
  }
  
  /// 전체 주소 빌드 (EditFeature에서 분리)
  func buildFullAddress(from components: [String], placemark: CLPlacemark) -> String {
    if !components.isEmpty {
      return components.joined(separator: " ")
    } else {
      return placemark.name ?? "주소 정보 없음"
    }
  }
  
  private func formatKoreanAddress(from placemark: CLPlacemark) -> String {
    var addressComponents: [String] = []
    
    if let administrativeArea = placemark.administrativeArea {
      let shortArea = administrativeArea
        .replacingOccurrences(of: "특별시", with: "")
        .replacingOccurrences(of: "광역시", with: "")
        .replacingOccurrences(of: "도", with: "")
      if !shortArea.isEmpty {
        addressComponents.append(shortArea)
      }
    }
    
    if let subAdministrativeArea = placemark.subAdministrativeArea {
      if !addressComponents.contains(where: { subAdministrativeArea.contains($0) }) {
        addressComponents.append(subAdministrativeArea)
      }
    }
    
    if let locality = placemark.locality {
      if !addressComponents.contains(where: { locality.contains($0) || $0.contains(locality) }) {
        addressComponents.append(locality)
      }
    }
    
//    if let subLocality = placemark.subLocality {
//      if placemark.locality != subLocality && 
//         !addressComponents.contains(where: { subLocality.contains($0) || $0.contains(subLocality) }) {
//        addressComponents.append(subLocality)
//      }
//    }
    
    if let thoroughfare = placemark.thoroughfare,
       addressComponents.count < 3 {
      addressComponents.append(thoroughfare)
    }
    
    if !addressComponents.isEmpty {
      return addressComponents.joined(separator: " ")
    } else if let name = placemark.name {
      return name
    } else {
      return "주소를 가져올 수 없습니다"
    }
  }
}
