//
//  ActivityLimitView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct ActivityLimitView: View {
  let ageLimit: Int?
  let heightLimit: Int?
  let maxParticipants: Int?
  
  init(ageLimit: Int? = nil, heightLimit: Int? = nil, maxParticipants: Int? = nil) {
    self.ageLimit = ageLimit ?? 0
    self.heightLimit = heightLimit ?? 0
    self.maxParticipants = maxParticipants ?? 0
  }
  
  var body: some View {
    HStack(spacing: 12) {
      
      Spacer()
      
      if let ageLimit = ageLimit {
        LimitItemView(
          icon: CVCImage.Limit.age.value,
          title: "연령제한",
          value: "\(ageLimit)세 이상"
        )
      }
      
      Spacer()
      
      if let heightLimit = heightLimit {
        LimitItemView(
          icon: CVCImage.Limit.height.value,
          title: "신장제한",
          value: "\(heightLimit)cm 이상"
        )
      }
      
      Spacer()
      
      if let maxParticipants = maxParticipants {
        LimitItemView(
          icon: CVCImage.Limit.max.value,
          title: "최대인원제한",
          value: "최대 \(maxParticipants)명"
        )
      }
      
      Spacer()
      
    }
    .padding(.vertical, 16)
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

// MARK: - LimitItemView
private struct LimitItemView: View {
  let icon: Image
  let title: String
  let value: String
  
  var body: some View {
    HStack(spacing: 12) {
      icon
        .renderingMode(.template)
        .foregroundColor(CVCColor.grayScale60)
        .frame(width: 20, height: 20)
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.system(size: 10, weight: .medium))
          .foregroundColor(CVCColor.grayScale60)
        
        Text(value)
          .font(.system(size: 12, weight: .semibold))
          .foregroundColor(CVCColor.grayScale90)
      }
    }
//    .frame(minWidth: 100)
  }
}

// MARK: - Compact Style
struct ActivityLimitCompactView: View {
  let ageLimit: String?
  let heightLimit: String?
  let maxParticipants: String?
  
  init(ageLimit: String? = nil, heightLimit: String? = nil, maxParticipants: String? = nil) {
    self.ageLimit = ageLimit
    self.heightLimit = heightLimit
    self.maxParticipants = maxParticipants
  }
  
  var body: some View {
    HStack(spacing: 8) {
      if let ageLimit = ageLimit {
        CompactLimitItemView(
          icon: CVCImage.Limit.age.value,
          value: ageLimit
        )
      }
      
      if let heightLimit = heightLimit {
        CompactLimitItemView(
          icon: CVCImage.Limit.height.value,
          value: heightLimit
        )
      }
      
      if let maxParticipants = maxParticipants {
        CompactLimitItemView(
          icon: CVCImage.Limit.max.value,
          value: maxParticipants
        )
      }
    }
  }
}

// MARK: - CompactLimitItemView
private struct CompactLimitItemView: View {
  let icon: Image
  let value: String
  
  var body: some View {
    HStack(spacing: 4) {
      icon
        .renderingMode(.template)
        .foregroundColor(CVCColor.grayScale60)
        .frame(width: 16, height: 16)
      
      Text(value)
        .font(.system(size: 12, weight: .medium))
        .foregroundColor(CVCColor.grayScale90)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(CVCColor.grayScale15)
    )
  }
}

// MARK: - Badge Style
struct ActivityLimitBadgeView: View {
  let ageLimit: String?
  let heightLimit: String?
  let maxParticipants: String?
  
  init(ageLimit: String? = nil, heightLimit: String? = nil, maxParticipants: String? = nil) {
    self.ageLimit = ageLimit
    self.heightLimit = heightLimit
    self.maxParticipants = maxParticipants
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      if let ageLimit = ageLimit {
        BadgeLimitItemView(
          icon: CVCImage.Limit.age.value,
          title: "연령제한",
          value: ageLimit
        )
      }
      
      if let heightLimit = heightLimit {
        BadgeLimitItemView(
          icon: CVCImage.Limit.height.value,
          title: "신장제한",
          value: heightLimit
        )
      }
      
      if let maxParticipants = maxParticipants {
        BadgeLimitItemView(
          icon: CVCImage.Limit.max.value,
          title: "최대인원제한",
          value: maxParticipants
        )
      }
    }
  }
}

// MARK: - BadgeLimitItemView
private struct BadgeLimitItemView: View {
  let icon: Image
  let title: String
  let value: String
  
  var body: some View {
    HStack(spacing: 6) {
      icon
        .renderingMode(.template)
        .foregroundColor(CVCColor.grayScale60)
        .frame(width: 14, height: 14)
      
      Text(title)
        .font(.system(size: 11, weight: .medium))
        .foregroundColor(CVCColor.grayScale60)
      
      Text(value)
        .font(.system(size: 11, weight: .semibold))
        .foregroundColor(CVCColor.grayScale90)
    }
  }
}

