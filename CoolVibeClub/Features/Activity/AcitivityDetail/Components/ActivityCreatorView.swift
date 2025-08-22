//
//  ActivityCreatorView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct ActivityCreatorView: View {
  let creator: CreatorInfo
  let onContactTap: (() -> Void)?
  
  init(creator: CreatorInfo, onContactTap: (() -> Void)? = nil) {
    self.creator = creator
    self.onContactTap = onContactTap
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // 타이틀
      Text("크리에이터 정보")
        .font(.system(size: 14, weight: .bold))
        .foregroundColor(CVCColor.grayScale45)
        .padding(.horizontal, 4)
      
      VStack(alignment: .leading, spacing: 16) {
        // 크리에이터 정보
        HStack(spacing: 12) {
          // 프로필 이미지
          CreatorProfileImageView(
            profileImageUrl: creator.profileImage,
            size: 60
          )
          
          HStack {
            // 크리에이터 정보
            VStack(alignment: .leading, spacing: 4) {
              Text(creator.nickname)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(CVCColor.grayScale90)
              
              if let introduction = creator.introduction {
                Text(introduction)
                  .font(.system(size: 12))
                  .foregroundColor(CVCColor.grayScale60)
                  .lineLimit(2)
                  .multilineTextAlignment(.leading)
              }
            }
          }
          
          Spacer()
          
          // 문의하기 버튼
          if let onContactTap = onContactTap {
            HStack {
              Spacer()
              
              Button(action: onContactTap) {
                HStack(spacing: 8) {
                  CVCImage.Action.message.template
                    .frame(width: 16, height: 16)
                    .foregroundColor(CVCColor.grayScale75)
                    .offset(x: 0, y: 0.5)
                  
                  Text("문의")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(CVCColor.grayScale75)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                  RoundedRectangle(cornerRadius: 20)
                    .fill(CVCColor.grayScale0)
                    .overlay(
                      RoundedRectangle(cornerRadius: 20)
                        .stroke(CVCColor.grayScale45, lineWidth: 1)
                    )
                )
              }
            }
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 20)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(CVCColor.grayScale15)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(CVCColor.grayScale30, lineWidth: 1)
          )
      )
    }
  }
}

// MARK: - CreatorInfo
struct CreatorInfo {
  let userId: String
  let nickname: String
  let profileImage: String?
  let introduction: String?
  
  // DetailCreator에서 변환하는 편의 초기화자
  init(from detailCreator: DetailCreator) {
    self.userId = detailCreator.userId
    self.nickname = detailCreator.nick
    self.profileImage = detailCreator.profileImage
    self.introduction = detailCreator.introduction
  }
  
  // 테스트용 초기화자
  init(userId: String, nickname: String, profileImage: String? = nil, introduction: String? = nil) {
    self.userId = userId
    self.nickname = nickname
    self.profileImage = profileImage
    self.introduction = introduction
  }
}

// MARK: - CreatorProfileImageView
private struct CreatorProfileImageView: View {
  let profileImageUrl: String?
  let size: CGFloat
  
  var body: some View {
    if let profileImageUrl = profileImageUrl, !profileImageUrl.isEmpty {
      AsyncImage(url: URL(string: profileImageUrl)) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
      } placeholder: {
        ProfilePlaceholderView(size: size)
      }
      .frame(width: size, height: size)
      .clipShape(Circle())
    } else {
      ProfilePlaceholderView(size: size)
    }
  }
}

// MARK: - ProfilePlaceholderView
private struct ProfilePlaceholderView: View {
  let size: CGFloat
  
  var body: some View {
    Circle()
      .fill(CVCColor.grayScale30)
      .frame(width: size, height: size)
      .overlay(
        CVCImage.Tab.profile.template
          .frame(width: size * 0.5, height: size * 0.5)
          .foregroundColor(CVCColor.grayScale60)
      )
  }
}

// MARK: - Preview
#Preview {
  VStack(spacing: 24) {
    ActivityCreatorView(
      creator: CreatorInfo(
        userId: "creator123",
        nickname: "스키 마스터 김코치",
        profileImage: nil,
        introduction: "10년 경력의 스키 강사입니다. 초보자부터 상급자까지 안전하고 즐거운 스키 경험을 제공합니다."
      ),
      onContactTap: {
        print("문의하기 버튼 탭됨")
      }
    )
    
    ActivityCreatorView(
      creator: CreatorInfo(
        userId: "creator456",
        nickname: "트래킹 가이드 박",
        profileImage: "https://example.com/profile.jpg",
        introduction: "자연을 사랑하는 트래킹 전문가입니다."
      )
    )
  }
  .padding()
  .background(Color.white)
}
