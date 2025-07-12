//
//  CVCImage.swift
//  CoolVibeClub
//
//  Created by Claire on 7/9/25.
//

import SwiftUI

enum CVCImage {
    // MARK: - Tab
    case globe
    case post
    case chat
    case profile

    // MARK: - Nav
    case search

    // MARK: - Etc
    case arrowRight
    case bellNoti
    case bell
    case heartFill
    case heart
    case menu
  
  // MARK: - Logo
  case kakao

    var value: Image {
        let name =
            switch self {
            case .globe:
                "ic_globe"
            case .post:
                "ic_post"
            case .chat:
                "ic_chat"
            case .profile:
                "ic_profile"
            case .search:
                "ic_search"
            case .arrowRight:
                "ic_arrow_right"
            case .bellNoti:
                "ic_bell_noti"
            case .bell:
                "ic_bell"
            case .heartFill:
                "ic_heart_fill"
            case .heart:
                "ic_heart"
            case .menu:
                "ic_menu"
            case .kakao:
              "ic_kakao"
            }
        return Image(name)
    }

    var template: some View {
        value
            .renderingMode(.template)
            .resizable()
    }
}
