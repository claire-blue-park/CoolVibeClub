//
//  ProfileSection.swift
//  CoolVibeClub
//
//  Created by Claire on 8/4/25.
//

import SwiftUI

extension ProfileView {
  
  // MARK: - 1. 프로필 이미지 영역
  struct ProfileImageView: View {
    @State private var showImagePicker = false
    @State private var profileImage: UIImage?
    
    var body: some View {
      ZStack {
        // 프로필 이미지 OR 기본 아이콘
        if let profileImage = profileImage {
          Image(uiImage: profileImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 120, height: 120)
            .clipShape(Circle())
        } else {
          // 기본 프로필 아이콘
          Circle()
            .fill(CVCColor.grayScale60.opacity(0.1))
            .frame(width: 120, height: 120)
            .overlay(
              CVCImage.profile.template
                .frame(width: 40, height: 40)
                .foregroundColor(CVCColor.grayScale60)
            )
        }
        
        // 원형 테두리 오버레이
        Circle()
          .fill(.clear)
          .frame(width: 126, height: 126)
          .background(
            Circle()
              .fill(CVCColor.grayScale0)
              .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
          )
          .overlay(
            Circle()
              .stroke(CVCColor.primaryLight, lineWidth: 1)
          )
          .mask(
            Circle()
              .stroke(lineWidth: 20)
              .frame(width: 126, height: 126)
          )
        
        // 카메라 버튼
        VStack {
          Spacer()
          HStack {
            Spacer()
            Button(action: {
              showImagePicker = true
            }) {
              ZStack {
                Circle()
                  .fill(CVCColor.grayScale0)
                  .frame(width: 36, height: 36)
                  .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                
                Image(systemName: "camera.fill")
                  .font(.system(size: 16, weight: .medium))
                  .foregroundColor(CVCColor.primary)
              }
            }
            .offset(x: -4, y: -4)
          }
        }
      }
      .frame(width: 120, height: 120)
      .sheet(isPresented: $showImagePicker) {
        ImagePicker(selectedImage: $profileImage)
      }
    }
  }
  
  // 이미지 피커 헬퍼 구조체
  private struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
      let picker = UIImagePickerController()
      picker.delegate = context.coordinator
      picker.sourceType = .photoLibrary
      picker.allowsEditing = true
      return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
      Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
      let parent: ImagePicker
      
      init(_ parent: ImagePicker) {
        self.parent = parent
      }
      
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 편집된 이미지가 있으면 사용, 없으면 원본 이미지 사용
        if let editedImage = info[.editedImage] as? UIImage {
          parent.selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
          parent.selectedImage = originalImage
        }
        
        parent.presentationMode.wrappedValue.dismiss()
      }
      
      func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.presentationMode.wrappedValue.dismiss()
      }
    }
  }
  
  // MARK: - 2. 프로필 내용 영역
  struct ProfileContentView: View {
    
    @Binding var nick: String
    @Binding var bio: String
    @Binding var tags: [String]
    //    @Binding var totalAmountSpent: Int // 📍 TODO: - Double?
    @Binding var totalPointEarned: Int
    @Binding var totalAmountSpent: Int
    
    var body: some View {
      VStack(spacing: 12) {
        // 닉네임
        Text(nick)
          .frame(maxWidth: .infinity, alignment: .center)
          .font(.system(size: 20))
          .foregroundStyle(CVCColor.grayScale90)
          .fontWeight(.bold)
        
        // 소개
        Text(bio)
          .frame(maxWidth: .infinity, alignment: .center)
          .font(.system(size: 12))
          .foregroundStyle(CVCColor.grayScale60)
          .fontWeight(.regular)
          .lineLimit(1)
        
        // 태그
        InterestTagView(tags: $tags)
        
        // 포인트
        PointBoxView(totalAmountSpent: $totalAmountSpent, totalPointEarned: $totalPointEarned)
        
      }
      .padding(20)
      .frame(maxWidth: .infinity)
      .background(CVCColor.grayScale0)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(CVCColor.primaryLight, lineWidth: 1)
      )
    }
  }
  
  private struct InterestTagView: View {
    @Binding var tags: [String]
    
    var body: some View {
      HStack {
        ForEach(tags, id: \.self) { tag in
          TagView(text: tag)
        }
      }
    }
  }
  
  private struct PointBoxView: View {
    
    @Binding var totalAmountSpent: Int
    @Binding var totalPointEarned: Int

    
    var body: some View {
      HStack {
        Spacer()
        
        // 총 사용 금액
        VStack(spacing: 4) {
          CVCImage.won.template
            .foregroundColor(CVCColor.primary)
            .frame(width: 28, height: 28)
          Text("\(totalAmountSpent)원")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(CVCColor.grayScale75)
          Text("총 사용 금액")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(CVCColor.grayScale60)
        }
        Spacer()
        
        // 누적 적립 포인트
        VStack(spacing: 4) {
          CVCImage.point.template
            .foregroundColor(CVCColor.primary)
            .frame(width: 28, height: 28)
          Text("\(totalPointEarned)P")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(CVCColor.grayScale75)
          Text("누적 적립 포인트")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(CVCColor.grayScale60)
        }
        Spacer()
        
        
      }
      .padding(20)
      .frame(maxWidth: .infinity)
      .background(CVCColor.grayScale0)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(CVCColor.grayScale30, lineWidth: 1)
      )
    }
  }
  
  // MARK: - 3. 예약 내역
  struct MyActivityView: View {
    @Binding var searchText: String
    
    var body: some View {
      VStack {
        HStack(spacing: 24) {
          // 3 - 1. 타이틀
          Text("내 액티비티")
            .foregroundStyle(CVCColor.grayScale90)
            .font(.system(size: 14, weight: .bold))
          Spacer()
          Button {
            
          } label: {
            HStack {
              Text("최신순")
                .foregroundStyle(CVCColor.primary)
                .font(.system(size: 12, weight: .bold))
              CVCImage.sort.template
                .frame(width: 16, height: 16)
                .foregroundColor(CVCColor.primary)
            }
          }
        }
        
        // 3 - 2. 서치바
        BorderLineSearchBar(
          searchText: $searchText,
          placeholder: "내 액티비티 검색",
          onSearchTextChanged: { _ in }
        )
        .padding(.vertical, 16)

      
        // 3 - 3. 예약 내역
        MyActivityCellView(title: "겨울 새싹 스키 원정대",
                           date: "2025년 4월 21일 오후 3:00 (일요일)",
                           location: "스위스 융프라우",
                           price: "123,000원",
                           rating: 5.0,
                           imageName: "실제_이미지_URL_또는_이미지명"
        )
        
      }
    }
  }
}

private struct MyActivityCellView: View {
  var title: String
  var date: String
  var location: String
  var price: String
  var rating: Double
  var imageName: String
  
  var body: some View {
    VStack(spacing: 12) {
      // 내용 + 이미지
      HStack {
        VStack(alignment: .leading, spacing: 8) {
          Text(title)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(CVCColor.grayScale75)
            .frame(alignment: .leading)
            .lineLimit(1)
          
          Text(date)
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(CVCColor.grayScale45)
            .lineLimit(1)
          
          HStack(spacing: 12) {
            Text(location)
              .font(.system(size: 13, weight: .medium))
              .foregroundColor(CVCColor.grayScale60)
              .lineLimit(1)
            
            HStack(spacing: 2) {
              Text(price)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(CVCColor.primary)
                .lineLimit(1)
              
              CVCImage.Navigation.noTailArrow.template
                .rotationEffect(.degrees(180))
                .frame(width: 13, height: 13)
                .foregroundColor(CVCColor.primary)
            }
          }
          Spacer()
        }
        
        Spacer()
        
        // 이미지
        AsyncImage(url: URL(string: imageName)) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
        } placeholder: {
          // 기본 이미지
          RoundedRectangle(cornerRadius: 12)
            .fill(CVCColor.grayScale0)
            .overlay(
              CVCImage.ticket.template
                .frame(width: 30, height: 30)
                .foregroundColor(CVCColor.primaryLight)
            )
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(CVCColor.primaryLight, lineWidth: 1)
            )
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }
      
      // 평점
      HStack(alignment: .center, spacing: 10) {
        CVCImage.starFill.template
          .frame(width: 20, height: 20)
          .foregroundColor(CVCColor.like)
        
        Text(String(format: "%.1f", rating))
          .font(.system(size: 16,  weight: .bold))
          .foregroundColor(CVCColor.grayScale75)
      }
      .frame(maxWidth: .infinity)
      .padding(16)
      .background(CVCColor.grayScale0)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(CVCColor.grayScale30, lineWidth: 1)
      )
      
    }
    .padding(20)
    .background(CVCColor.grayScale0)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(CVCColor.grayScale30, lineWidth: 1)
    )
    
  }
}


