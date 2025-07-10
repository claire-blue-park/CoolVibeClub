//
//  TabBarView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/9/25.
//

import SwiftUI

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
    .padding()
    .frame(height: 72)
    .foregroundColor(CVCColor.grayScale90)
    .background {
      RoundedRectangle(cornerRadius: 24)
        .fill(Color.white)
        .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
    }
    .padding(.horizontal, 20)
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
