//
//  ImageLoadHelper.swift
//  CoolVibeClub
//
//  Created by Claire on 7/14/25.
//

import SwiftUI

final class ImageLoadHelper {
  static let shared = ImageLoadHelper()
  private init() {}

  func loadImageWithHeaders(
    path: String, endpoint: Endpoint, completion: @escaping (UIImage?) -> Void
  ) {
    // 이미지 URL 생성
    let urlString: String
    if path.lowercased().hasPrefix("http") {
      urlString = path
      print("🔗 완전한 URL 사용: \(urlString)")
    } else {
      let baseURLString =
        endpoint.baseURL.hasSuffix("/") ? String(endpoint.baseURL.dropLast()) : endpoint.baseURL
      urlString = "\(baseURLString)/v1\(path)"
      print("🔗 상대 경로 변환: \(urlString)")
    }
    guard let url = URL(string: urlString) else {
      print("❌ 잘못된 URL 형식: \(urlString)")
      completion(nil)
      return
    }
    var request = URLRequest(url: url)
    let headers = endpoint.headers
    headers.forEach { header in
      request.setValue(header.value, forHTTPHeaderField: header.name)
    }
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("❌ 이미지 로딩 에러: \(error.localizedDescription)")
        DispatchQueue.main.async { completion(nil) }
        return
      }
      if let data = data, let image = UIImage(data: data) {
        print("✅ 이미지 변환 성공")
        DispatchQueue.main.async { completion(image) }
      } else {
        print("❌ 이미지 변환 실패")
        DispatchQueue.main.async { completion(nil) }
      }
    }.resume()
  }
}
