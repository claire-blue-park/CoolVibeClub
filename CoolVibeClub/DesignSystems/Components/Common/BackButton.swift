//
//  BackButton.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct BackButton: View {
  @Environment(\.dismiss) private var dismiss
  let customAction: (() -> Void)?
  let foregroundColor: Color?
  
  init(customAction: (() -> Void)? = nil, foregroundColor: Color? = CVCColor.grayScale0) {
    self.customAction = customAction
    self.foregroundColor = foregroundColor
  }
  
  var body: some View {
    Button {
      if let customAction = customAction {
        customAction()
      } else {
        dismiss()
      }
    } label: {
      CVCImage.arrowLeft.value
        .renderingMode(.template)
        .foregroundColor(foregroundColor)
        .frame(width: 24, height: 24)
//        .padding(8)
    }
  }
}


struct BackCircleButton: View {
  @Environment(\.dismiss) private var dismiss
  let customAction: (() -> Void)?
  
  init(customAction: (() -> Void)? = nil) {
    self.customAction = customAction
  }
  
  var body: some View {
    Button {
      if let customAction = customAction {
        customAction()
      } else {
        dismiss()
      }
    } label: {
      CVCImage.arrowLeft.value
        .renderingMode(.template)
        .foregroundColor(CVCColor.grayScale90)
        .frame(width: 24, height: 24)
        .padding(8)
        .background(
          Circle()
            .fill(CVCColor.translucent60)
        )
        .clipShape(Circle())
    }
  }
}

#Preview {
    BackButton()
}
