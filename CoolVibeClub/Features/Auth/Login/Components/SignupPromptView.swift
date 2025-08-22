//
//  SignupPromptView.swift
//  CoolVibeClub
//
//

import SwiftUI

struct SignupPromptView: View {
  let onSignupTapped: () -> Void
  
  var body: some View {
    Button(action: onSignupTapped) {
      HStack(spacing: 0) {
        Text("아직 클럽 회원이 아니신가요?  회원가입 하기")
          .font(.system(size: 12))
          .foregroundStyle(CVCColor.grayScale60)
        
        CVCImage.Navigation.noTailArrow.template
          .rotationEffect(.degrees(180))
          .foregroundStyle(CVCColor.grayScale60)
          .frame(width: 12, height: 12)
      }
    }
  }
}

#Preview {
  SignupPromptView(onSignupTapped: {})
}
