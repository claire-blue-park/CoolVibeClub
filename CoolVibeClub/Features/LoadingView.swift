//
//  LoadingView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/11/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            
            // 로고 또는 앱 이름
          Text("Cool Vibe Club")
              .navTitleStyle()
            
            // 로딩 인디케이터
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: CVCColor.primary))
                .scaleEffect(1.5)
                .padding(.bottom, 20)
            
            // 로딩 메시지
            Text("로그인 정보를 확인하는 중입니다...")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
                .padding(.bottom, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    LoadingView()
}
