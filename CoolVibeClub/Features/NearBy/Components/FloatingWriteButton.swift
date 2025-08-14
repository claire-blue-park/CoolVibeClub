//
//  FloatingWriteButton.swift
//  CoolVibeClub
//
//  Created by Claire on 8/14/25.
//

import SwiftUI

struct FloatingWriteButton: View {
  let action: () -> Void
  let isTabBarVisible: Bool
  let title: String
  let icon: String
  
  init(
    action: @escaping () -> Void,
    isTabBarVisible: Bool = true,
    title: String = "글쓰기",
    icon: String = "plus"
  ) {
    self.action = action
    self.isTabBarVisible = isTabBarVisible
    self.title = title
    self.icon = icon
  }
  
  var body: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        Button(action: action) {
          HStack(spacing: 8) {
            Image(systemName: icon)
              .font(.system(size: 14, weight: .semibold))
            Text(title)
              .font(.system(size: 14, weight: .semibold))
          }
          .foregroundColor(CVCColor.grayScale0)
          .padding(.horizontal, 20)
          .padding(.vertical, 12)
          .background(CVCColor.primary)
          .cornerRadius(25)
          .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
        }
        .padding(.trailing, 20)
        .padding(.bottom, isTabBarVisible ? 60 : 30)
      }
    }
  }
}
