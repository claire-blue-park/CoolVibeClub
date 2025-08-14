//
//  WritingButton.swift
//  CoolVibeClub
//
//  Created by Claire on 8/15/25.
//

import SwiftUI

struct WritingButton: View {
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack(spacing: 8) {
        Image(systemName: "plus")
          .font(.system(size: 14, weight: .semibold))
        Text("글쓰기")
          .font(.system(size: 14, weight: .semibold))
      }
      .foregroundColor(CVCColor.grayScale0)
      .padding(.horizontal, 20)
      .padding(.vertical, 12)
      .background(CVCColor.primary)
      .cornerRadius(25)
      .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
    }
  }
}
