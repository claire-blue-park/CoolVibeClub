//
//  Tab.swift
//  CoolVibeClub
//
//  Created by Claire on 7/9/25.
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
        "WORLD"
      case .tab2:
        "POST"
      case .tab3:
        "CHAT"
      case .tab4:
        "PROFILE"

      }
    return Text(title)
      .font(.system(size: 11, weight: .bold))
         .foregroundStyle(CVCColor.primary)
  }

  var iconView: some View {
    let image =
      switch self {
      case .tab1:
        CVCImage.globe.value
      case .tab2:
        CVCImage.post.value
      case .tab3:
        CVCImage.chat.value
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
