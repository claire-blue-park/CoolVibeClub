//
//  ChatIntent.swift
//  CoolVibeClub
//
//  Created by Claire on 8/12/25.
//

import SwiftUI
import PhotosUI

@MainActor
final class ChatIntent: ObservableObject, Intent {
  struct ChatState: StateMarker {
    var messages: [Message] = []
    var currentChatRoom: ChatRoom?
    var isLoading: Bool = true
    var error: String? = nil
    var input: String = ""
    var isKeyboardVisible: Bool = false
    var showingFilePicker: Bool = false
    var showingPhotosPicker: Bool = false
    var selectedPhotos: [PhotosPickerItem] = []
    var showingDocumentPicker: Bool = false
  }

  enum ChatAction: ActionMarker {
    case loadInitial
    case setInput(String)
    case sendMessage
    case retry(Message)
    case receive(ChatMessage)
    case setKeyboardVisible(Bool)
    case setShowingFilePicker(Bool)
    case setShowingPhotosPicker(Bool)
    case setSelectedPhotos([PhotosPickerItem])
    case setShowingDocumentPicker(Bool)
    case uploadFiles([URL])
  }

  typealias ActionType = ChatAction

  @Published private(set) var state: ChatState = .init()

  // Dependencies
  private let roomId: String
  private let chatService: ChatService = .shared

  init(roomId: String) {
    self.roomId = roomId
  }

  func send(_ action: ChatAction) {
    switch action {
    case .loadInitial:
      Task { await loadChatMessages() }

    case .setInput(let text):
      self.state.input = text

    case .sendMessage:
      Task { await sendMessage() }

    case .retry(let message):
      Task { await retryMessage(message) }

    case .receive(let chatMessage):
      let currentUserId = UserDefaultsHelper.shared.getUserId()
      let isMe = chatMessage.sender.userId == currentUserId
      if !isMe {
        let newMessage = Message(text: chatMessage.content, isMe: false, status: .sent, files: chatMessage.files)
        self.state.messages.append(newMessage)
      }

    case .setKeyboardVisible(let visible):
      self.state.isKeyboardVisible = visible

    case .setShowingFilePicker(let show):
      self.state.showingFilePicker = show

    case .setShowingPhotosPicker(let show):
      self.state.showingPhotosPicker = show

    case .setSelectedPhotos(let items):
      self.state.selectedPhotos = items
      Task { await handleSelectedPhotos(items) }

    case .setShowingDocumentPicker(let show):
      self.state.showingDocumentPicker = show

    case .uploadFiles(let urls):
      Task { await uploadFiles(urls) }
    }
  }

  // MARK: - Private flows
  private func loadChatMessages() async {
    do {
      let actualRoomId: String
      if roomId.hasPrefix("temp_") {
        let opponentId = String(roomId.dropFirst(5))
        let chatRoom = try await chatService.createOrFindChatRoom(opponentId: opponentId)
        actualRoomId = chatRoom.roomId
        self.state.currentChatRoom = chatRoom
      } else {
        actualRoomId = roomId
      }

      let chatHistory = try await chatService.fetchMessages(roomId: actualRoomId)
      let currentUserId = UserDefaultsHelper.shared.getUserId()
      self.state.messages = chatHistory.data.map { chatMessage in
        let isMe = chatMessage.sender.userId == currentUserId
        return Message(text: chatMessage.content, isMe: isMe, files: chatMessage.files)
      }
      self.state.isLoading = false

      chatService.connectToRoom(actualRoomId)
      chatService.joinChatRoom(actualRoomId)

      chatService.onMessageReceived { [weak self] chatMessage in
        Task { @MainActor in
          self?.send(.receive(chatMessage))
        }
      }
    } catch {
      self.state.isLoading = false
    }
  }

  private func retryMessage(_ message: Message) async {
    guard let roomId = state.currentChatRoom?.roomId ?? (roomId.hasPrefix("temp_") ? nil : roomId) else { return }
    if let index = state.messages.firstIndex(where: { $0.id == message.id }) {
      self.state.messages[index].status = .sending
    }
    do {
      _ = try await chatService.sendMessage(roomId: roomId, content: message.text)
      if let index = state.messages.firstIndex(where: { $0.id == message.id }) {
        self.state.messages[index].status = .sent
      }
    } catch {
      if let index = state.messages.firstIndex(where: { $0.id == message.id }) {
        self.state.messages[index].status = .failed
      }
    }
  }

  private func sendMessage() async {
    guard !state.input.isEmpty else { return }
    let actualRoomId = state.currentChatRoom?.roomId ?? roomId
    let messageText = state.input
    self.state.input = ""

    let newMessage = Message(text: messageText, isMe: true, status: .sending)
    self.state.messages.append(newMessage)

    chatService.sendMessageViaSocket(roomId: actualRoomId, content: messageText) { [weak self] success in
      Task { @MainActor in
        guard let self else { return }
        if let index = self.state.messages.firstIndex(where: { $0.id == newMessage.id }) {
          if success { self.state.messages[index].status = .sent }
        }
      }
    }

    do {
      _ = try await chatService.sendMessage(roomId: actualRoomId, content: messageText)
      if let index = state.messages.firstIndex(where: { $0.id == newMessage.id }) {
        if state.messages[index].status == .sending { state.messages[index].status = .sent }
      }
    } catch {
      if let index = state.messages.firstIndex(where: { $0.id == newMessage.id }) {
        if state.messages[index].status == .sending { state.messages[index].status = .failed }
      }
    }
  }

  private func handleSelectedPhotos(_ photos: [PhotosPickerItem]) async {
    if photos.count > 5 { return }
    var imageURLs: [URL] = []
    for photo in photos {
      if let imageData = try? await photo.loadTransferable(type: Data.self) {
        if imageData.count > 5 * 1024 * 1024 {
          if let compressedData = compressImage(imageData) {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
            try? compressedData.write(to: tempURL)
            imageURLs.append(tempURL)
          }
        } else {
          let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
          try? imageData.write(to: tempURL)
          imageURLs.append(tempURL)
        }
      }
    }
    self.state.selectedPhotos = []
    if !imageURLs.isEmpty { await uploadFiles(imageURLs) }
  }

  private func uploadFiles(_ urls: [URL]) async {
    let actualRoomId = state.currentChatRoom?.roomId ?? roomId
    let fileMessage = Message(text: "📎 파일", isMe: true, status: .sending, files: [])
    self.state.messages.append(fileMessage)
    do {
      let response = try await chatService.uploadFiles(roomId: actualRoomId, fileURLs: urls)
      if let index = state.messages.firstIndex(where: { $0.id == fileMessage.id }) {
        self.state.messages[index].status = .sent
        self.state.messages[index].files = response.files
      }
      for url in urls { try? FileManager.default.removeItem(at: url) }
    } catch {
      if let index = state.messages.firstIndex(where: { $0.id == fileMessage.id }) {
        self.state.messages[index].status = .failed
      }
    }
  }

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
}
