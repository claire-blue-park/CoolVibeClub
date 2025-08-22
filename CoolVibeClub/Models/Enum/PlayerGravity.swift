//
//  PlayerGravity.swift
//  CoolVibeClub
//
//  Created by Claire on 8/19/25.
//

import Foundation

enum PlayerGravity {
  case aspectFill  // 비율 유지하면서 뷰 전체 채우기 - default
  case resize      // 비율 무시하고 뷰에 맞게 늘리기
  case customFit   // 커스텀 transform으로 비율 유지하며 뷰에 꽉 차게
}
