//
//  FontHelper.swift
//  CoolVibeClub
//
//  Created by Claire on 7/10/25.
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
