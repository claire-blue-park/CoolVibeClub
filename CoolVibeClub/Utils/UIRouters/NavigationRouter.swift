//
//  NavigationRouter.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import Foundation

@MainActor
final class NavigationRouter<P: Hashable & Sendable>: ObservableObject {
    @Published
    var path: [P] = []
    
    func push(_ path: P) {
        self.path.append(path)
    }
    
    func push<T: Hashable & Sendable>(_ path: T) {
        guard let path = path as? P else {
            return
        }
        self.path.append(path)
    }
    
    func pop() {
        let _ = path.popLast()
    }
    
    func popAll() async {
        path.removeAll()
    }
}

