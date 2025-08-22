//
//  ContinueButtonView.swift
//  CoolVibeClub
//
//  계속 버튼 컴포넌트
//  🔥 컴포넌트 분리: 재사용 가능한 버튼 스타일
//

import SwiftUI

struct CTAButton: View {
  let title: String
  let isEnabled: Bool
  let action: () -> Void
  
  init(
    title: String,
    isEnabled: Bool = true,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.isEnabled = isEnabled
    self.action = action
  }
  
  var body: some View {
    Button(action: action) {
      Text(title)
        .foregroundColor(CVCColor.grayScale0)
        .font(.system(size: 15, weight: .semibold))
        .frame(maxWidth: .infinity)
        .padding()
        .background(isEnabled ? CVCColor.primary : CVCColor.grayScale30)
        .cornerRadius(36)
    }
    .disabled(!isEnabled)
    .padding(.horizontal)
  }
}

#Preview {
  VStack {
    CTAButton(title: "다음", action: {})
    CTAButton(title: "다음", isEnabled: false, action: {})
  }
}
