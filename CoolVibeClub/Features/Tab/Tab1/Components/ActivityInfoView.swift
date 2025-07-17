//
//  ActivityInfoView.swift
//  CoolVibeClub
//
//  Created by Claire on 7/16/25.
//

import SwiftUI

struct ActivityInfoView: View {
  let activityData: ActivityInfoData
  let onLikeTapped: () -> Void
  let onNavigateTapped: () -> Void

  @State private var loadedImage: UIImage? = nil
  @State private var isLoading: Bool = false

  var body: some View {
    ZStack(alignment: .topLeading) {
      // 배경 이미지
      GeometryReader { geometry in
        let width = geometry.size.width
        Group {
          if isLoading {
            ProgressView()
              .frame(width: width, height: width)
              .background(Color.gray.opacity(0.08))
          } else if let uiImage = loadedImage {
            Image(uiImage: uiImage)
              .resizable()
              .scaledToFill()
              .frame(width: width, height: width)
              .clipped()
              .cornerRadius(36)
          } else {
            Image("sample_activity")  // placeholder
              .resizable()
              .scaledToFill()
              .frame(width: width, height: width)
              .clipped()
              // .cornerRadius(36)
          }
        }
      }
      .onAppear {
        if loadedImage == nil && !isLoading {
          isLoading = true
          let endpoint = ActivityEndpoint(requestType: .newActivity)
          ImageLoadHelper.shared.loadImageWithHeaders(
            path: activityData.imageName, endpoint: endpoint
          ) { image in
            self.loadedImage = image
            self.isLoading = false
          }
        }
      }

      // 상단 라벨
      HStack(spacing: 8) {
        ZStack {
          Circle()
            .fill(Color.white)
            .frame(width: 32, height: 32)
          CVCImage.mapPin.value
            .resizable()
            .scaledToFit()
            .frame(width: 18, height: 18)
            .foregroundColor(Color.gray)
        }
        VStack(alignment: .leading, spacing: 0) {
          Text(activityData.country)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
          Text(activityData.category)
            .font(.system(size: 11, weight: .light))
            .foregroundColor(.white)
        }
      }
      .padding(.leading, 8)
      .padding(.trailing, 16)
      .padding(.vertical, 8)
      .background(Color.black.opacity(0.55))
      .clipShape(Capsule())
      .padding([.top, .leading], 12)
      .zIndex(2)

      // 하단 정보
      VStack(alignment: .leading, spacing: 8) {
        Spacer()
        Text(activityData.title)
          .font(.system(size: 22, weight: .bold))
          .foregroundColor(.white)
          .lineLimit(2)
        Text(activityData.price)
          .font(.system(size: 14))
          .foregroundColor(.white)
      }
      .padding([.leading, .bottom], 24)
      .frame(maxWidth: .infinity, alignment: .leading)

      // 우측 하단 버튼
      VStack {
        Spacer()
        HStack {
          Spacer()
          Button(action: onNavigateTapped) {
            Image(systemName: "arrow.right")
              .foregroundColor(.black)
              .frame(width: 32, height: 32)
              .background(Color.white)
              .clipShape(Circle())
          }
          .frame(width: 64, height: 64)
          .background(Color.white)
          .clipShape(Circle())
        }
        .padding([.trailing, .bottom], 16)
      }
    }
    .frame(height: 340) 
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .background(Color.gray.opacity(0.08))
    .cornerRadius(36)
    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
  }
}
