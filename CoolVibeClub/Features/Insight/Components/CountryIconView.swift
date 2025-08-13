//
//  CountryIconView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct CountryIconView: View {
    let country: CountryCategories
    let isSelected: Bool
    var body: some View {
        VStack(spacing: 2) {
            // 국가 아이콘
            getIconContent()
                .frame(width: 50, height: 50)
            // 국가명
            Text(country.name)
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
      let frameSize: CGFloat = 48
      
        switch country.name {
        case "전체":
            CVCImage.globe.value
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
//                .foregroundColor(.gray)
        case "대한민국":
            CVCImage.countryKorea.value
                .resizable()
                .scaledToFill()
                .frame(width: frameSize, height: frameSize)
//                .clipShape(Circle())
        case "일본":
            CVCImage.countryJapan.value
                .resizable()
                .scaledToFill()
                .frame(width: frameSize, height: frameSize)
//                .clipShape(Circle())
        case "호주":
            CVCImage.countryAustralia.value
                .resizable()
                .scaledToFill()
                .frame(width: frameSize, height: frameSize)
//                .clipShape(Circle())
        case "필리핀":
            CVCImage.countryPhilippines.value
                .resizable()
                .scaledToFill()
                .frame(width: frameSize, height: frameSize)
//                .clipShape(Circle())
        case "태국":
            CVCImage.countryThailand.value
                .resizable()
                .scaledToFill()
                .frame(width: frameSize, height: frameSize)
//                .clipShape(Circle())
        default:
            Image(country.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: frameSize, height: frameSize)
//                .clipShape(Circle())
        }
    }
    
}
