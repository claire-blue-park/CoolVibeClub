//
//  AttendanceWebView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import WebKit

struct AttendanceWebView: View {
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        // 커스텀 네비게이션 바
        HStack {
          BackButton {
            dismiss()
          }
          
          Spacer()
          
          Text("출석 이벤트")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(CVCColor.grayScale90)
          
          Spacer()
          
          Color.clear
            .frame(width: 24, height: 24)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        
        // WebView
        AttendanceWebViewRepresentable()
      }
      .navigationBarHidden(true)
    }
  }
}

struct AttendanceWebViewRepresentable: UIViewRepresentable {
  
  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()
    config.userContentController = context.coordinator.wkController
  
    let webView = WKWebView(frame: .zero, configuration: config)
    context.coordinator.webView = webView
    
    // URL 로드
    if let url = BannerEndpoint(requestType: .eventApplication).url {
      var request = URLRequest(url: url)
      request.addValue(APIKeys.SesacKey, forHTTPHeaderField: "SeSACKey")
      webView.load(request)
    }

    return webView
  }
  
  func updateUIView(_ uiView: WKWebView, context: Context) {
    // 필요시 업데이트 로직
  }
  
  func makeCoordinator() -> AttendanceWebViewCoordinator {
    return AttendanceWebViewCoordinator()
  }
}

// WebViewCoordinator 로직을 직접 구현
enum BannerHandlerKey {
  static let attClickedKey = "click_attendance_button"
  static let attCompleteKey = "complete_attendance"
}

final class AttendanceWebViewCoordinator: NSObject, WKScriptMessageHandler {
  var webView: WKWebView?
  let wkController = WKUserContentController()
  
  override init() {
    super.init()
    
    wkController.add(self, name: BannerHandlerKey.attClickedKey)
    wkController.add(self, name: BannerHandlerKey.attCompleteKey)
  }
  
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if let webView {
      switch message.name {
      case BannerHandlerKey.attClickedKey:
        if let token = UserDefaultsHelper.shared.getAccessToken() {
          webView.evaluateJavaScript ("requestAttendance('\(token)')")
        }
      case BannerHandlerKey.attCompleteKey:
        
        let count = message.body as? Int
        
        // count가 있으면 횟수 포함, 없으면 기본 메시지
        let notiMessage: String
        if let count {
          notiMessage = "\(count)번째 출석 완료! 🎉"
        } else {
          notiMessage = "출석이 완료! 🎉"
        }
        
        DispatchQueue.main.async {
          NotificationCenter.default.post(name: .attendanceCompleted, object: notiMessage)
        }
      default:
        break
      }
    }
  }
}

#Preview {
  AttendanceWebView()
}
