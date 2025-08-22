//
//  ActivityCardWithBorder.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import AVFoundation
import AVKit

struct ActivityCardWithBorder: View {
  let activity: ActivityInfoData
  let image: UIImage?
  @State private var isLiked: Bool
  
  init(activity: ActivityInfoData, image: UIImage? = nil) {
    self.activity = activity
    self.image = image
    self._isLiked = State(initialValue: activity.isLiked)
  }
  
  var body: some View {
    VStack(spacing: 12) {
      // Image Section with overlays
      ZStack {
        // Background image or video
        if let image = image {
          Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 233, height: 120)
            .clipped()
            .cornerRadius(16)
        } else {
          // URL 기반 미디어 표시
          ActivityCardMediaView(
            url: activity.imageName,
            endpoint: ActivityEndpoint(requestType: .newActivity())
          )
            .frame(width: 233, height: 120)
            .cornerRadius(16)
        }
        
        // Border overlay
        RoundedRectangle(cornerRadius: 16)
          .inset(by: 2)
          .stroke(CVCColor.primaryLight, lineWidth: 4)
          .frame(width: 233, height: 120)
        
        // MARK: - 하트 버튼 (좌상단)
        VStack {
          HStack {
            LikeButton()
              .padding(.top, 12)
              .padding(.leading, 12)
            
            Spacer()
          }
          Spacer()
        }
        
        // MARK: - 위치 뱃지 (우측 최상단)
        VStack {
          HStack {
            Spacer()
            
            HStack(alignment: .center, spacing: 4) {
              Image(systemName: "location.fill")
                .font(.system(size: 8))
                .foregroundColor(CVCColor.grayScale0)
              
              Text(activity.country)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(CVCColor.grayScale0)
                .lineLimit(1)
            }
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .background(
              VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
            )
            .cornerRadius(10)
            .overlay(
              RoundedRectangle(cornerRadius: 10)
                .inset(by: 0.5)
                .stroke(CVCColor.translucent45, lineWidth: 1)
            )
          }
          .padding(.horizontal, 12)
          .padding(.top, 12)
          
          Spacer()
        }
        
        // MARK: - HOT/NEW 뱃지 (좌하단)
        if !activity.tags.isEmpty {
          VStack {
            Spacer()
            
            HStack {
              HStack(alignment: .center, spacing: 2) {
                CVCImage.flame.template
                  .frame(width: 12, height: 12)
                  .foregroundColor(CVCColor.grayScale0)
                
                Text(activity.tags.first ?? "")
                  .font(.system(size: 10, weight: .semibold))
                  .foregroundColor(CVCColor.grayScale0)
              }
              .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
              .background(
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
              )
              .cornerRadius(4)
              .overlay(
                RoundedRectangle(cornerRadius: 4)
                  .inset(by: 0.5)
                  .stroke(CVCColor.translucent45, lineWidth: 1)
              )
              .padding(.bottom, 12)
              .padding(.leading, 12)
              
              Spacer()
            }
          }
        }
      }
      .frame(width: 233, height: 120)
      
      // MARK: - 내용 영역
      VStack(alignment: .leading, spacing: 8) {
        // MARK: - 제목
        Text(activity.title)
          .font(.system(size: 16, weight: .black))
          .foregroundColor(CVCColor.grayScale90)
          .multilineTextAlignment(.leading)
        
        
        // MARK: - 가격 (취소선 자동 조정)
        HStack(alignment: .center, spacing: 8) {
          ZStack {
            Text("\(activity.originalPrice)")
              .priceOriginalStyleInCard()
              .strikethrough()
          }
          
          Text(activity.price)
            .priceFinalStyleInCard(isPercentage: false)
          
          Text("\(activity.discountRate)%")
            .priceFinalStyleInCard(isPercentage: true)
          
          Spacer()
        }
      }
      .padding(.horizontal, 16)
      .frame(width: 263)
      
    }
  }
}

