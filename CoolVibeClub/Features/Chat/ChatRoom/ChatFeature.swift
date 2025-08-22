//
//  ChatFeature.swift
//  CoolVibeClub
//
//  TCA(The Composable Architecture) 스타일 구조
//  🔥 이해 필수: Action(액션), State(상태), Reducer(로직) 패턴
//

import SwiftUI
import Foundation
import PhotosUI

// MARK: - 🔥 State (상태 관리)
/// Chat 화면의 모든 상태를 담는 구조체
/// 🔥 중요: 화면에 보여지는 모든 데이터와 상태가 여기에 모임
struct ChatState {
  // 메시지 관련 상태
  var messages: [Message] = []
  var currentChatRoom: ChatRoom?
  var input: String = ""
  
  // UI 상태
  var isLoading: Bool = true
  var errorMessage: String? = nil
  var isKeyboardVisible: Bool = false
  
  // 파일 업로드 관련 상태
  var showingFilePicker: Bool = false
  var showingPhotosPicker: Bool = false
  var showingDocumentPicker: Bool = false
  var selectedPhotos: [PhotosPickerItem] = []
  var selectedUIImages: [UIImage] = []
}

// MARK: - 🔥 Action (액션 정의)
/// 사용자가 할 수 있는 모든 행동을 열거형으로 정의
/// 🔥 중요: 메시지 전송, 파일 업로드 등 모든 사용자 행동이 Action이 됨
enum ChatAction {
  // 초기화 액션
  case loadInitial                         // 초기 채팅 데이터 로드
  
  // 메시지 관련 액션
  case setInput(String)                    // 입력 텍스트 변경
  case sendMessage                         // 메시지 전송
  case retryMessage(Message)               // 메시지 재전송
  case receiveMessage(ChatMessage)         // 메시지 수신
  
  // UI 상태 액션
  case setKeyboardVisible(Bool)            // 키보드 표시/숨김
  case setError(String?)                   // 에러 메시지 설정
  case setLoading(Bool)                    // 로딩 상태 변경
  
  // 파일 업로드 액션
  case setShowingFilePicker(Bool)          // 파일 선택기 표시/숨김
  case setShowingPhotosPicker(Bool)        // 사진 선택기 표시/숨김
  case setShowingDocumentPicker(Bool)      // 문서 선택기 표시/숨김
  case setSelectedPhotos([PhotosPickerItem]) // 선택된 사진 설정
  case setSelectedUIImages([UIImage])      // 선택된 UI 이미지 설정
  case removePhoto(UIImage)                // 사진 제거
  case uploadFiles([URL])                  // 파일 업로드
  
  // 내부 액션 (Private)
  case _chatRoomLoaded(ChatRoom?)          // 채팅방 로드 완료 (내부용)
  case _messagesLoaded([Message])          // 메시지 로드 완료 (내부용)
  case _messageStatusUpdated(UUID, MessageStatus) // 메시지 상태 업데이트 (내부용)
  case _photosConverted([UIImage])         // 사진 변환 완료 (내부용)
}

// MARK: - 🔥 Store (상태 저장소)
/// State와 Action을 연결하고 관리하는 클래스
/// 🔥 중요: 이 클래스가 모든 상태 변화를 처리함
@MainActor
final class ChatStore: ObservableObject {
  // 현재 상태 (Published로 UI 자동 업데이트)
  @Published var state = ChatState()
  
  // Dependencies
  private let roomId: String
  private let chatService: ChatService = .shared
  
  init(roomId: String) {
    self.roomId = roomId
  }
  
  // MARK: - 🔥 Reducer (액션 처리 로직)
  /// Action이 들어왔을 때 State를 어떻게 변경할지 정의
  /// 🔥 중요: 모든 비즈니스 로직이 여기에 집중됨
  func send(_ action: ChatAction) {
    switch action {
      
    // 초기화 처리
    case .loadInitial:
      performInitialLoading()
      
    // 메시지 관련 처리
    case .setInput(let text):
      state.input = text
      
    case .sendMessage:
      performSendMessage()
      
    case .retryMessage(let message):
      performRetryMessage(message)
      
    case .receiveMessage(let chatMessage):
      handleReceivedMessage(chatMessage)
      
    // UI 상태 처리
    case .setKeyboardVisible(let visible):
      state.isKeyboardVisible = visible
      
    case .setError(let message):
      state.errorMessage = message
      
    case .setLoading(let isLoading):
      state.isLoading = isLoading
      
    // 파일 업로드 처리
    case .setShowingFilePicker(let show):
      state.showingFilePicker = show
      
    case .setShowingPhotosPicker(let show):
      state.showingPhotosPicker = show
      
    case .setShowingDocumentPicker(let show):
      state.showingDocumentPicker = show
      
    case .setSelectedPhotos(let items):
      state.selectedPhotos = items
      performPhotosConversion(items)
      
    case .setSelectedUIImages(let images):
      state.selectedUIImages = images
      
    case .removePhoto(let photo):
      state.selectedUIImages.removeAll { $0 === photo }
      
    case .uploadFiles(let urls):
      performFileUpload(urls)
      
    // 내부 액션 처리
    case ._chatRoomLoaded(let chatRoom):
      state.currentChatRoom = chatRoom
      
    case ._messagesLoaded(let messages):
      state.messages = messages
      send(.setLoading(false))
      
    case ._messageStatusUpdated(let messageId, let status):
      if let index = state.messages.firstIndex(where: { $0.id == messageId }) {
        state.messages[index].status = status
      }
      
    case ._photosConverted(let images):
      state.selectedUIImages = images
      state.selectedPhotos = [] // PhotosPicker selection 초기화
    }
  }
  
  // MARK: - 🔥 비동기 작업 함수들
  
  /// 초기 데이터 로딩 수행
  private func performInitialLoading() {
    Task {
      await loadChatMessages()
    }
  }
  
  /// 메시지 전송 수행
  private func performSendMessage() {
    Task {
      await sendMessage()
    }
  }
  
  /// 메시지 재전송 수행
  private func performRetryMessage(_ message: Message) {
    Task {
      await retryMessage(message)
    }
  }
  
  /// 사진 변환 수행
  private func performPhotosConversion(_ photos: [PhotosPickerItem]) {
    Task {
      await convertPhotosToUIImages(photos)
    }
  }
  
  /// 파일 업로드 수행
  private func performFileUpload(_ urls: [URL]) {
    Task {
      await uploadFiles(urls)
    }
  }
  
  /// 채팅 메시지를 서버에서 로딩
  private func loadChatMessages() async {
    await MainActor.run {
      send(.setLoading(true))
      send(.setError(nil))
    }
    
    do {
      let actualRoomId: String
      if roomId.hasPrefix("temp_") {
        let opponentId = String(roomId.dropFirst(5))
        let chatRoom = try await chatService.createOrFindChatRoom(opponentId: opponentId)
        actualRoomId = chatRoom.roomId
        await MainActor.run {
          send(._chatRoomLoaded(chatRoom))
        }
      } else {
        actualRoomId = roomId
      }
      
      let chatHistory = try await chatService.fetchMessages(roomId: actualRoomId)
      let currentUserId = UserDefaultsHelper.shared.getUserId()
      let messages = chatHistory.data.map { chatMessage in
        let isMe = chatMessage.sender.userId == currentUserId
        let timestamp = parseServerTimestamp(chatMessage.createdAt) ?? Date()
        return Message(text: chatMessage.content, isMe: isMe, files: chatMessage.files, timestamp: timestamp)
      }
      
      await MainActor.run {
        send(._messagesLoaded(messages))
      }
      
      // Socket 연결 설정
      chatService.connectToRoom(actualRoomId)
      chatService.joinChatRoom(actualRoomId)
      
      chatService.onMessageReceived { [weak self] chatMessage in
        Task { @MainActor in
          self?.send(.receiveMessage(chatMessage))
        }
      }
      
    } catch {
      await MainActor.run {
        send(.setError("채팅 메시지를 불러오는데 실패했습니다: \(error.localizedDescription)"))
        send(.setLoading(false))
      }
    }
  }
  
  /// 메시지 재전송
  private func retryMessage(_ message: Message) async {
    guard let roomId = state.currentChatRoom?.roomId ?? (roomId.hasPrefix("temp_") ? nil : roomId) else { return }
    
    await MainActor.run {
      send(._messageStatusUpdated(message.id, .sending))
    }
    
    do {
      _ = try await chatService.sendMessage(roomId: roomId, content: message.text)
      await MainActor.run {
        send(._messageStatusUpdated(message.id, .sent))
      }
    } catch {
      await MainActor.run {
        send(._messageStatusUpdated(message.id, .failed))
      }
    }
  }
  
  /// 메시지 전송
  private func sendMessage() async {
    guard !state.input.isEmpty || !state.selectedUIImages.isEmpty else { return }
    
    // 선택된 이미지가 있으면 먼저 업로드
    if !state.selectedUIImages.isEmpty {
      await uploadSelectedImages()
    }
    
    guard !state.input.isEmpty else { return }
    let actualRoomId = state.currentChatRoom?.roomId ?? roomId
    let messageText = state.input
    
    await MainActor.run {
      state.input = ""
    }
    
    let newMessage = Message(text: messageText, isMe: true, status: .sending)
    await MainActor.run {
      state.messages.append(newMessage)
    }
    
    // Socket으로 즉시 전송
    chatService.sendMessageViaSocket(roomId: actualRoomId, content: messageText) { [weak self] success in
      Task { @MainActor in
        guard let self else { return }
        if success {
          self.send(._messageStatusUpdated(newMessage.id, .sent))
        }
      }
    }
    
    // HTTP API로도 전송 (백업)
    do {
      _ = try await chatService.sendMessage(roomId: actualRoomId, content: messageText)
      await MainActor.run {
        send(._messageStatusUpdated(newMessage.id, .sent))
      }
    } catch {
      await MainActor.run {
        send(._messageStatusUpdated(newMessage.id, .failed))
      }
    }
  }
  
  /// 사진을 UIImage로 변환
  private func convertPhotosToUIImages(_ photos: [PhotosPickerItem]) async {
    if photos.count > 5 { return }
    var uiImages: [UIImage] = []
    
    for photo in photos {
      if let imageData = try? await photo.loadTransferable(type: Data.self),
         let uiImage = UIImage(data: imageData) {
        uiImages.append(uiImage)
      }
    }
    
    await MainActor.run {
      send(._photosConverted(uiImages))
    }
  }
  
  /// 선택된 이미지 업로드
  private func uploadSelectedImages() async {
    let images = state.selectedUIImages
    var imageURLs: [URL] = []
    
    for image in images {
      if let imageData = image.jpegData(compressionQuality: 0.8) {
        let compressedData = imageData.count > 5 * 1024 * 1024 ? compressImage(imageData) : imageData
        if let finalData = compressedData {
          let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
          try? finalData.write(to: tempURL)
          imageURLs.append(tempURL)
        }
      }
    }
    
    await MainActor.run {
      state.selectedUIImages = [] // UI 이미지들 초기화
    }
    
    if !imageURLs.isEmpty {
      await uploadFiles(imageURLs)
    }
  }
  
  /// 파일 업로드
  private func uploadFiles(_ urls: [URL]) async {
    let actualRoomId = state.currentChatRoom?.roomId ?? roomId
    let fileMessage = Message(text: "📎 파일", isMe: true, status: .sending, files: [])
    
    await MainActor.run {
      state.messages.append(fileMessage)
    }
    
    do {
      let response = try await chatService.uploadFiles(roomId: actualRoomId, fileURLs: urls)
      await MainActor.run {
        if let index = state.messages.firstIndex(where: { $0.id == fileMessage.id }) {
          state.messages[index].status = .sent
          state.messages[index].files = response.files
        }
      }
      
      // 임시 파일 정리
      for url in urls {
        try? FileManager.default.removeItem(at: url)
      }
    } catch {
      await MainActor.run {
        send(._messageStatusUpdated(fileMessage.id, .failed))
      }
    }
  }
  
  // MARK: - 🔥 Helper Functions
  
  /// 수신된 메시지 처리
  private func handleReceivedMessage(_ chatMessage: ChatMessage) {
    let currentUserId = UserDefaultsHelper.shared.getUserId()
    let isMe = chatMessage.sender.userId == currentUserId
    if !isMe {
      let timestamp = parseServerTimestamp(chatMessage.createdAt) ?? Date()
      let newMessage = Message(text: chatMessage.content, isMe: false, status: .sent, files: chatMessage.files, timestamp: timestamp)
      state.messages.append(newMessage)
    }
  }
  
  /// 이미지 압축
  private func compressImage(_ data: Data) -> Data? {
    guard let image = UIImage(data: data) else { return nil }
    let maxSize: CGFloat = 1920
    let resized = resizeImage(image, maxSize: maxSize)
    var q: CGFloat = 0.8
    var out = resized.jpegData(compressionQuality: q)
    while let d = out, d.count > 5 * 1024 * 1024, q > 0.1 {
      q -= 0.1
      out = resized.jpegData(compressionQuality: q)
    }
    return out
  }
  
  /// 이미지 리사이즈
  private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
    let size = image.size
    let ar = size.width / size.height
    var newSize = size
    if size.width > maxSize || size.height > maxSize {
      newSize = ar > 1 ? CGSize(width: maxSize, height: maxSize / ar) : CGSize(width: maxSize * ar, height: maxSize)
    }
    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
  }
  
  /// 서버 타임스탬프 파싱
  private func parseServerTimestamp(_ timestamp: String) -> Date? {
    let formatter = DateFormatter()
    
    // ISO 8601 형식 시도 (예: "2025-08-13T07:42:07Z")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    if let date = formatter.date(from: timestamp) {
      return date
    }
    
    // ISO 8601 with milliseconds (예: "2025-08-13T07:42:07.123Z")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    if let date = formatter.date(from: timestamp) {
      return date
    }
    
    // 다른 일반적인 형식들 시도
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.timeZone = TimeZone.current
    if let date = formatter.date(from: timestamp) {
      return date
    }
    
    return nil
  }
}