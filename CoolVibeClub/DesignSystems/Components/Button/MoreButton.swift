//
//  MoreButton.swift
//  CoolVibeClub
//
//  Created by Claire on 8/15/25.
//

import  SwiftUI

struct MoreButton: View {
  let editAction: () -> Void
  let deleteAction: () -> Void
  
  @State private var showMenu = false
  
  var body: some View {
    Menu {
      Button {
        editAction()
      } label: {
        Label("수정", systemImage: "pencil")
      }
      
      Button(role: .destructive) {
        deleteAction()
      } label: {
        Label("삭제", systemImage: "trash")
      }
    } label: {
      Image(systemName: "ellipsis")
        .font(.system(size: 16, weight: .medium))
        .foregroundStyle(CVCColor.grayScale60)
        .frame(width: 44, height: 44) // 터치 영역 확대
        .contentShape(Rectangle()) // 전체 영역 터치 가능
        .background(Color.clear) // 투명 배경으로 터치 영역 확보
    }
    .menuStyle(BorderlessButtonMenuStyle()) // iOS 14+ 메뉴 스타일
    .simultaneousGesture(TapGesture().onEnded { _ in
      // 탭 제스처 우선순위 확보
    })
  }
}
//
//struct MoreButton: View {
//  var editAction: () -> Void
//  var deleteAction: () -> Void
//  
//  var body: some View {
//    Menu {
//      Button(action: {
//        editAction()
//      }) {
//        Label("수정", systemImage: "pencil")
//      }
//      
//      Button(role: .destructive, action: {
//        deleteAction()
//      }) {
//        Label("삭제", systemImage: "trash")
//      }
//    } label: {
//      Image(systemName: "ellipsis")
//        .font(.system(size: 16))
//        .foregroundStyle(CVCColor.grayScale60)
//        .padding(8)
//        .contentShape(Rectangle())
//    }
//  }
//}
