//
//  TabBarButton.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

enum NavBarButton {
    case search(action: () -> Void)
    case menu(action: () -> Void)
    case alert(action: () -> Void)
    case close(action: () -> Void)
    case back(action: () -> Void)
    case like(isLiked: Bool, action: () -> Void)
}
