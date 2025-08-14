//
//  DistaneSliderView.swift
//  CoolVibeClub
//
//  Created by Claire on 8/15/25.
//

import SwiftUI

struct DistanceSliderView: View {
  @State private var selectedDistance: Double = 3
  let maxDistance: Double = 10
  let minDistance: Double = 0
  var onDistanceChanged: ((Double) -> Void)?
  
  init(onDistanceChanged: ((Double) -> Void)? = nil) {
    self.onDistanceChanged = onDistanceChanged
  }
  
  var body: some View {
    VStack(spacing: 6) {
      // MARK: - 텍스트 구간
      HStack {
        Text("Distance")
          .font(.system(size: 13, weight: .bold))
          .foregroundColor(CVCColor.grayScale60)
        Spacer()
        Text(String(format: "%.0f KM", selectedDistance))
          .font(.system(size: 13, weight: .bold))
          .foregroundColor(CVCColor.primary)
      }
      .padding(.horizontal, 4)
      
      
      // MARK: - 슬라이더 구간
      HStack(spacing: 12) {
        GeometryReader { geometry in
          ZStack(alignment: .leading) {
            /// 배경
            RoundedRectangle(cornerRadius: 12)
              .fill(CVCColor.grayScale15)
              .frame(height: 36)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(CVCColor.grayScale30, lineWidth: 1)
              )
            
            /// - Track(비활성화 구역)
            Capsule()
              .fill(CVCColor.grayScale30)
              .frame(height: 10)
              .padding(.horizontal, 16)
            
            /// Track(활성화 구역)
            Capsule()
              .fill(CVCColor.primary)
              .frame(width: geometry.size.width * (selectedDistance / maxDistance), height: 10)
              .padding(.horizontal, 16)
            
            /// Tumb
            ZStack {
              /// 실질적인 터치 영역
              Circle()
                .fill(Color.clear)
                .frame(width: 24, height: 24)
                .contentShape(Circle()) // 터치 영역을 명시적으로 정의
                .offset(x: geometry.size.width * (selectedDistance / maxDistance) - 12)
              
              /// UI
              Circle()
                .fill(CVCColor.grayScale0)
                .frame(width: 4, height: 4)
                .offset(x: geometry.size.width * (selectedDistance / maxDistance) - 16)
            }
            .gesture(
              DragGesture()
                .onChanged { value in
                  let newValue = min(max(0, value.location.x / geometry.size.width * maxDistance), maxDistance)
                  selectedDistance = newValue
                  onDistanceChanged?(newValue)
                }
            )
            .padding(.horizontal, 16)
          }
        }
      }
    }
    .frame(height: 70)
  }
}

