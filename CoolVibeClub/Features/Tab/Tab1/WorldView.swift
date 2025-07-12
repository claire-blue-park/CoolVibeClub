//
//  WorldView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/9/25.
//

import SwiftUI

struct WorldView: View {
    var body: some View {
        VStack {
            NavBarView(title: "Cool Vibe Club", rightItems: nil)
                .frame(maxWidth: .infinity)

            Spacer()
        }
    }
}

#Preview {
    WorldView()
}
