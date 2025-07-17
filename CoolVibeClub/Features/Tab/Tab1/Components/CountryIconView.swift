//
//  CountryIconView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/12/25.
//

import SwiftUI

struct CountryIconView: View {
    let country: Country
    let isSelected: Bool
    var body: some View {
        HStack(spacing: 8) {
            if isSelected {
                Image(country.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle().stroke(
                            isSelected ? CVCColor.grayScale100 : CVCColor.grayScale30, lineWidth: 1)
                    )
            }
            Text(country.name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isSelected ? CVCColor.grayScale100 : CVCColor.grayScale15)
        // .overlay(
        //     Capsule().stroke(
        //         isSelected ? CVCColor.primary.opacity(0) : CVCColor.grayScale30,
        //         lineWidth: isSelected ? 0 : 2
        //     )
        // )
        .clipShape(Capsule())
        .shadow(color: isSelected ? Color.black.opacity(0.1) : .clear, radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
