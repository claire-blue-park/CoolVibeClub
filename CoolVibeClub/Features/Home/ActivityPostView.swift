//
//  ActivityPostView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct ActivityPostView: View {
  var body: some View {
    VStack {
      HStack {
        // 3 - 1. 타이틀
        Text("액티비티 포스트")
          .foregroundStyle(CVCColor.grayScale90)
          .font(.system(size: 14, weight: .bold))
        Spacer()
        Button {
          
        } label: {
          HStack {
            Text("최신순")
              .foregroundStyle(CVCColor.primary)
              .font(.system(size: 12, weight: .bold))
            CVCImage.sort.value
              .frame(width: 16, height: 16)
              .foregroundColor(CVCColor.primary)
          }
        }
      }
      // 3 - 2. 포스트 스크롤 영역
      PostCellView()
        .padding(.top, 20)
    }
  }
}

private struct PostCellView: View {
  var body: some View {
    VStack(spacing: 12) {
      // 프로필 영역
      HStack {
        // 프로필 이미지
        Image("")
          .frame(width: 32, height: 32)
          .background {
            RoundedRectangle(cornerRadius: 16)
              .fill(Color.primary)
          }
        VStack(alignment: .leading) {
          // 닉네임
          Text("씩씩한 새싹이")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(CVCColor.grayScale90)
          
          // 업로드 시간
          Text("1시간 34분 전")
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(CVCColor.grayScale60)
        }
        Spacer()
      }
      
      // 이미지
      Image("")
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background {
          RoundedRectangle(cornerRadius: 12)
            .fill(CVCColor.grayScale15)
        }
        .padding(.horizontal, -2)
      
      // 제목
      Text("하늘을 나는 새싹 패러글라이딩")
        .frame(maxWidth: .infinity - 4, alignment: .leading)
        .font(.system(size: 12, weight: .bold))
        .foregroundStyle(CVCColor.grayScale90)
      
      // 내용
      Text("처음엔 겁이 났어요. 줄 하나에 매달려 하늘을 난다는 게 상상조차 안 됐거든요. 하지만 이륙하는 순간, 걱정은 모두 사라졌습니다.")
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 2)
        .lineSpacing(4)
        .font(.system(size: 12, weight: .regular))
        .foregroundStyle(CVCColor.grayScale60)
      
    }
  }
}

