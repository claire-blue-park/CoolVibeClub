//
//  CountryIconView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct CountryIconView: View {
  let country: Country
  let isSelected: Bool
  var body: some View {
    VStack(spacing: 2) {
      // 국가 아이콘
      getIconContent()
        .frame(width: 50, height: 50)
      
      // 국가명
      Text(country.rawValue)
        .font(.system(size: 12, weight: isSelected ? .bold : .regular))
        .foregroundColor(isSelected ? CVCColor.primary : CVCColor.grayScale60)
        .lineLimit(1)
    }
    .padding(EdgeInsets(top: 4, leading: 4, bottom: 8, trailing: 4))
    .background {
      RoundedRectangle(cornerRadius: 12)
        .fill(isSelected ? CVCColor.primaryBright  : Color.clear)
    }
    .animation(.easeInOut(duration: 0.2), value: isSelected)
  }
  
  @ViewBuilder
  private func getIconContent() -> some View {
    
    switch country {
    case .all:
      countryView(image: CVCImage.globe.value, frameSize: 20)
      
    case .korea:
      countryView(image: CVCImage.countryKorea.value)
      
    case .japan:
      countryView(image: CVCImage.countryJapan.value)
      
    case .australia:
      countryView(image: CVCImage.countryAustralia.value)
      
    case .philippines:
      countryView(image: CVCImage.countryPhilippines.value)
      
    case .thailand:
      countryView(image: CVCImage.countryThailand.value)
      
    default:
      countryView(image: Image(country.imageName))
    }
  }
  
  struct countryView: View {
    let image: Image
    var frameSize: CGFloat
    
    init(image: Image, frameSize: CGFloat = 48) {
      self.image = image
      self.frameSize = frameSize
    }
    
    var body: some View {
      image
        .resizable()
        .scaledToFill()
        .frame(width: frameSize, height: frameSize)
    }
  }
  
}
