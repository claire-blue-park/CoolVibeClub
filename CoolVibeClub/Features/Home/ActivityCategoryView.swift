//
//  ActivityCategoryView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct ActivityCategoryView: View {
  let category: String
  let isSelected: Bool
  var body: some View {
    Text(category)
      .font(.system(size: 12, weight: isSelected ? .bold : .regular))
      .foregroundColor(isSelected ? CVCColor.primary : CVCColor.grayScale60)
      .lineLimit(1)
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(
        Capsule()
          .stroke(
            isSelected ? CVCColor.primary : CVCColor.grayScale60,
            lineWidth: 1
          )
          .background(
            Capsule()
              .fill(isSelected ? CVCColor.primaryBright : .clear)
          )
      )
      .animation(.easeInOut(duration: 0.2), value: isSelected)
  }
  
}
