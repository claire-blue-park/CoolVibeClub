//
//  ActivityPostCell.swift
//  CoolVibeClub
//
//  Created by Claire on 8/15/25.
//

import SwiftUI

struct ActivityPostCell: View {
  let post: ActivityPost
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // MARK: - 유저 정보
      HStack(spacing: 12) {
        CachedAsyncImage(
          urlString: post.creator.profileImage ?? "",
          endpoint: ActivityPostEndpoint(requestType: .fetchPostsByGeolocation(
            country: nil, category: nil, longitude: nil, latitude: nil,
            maxDistance: nil, limit: nil, next: nil, orderBy: nil
          )),
          contentMode: .fill
        ) {
          Image(systemName: "person.circle.fill")
            .font(.system(size: 24))
            .foregroundStyle(CVCColor.grayScale60)
            .frame(width: 40, height: 40)
            .background(CVCColor.grayScale15)
            .clipShape(Circle())
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
        
        // 닉네임, 작성 시간
        VStack(alignment: .leading, spacing: 2) {
          Text(post.creator.nick)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(CVCColor.grayScale90)
          
          HStack(spacing: 2) {
            CVCImage.Action.time.template
              .frame(width: 12, height: 12)
              .foregroundStyle(CVCColor.grayScale60)
            
            Text(post.formattedCreatedAt)
              .font(.system(size: 11, weight: .regular))
              .foregroundStyle(CVCColor.grayScale60)
          }
        }
        
        Spacer()
        
        // MARK: - More Button
        MoreButton {
          print("Edit post: \(post.title)")
        } deleteAction: {
          print("Delete post: \(post.title)")
        }
      }
      
      // MARK: - 이미지 그리드
      PostImageGrid(images: post.files)
        .frame(maxWidth: .infinity)
      
      // MARK: - 제목
      Text(post.title)
        .postTitleStyle()
      
      // MARK: - 설명
      Text(post.content)
        .postContentStyle()
      
      // MARK: - 카테고리 태그
      HStack(spacing: 8) {
        TagView(text: post.category)
        TagView(text: post.country)
        
        Spacer()
      }
      .padding(.horizontal, 8)
    }
    .padding(.horizontal, 16)
    .padding(.top, 12)
    .padding(.bottom, 20)
    .background(CVCColor.grayScale0)
  }
}
