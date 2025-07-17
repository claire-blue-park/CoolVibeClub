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
    case mapPin

    // MARK: - Logo
    case kakao
    case imagePlaceholder  // 이미지 로딩 실패 시 기본 이미지

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
            case .mapPin:
                "ic_map_pin"
            case .kakao:
                "ic_kakao"
            case .imagePlaceholder:
                "ic_image_placeholder"  // 실제 에셋에 있으면 사용
            }
        return Image(name)
    }

    static func systemPlaceholder() -> Image {
        Image(systemName: "photo")
    }

    var template: some View {
        value
            .renderingMode(.template)
            .resizable()
    }
}
