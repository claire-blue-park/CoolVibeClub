//
//  LocationService.swift
//  CoolVibeClub
//
//  Created by Claire on 7/28/25.
//

import Foundation
import CoreLocation
import SwiftUI
import UIKit

// MARK: - Location Authorization Status
enum LocationAuthorizationStatus {
  case notDetermined
  case authorized
  case denied
  case restricted
}

// MARK: - Location Service
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
  static let shared = LocationService()
  
  @Published var authorizationStatus: LocationAuthorizationStatus = .notDetermined
  @Published var currentLocation: CLLocation?
  @Published var isLocationEnabled: Bool = false
  @Published var showLocationAlert: Bool = false
  
  private let locationManager = CLLocationManager()
  
  // 포스트 로딩을 위한 클로저
  var onLocationAuthorized: ((CLLocation?) -> Void)?
  
  override init() {
    super.init()
    setupLocationManager()
  }
  
  private func setupLocationManager() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = 10 // 10미터 이상 이동시에만 업데이트
    print("🔧 LocationService 초기화 - 현재 권한 상태: \(locationManager.authorizationStatus.rawValue)")
    updateAuthorizationStatus()
    print("📊 권한 상태 업데이트 후: \(authorizationStatus)")
  }
  
  // MARK: - Public Methods
  func requestLocationPermission() {
    if authorizationStatus == .denied {
      // 설정 앱으로 이동
      if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(settingsUrl)
      }
    } else {
      switch locationManager.authorizationStatus {
      case .notDetermined:
        print("📍 위치 권한 요청")
        locationManager.requestWhenInUseAuthorization()
      case .denied, .restricted:
        print("⚠️ 위치 권한이 거부되거나 제한됨 - 설정 앱으로 이동 필요")
        break
      case .authorizedWhenInUse, .authorizedAlways:
        print("📍 위치 권한이 이미 승인됨 - 위치 업데이트 시작")
        startLocationUpdates()
      @unknown default:
        print("⚠️ 알 수 없는 위치 권한 상태")
        break
      }
    }
  }
  
  func handleLocationAuthorizationChange() {
    switch authorizationStatus {
    case .authorized:
      print("📍 위치 권한 승인됨")
      let coordinates = getCurrentCoordinates()
      print("📍 현재 위치: \(coordinates.latitude), \(coordinates.longitude)")
      
      // 위치 권한 승인되면 포스트 로드
      onLocationAuthorized?(currentLocation)
      
    case .denied:
      showLocationAlert = true
    case .restricted:
      print("⚠️ 위치 권한이 제한됨")
    case .notDetermined:
      break
    }
  }
  
  func startLocationUpdates() {
    guard locationManager.authorizationStatus == .authorizedWhenInUse || 
          locationManager.authorizationStatus == .authorizedAlways else {
      return
    }
    
    locationManager.startUpdatingLocation()
    isLocationEnabled = true
  }
  
  func stopLocationUpdates() {
    locationManager.stopUpdatingLocation()
    isLocationEnabled = false
  }
  
  func getCurrentCoordinates() -> (latitude: Double, longitude: Double) {
    guard let location = currentLocation else {
      return (0.0, 0.0)
    }
    return (location.coordinate.latitude, location.coordinate.longitude)
  }
  
  // MARK: - Private Methods
  private func updateAuthorizationStatus() {
    switch locationManager.authorizationStatus {
    case .notDetermined:
      authorizationStatus = .notDetermined
    case .authorizedWhenInUse, .authorizedAlways:
      authorizationStatus = .authorized
    case .denied:
      authorizationStatus = .denied
    case .restricted:
      authorizationStatus = .restricted
    @unknown default:
      authorizationStatus = .notDetermined
    }
  }
  
  // MARK: - CLLocationManagerDelegate
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    print("📍 위치 권한 상태 변경: \(manager.authorizationStatus.rawValue)")
    updateAuthorizationStatus()
    
    switch manager.authorizationStatus {
    case .authorizedWhenInUse, .authorizedAlways:
      print("✅ 위치 권한 승인됨 - 위치 업데이트 시작")
      startLocationUpdates()
    case .denied:
      print("❌ 위치 권한 거부됨")
      stopLocationUpdates()
      currentLocation = nil
    case .restricted:
      print("⚠️ 위치 권한 제한됨")
      stopLocationUpdates()
      currentLocation = nil
    case .notDetermined:
      print("❓ 위치 권한 미결정 상태")
      break
    @unknown default:
      print("⚠️ 알 수 없는 위치 권한 상태")
      break
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    currentLocation = location
    
    print("📍 위치 업데이트: \(location.coordinate.latitude), \(location.coordinate.longitude)")
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("❌ 위치 서비스 오류: \(error.localizedDescription)")
  }
}
