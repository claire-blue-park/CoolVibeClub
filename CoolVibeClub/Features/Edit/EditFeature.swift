//
//  EditFeature.swift
//  CoolVibeClub
//
//

import SwiftUI
import Foundation
import PhotosUI
import CoreLocation

struct EditState {
  // 게시글 내용
  var title: String = ""
  var content: String = ""
  var selectedPhotos: [UIImage] = []
  var selectedCategory: ActivityCategory? = nil
  var selectedLocation: LocationInfo? = nil
  
  // UI 상태
  var isLoading: Bool = false
  var errorMessage: String? = nil
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
  // 초기화 액션
  case loadInitialData                     // 초기 데이터 로드
  
  // 게시글 관련 액션
  case setTitle(String)                    // 제목 설정
  case setContent(String)                  // 내용 설정
  case submitPost                          // 게시글 제출
  
  // 사진 관련 액션
  case showPhotoPicker(Bool)               // 사진 선택기 표시/숨김
  case handlePhotoSelection([PhotosPickerItem]) // 사진 선택 처리
  case removePhoto(UIImage)                // 사진 제거
  case setPhotoPickerItems([PhotosPickerItem]) // 사진 선택 아이템 설정
  
  // 카테고리 관련 액션
  case selectCategory(ActivityCategory)        // 카테고리 선택
  
  // 위치 관련 액션
  case toggleLocationSelection             // 위치 선택 토글
  case setSelectedLocation(LocationInfo?)  // 선택된 위치 설정
  
  // UI 상태 액션
  case setLoading(Bool)                    // 로딩 상태 설정
  case setError(String?)                   // 에러 메시지 설정
  case showAlert(String)                   // 알림 표시
  case setShowingAlert(Bool)               // 알림 표시 상태 설정
  case setPostSubmitted(Bool)              // 게시글 제출 상태 설정
  
  // 내부 액션 (Private)
  case _photosProcessed([UIImage])         // 사진 처리 완료 (내부용)
  case _locationUpdated(LocationInfo)      // 위치 업데이트 완료 (내부용)
  case _postSubmissionCompleted(Bool)      // 게시글 제출 완료 (내부용)
}

@MainActor
final class EditStore: ObservableObject {

  @Published var state = EditState()
  
  private let locationService = LocationService.shared
  private let activityPostClient = ActivityPostClient.live
  private let geoHelper = GeoHelper.shared
  
  init() {}
  
  func send(_ action: EditAction) {
    switch action {
      
    // 초기화 처리
    case .loadInitialData:
      performInitialDataLoading()
      
    // 게시글 관련 처리
    case .setTitle(let title):
      state.title = title
      
    case .setContent(let content):
      state.content = content
      
    case .submitPost:
      performPostSubmission()
      
    // 사진 관련 처리
    case .showPhotoPicker(let show):
      state.showingPhotoPicker = show
      
    case .handlePhotoSelection(let items):
      performPhotoSelection(items)
      
    case .removePhoto(let photo):
      state.selectedPhotos.removeAll { $0 == photo }
      
    case .setPhotoPickerItems(let items):
      state.photoPickerItems = items
      
    // 카테고리 관련 처리
    case .selectCategory(let category):
      state.selectedCategory = category
      
    // 위치 관련 처리
    case .toggleLocationSelection:
      performLocationToggle()
      
    case .setSelectedLocation(let location):
      state.selectedLocation = location
      
    // UI 상태 처리
    case .setLoading(let isLoading):
      state.isLoading = isLoading
      
    case .setError(let message):
      state.errorMessage = message
      
    case .showAlert(let message):
      state.alertMessage = message
      state.showingAlert = true
      
    case .setShowingAlert(let showing):
      state.showingAlert = showing
      
    case .setPostSubmitted(let submitted):
      state.isPostSubmitted = submitted
      
    // 내부 액션 처리
    case ._photosProcessed(let photos):
      state.selectedPhotos = Array(photos.prefix(5))
      state.photoPickerItems = []
      
    case ._locationUpdated(let location):
      state.selectedLocation = location
      send(.setLoading(false))
      
    case ._postSubmissionCompleted(let success):
      send(.setLoading(false))
      if success {
        send(.setPostSubmitted(true))
        send(.showAlert("게시글이 성공적으로 등록되었습니다!"))
      } else {
        send(.showAlert("게시글 등록에 실패했습니다. 다시 시도해 주세요."))
      }
    }
  }
  
  
  /// 초기 데이터 로딩 수행
  private func performInitialDataLoading() {
    Task {
      await loadInitialData()
    }
  }
  
  /// 게시글 제출 수행
  private func performPostSubmission() {
    Task {
      await submitPost()
    }
  }
  
  /// 사진 선택 처리 수행
  private func performPhotoSelection(_ items: [PhotosPickerItem]) {
    Task {
      await handlePhotoSelection(items)
    }
  }
  
  /// 위치 토글 수행
  private func performLocationToggle() {
    Task {
      await toggleLocationSelection()
    }
  }
  
  /// 초기 데이터 로딩
  private func loadInitialData() async {
    print("📝 EditStore: 초기 데이터 로드")
    // 추후 사용자 정보나 임시 저장된 데이터 로드 등을 구현할 수 있음
  }
  
  /// 게시글 제출 처리
  private func submitPost() async {
    print("📝 게시글 제출 시작")
    
    guard state.canSubmit else {
      await MainActor.run {
        send(.showAlert("모든 필수 항목을 입력해 주세요."))
      }
      return
    }
    
    await MainActor.run {
      send(.setLoading(true))
    }
    
    do {
      // 게시글 데이터 구성
      let postData = PostData(
        title: state.title.trimmingCharacters(in: .whitespacesAndNewlines),
        content: state.content.trimmingCharacters(in: .whitespacesAndNewlines),
        category: state.selectedCategory ?? .sightseeing,
        location: state.selectedLocation,
        photos: state.selectedPhotos
      )
      
      print("📝 게시글 데이터:")
      print("  - 제목: \(postData.title)")
      print("  - 내용 길이: \(postData.content.count)")
      print("  - 카테고리: \(postData.category.rawValue)")
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
        country: postData.location?.address.contains("한국") == true ? "한국" : "한국",
        category: mapCategoryToServer(postData.category),
        title: postData.title,
        content: postData.content,
        activityId: "688865113025b7866e4fd404", // 하드코딩된 activity ID
        latitude: postData.location?.latitude ?? 37.518035,
        longitude: postData.location?.longitude ?? 126.886720,
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
      
      print("✅ 게시글 생성 성공: \(response.id ?? "ID 없음")")
      
      await MainActor.run {
        send(._postSubmissionCompleted(true))
      }
      
    } catch {
      print("❌ 게시글 제출 실패: \(error.localizedDescription)")
      
      await MainActor.run {
        send(._postSubmissionCompleted(false))
      }
    }
  }
  
  /// 사진 선택 처리
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
    
    await MainActor.run {
      send(._photosProcessed(newPhotos))
      print("📸 UI 업데이트 완료 - 최종 사진 수: \(state.selectedPhotos.count)")
    }
  }
  
  /// 위치 선택 토글
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
  
  /// 현재 위치 사용
  private func useCurrentLocation() async {
    await MainActor.run {
      send(.setLoading(true))
    }
    
    if let locationInfo = await geoHelper.getCurrentLocationInfo(from: locationService) {
      await MainActor.run {
        send(._locationUpdated(locationInfo))
      }
    } else {
      await MainActor.run {
        send(.setLoading(false))
        send(.showAlert("현재 위치를 가져올 수 없습니다."))
      }
    }
  }
  
  
  // MARK: - Helper Functions
  
  /// 카테고리를 서버 형식으로 변환
  private func mapCategoryToServer(_ category: ActivityCategory) -> String {
    return category.serverParam ?? "관광"
  }
  
  /// 이미지 리사이즈
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

// MARK: - Supporting Models (기존 EditIntent에서 사용하던 모델들)





//enum PostCategory: CaseIterable {
//  case general, question, recommendation, event, review
//  
//  var displayName: String {
//    switch self {
//    case .general: return "일반"
//    case .question: return "질문"
//    case .recommendation: return "추천"
//    case .event: return "이벤트"
//    case .review: return "후기"
//    }
//  }
//  
//  func mapCategoryToServer(_ category: PostCategory) -> String {
//    switch category {
//    case .general: return "관광"
//    case .question: return "관광"
//    case .recommendation: return "관광"
//    case .event: return "관광"
//    case .review: return "관광"
//    }
//  }
//}

