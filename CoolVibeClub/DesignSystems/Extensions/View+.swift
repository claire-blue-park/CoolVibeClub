//
//  View+.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

// MARK: - 키보드
extension View {
  func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}

// MARK: - 코너
extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners))
  }
}

struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners
  
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}

// MARK: - 알림
extension View {
  // 기본 커스텀 알림
  func customAlert(
    isPresented: Binding<Bool>,
    title: String = "",
    message: String,
    confirmTitle: String = "확인",
    onConfirm: (() -> Void)? = nil
  ) -> some View {
    self.alert(title, isPresented: isPresented) {
      Button(confirmTitle) {
        onConfirm?()
      }
    } message: {
      Text(message)
    }
  }
  
  // 글로벌 알림 매니저 연결
  func withGlobalAlert() -> some View {
    GlobalAlertWrapper(content: self)
  }
}

struct GlobalAlertWrapper<Content: View>: View {
  let content: Content
  @ObservedObject private var alertManager = AlertManager.shared
  
  var body: some View {
    content
      .alert(
        alertManager.alertItem?.title ?? "",
        isPresented: $alertManager.showAlert
      ) {
        Button(alertManager.alertItem?.confirmTitle ?? "확인") {
          alertManager.alertItem?.onConfirm?()
          alertManager.hideAlert()
        }
      } message: {
        Text(alertManager.alertItem?.message ?? "")
      }
  }
}

// 간편 사용을 위한 글로벌 함수들
func showAlert(message: String) {
  AlertManager.shared.showAlert(message: message)
}

func showAlert(title: String = "", message: String, onConfirm: (() -> Void)? = nil) {
  AlertManager.shared.showAlert(title: title, message: message, onConfirm: onConfirm)
}
