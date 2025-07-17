//
//  ActivityCategoryView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/13/25.
//

import SwiftUI

struct ActivityCategoryView: View {
    let category: String
    let isSelected: Bool
    var body: some View {
        Text(category)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(isSelected ? .white : .black)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(isSelected ? CVCColor.grayScale100 : CVCColor.grayScale15)
            // .overlay(
            //     Capsule().stroke(
            //         isSelected ? CVCColor.primary.opacity(0) : CVCColor.grayScale30,
            //         lineWidth: isSelected ? 0 : 2
            //     )
            // )
            .clipShape(Capsule())
            .shadow(color: isSelected ? Color.black.opacity(0.1) : .clear, radius: 4, x: 0, y: 2)
            // .animation(.easeInOut(duration: 0.4), value: isSelected)
    }
}
