//
//  ImageLoadHelper.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import Alamofire
import Kingfisher

// MARK: - MediaExtension
enum MediaExtension: String, CaseIterable {
  // Video Extensions
  case mp4, mov, avi, mkv, m4v, webm, m3u8
  
  // Image Extensions  
  case jpg, jpeg, png, gif, bmp, webp, svg
  
  var mediaType: MediaType {
    switch self {
    case .mp4, .mov, .avi, .mkv, .m4v, .webm, .m3u8:
      return .video
    case .jpg, .jpeg, .png, .gif, .bmp, .webp, .svg:
      return .image
    }
  }
  
  static var videoExtensions: [MediaExtension] {
    return allCases.filter { $0.mediaType == .video }
  }
  
  static var imageExtensions: [MediaExtension] {
    return allCases.filter { $0.mediaType == .image }
  }
}

// MARK: - MediaType
enum MediaType {
  case image
  case video
  
  static func from(url: String) -> MediaType {
    if let urlObj = URL(string: url), !urlObj.pathExtension.isEmpty {
      let pathExtension = urlObj.pathExtension.lowercased()
      if let mediaExtension = MediaExtension(rawValue: pathExtension) {
        return mediaExtension.mediaType
      }
    }
    
    // Fallback for URLs without clear extension
    let lowercasedURL = url.lowercased()
    for mediaExt in MediaExtension.allCases {
      if lowercasedURL.hasSuffix(".\(mediaExt.rawValue)") {
        return mediaExt.mediaType
      }
    }
    
    // Default to image if extension is unknown
    return .image
  }
}

// MARK: - MediaResult
enum MediaResult {
  case image(UIImage)
  case video(URL)
  case failure(String)
}

final class ImageLoadHelper {
  static let shared = ImageLoadHelper()
  private let session: Session
  
  private init() {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 30
    configuration.timeoutIntervalForResource = 60
    let interceptor = TokenRefreshInterceptor()
    session = Session(configuration: configuration, interceptor: interceptor)
    
    // Kingfisher 캐시 설정
    setupImageCache()
  }
  
  // MARK: - 이미지 캐시 설정
  private func setupImageCache() {
    let cache = ImageCache.default
    
    // 메모리 캐시 설정
    cache.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024 // 100MB
    cache.memoryStorage.config.expiration = .seconds(300) // 5분
    
    // 디스크 캐시 설정
    cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024 // 500MB
    cache.diskStorage.config.expiration = .days(7) // 7일
    
    print("✅ Kingfisher 캐시 설정 완료 - 메모리: 100MB, 디스크: 500MB")
  }
  
  // MARK: - 캐싱된 이미지 로딩 (Alamofire 기반으로 개선)
  func loadCachedImage(
    path: String,
    endpoint: Endpoint,
    completion: @escaping (UIImage?) -> Void
  ) {
    let mediaType = getMediaType(for: path)
    
    if mediaType == .video {
      print("🎬 비디오 파일 감지: \(path) - 이미지 로딩 건너뜀")
      DispatchQueue.main.async { completion(nil) }
      return
    }
    
    let urlString: String
    if path.lowercased().hasPrefix("http") {
      urlString = path
    } else {
      let baseURLString = endpoint.baseURL.hasSuffix("/") ? String(endpoint.baseURL.dropLast()) : endpoint.baseURL
      urlString = "\(baseURLString)/v1\(path)"
    }
    
    guard let url = URL(string: urlString) else {
      print("❌ 잘못된 URL 형식: \(urlString)")
      completion(nil)
      return
    }
    
    // 먼저 Kingfisher 캐시에서 확인
    let cacheKey = urlString
    ImageCache.default.retrieveImage(forKey: cacheKey) { result in
      switch result {
      case .success(let value):
        if let image = value.image {
          print("✅ 캐시에서 이미지 로드: \(url)")
          DispatchQueue.main.async {
            completion(image)
          }
          return
        }
        
        // 캐시에 없으면 Alamofire로 다운로드 (토큰 갱신 지원)
        print("🔄 캐시에 없음 - Alamofire로 다운로드: \(url)")
        self.downloadImageWithAlamofire(url: url, endpoint: endpoint, cacheKey: cacheKey, completion: completion)
        
      case .failure(let error):
        print("❌ 캐시 확인 실패: \(error.localizedDescription)")
        // 캐시 확인 실패해도 다운로드 시도
        self.downloadImageWithAlamofire(url: url, endpoint: endpoint, cacheKey: cacheKey, completion: completion)
      }
    }
  }
  
  // MARK: - Alamofire를 사용한 이미지 다운로드 (토큰 갱신 지원)
  private func downloadImageWithAlamofire(
    url: URL,
    endpoint: Endpoint,
    cacheKey: String,
    completion: @escaping (UIImage?) -> Void
  ) {
    session.request(url, headers: HTTPHeaders(endpoint.headers.dictionary))
      .responseData { response in
        switch response.result {
        case .success(let data):
          if let image = UIImage(data: data) {
            print("✅ Alamofire 이미지 다운로드 성공: \(url)")
            
            // Kingfisher 캐시에 저장
            ImageCache.default.store(image, forKey: cacheKey)
            
            DispatchQueue.main.async {
              completion(image)
            }
          } else {
            print("❌ 이미지 데이터 변환 실패: \(url)")
            DispatchQueue.main.async {
              completion(nil)
            }
          }
        case .failure(let error):
          if let statusCode = response.response?.statusCode {
            print("❌ Alamofire 이미지 다운로드 실패: HTTP \(statusCode) - \(error.localizedDescription) - \(url)")
          } else {
            print("❌ Alamofire 이미지 다운로드 실패: \(error.localizedDescription) - \(url)")
          }
          DispatchQueue.main.async {
            completion(nil)
          }
        }
      }
  }
  
  // MARK: - 캐시 관리 메서드
  func clearImageCache() {
    ImageCache.default.clearMemoryCache()
    ImageCache.default.clearDiskCache()
    print("🗑️ 이미지 캐시 삭제 완료")
  }
  
  func getCacheSize(completion: @escaping (UInt) -> Void) {
    ImageCache.default.calculateDiskStorageSize { result in
      switch result {
      case .success(let size):
        completion(size)
      case .failure:
        completion(0)
      }
    }
  }
  
  func getCacheSize() async -> UInt {
    return await withCheckedContinuation { continuation in
      ImageCache.default.calculateDiskStorageSize { result in
        switch result {
        case .success(let size):
          continuation.resume(returning: size)
        case .failure:
          continuation.resume(returning: 0)
        }
      }
    }
  }
  
  // MARK: - Media Type 확인
  func getMediaType(for path: String) -> MediaType {
    let urlString: String
    if path.lowercased().hasPrefix("http") {
      urlString = path
      print("🔗 완전한 URL 사용: \(urlString)")
    } else {
      urlString = path
      print("🔗 상대 경로 사용: \(path)")
    }
    
    return MediaType.from(url: urlString)
  }

  func loadImageWithHeaders(
    path: String, endpoint: Endpoint, completion: @escaping (UIImage?) -> Void
  ) {
    let mediaType = getMediaType(for: path)
    
    if mediaType == .video {
      print("🎬 비디오 파일 감지: \(path) - 이미지 로딩 건너뜀")
      DispatchQueue.main.async { completion(nil) }
      return
    }
    
    let urlString: String
    if path.lowercased().hasPrefix("http") {
      urlString = path
      print("🔗 완전한 URL 사용: \(urlString)")
    } else {
      let baseURLString = endpoint.baseURL.hasSuffix("/") ? String(endpoint.baseURL.dropLast()) : endpoint.baseURL
      urlString = "\(baseURLString)/v1\(path)"
      print("🔗 상대 경로 변환: \(urlString)")
    }
    
    guard let url = URL(string: urlString) else {
      print("❌ 잘못된 URL 형식: \(urlString)")
      completion(nil)
      return
    }
    
    print("🔍 요청 헤더: \(endpoint.headers.dictionary)")
    
    session.request(url, headers: HTTPHeaders(endpoint.headers.dictionary))
      .responseData { response in
        switch response.result {
        case .success(let data):
          if let image = UIImage(data: data) {
            print("✅ 이미지 변환 성공: \(url)")
            DispatchQueue.main.async { completion(image) }
          } else {
            print("❌ 이미지 데이터 변환 실패: \(url)")
            DispatchQueue.main.async { completion(nil) }
          }
        case .failure(let error):
          if let statusCode = response.response?.statusCode {
            print("❌ 이미지 로딩 실패: HTTP \(statusCode) - \(error.localizedDescription) - \(url)")
          } else {
            print("❌ 이미지 로딩 실패: \(error.localizedDescription) - \(url)")
          }
          DispatchQueue.main.async { completion(nil) }
        }
      }
  }
  
  // MARK: - 미디어 타입별 URL 처리
  func loadMediaWithHeaders(
    path: String,
    endpoint: Endpoint,
    completion: @escaping (MediaResult) -> Void
  ) {
    let mediaType = getMediaType(for: path)
    
    let urlString: String
    if path.lowercased().hasPrefix("http") {
      urlString = path
      print("🔗 완전한 URL 사용: \(urlString)")
    } else {
      let baseURLString = endpoint.baseURL.hasSuffix("/") ? String(endpoint.baseURL.dropLast()) : endpoint.baseURL
      urlString = "\(baseURLString)/v1\(path)"
      print("🔗 상대 경로 변환: \(urlString)")
    }
    
    guard let url = URL(string: urlString) else {
      print("❌ 잘못된 URL 형식: \(urlString)")
      DispatchQueue.main.async { completion(.failure("잘못된 URL 형식")) }
      return
    }
    
    print("🔍 미디어 요청 시작: \(urlString) - 타입: \(mediaType)")
    print("🔍 요청 헤더: \(endpoint.headers.dictionary)")
    
    switch mediaType {
    case .video:
      let destination: DownloadRequest.Destination = { _, _ in
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(url.lastPathComponent)
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
      }
      
      session.download(url, headers: HTTPHeaders(endpoint.headers.dictionary), to: destination)
        .response { response in
          if let fileURL = response.fileURL {
            print("✅ 비디오 다운로드 완료: \(fileURL.absoluteString)")
            DispatchQueue.main.async { completion(.video(fileURL)) }
          } else if let error = response.error {
            if let statusCode = response.response?.statusCode {
              print("❌ 비디오 다운로드 실패: HTTP \(statusCode) - \(error.localizedDescription) - \(url)")
              DispatchQueue.main.async { completion(.failure("비디오 다운로드 실패: HTTP \(statusCode) - \(error.localizedDescription)")) }
            } else {
              print("❌ 비디오 다운로드 실패: \(error.localizedDescription) - \(url)")
              DispatchQueue.main.async { completion(.failure("비디오 다운로드 실패: \(error.localizedDescription)")) }
            }
          }
        }
      
    case .image:
      session.request(url, headers: HTTPHeaders(endpoint.headers.dictionary))
        .responseData { response in
          switch response.result {
          case .success(let data):
            if let image = UIImage(data: data) {
              print("✅ 이미지 변환 성공: \(url)")
              DispatchQueue.main.async { completion(.image(image)) }
            } else {
              print("❌ 이미지 데이터 변환 실패: \(url)")
              DispatchQueue.main.async { completion(.failure("이미지 데이터 변환 실패")) }
            }
          case .failure(let error):
            if let statusCode = response.response?.statusCode {
              print("❌ 이미지 로딩 실패: HTTP \(statusCode) - \(error.localizedDescription) - \(url)")
              DispatchQueue.main.async { completion(.failure("이미지 로딩 실패: HTTP \(statusCode) - \(error.localizedDescription)")) }
            } else {
              print("❌ 이미지 로딩 실패: \(error.localizedDescription) - \(url)")
              DispatchQueue.main.async { completion(.failure(error.localizedDescription)) }
            }
          }
        }
    }
  }
}
