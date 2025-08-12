//
//  FontHelper.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct FontHelper {
  
  func checkFont() {
    for fontFamily in UIFont.familyNames {
      for fontName in UIFont.fontNames(forFamilyName: fontFamily) {
        print(fontName)
      }
    }
  }
}
