//
//  SocialLoginSectionView.swift
//  CoolVibeClub
//
//

import SwiftUI

struct SocialLoginView: View {
  let onLoginSuccess: () -> Void
  
  var body: some View {
    VStack(spacing: 24) {
      HStack {
        Rectangle()
          .frame(height: 1)
          .foregroundColor(Color.gray.opacity(0.3))
        
        Text("또는 소셜 로그인")
          .font(.caption)
          .foregroundColor(.gray)
        
        Rectangle()
          .frame(height: 1)
          .foregroundColor(Color.gray.opacity(0.3))
      }
      .padding(.horizontal)
      
      HStack(spacing: 24) {
        KakaoLoginButton(onLoginSuccess: onLoginSuccess)
        AppleLoginButton(onLoginSuccess: onLoginSuccess)
      }
      .padding(.bottom, 32)
    }
  }
}

#Preview {
  SocialLoginView(onLoginSuccess: {})
}
