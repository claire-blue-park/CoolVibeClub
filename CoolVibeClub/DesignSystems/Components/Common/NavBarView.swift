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
  let leftItems: [NavBarButton]?
  let rightItems: [NavBarButton]?
  let isCenterTitle: Bool
  @State private var showSearch = false
  
  init(
    title: String,
    leftItems: [NavBarButton]? = nil,
    rightItems: [NavBarButton]? = nil,
    isCenterTitle: Bool = false
  ) {
    self.title = title
    self.leftItems = leftItems
    self.rightItems = rightItems
    self.isCenterTitle = isCenterTitle
  }
  
  var body: some View {
    HStack {
      // 왼쪽 버튼들
      if let leftItems = leftItems {
        HStack(spacing: 16) {
          ForEach(0..<leftItems.count, id: \Int.self) { idx in
            navBarButtonView(for: leftItems[idx])
          }
        }
      }
      
      if isCenterTitle {
        Spacer()
        Text(title)
          .font(.system(size: 18, weight: .bold))
          .foregroundColor(CVCColor.grayScale90)
        Spacer()
      } else {
        Text(title)
          .navTitleStyle()
        Spacer()
      }
      
      // 오른쪽 버튼들
      if let rightItems = rightItems {
        HStack(spacing: 16) {
          ForEach(0..<rightItems.count, id: \Int.self) { idx in
            navBarButtonView(for: rightItems[idx])
          }
        }
      } else if isCenterTitle {
        // 중앙 정렬을 위한 빈 공간
        Color.clear.frame(width: 24, height: 24)
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
    
    // 간단한 화살표 뒤로가기
  case .backArrow(let action):
    Button(action: action) {
      CVCImage.Navigation.arrowLeft.template
        .foregroundStyle(CVCColor.grayScale90)
        .frame(width: 24, height: 24)
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
