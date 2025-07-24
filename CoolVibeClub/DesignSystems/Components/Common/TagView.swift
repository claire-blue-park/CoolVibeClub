//
//  TagView.swift
//  CoolVibeClub
//
//  Created by Claire on 8/4/25.
//

import SwiftUI

struct TagView: View {
  let text: String
  var body: some View {
    Text(text)
      .font(.system(size: 12, weight: .medium))
      .foregroundColor(CVCColor.primaryDark)
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(CVCColor.primaryLight)
      .cornerRadius(16)
  }
}
