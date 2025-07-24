//
//  AlertManager.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct AlertItem {
  let title: String
  let message: String
  let confirmTitle: String
  let onConfirm: (() -> Void)?
  
  init(title: String = "", message: String, confirmTitle: String = "확인", onConfirm: (() -> Void)? = nil) {
    self.title = title
    self.message = message
    self.confirmTitle = confirmTitle
    self.onConfirm = onConfirm
  }
}

final class AlertManager: ObservableObject {
  static let shared = AlertManager()
  
  @Published var alertItem: AlertItem?
  @Published var showAlert = false
  
  private init() {}
  
  func showAlert(message: String) {
    alertItem = AlertItem(message: message)
    showAlert = true
  }
  
  func showAlert(title: String = "", message: String, confirmTitle: String = "확인", onConfirm: (() -> Void)? = nil) {
    alertItem = AlertItem(
      title: title,
      message: message,
      confirmTitle: confirmTitle,
      onConfirm: onConfirm
    )
    showAlert = true
  }
  
  func hideAlert() {
    showAlert = false
    alertItem = nil
  }
}