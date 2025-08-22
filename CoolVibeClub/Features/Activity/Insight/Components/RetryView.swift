//
//  RetryView.swift
//  CoolVibeClub
//
//  Created by Claire on 8/18/25.
//

import SwiftUI

struct RetryView: View {
  let errorMessage: String
  let onRetry: () -> Void
  
  var body: some View {
    VStack(spacing: 16) {
      Text("오류 발생")
        .font(.headline)
        .foregroundColor(.red)
      Text(errorMessage)
        .font(.caption)
        .foregroundColor(.gray)
      Button("다시 시도") {
        onRetry()
      }
      .padding()
      .background(CVCColor.primary)
      .foregroundColor(.white)
      .cornerRadius(8)
    }
    .padding()
  }
}

#Preview {
  RetryView(errorMessage: "네트워크 연결을 확인해주세요") {
    print("다시 시도")
  }
}
