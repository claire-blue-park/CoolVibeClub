//
//  LocationPermissionAlert.swift
//  CoolVibeClub
//
//  Created by Claire on 8/14/25.
//

import SwiftUI

struct LocationPermissionAlert: ViewModifier {
  @Binding var isPresented: Bool
  
  func body(content: Content) -> some View {
    content
      .alert("위치 권한 필요", isPresented: $isPresented) {
        Button("설정으로 이동") {
          openSettings()
        }
        Button("취소", role: .cancel) { }
      } message: {
        Text("위치 기반 서비스를 이용하려면 설정에서 위치 권한을 허용해 주세요.")
      }
  }
  
  private func openSettings() {
    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(settingsUrl)
    }
  }
}

// MARK: - View Extension
extension View {
  func locationPermissionAlert(isPresented: Binding<Bool>) -> some View {
    self.modifier(LocationPermissionAlert(isPresented: isPresented))
  }
}

// MARK: - Alternative Component Approach
struct LocationPermissionAlertView: View {
  @Binding var isPresented: Bool
  let title: String
  let message: String
  let settingsButtonTitle: String
  let cancelButtonTitle: String
  
  init(
    isPresented: Binding<Bool>,
    title: String = "위치 권한 필요",
    message: String = "위치 기반 서비스를 이용하려면 설정에서 위치 권한을 허용해 주세요.",
    settingsButtonTitle: String = "설정으로 이동",
    cancelButtonTitle: String = "취소"
  ) {
    self._isPresented = isPresented
    self.title = title
    self.message = message
    self.settingsButtonTitle = settingsButtonTitle
    self.cancelButtonTitle = cancelButtonTitle
  }
  
  var body: some View {
    EmptyView()
      .alert(title, isPresented: $isPresented) {
        Button(settingsButtonTitle) {
          openSettings()
        }
        Button(cancelButtonTitle, role: .cancel) { }
      } message: {
        Text(message)
      }
  }
  
  private func openSettings() {
    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(settingsUrl)
    }
  }
}
