//
//  ActivityPostClient.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import Alamofire

// MARK: - ActivityPostClient
struct ActivityPostClient {
  let fetchPostsByGeolocation: (String?, String?, String?, String?, String?, Int?, String?, String?) async throws -> ActivityPostsResponse
  let uploadFiles: ([UIImage]) async throws -> [String]
  let createPost: (CreatePostRequest) async throws -> CreatePostResponse
}

// MARK: - Live Implementation
extension ActivityPostClient {
  static let live = ActivityPostClient(
    fetchPostsByGeolocation: { country, category, longitude, latitude, maxDistance, limit, next, orderBy in
      let endpoint = ActivityPostEndpoint(
        requestType: .fetchPostsByGeolocation(
          country: country,
          category: category,
          longitude: longitude,
          latitude: latitude,
          maxDistance: maxDistance,
          limit: limit,
          next: next,
          orderBy: orderBy
        )
      )
      
      print("🌐 ActivityPost API 요청: \(endpoint.baseURL)\(endpoint.path)")
      print("📍 파라미터: country=\(country ?? "nil"), category=\(category ?? "nil"), lat=\(latitude ?? "nil"), lng=\(longitude ?? "nil"), maxDistance=\(maxDistance ?? "nil")")
      
      let interceptor = TokenRefreshInterceptor()
      let session = Session(interceptor: interceptor)
      
      let response = try await session.request(
        "\(endpoint.baseURL)\(endpoint.path)",
        method: endpoint.method,
        parameters: endpoint.parameters,
        headers: endpoint.headers
      )
      .validate()
      .serializingDecodable(ActivityPostsResponse.self)
      .value
      
      print("✅ ActivityPost API 응답: \(response.data.count)개 포스트")
      return response
    },
    uploadFiles: { images in
      let endpoint = ActivityPostEndpoint(requestType: .uploadFiles)
      let interceptor = TokenRefreshInterceptor()
      let session = Session(interceptor: interceptor)
      
      print("📤 파일 업로드 시작: \(images.count)개 이미지")
      print("🌐 URL: \(endpoint.baseURL)\(endpoint.path)")
      print("🔗 Method: \(endpoint.method.rawValue)")
      print("📋 Headers: \(endpoint.headers)")
      
      do {
        let uploadRequest = session.upload(
          multipartFormData: { formData in
            for (index, image) in images.enumerated() {
              if let imageData = image.jpegData(compressionQuality: 0.8) {
                print("📎 파일 \(index + 1): \(imageData.count) bytes, image_\(index).jpg")
                formData.append(
                  imageData,
                  withName: "files",
                  fileName: "image_\(index).jpg",
                  mimeType: "image/jpeg"
                )
              }
            }
          },
          to: "\(endpoint.baseURL)\(endpoint.path)",
          method: endpoint.method,
          headers: endpoint.headers
        )
        
        let dataResponse = try await uploadRequest.serializingData().value
        
        // HTTP 상태 코드 확인
        if let httpResponse = uploadRequest.response {
          print("📊 파일 업로드 HTTP 상태 코드: \(httpResponse.statusCode)")
          if httpResponse.statusCode >= 400 {
            print("❌ 파일 업로드 HTTP 에러 상태 코드: \(httpResponse.statusCode)")
            if let responseString = String(data: dataResponse, encoding: .utf8) {
              print("❌ 파일 업로드 에러 응답: \(responseString)")
            }
          }
        }
        
        let response = dataResponse
        
        // 응답 데이터 로깅
        print("📥 파일 업로드 응답 데이터:")
        if let responseString = String(data: response, encoding: .utf8) {
          print(responseString)
        }
        
        // JSON 디코딩
        let decodedResponse = try JSONDecoder().decode(UploadFilesResponse.self, from: response)
        print("✅ 파일 업로드 성공: \(decodedResponse.files.count)개 파일")
        return decodedResponse.files
        
      } catch let error as AFError {
        print("❌ 파일 업로드 Alamofire 에러: \(error)")
        print("❌ 에러 상세: \(error.localizedDescription)")
        
        switch error {
        case .responseValidationFailed(reason: let reason):
          print("❌ 응답 검증 실패: \(reason)")
        case .responseSerializationFailed(reason: let reason):
          print("❌ 응답 직렬화 실패: \(reason)")
        default:
          print("❌ 기타 AFError: \(error)")
        }
        
        throw error
      } catch {
        print("❌ 파일 업로드 일반 에러: \(error)")
        throw error
      }
    },
    createPost: { request in
      let endpoint = ActivityPostEndpoint(requestType: .createPost)
      let interceptor = TokenRefreshInterceptor()
      let session = Session(interceptor: interceptor)
      
      let parameters = [
        "country": request.country,
        "category": request.category,
        "title": request.title,
        "content": request.content,
        "activity_id": request.activityId,
        "latitude": request.latitude,
        "longitude": request.longitude,
        "files": request.files
      ] as [String : Any]
      
      print("📝 게시글 생성 요청 시작")
      print("🌐 URL: \(endpoint.baseURL)\(endpoint.path)")
      print("🔗 Method: \(endpoint.method.rawValue)")
      print("📋 Headers: \(endpoint.headers)")
      print("📦 Parameters: \(parameters)")
      
      let dataRequest = session.request(
        "\(endpoint.baseURL)\(endpoint.path)",
        method: endpoint.method,
        parameters: parameters,
        encoding: JSONEncoding.default,
        headers: endpoint.headers
      )
      
      // 요청 데이터 로깅
      print("📤 실제 전송 데이터:")
      if let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted),
         let jsonString = String(data: httpBody, encoding: .utf8) {
        print(jsonString)
      }
      
      do {
        let dataResponse = try await dataRequest.serializingData().value
        
        // HTTP 상태 코드 확인
        if let httpResponse = dataRequest.response {
          print("📊 HTTP 상태 코드: \(httpResponse.statusCode)")
          if httpResponse.statusCode >= 400 {
            print("❌ HTTP 에러 상태 코드: \(httpResponse.statusCode)")
            if let responseString = String(data: dataResponse, encoding: .utf8) {
              print("❌ 에러 응답: \(responseString)")
            }
          }
        }
        
        let response = dataResponse
        
        // 응답 데이터 로깅
        print("📥 서버 응답 데이터:")
        if let responseString = String(data: response, encoding: .utf8) {
          print(responseString)
        }
        
        // JSON 디코딩 시도
        do {
          let decodedResponse = try JSONDecoder().decode(CreatePostResponse.self, from: response)
          print("✅ 게시글 생성 성공: ID \(decodedResponse.id ?? "알 수 없음")")
          return decodedResponse
        } catch {
          print("❌ JSON 디코딩 실패: \(error)")
          // 디코딩에 실패해도 성공으로 간주 (서버 응답이 있으면 성공)
          if let httpResponse = dataRequest.response, httpResponse.statusCode == 200 {
            print("✅ HTTP 200 응답이므로 게시글 생성 성공으로 처리")
            return CreatePostResponse(id: nil, message: "게시글이 생성되었습니다.")
          } else {
            throw error
          }
        }
        
      } catch let error as AFError {
        print("❌ 게시글 생성 Alamofire 에러: \(error)")
        print("❌ 에러 상세: \(error.localizedDescription)")
        
        switch error {
        case .responseValidationFailed(reason: let reason):
          print("❌ 응답 검증 실패: \(reason)")
        case .responseSerializationFailed(reason: let reason):
          print("❌ 응답 직렬화 실패: \(reason)")
        default:
          print("❌ 기타 AFError: \(error)")
        }
        
        throw error
      } catch {
        print("❌ 게시글 생성 일반 에러: \(error)")
        throw error
      }
    }
  )
}

// MARK: - Mock Implementation
extension ActivityPostClient {
  static let mock = ActivityPostClient(
    fetchPostsByGeolocation: { _, _, _, _, _, _, _, _ in
      // Mock 데이터 반환
      let mockPosts = [
        ActivityPost(
          id: "1",
          country: "대한민국",
          category: "관광",
          title: "서울 한강 러닝 모임",
          content: "오늘 한강에서 러닝했어요! 날씨가 너무 좋았습니다. 다음에도 같이 뛰실 분들 환영해요!",
          activity: PostActivity(
            id: "activity1",
            title: "한강 러닝 투어",
            country: "대한민국",
            category: "스포츠",
            thumbnails: ["https://example.com/activity1.jpg"],
            geolocation: ActivityGeolocation(longitude: 126.9780, latitude: 37.5665),
            price: ActivityPrice(original: 20000, final: 15000),
            tags: ["러닝", "한강"],
            pointReward: 100,
            isAdvertisement: false,
            isKeep: true,
            keepCount: 25
          ),
          geolocation: PostGeolocation(longitude: 126.9780, latitude: 37.5665),
          creator: PostCreator(
            userId: "user1",
            nick: "러닝러버",
            profileImage: nil,
            introduction: "러닝을 좋아합니다"
          ),
          files: [
            "https://example.com/hangang1.jpg",
            "https://example.com/hangang2.jpg"
          ],
          isLike: false,
          likeCount: 3,
          createdAt: "2025-01-28T08:30:00Z",
          updatedAt: "2025-01-28T08:30:00Z"
        ),
        ActivityPost(
          id: "2",
          country: "대한민국",
          category: "관광",
          title: "제주도 오름 등반 후기",
          content: "성산일출봉에 다녀왔습니다. 일출이 정말 아름다웠어요! 다들 제주도 오시면 꼭 가보세요.",
          activity: PostActivity(
            id: "activity2",
            title: "제주 성산일출봉 투어",
            country: "대한민국",
            category: "관광",
            thumbnails: ["https://example.com/activity2.jpg"],
            geolocation: ActivityGeolocation(longitude: 126.9422, latitude: 33.4588),
            price: ActivityPrice(original: 50000, final: 40000),
            tags: ["제주", "등반", "일출"],
            pointReward: 200,
            isAdvertisement: false,
            isKeep: false,
            keepCount: 50
          ),
          geolocation: PostGeolocation(longitude: 126.9422, latitude: 33.4588),
          creator: PostCreator(
            userId: "user2",
            nick: "산악인",
            profileImage: nil,
            introduction: "산을 사랑하는 사람"
          ),
          files: [
            "https://example.com/jeju1.jpg"
          ],
          isLike: true,
          likeCount: 2,
          createdAt: "2025-01-28T06:15:00Z",
          updatedAt: "2025-01-28T06:15:00Z"
        )
      ]
      
      return ActivityPostsResponse(data: mockPosts, nextCursor: nil)
    },
    uploadFiles: { images in
      // Mock 파일 URL 반환
      let mockFiles = images.enumerated().map { index, _ in
        "/data/posts/image_\(Date().timeIntervalSince1970)_\(index).png"
      }
      return mockFiles
    },
    createPost: { request in
      // Mock 게시글 생성 응답
      return CreatePostResponse(
        id: "mock_\(Date().timeIntervalSince1970)",
        message: "게시글이 성공적으로 생성되었습니다."
      )
    }
  )
}

// MARK: - Request/Response Models

struct CreatePostRequest {
  let country: String
  let category: String
  let title: String
  let content: String
  let activityId: String
  let latitude: Double
  let longitude: Double
  let files: [String]
}

struct CreatePostResponse: Decodable {
  let id: String?
  let message: String?
  
  // 실제 서버 응답 구조에 맞춰서 필드를 옵셔널로 처리
  private enum CodingKeys: String, CodingKey {
    case id
    case message
  }
  
  init(id: String?, message: String?) {
    self.id = id
    self.message = message
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decodeIfPresent(String.self, forKey: .id)
    message = try container.decodeIfPresent(String.self, forKey: .message)
  }
}

struct UploadFilesResponse: Decodable {
  let files: [String]
}
