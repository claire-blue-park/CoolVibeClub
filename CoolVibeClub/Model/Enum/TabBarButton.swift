//
//  TabBarButton.swift
//  CoolVibeClub
//
//  Created by Claire on 7/10/25.
//

import Foundation

enum NavBarButton {
    case search(action: () -> Void)
    case menu(action: () -> Void)

    case alert(action: () -> Void)
    case close(action: () -> Void)
}
