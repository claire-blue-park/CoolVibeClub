//
//  Tab.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

enum Tab {
  case tab1
  case tab2
  case tab3
  case tab4

  var titleView: some View {
    let title =
      switch self {
      case .tab1:
        "INSIGHT"
      case .tab2:
        "NEARBY"
      case .tab3:
        "MESSAGE"
      case .tab4:
        "MY"

      }
    return Text(title)
      .font(.system(size: 11, weight: .bold))
         .foregroundStyle(CVCColor.primary)
  }

  var iconView: some View {
    let image =
      switch self {
      case .tab1:
        CVCImage.sparkle.value
      case .tab2:
        CVCImage.mapPin.value
      case .tab3:
        CVCImage.message.value
      case .tab4:
        CVCImage.profile.value

      }
    return
      image
      .resizable()
      .scaledToFit()
      .frame(width: 22)
  }
}
