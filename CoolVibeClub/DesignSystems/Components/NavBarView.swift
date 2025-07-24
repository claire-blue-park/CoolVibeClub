//
//  NavBarView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct NavBarView: View {
  let title: String
  let rightItems: [NavBarButton]?
  @State private var showSearch = false
  
  var body: some View {
    HStack {
      Text(title)
        .navTitleStyle()
      Spacer()
      if let rightItems = rightItems {
        HStack(spacing: 16) {
          ForEach(0..<rightItems.count, id: \Int.self) { idx in
            navBarButtonView(for: rightItems[idx])
          }
        }
      }
    }
    .frame(height: 56)
    .padding(.horizontal)
  }
}

@ViewBuilder
func navBarButtonView(for item: NavBarButton) -> some View {
  switch item {
    // 검색
  case .search(let action):
    Button(action: action) {
      CVCImage.search.template
        .foregroundStyle(CVCColor.grayScale75)
        .frame(width: 24, height: 24)
    }
    
    // 메뉴
  case .menu(let action):
    Button(action: action) {
      CVCImage.menu.template
        .foregroundStyle(CVCColor.grayScale75)
        .frame(width: 24, height: 24)
    }
    
    // 알림
  case .alert(let action):
    Button(action: action) {
      CVCImage.bell.template
        .foregroundStyle(CVCColor.grayScale75)
        .frame(width: 24, height: 24)
    }
    
    // 닫기
  case .close(let action):
    Button(action: action) {
      CVCImage.arrowRight.template
        .foregroundStyle(CVCColor.grayScale75)
        .frame(width: 24, height: 24)
    }
    
    // 뒤로가기
  case .back(let action):
    Button(action: action) {
      BackCircleButton()
    }
    
    // 좋아요
  case .like(let isLiked, let action):
    Button(action: action) {
      LikeCircleButton(isLiked: isLiked) { _ in
        action()
      }
    }
  }
}
