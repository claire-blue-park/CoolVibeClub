//
//  ActivityCard.swift
//  CoolVibeClub
//
//  Created by Claire on 8/6/25.
//

import SwiftUI
import AVFoundation
import AVKit
import UIKit

struct ActivityCard: View {
  let activity: ActivityInfoData
  let image: UIImage?
  @State private var isLiked: Bool
  
  private let imageSectionHeight: CGFloat = 200
  
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
            .frame(maxWidth: .infinity)
            .frame(height: imageSectionHeight)
            .clipped()
            .cornerRadius(16)
        } else {
          // URL 기반 미디어 표시
          ActivityCardMediaView(
            url: activity.imageName,
            endpoint: ActivityEndpoint(requestType: .newActivity())
          )
            .frame(maxWidth: .infinity)
            .frame(height: imageSectionHeight)
            .cornerRadius(16)
        }
        
        
        // MARK: - 하트 버튼 (좌상단)
        VStack {
          HStack {
            LikeButton(isLiked: isLiked) { newIsLiked in
              isLiked = newIsLiked
            }
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
        VStack {
          Spacer()
          
          HStack {
            if !activity.tags.isEmpty  {
              HStack(alignment: .center, spacing: 4) {
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
            }
            
            
            Spacer()
            
            // MARK: - 광고 뱃지 (우하단)
            
            HStack(spacing: 4) {
              CVCImage.info.template
                .frame(width: 12, height: 12)
                .foregroundColor(CVCColor.grayScale0)
              
              Text("AD")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(CVCColor.grayScale0)
              
            }
            .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
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
        }
        .padding(12)
      }
      .frame(maxWidth: .infinity)
      .frame(height: imageSectionHeight)
      
      // MARK: - 내용 영역
      VStack(alignment: .leading, spacing: 8) {
        // MARK: - 제목
        Text(activity.title)
          .font(.system(size: 16, weight: .bold))
          .foregroundColor(CVCColor.grayScale90)
          .multilineTextAlignment(.leading)
        
        // MARK: - 설명 (태그 기반)
        Text(activity.tags.isEmpty ? "\(activity.category) 액티비티입니다." : activity.tags.prefix(3).joined(separator: " • "))
          .font(.system(size: 12, weight: .regular))
          .foregroundColor(CVCColor.grayScale60)
          .multilineTextAlignment(.leading)
          .lineLimit(3)
        
        // MARK: - 가격 (취소선 자동 조정)
        HStack(alignment: .center, spacing: 8) {
          if activity.discountRate > 0 {
            ZStack {
              Text(activity.originalPrice)
                .priceOriginalStyleInCard()
                .strikethrough()
            }
          }
          
          Text(activity.price)
            .priceFinalStyleInCard(isPercentage: false)
          
          if activity.discountRate > 0 {
            Text("\(activity.discountRate)%")
              .priceFinalStyleInCard(isPercentage: true)
          }
          
          Spacer()
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    
  }
}

// MARK: - VisualEffectView for Blur Effect
struct VisualEffectView: UIViewRepresentable {
  let effect: UIVisualEffect
  
  func makeUIView(context: Context) -> UIVisualEffectView {
    UIVisualEffectView(effect: effect)
  }
  
  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    uiView.effect = effect
  }
}
