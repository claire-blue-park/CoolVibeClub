//
//  SlideBanner.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import Alamofire
import CoreLocation
import AVFoundation

struct SlideBanner: View {
  @State private var showWebView = false
  @State private var currentIndex = 0
  @State private var timer: Timer?
  
  private let bannerImages = ["banner_attendance", "banner_pickup", "banner_filter"]
  private let autoScrollInterval: TimeInterval = 3.0 // 3초마다 전환
  
  var body: some View {
    TabView(selection: $currentIndex) {
      ForEach(Array(bannerImages.enumerated()), id: \.offset) { index, imageName in
        Image(imageName)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(height: 100)
          .clipped()
//          .cornerRadius(12)
          .tag(index)
          .onTapGesture {
            showWebView = true
          }
      }
    }
    .frame(height: 120)
    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    .onAppear {
      startAutoScroll()
    }
    .onDisappear {
      stopAutoScroll()
    }
    .sheet(isPresented: $showWebView) {
      AttendanceWebView()
    }
    .onReceive(NotificationCenter.default.publisher(for: .attendanceCompleted)) { notification in
      showWebView = false
      
      // message.body에서 출석 횟수 가져오기
      let message = notification.object as? String ?? "출석 완료!🌟"

      AlertManager.shared.showAlert(
        title: "출석 완료",
        message: message
      )
    }
  }
  
  private func startAutoScroll() {
    timer = Timer.scheduledTimer(withTimeInterval: autoScrollInterval, repeats: true) { _ in
      withAnimation(.easeInOut(duration: 0.5)) {
        currentIndex = (currentIndex + 1) % bannerImages.count
      }
    }
  }
  
  private func stopAutoScroll() {
    timer?.invalidate()
    timer = nil
  }
}

#Preview {
  SlideBanner()
    .padding()
}
