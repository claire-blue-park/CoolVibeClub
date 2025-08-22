//
//  LoginTitleView.swift
//  CoolVibeClub
//
//

import SwiftUI

struct LoginTitleView: View {
  let title: String
  
  init(_ title: String = "Cool Vibe Club") {
    self.title = title
  }
  
  var body: some View {
    VStack(spacing: 8) {
      Text(title)
        .loginTitleStyle()
      
      Text("이메일 로그인")
        .font(.system(size: 16, weight: .bold))
        .foregroundColor(CVCColor.grayScale90)
        .frame(maxWidth: .infinity)
    }
  }
}

#Preview {
  LoginTitleView()
}
