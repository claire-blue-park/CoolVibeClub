//
//  ProfileImageView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct ProfileImageView: View {
  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      Image("profile_sample")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 110, height: 110)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 6))
        .shadow(radius: 4)
      Button(action: {}) {
        ZStack {
          Circle()
            .fill(Color.white)
            .frame(width: 36, height: 36)
            .shadow(radius: 2)
          Image(systemName: "camera.fill")
            .foregroundColor(CVCColor.point)
        }
      }
      .offset(x: 8, y: 8)
    }
  }
}

#Preview {
  ProfileImageView()
}
