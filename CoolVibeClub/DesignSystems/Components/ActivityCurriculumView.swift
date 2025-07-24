//
//  ActivityCurriculumView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI

struct ActivityCurriculumView: View {
//  let title: String
  let items: [CurriculumItem]
  let location: CurriculumLocation?
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      // 타이틀
      Text("액티비티 커리큘럼")
        .font(.system(size: 14, weight: .bold))
        .foregroundColor(CVCColor.grayScale45)
        .padding(.horizontal, 4)
      
      VStack(alignment: .leading, spacing: 0) {
        // 커리큘럼 아이템들
        ForEach(Array(items.enumerated()), id: \.offset) { index, item in
          CurriculumItemRow(
            item: item,
            isLast: index == items.count - 1
          )
        }
        
        // 위치 정보
        if let location = location {
          CurriculumLocationRow(location: location)
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 20)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(CVCColor.grayScale15)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(CVCColor.grayScale30, lineWidth: 1)
          )
      )
//      .padding(.horizontal, 16)
    }
  }
}

// MARK: - CurriculumItem
struct CurriculumItem {
  let time: String
  let title: String
  let description: String?
}

// MARK: - CurriculumLocation
struct CurriculumLocation {
  let name: String
  let address: String
  let mapImage: String?
}

// MARK: - CurriculumItemRow
private struct CurriculumItemRow: View {
  let item: CurriculumItem
  let isLast: Bool
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      // 타임라인 점과 선
      VStack(spacing: 0) {
        Circle()
          .fill(CVCColor.primary)
          .frame(width: 8, height: 8)
        
        if !isLast {
          Rectangle()
            .fill(CVCColor.grayScale30)
            .frame(width: 2, height: 40)
        }
      }
      .padding(.top, 4)
      
      // 내용
      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text(item.time)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(CVCColor.grayScale45)
          
          Spacer()
        }
        
        Text(item.title)
          .font(.system(size: 13, weight: .semibold))
          .foregroundColor(CVCColor.grayScale75)
        
        if let description = item.description {
          Text(description)
            .font(.system(size: 12))
            .foregroundColor(CVCColor.grayScale60)
            .lineSpacing(2)
        }
      }
      .padding(.bottom, isLast ? 0 : 16)
    }
  }
}

// MARK: - CurriculumLocationRow
private struct CurriculumLocationRow: View {
  let location: CurriculumLocation
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      // 지도 아이콘
      VStack(spacing: 0) {
        CVCImage.Action.distance.template
          .frame(width: 20, height: 20)
          .foregroundStyle(CVCColor.grayScale45)
 
      }
      .padding(.top, 4)
      
      // 위치 정보
      VStack(alignment: .leading, spacing: 8) {
        VStack(alignment: .leading, spacing: 4) {
          Text(location.name)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(CVCColor.grayScale75)
          
          Text(location.address)
            .font(.system(size: 10))
            .foregroundColor(CVCColor.grayScale45)
        }
        
//        // 지도 이미지 (있는 경우)
//        if let mapImage = location.mapImage {
//          AsyncImage(url: URL(string: mapImage)) { image in
//            image
//              .resizable()
//              .aspectRatio(contentMode: .fill)
//          } placeholder: {
//            Rectangle()
//              .fill(CVCColor.grayScale30)
//              .overlay(
//                VStack(spacing: 4) {
//                  CVCImage.Action.mapPin.template
//                    .frame(width: 20, height: 20)
//                    .foregroundColor(CVCColor.grayScale60)
//                  Text("지도 로딩 중...")
//                    .font(.caption2)
//                    .foregroundColor(CVCColor.grayScale60)
//                }
//              )
//          }
//          .frame(height: 80)
//          .clipShape(RoundedRectangle(cornerRadius: 8))
//        }
      }
    
    }
    .padding(.top, 24)
  }
}

// MARK: - Preview
#Preview {
  VStack(spacing: 24) {
    ActivityCurriculumView(
//      title: "액티비티 커리큘럼",
      items: [
        CurriculumItem(
          time: "10분 - 20분",
          title: "부상 방지를 위한 기본 스트레칭",
          description: nil
        ),
        CurriculumItem(
          time: "20분 - 30분",
          title: "장비 착용 및 점검 (강사 동행)",
          description: nil
        ),
        CurriculumItem(
          time: "30분 - 60분",
          title: "안전교육 및 기본 자세 설명",
          description: nil
        ),
        CurriculumItem(
          time: "60분 - 90분",
          title: "초보자 코스에서 자세 교정과 간단한 주행 연습",
          description: nil
        ),
        CurriculumItem(
          time: "90분 - 120분",
          title: "짧은 자유 시간 후, 기념 촬영으로 마무리",
          description: nil
        )
      ],
      location: CurriculumLocation(
        name: "용평리우, 스위스",
        address: "3984 GXP7+P2 Fieschertal, Swiss",
        mapImage: nil
      )
    )
  }
  .padding()
  .background(Color.white)
}
