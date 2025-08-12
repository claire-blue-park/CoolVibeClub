//
//  ContentView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some View {
        if isLoggedIn {
          CVCTabView()
        } else {
            LoginView(onLoginSuccess: {
                isLoggedIn = true
            })
        }
    }
}

#Preview {
    ContentView()
}
