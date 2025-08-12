//
//  CVCColor.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

enum CVCColor {
  static let grayScale0 = Color(white: 1.0)
  static let grayScale15 = Color(white: 249.0 / 255.0)
  static let grayScale30 = Color(white: 234.0 / 255.0)
  static let grayScale45 = Color(red: 216.0 / 255.0, green: 214.0 / 255.0, blue: 215.0 / 255.0)
  static let grayScale60 = Color(red: 171.0 / 255.0, green: 171.0 / 255.0, blue: 174.0 / 255.0)
  
  static let grayScale75 = Color(red: 106.0 / 255.0, green: 106.0 / 255.0, blue: 110.0 / 255.0)
  static let grayScale90 = Color(red: 67.0 / 255.0, green: 67.0 / 255.0, blue: 71.0 / 255.0)
  static let grayScale100 = Color(white: 11.0 / 255.0)
  
  static let primary = Color(red: 32.0 / 255.0, green: 108.0 / 255.0, blue: 235.0 / 255.0) // #206CEB
//  static let primaryLight = Color(red: 214.0 / 255.0, green: 229.0 / 255.0, blue: 234.0 / 255.0)
  static let primaryLight = Color(red: 219.0 / 255.0, green: 231.0 / 255.0, blue: 252.0 / 255.0) // #dbe7fc
//  static let primaryDark = Color(red: 67.0 / 255.0, green: 130.0 / 255.0, blue: 172.0 / 255.0)
  static let primaryDark = Color(red: 14.0 / 255.0, green: 65.0 / 255.0, blue: 151.0 / 255.0) // #0e4197
//  static let primaryDark = Color(red: 5.0 / 255.0, green: 25.0 / 255.0, blue: 58.0 / 255.0)

  static let primaryBright = primary.opacity(0.05)
  
  static let point = Color(red: 230.0 / 255.0, green: 255.0 / 255.0, blue: 90.0 / 255.0) // #E6FF5A
  static let like = Color(red: 255.0 / 255.0, green: 49.0 / 255.0, blue: 68.0 / 255.0) // #ff3144
  
  // Additional colors for activity cards
  //    static let sesacActivityLightseafoam = Color(red: 102.0 / 255.0, green: 204.0 / 255.0, blue: 153.0 / 255.0)
  //    static let sesacActivityBlackseafoam = Color(red: 32.0 / 255.0, green: 108.0 / 255.0, blue: 235.0 / 255.0)
  static let translucent15 = Color(red: 233.0 / 255.0, green: 229.0 / 255.0, blue: 226.0 / 255.0, opacity: 0.15)
  static let translucent45 = Color(red: 233.0 / 255.0, green: 229.0 / 255.0, blue: 226.0 / 255.0, opacity: 0.5)
  static let translucent60 = Color(red: 188.0 / 255.0, green: 188.0 / 255.0, blue: 190.0 / 255.0, opacity: 0.6)
  static let translucent75 = Color(red: 106.0 / 255.0, green: 106.0 / 255.0, blue: 110.0 / 255.0, opacity: 0.5)
  static let translucent90 = Color(red: 45.0 / 255.0, green: 48.0 / 255.0, blue: 49.0 / 255.0, opacity: 0.6)
  
}
