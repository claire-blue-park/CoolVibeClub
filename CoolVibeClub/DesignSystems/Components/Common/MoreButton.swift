//
//  MoreButton.swift
//  CoolVibeClub
//
//  Created by Claire on 8/15/25.
//

import SwiftUI

struct MoreButton: View {
  var editAction: () -> Void
  var deleteAction: () -> Void
  
    var body: some View {
      Menu {
        Button(action: {
          editAction()
        }) {
          Label("수정", systemImage: "pencil")
        }
        
        Button(role: .destructive, action: {
          deleteAction()
        }) {
          Label("삭제", systemImage: "trash")
        }
      } label: {
        Image(systemName: "ellipsis")
          .font(.system(size: 16))
          .foregroundStyle(CVCColor.grayScale60)
          .padding(8)
          .contentShape(Rectangle()) // Ensures the entire area is tappable
      }
    }
}
