//
//  TabBarView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import UIKit

struct TabBarView: View {
  @Binding var selected: Tab
  @Namespace private var dotNamespace

  var body: some View {
    HStack {
      ForEach([Tab.tab1, Tab.tab2, Tab.tab3, Tab.tab4], id: \.self) { tab in
        TabButton(selected: $selected, tab: tab, dotNamespace: dotNamespace)
        if tab != .tab4 { Spacer() }
      }
    }
    .padding(.horizontal, 24)
    .padding(.top, 24)
    .padding(.bottom, 32)
    .frame(maxWidth: .infinity)
    .frame(height: 70)
    .foregroundColor(CVCColor.grayScale90)
    .background {
      VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
          RoundedRectangle(cornerRadius: 24)
            .stroke(Color.white.opacity(0.8), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 6)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)
        .ignoresSafeArea(.container, edges: .bottom)
    }
  }

  private struct TabButton: View {
    @Binding var selected: Tab
    let tab: Tab
    let dotNamespace: Namespace.ID

    var body: some View {
      Button {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
          selected = tab
        }
      } label: {
        VStack(alignment: .center, spacing: 4) {
          if selected == tab {
            tab.titleView
              .foregroundColor(CVCColor.grayScale90)
            Circle()
              .frame(width: 4, height: 4)
              .foregroundColor(CVCColor.grayScale90)
              .matchedGeometryEffect(id: "tabDot", in: dotNamespace)
              .padding(.top, 2)
          } else {
            tab.iconView
              .foregroundColor(CVCColor.grayScale60)
          }
        }
        .frame(width: 60, height: 44, alignment: .center)
      }
    }
  }
}

