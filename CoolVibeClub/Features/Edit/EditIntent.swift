//
//  EditIntent.swift
//  CoolVibeClub
//
//  Created by Claire on 8/13/25.
//

import Foundation
import SwiftUI
import PhotosUI
import CoreLocation

@MainActor
final class EditIntent: ObservableObject {
  struct EditState {
    var isLoading: Bool = false
    var error: String? = nil
    
    // 게시글 내용
    var title: String = ""
    var content: String = ""
    var selectedPhotos: [UIImage] = []
    var selectedCategory: PostCategory? = nil
    var selectedLocation: LocationInfo? = nil
    
    // UI 상태
    var showingPhotoPicker: Bool = false
    var showingAlert: Bool = false
    var alertMessage: String = ""
    var isPostSubmitted: Bool = false
    
    // 사진 선택
    var photoPickerItems: [PhotosPickerItem] = []
    
    // 게시 가능 여부
    var canSubmit: Bool {
      !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
      !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
  }
  
  enum EditAction {
    case loadInitialData
    case submitPost
    case showPhotoPicker(Bool)
    case handlePhotoSelection([PhotosPickerItem])
    case removePhoto(UIImage)
    case selectCategory(PostCategory)
    case toggleLocationSelection
    case setSelectedLocation(LocationInfo?)
  }
  
  @Published var state = EditState()
  
  // Dependencies
  private let locationService = LocationService.shared
  private let activityPostClient = ActivityPostClient.live
  
  func send(_ action: EditAction) {
    switch action {
    case .loadInitialData:
      Task { await loadInitialData() }
      
    case .submitPost:
      Task { await submitPost() }
      
    case .showPhotoPicker(let show):
      self.state.showingPhotoPicker = show
      
    case .handlePhotoSelection(let items):
      Task { await handlePhotoSelection(items) }
      
    case .removePhoto(let photo):
      self.state.selectedPhotos.removeAll { $0 == photo }
      
    case .selectCategory(let category):
      self.state.selectedCategory = category
      
    case .toggleLocationSelection:
      Task { await toggleLocationSelection() }
      
    case .setSelectedLocation(let location):
      self.state.selectedLocation = location
    }
  }
  
  // MARK: - Private Methods
  
  private func loadInitialData() async {
    print("📝 EditIntent: 초기 데이터 로드")
    // 추후 사용자 정보나 임시 저장된 데이터 로드 등을 구현할 수 있음
  }
  
  private func submitPost() async {
    print("📝 게시글 제출 시작")
    
    guard state.canSubmit else {
      await showAlert("모든 필수 항목을 입력해 주세요.")
      return
    }
    
    self.state.isLoading = true
    
    do {
      // 게시글 데이터 구성
      let postData = PostData(
        title: state.title.trimmingCharacters(in: .whitespacesAndNewlines),
        content: state.content.trimmingCharacters(in: .whitespacesAndNewlines),
        category: state.selectedCategory ?? .general,
        location: state.selectedLocation,
        photos: state.selectedPhotos
      )
      
      print("📝 게시글 데이터:")
      print("  - 제목: \(postData.title)")
      print("  - 내용 길이: \(postData.content.count)")
      print("  - 카테고리: \(postData.category.displayName)")
      print("  - 위치: \(postData.location?.name ?? "없음")")
      print("  - 사진 개수: \(postData.photos.count)")
      
      // 1. 사진이 있으면 먼저 파일 업로드
      var fileUrls: [String] = []
      if !postData.photos.isEmpty {
        print("📤 사진 업로드 중...")
        fileUrls = try await activityPostClient.uploadFiles(postData.photos)
        print("✅ 사진 업로드 완료: \(fileUrls)")
      }
      
      // 2. 게시글 생성
      let createRequest = CreatePostRequest(
        country: postData.location?.address.contains("한국") == true ? "한국" : "한국", // 기본값으로 한국 설정 (스크린샷 예시 기준)
        category: mapCategoryToServer(postData.category),
        title: postData.title,
        content: postData.content,
        activityId: "688865113025b7866e4fd404", // 하드코딩된 activity ID
        latitude: postData.location?.latitude ?? 37.518035, // 기본값 설정
        longitude: postData.location?.longitude ?? 126.886720, // 기본값 설정
        files: fileUrls
      )
      
      print("📝 서버 요청 데이터:")
      print("  - country: \(createRequest.country)")
      print("  - category: \(createRequest.category)")
      print("  - activityId: \(createRequest.activityId)")
      print("  - latitude: \(createRequest.latitude)")
      print("  - longitude: \(createRequest.longitude)")
      print("  - files: \(createRequest.files)")
      
      let response = try await activityPostClient.createPost(createRequest)
      
      self.state.isPostSubmitted = true
      await showAlert("게시글이 성공적으로 등록되었습니다!")
      print("✅ 게시글 생성 성공: \(response.id ?? "ID 없음")")
      
    } catch {
      print("❌ 게시글 제출 실패: \(error.localizedDescription)")
      await showAlert("게시글 등록에 실패했습니다. 다시 시도해 주세요.")
    }
    
    self.state.isLoading = false
  }
  
  private func handlePhotoSelection(_ items: [PhotosPickerItem]) async {
    print("📸 사진 선택 처리 시작: \(items.count)개")
    
    guard !items.isEmpty else {
      print("❌ 선택된 사진이 없습니다")
      return
    }
    
    var newPhotos: [UIImage] = []
    
    for (index, item) in items.enumerated() {
      print("📸 \(index + 1)번째 사진 처리 시작...")
      
      do {
        if let data = try await item.loadTransferable(type: Data.self) {
          print("📸 데이터 로드 성공: \(data.count) bytes")
          
          if let image = UIImage(data: data) {
            print("📸 UIImage 생성 성공: \(image.size)")
            
            // 이미지 압축 및 리사이징
            let resizedImage = resizeImage(image, maxSize: 1920)
            
            if let compressedData = resizedImage.jpegData(compressionQuality: 0.8),
               let finalImage = UIImage(data: compressedData) {
              newPhotos.append(finalImage)
              print("📸 \(index + 1)번째 이미지 처리 완료: 원본 \(data.count) bytes -> 압축 \(compressedData.count) bytes")
            } else {
              print("❌ \(index + 1)번째 이미지 압축 실패")
            }
          } else {
            print("❌ \(index + 1)번째 UIImage 생성 실패")
          }
        } else {
          print("❌ \(index + 1)번째 데이터 로드 실패")
        }
      } catch {
        print("❌ \(index + 1)번째 사진 처리 중 에러: \(error.localizedDescription)")
      }
    }
    
    print("📸 총 처리된 사진 수: \(newPhotos.count)")
    
    // MainActor에서 UI 업데이트 수행
    await MainActor.run {
      // 기존 사진을 지우고 새로 선택한 사진으로 교체 (최대 5개)
      let photosToSet = Array(newPhotos.prefix(5))
      
      self.state.selectedPhotos = photosToSet
      self.state.photoPickerItems = []
      
      print("📸 UI 업데이트 완료 - 최종 사진 수: \(self.state.selectedPhotos.count)")
    }
  }
  
  private func toggleLocationSelection() async {
    if state.selectedLocation != nil {
      // 이미 선택된 위치가 있으면 현재 위치로 업데이트
      print("📍 위치 업데이트 시작 - 기존 위치 유지하며 새 위치 요청")
      await useCurrentLocation()
    } else {
      // 현재 위치 사용
      await useCurrentLocation()
    }
  }
  
  private func useCurrentLocation() async {
    // 위치 업데이트 중임을 표시
    self.state.isLoading = true
    
    guard let currentLocation = locationService.currentLocation else {
      self.state.isLoading = false
      await showAlert("현재 위치를 가져올 수 없습니다.")
      return
    }
    
    print("📍 현재 위치 사용: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
    
    // 이전 위치 정보 백업 (실패 시 복원용)
    let previousLocation = state.selectedLocation
    
    // 역지오코딩을 통해 실제 주소 정보 가져오기
    do {
      let geocoder = CLGeocoder()
      let placemarks = try await geocoder.reverseGeocodeLocation(currentLocation)
      
      if let placemark = placemarks.first {
        // NearByView LocationStatusView와 동일한 한국 주소 형식으로 구성
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
        let fullAddress: String
        if !addressComponents.isEmpty {
          fullAddress = addressComponents.joined(separator: " ")
        } else {
          // 대체 주소 정보 사용
          if let name = placemark.name {
            fullAddress = name
          } else {
            fullAddress = "주소 정보 없음"
          }
        }
        
        let displayName = placemark.name ?? "현재 위치"
        
        let locationInfo = LocationInfo(
          name: displayName,
          address: fullAddress,
          latitude: currentLocation.coordinate.latitude,
          longitude: currentLocation.coordinate.longitude
        )
        
        self.state.selectedLocation = locationInfo
        self.state.isLoading = false
        print("📍 역지오코딩 성공 - 주소: \(fullAddress)")
        
      } else {
        // 역지오코딩 실패 시 좌표 정보로 대체
        await setLocationWithCoordinates(currentLocation, previousLocation: previousLocation)
      }
    } catch {
      print("❌ 역지오코딩 실패: \(error.localizedDescription)")
      // 역지오코딩 실패 시 좌표 정보로 대체하거나 이전 위치 유지
      await setLocationWithCoordinates(currentLocation, previousLocation: previousLocation)
    }
  }
  
  private func setLocationWithCoordinates(_ location: CLLocation, previousLocation: LocationInfo? = nil) async {
    let locationInfo = LocationInfo(
      name: "현재 위치",
      address: "위도: \(String(format: "%.4f", location.coordinate.latitude)), 경도: \(String(format: "%.4f", location.coordinate.longitude))",
      latitude: location.coordinate.latitude,
      longitude: location.coordinate.longitude
    )
    
    self.state.selectedLocation = locationInfo
    self.state.isLoading = false
    
    // 좌표만 사용하게 된 경우 사용자에게 알림 (선택적)
    if previousLocation != nil {
      print("⚠️ 주소 정보를 가져오지 못해 좌표로 표시합니다")
    }
    print("📍 좌표 기반 위치 정보 설정 완료")
  }
  
  private func showAlert(_ message: String) async {
    await MainActor.run {
      self.state.alertMessage = message
      self.state.showingAlert = true
    }
  }
  
  // MARK: - Helper Methods
  
  private func mapCategoryToServer(_ category: PostCategory) -> String {
    switch category {
    case .general: return "관광"
    case .question: return "관광"
    case .recommendation: return "관광"
    case .event: return "관광"
    case .review: return "관광"
    }
  }
  
  private func generateActivityId() -> String {
    return UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
  }
  
  // MARK: - Image Processing
  
  private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
    let size = image.size
    let aspectRatio = size.width / size.height
    var newSize = size
    
    if size.width > maxSize || size.height > maxSize {
      if aspectRatio > 1 {
        newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
      } else {
        newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
      }
    }
    
    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { _ in
      image.draw(in: CGRect(origin: .zero, size: newSize))
    }
  }
}

// MARK: - Supporting Models

struct PostData {
  let title: String
  let content: String
  let category: PostCategory
  let location: LocationInfo?
  let photos: [UIImage]
}

struct LocationInfo {
  let name: String
  let address: String
  let latitude: Double
  let longitude: Double
}

enum PostCategory: CaseIterable {
  case general, question, recommendation, event, review
  
  var displayName: String {
    switch self {
    case .general: return "일반"
    case .question: return "질문"
    case .recommendation: return "추천"
    case .event: return "이벤트"
    case .review: return "후기"
    }
  }
}
