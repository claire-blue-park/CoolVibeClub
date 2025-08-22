//
//  Text+.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

extension Text {
  func mightyCourage(size: CGFloat) -> some View {
    self.font(.custom("MightyCouragePersonalUseOnl", size: size))
  }
  
  func paperlogyBlack(size: CGFloat) -> some View {
    self.font(.custom("Paperlogy-9Black", size: size))
  }
  
  func navTitleStyle() -> some View {
    self.mightyCourage(size: 20)
      .foregroundStyle(CVCColor.primary)
  }
  
  func loginTitleStyle() -> some View {
    self.mightyCourage(size: 24)
      .foregroundStyle(CVCColor.primary)
  }
  
  func activityTitleStyle(_ textColor: Color = CVCColor.grayScale0) -> some View {
    self.paperlogyBlack(size: 26)
      .foregroundStyle(textColor)
  }
  
  // MARK: - 포스트
  func postTitleStyle(_ textColor: Color = CVCColor.grayScale0) -> some View {
    self.font(.system(size: 16, weight: .bold))
      .foregroundStyle(CVCColor.grayScale90)
      .multilineTextAlignment(.leading)
      .padding(.horizontal, 8)
  }

  func postContentStyle(_ textColor: Color = CVCColor.grayScale0) -> some View {
    self.font(.system(size: 12, weight: .regular))
      .foregroundStyle(CVCColor.grayScale75)
      .multilineTextAlignment(.leading)
      .lineLimit(3)
      .padding(.horizontal, 8)
  }

  // MARK: - 가격
  func bannerTitleStyle(_ textColor: Color = CVCColor.grayScale90) -> some View {
    self.paperlogyBlack(size: 22)
      .foregroundStyle(textColor)
  }
  
  func priceStyle(_ textColor: Color = CVCColor.grayScale90) -> some View {
    self.paperlogyBlack(size: 20)
      .foregroundStyle(textColor)
  }
  
  func priceOriginalStyle(_ textColor: Color = CVCColor.grayScale45) -> some View {
    self.paperlogyBlack(size: 16)
      .foregroundStyle(textColor)
  }
  
  func priceFinalStyle(isPercentage: Bool) -> some View {
    self.paperlogyBlack(size: 22)
      .foregroundStyle(isPercentage ? CVCColor.primary : CVCColor.grayScale75)
  }

  
  func priceOriginalStyleInCard(_ textColor: Color = CVCColor.grayScale45) -> some View {
    self.paperlogyBlack(size: 14)
      .foregroundStyle(textColor)
  }
  
  func priceFinalStyleInCard(isPercentage: Bool) -> some View {
    self.paperlogyBlack(size: 16)
      .foregroundStyle(isPercentage ? CVCColor.primary : CVCColor.grayScale75)
  }
}
