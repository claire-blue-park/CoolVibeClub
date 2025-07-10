//
//  CVCImage.swift
//  CoolVibeClub
//
//  Created by Claire on 7/9/25.
//

import SwiftUI

enum CVCImage {
    case globe
    case post
    case chat
    case profile

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
            }
        return Image(name)
    }

    var template: some View {
        value
            .renderingMode(.template)
            .resizable()
    }
}
