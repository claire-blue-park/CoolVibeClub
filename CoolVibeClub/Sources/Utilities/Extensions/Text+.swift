//
//  Text+.swift
//  CoolVibeClub
//
//  Created by Claire on 7/10/25.
//

import SwiftUI

extension Text {
  func mightyCourage(size: CGFloat) -> some View {
    self.font(.custom("MightyCouragePersonalUseOnl", size: size))
  }

   func navTitleStyle() -> some View {
       self.mightyCourage(size: 20)
           .foregroundStyle(CVCColor.primary)
   }
}
