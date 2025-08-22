//
//  EditView.swift
//  CoolVibeClub
//
//  Created by Claire on 8/13/25.
//

import SwiftUI
import PhotosUI
import CoreLocation

struct EditView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var store = EditStore()
  @StateObject private var locationService = LocationService.shared
  
  init() {}
  
  var body: some View {
    NavigationView {
      ZStack {
        CVCColor.grayScale0
          .ignoresSafeArea()
        
        VStack(spacing: 0) {
          // MARK: - Navigation Bar
          HStack {
            Button("취소") {
              dismiss()
            }
            .foregroundColor(CVCColor.grayScale60)
            
            Spacer()
            
            Text("글쓰기")
              .font(.system(size: 14, weight: .bold))
              .foregroundColor(CVCColor.grayScale90)
            
            Spacer()
            
            Button("게시") {
              store.send(.submitPost)
            }
            .foregroundColor(store.state.canSubmit ? CVCColor.primary : CVCColor.grayScale45)
            .disabled(!store.state.canSubmit)
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 20)
//          .background(CVCColor.grayScale0)
          
          Divider()
            .background(CVCColor.grayScale15)
          
          ScrollView {
            VStack(alignment: .leading, spacing: 20) {
              // MARK: - 위치 정보
              LocationInfoSection(
                currentLocation: locationService.currentLocation,
                selectedLocation: store.state.selectedLocation,
                onLocationTap: {
                  store.send(.toggleLocationSelection)
                }
              )
              
              // MARK: - 텍스트 입력
              TextInputSection(
                title: Binding(
                  get: { store.state.title },
                  set: { store.send(.setTitle($0)) }
                ),
                content: Binding(
                  get: { store.state.content },
                  set: { store.send(.setContent($0)) }
                ),
                titlePlaceholder: "제목을 입력하세요",
                contentPlaceholder: "내용을 입력하세요..."
              )
              
              // MARK: - 사진 첨부
              PhotoAttachmentSection(
                selectedPhotos: store.state.selectedPhotos,
                onPhotoAdd: {
                  store.send(.showPhotoPicker(true))
                },
                onPhotoRemove: { photo in
                  store.send(.removePhoto(photo))
                }
              )
              
              // MARK: - 카테고리 선택
//              CategorySelectionSection(
//                selectedCategory: intent.state.selectedCategory,
//                onCategorySelect: { category in
//                  intent.send(.selectCategory(category))
//                }
//              )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
          }
        }
        
      }
    }
    .navigationBarHidden(true)
    .photosPicker(
      isPresented: Binding(
        get: { store.state.showingPhotoPicker },
        set: { store.send(.showPhotoPicker($0)) }
      ),
      selection: Binding(
        get: { store.state.photoPickerItems },
        set: { store.send(.setPhotoPickerItems($0)) }
      ),
      maxSelectionCount: 5,
      matching: .images
    )
    .onChange(of: store.state.photoPickerItems) { newItems in
      store.send(.handlePhotoSelection(newItems))
    }
    .onAppear {
      store.send(.loadInitialData)
      locationService.requestLocationPermission()
    }
    .alert("게시글 작성", isPresented: Binding(
      get: { store.state.showingAlert },
      set: { store.send(.setShowingAlert($0)) }
    )) {
      Button("확인") {
        if store.state.isPostSubmitted {
          dismiss()
        }
      }
    } message: {
      Text(store.state.alertMessage)
    }
  }
}

// MARK: - Location Info Section
struct LocationInfoSection: View {
  let currentLocation: CLLocation?
  let selectedLocation: LocationInfo?
  let onLocationTap: () -> Void
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        CVCImage.location.template
          .frame(width: 16, height: 16)
          .foregroundColor(CVCColor.primary)
        
        Text("위치")
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(CVCColor.grayScale90)
        
        Spacer()
        
        Button(action: onLocationTap) {
          HStack(spacing: 4) {
            Image(systemName: selectedLocation != nil ? "arrow.clockwise.circle.fill" : "location.circle")
              .font(.system(size: 11))
            Text(selectedLocation != nil ? "위치 업데이트" : "현위치 가져오기")
              .font(.system(size: 12))
          }
          .foregroundColor(CVCColor.primary)
        }
      }
      
      if let location = selectedLocation {
        
        TagView(text: location.address)
//        VStack(alignment: .leading, spacing: 4) {
////          Text(location.name)
////            .font(.system(size: 14, weight: .medium))
////            .foregroundColor(CVCColor.grayScale90)
//          
//          Text(location.address)
//            .font(.system(size: 12))
//            .foregroundColor(CVCColor.grayScale60)
//        }
//        .padding(.horizontal, 12)
//        .padding(.vertical, 8)
//        .background(CVCColor.grayScale15)
//        .cornerRadius(8)
      }
      
      else if currentLocation != nil {
//        Button(action: onLocationTap) {
//          HStack(spacing: 8) {
//            Image(systemName: "location.circle")
//              .foregroundColor(CVCColor.primary)
//
//            Text("현재 위치 사용하기")
//              .font(.system(size: 14))
//              .foregroundColor(CVCColor.primary)
//          }
//          .padding(.horizontal, 12)
//          .padding(.vertical, 8)
//          .background(CVCColor.primaryLight.opacity(0.1))
//          .cornerRadius(8)
//        }
      } else {
        Text("위치 정보를 가져올 수 없습니다")
          .font(.system(size: 12))
          .foregroundColor(CVCColor.grayScale60)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
      }
    }
  }
}
// MARK: - Text Input Section
struct TextInputSection: View {
  @Binding var title: String
  @Binding var content: String
  let titlePlaceholder: String
  let contentPlaceholder: String
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // 제목
      VStack(alignment: .leading, spacing: 8) {
        Text("제목")
          .font(.system(size: 12, weight: .semibold))
          .foregroundColor(CVCColor.grayScale90)
        
        TextField(titlePlaceholder, text: $title)
          .font(.system(size: 13))
          .padding(.horizontal, 12)
          .padding(.vertical, 10)
          .background(CVCColor.grayScale15)
          .cornerRadius(8)
      }
      
      // 내용
      VStack(alignment: .leading, spacing: 8) {
        Text("내용")
          .font(.system(size: 12, weight: .semibold))
          .foregroundColor(CVCColor.grayScale90)
        
        TextEditor(text: $content)
          .font(.system(size: 13))
          .frame(minHeight: 120)
          .padding(.horizontal, 8)
          .padding(.vertical, 8)
          .cornerRadius(8)
          .overlay{
            RoundedRectangle(cornerRadius: 8)
              .stroke(lineWidth: 1)
              .foregroundStyle(CVCColor.grayScale30)
          }
          .overlay(
            Group {
              if content.isEmpty {
                HStack {
                  VStack {
                    Text(contentPlaceholder)
                      .font(.system(size: 13))
                      .foregroundColor(CVCColor.grayScale60)
                      .padding(.horizontal, 12)
                      .padding(.vertical, 16)
                    Spacer()
                  }
                  Spacer()
                }
              }
            }
          )
      }
    }
  }
}

// MARK: - Photo Attachment Section
struct PhotoAttachmentSection: View {
  let selectedPhotos: [UIImage]
  let onPhotoAdd: () -> Void
  let onPhotoRemove: (UIImage) -> Void
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Text("사진 첨부")
          .font(.system(size: 12, weight: .semibold))
          .foregroundColor(CVCColor.grayScale90)
        
        Text("(\(selectedPhotos.count)/5)")
          .font(.system(size: 12))
          .foregroundColor(CVCColor.grayScale45)
        
        Spacer()
        
        Button(action: onPhotoAdd) {
          HStack(spacing: 4) {
            Image(systemName: "plus")
              .font(.system(size: 10))
            Text("추가")
              .font(.system(size: 12))
          }
          .foregroundColor(CVCColor.primary)
        }
        .disabled(selectedPhotos.count >= 5)
      }
      
      if selectedPhotos.isEmpty {
        Button(action: onPhotoAdd) {
          VStack(spacing: 8) {
            Image(systemName: "photo")
              .font(.system(size: 24))
              .foregroundColor(CVCColor.grayScale60)
            
            Text("사진을 추가해보세요")
              .font(.system(size: 12))
              .foregroundColor(CVCColor.grayScale60)
          }
          .frame(maxWidth: .infinity)
          .frame(height: 80)
          .background(CVCColor.grayScale15)
          .cornerRadius(8)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(CVCColor.grayScale30, style: StrokeStyle(lineWidth: 1, dash: [5]))
          )
        }
      } else {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(Array(selectedPhotos.enumerated()), id: \.offset) { index, photo in
              ZStack(alignment: .topTrailing) {
                Image(uiImage: photo)
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 80, height: 80)
                  .clipped()
                  .cornerRadius(8)
                  .overlay {
                    RoundedRectangle(cornerRadius: 8)
                      .stroke(lineWidth: 1)
                      .foregroundStyle(CVCColor.grayScale30)
                  }
                
                Button(action: {
                  onPhotoRemove(photo)
                }) {
                  Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .background(CVCColor.grayScale60)
                    .clipShape(Circle())
                }
                .offset(x: 4, y: -4)
              }
              .padding(.vertical, 4)
            }
          }
          .padding(.horizontal, 2)
        }
      }
    }
  }
}

// MARK: - Category Selection Section
//struct CategorySelectionSection: View {
//  let selectedCategory: PostCategory?
//  let onCategorySelect: (PostCategory) -> Void
//  
//  let categories: [PostCategory] = [
//    .general, .question, .recommendation, .event, .review
//  ]
//  
//  var body: some View {
//    VStack(alignment: .leading, spacing: 12) {
//      Text("카테고리")
//        .font(.system(size: 14, weight: .semibold))
//        .foregroundColor(CVCColor.grayScale90)
//      
//      ScrollView(.horizontal, showsIndicators: false) {
//        HStack(spacing: 8) {
//          ForEach(categories, id: \.self) { category in
//            Button(action: {
//              onCategorySelect(category)
//            }) {
//              Text(category.displayName)
//                .font(.system(size: 12, weight: .medium))
//                .padding(.horizontal, 12)
//                .padding(.vertical, 6)
//                .background(selectedCategory == category ? CVCColor.primary : CVCColor.grayScale15)
//                .foregroundColor(selectedCategory == category ? .white : CVCColor.grayScale60)
//                .cornerRadius(16)
//            }
//          }
//        }
//        .padding(.horizontal, 2)
//      }
//    }
//  }
//}

// Supporting models are now defined in EditIntent.swift

#Preview {
  EditView()
}
