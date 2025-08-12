//
//  ChatView.swift
//  CoolVibeClub
//
//  Created by Claire on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

enum MessageStatus {
  case sending    // 전송 중
  case sent       // 전송 완료
  case failed     // 전송 실패
}

struct ChatView: View {
  let roomId: String
  let opponentNick: String
  @EnvironmentObject private var tabVisibilityStore: TabVisibilityStore
  @State private var messages: [Message] = []
  
  @State private var currentChatRoom: ChatRoom? = nil
  @State private var isLoading: Bool = true
  
  @State private var input: String = ""
  @State private var showingFilePicker: Bool = false
  @State private var showingPhotosPicker: Bool = false
  @State private var selectedPhotos: [PhotosPickerItem] = []
  @State private var showingDocumentPicker: Bool = false
  @State private var isKeyboardVisible: Bool = false
  
  private let chatService = ChatService.shared
  
  var body: some View {
    VStack {
      ZStack {
        HStack {
          BackButton(foregroundColor: CVCColor.grayScale90)
          Spacer()
        }
        Text(opponentNick)
          .font(.system(size: 16, weight: .bold))
          .lineLimit(1)
          .frame(width: 200, alignment: .center)
      }
      .padding(.horizontal, 16)
      .padding(.top, 16)
      
      VStack(spacing: 0) {
        ScrollViewReader { proxy in
          ScrollView(showsIndicators: false) {
            MessageListView(
              messages: messages,
              statusIconBuilder: { status, message in
                statusIcon(for: status, message: message)
              }
            )
          }
          .onTapGesture {
            self.hideKeyboard()
          }
          .onChange(of: messages.count) { _ in
            DispatchQueue.main.async {
              withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo("bottomSpacer", anchor: .bottom)
              }
            }
          }
          .onChange(of: isKeyboardVisible) { isVisible in
            if isVisible && !messages.isEmpty {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.3)) {
                  proxy.scrollTo("bottomSpacer", anchor: .bottom)
                }
              }
            }
          }
        }
        
        MessageInputView(
          input: $input,
          showingFilePicker: $showingFilePicker,
          showingPhotosPicker: $showingPhotosPicker,
          showingDocumentPicker: $showingDocumentPicker,
          onSendMessage: sendMessage
        )
      }
      .navigationBarHidden(true)
      .photosPicker(isPresented: $showingPhotosPicker, selection: $selectedPhotos, maxSelectionCount: 5)
      .sheet(isPresented: $showingDocumentPicker) {
        DocumentPicker { urls in
          if urls.count > 5 {
            return
          }
          uploadFiles(urls)
        }
      }
      .onAppear {
        tabVisibilityStore.setVisibility(false)
        loadChatMessages()
        setupRealtimeMessageReceiver()
      }
      .onDisappear {
        let actualRoomId = currentChatRoom?.roomId ?? roomId
        chatService.leaveChatRoom(actualRoomId)
      }
      .onChange(of: selectedPhotos) { newPhotos in
        handleSelectedPhotos(newPhotos)
      }
      .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
        isKeyboardVisible = true
      }
      .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
        isKeyboardVisible = false
      }
    }
  }
  
  func loadChatMessages() {
    print("🔄 채팅 메시지 로드 시작")
    print("🆔 초기 Room ID: \(roomId)")
    Task {
      do {
        let actualRoomId: String
        if roomId.hasPrefix("temp_") {
          print("🆔 임시 Room ID 감지 - 실제 채팅방 생성/조회 중...")
          let opponentId = String(roomId.dropFirst(5))
          print("👤 상대방 ID: \(opponentId)")
          let chatRoom = try await ChatService.shared.createOrFindChatRoom(opponentId: opponentId)
          actualRoomId = chatRoom.roomId
          print("✅ 실제 Room ID: \(actualRoomId)")
          await MainActor.run {
            self.currentChatRoom = chatRoom
          }
        } else {
          actualRoomId = roomId
          print("✅ 실제 Room ID 사용: \(actualRoomId)")
        }
        
        print("📜 채팅 히스토리 조회 중...")
        let chatHistory = try await ChatService.shared.fetchMessages(roomId: actualRoomId)
        print("📜 조회된 메시지 수: \(chatHistory.data.count)")
        
        await MainActor.run {
          let currentUserId = UserDefaultsHelper.shared.getUserId()
          print("👤 현재 사용자 ID: \(currentUserId ?? "없음")")
          
          self.messages = chatHistory.data.map { chatMessage in
            let isMe = chatMessage.sender.userId == currentUserId
            print("💬 메시지: \(chatMessage.content) (보낸이: \(chatMessage.sender.nick), 내가 보냄: \(isMe))")
            return Message(
              text: chatMessage.content,
              isMe: isMe,
              files: chatMessage.files
            )
          }
          self.isLoading = false
          
          print("🔌 소켓 연결 시작...")
          chatService.connectToRoom(actualRoomId)
          print("🏠 채팅방 참여...")
          chatService.joinChatRoom(actualRoomId)
        }
      } catch {
        print("❌ 채팅 메시지 로드 실패: \(error.localizedDescription)")
        if let error = error as? ChatMessageError {
          print("🔍 Chat Message Error Details: \(error)")
        }
        await MainActor.run {
          self.isLoading = false
        }
      }
    }
  }
  
  func fetchRoomData(opponentId: String) {
    Task {
      do {
        let chatRoom = try await ChatService.shared.createOrFindChatRoom(opponentId: opponentId)
        let chatHistory = try await ChatService.shared.fetchMessages(roomId: chatRoom.roomId)
        await MainActor.run {
          self.currentChatRoom = chatRoom
          let currentUserId = UserDefaultsHelper.shared.getUserId()
          self.messages = chatHistory.data.map { chatMessage in
            let isMe = chatMessage.sender.userId == currentUserId
            return Message(
              text: chatMessage.content,
              isMe: isMe,
              files: chatMessage.files
            )
          }
          self.isLoading = false
          chatService.connectToRoom(chatRoom.roomId)
          chatService.joinChatRoom(chatRoom.roomId)
        }
      } catch {
      }
    }
  }
  
  func setupRealtimeMessageReceiver() {
    chatService.onMessageReceived { [self] chatMessage in
      DispatchQueue.main.async {
        let currentUserId = UserDefaultsHelper.shared.getUserId()
        let isMe = chatMessage.sender.userId == currentUserId
        if !isMe {
          let newMessage = Message(
            text: chatMessage.content,
            isMe: false,
            status: .sent,
            files: chatMessage.files
          )
          self.messages.append(newMessage)
        }
      }
    }
  }
  
  func statusIcon(for status: MessageStatus, message: Message) -> AnyView {
    switch status {
    case .sending:
      return AnyView(
        ProgressView()
          .scaleEffect(0.6)
          .frame(width: 16, height: 16)
      )
    case .sent:
      return AnyView(
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 12))
          .foregroundColor(CVCColor.grayScale45)
      )
    case .failed:
      return AnyView(
        Button(action: {
          retryMessage(message)
        }) {
          Image(systemName: "exclamationmark.circle.fill")
            .font(.system(size: 12))
            .foregroundColor(Color.red)
        }
      )
    }
  }
  
  func retryMessage(_ message: Message) {
    guard let roomId = currentChatRoom?.roomId else { return }
    
    if let index = messages.firstIndex(where: { $0.id == message.id }) {
      messages[index].status = .sending
    }
    
    Task {
      do {
        let response = try await ChatService.shared.sendMessage(
          roomId: roomId,
          content: message.text
        )
        await MainActor.run {
          if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].status = .sent
          }
        }
      } catch {
        await MainActor.run {
          if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages[index].status = .failed
          }
        }
      }
    }
  }
  
  func sendMessage() {
    guard !input.isEmpty else { 
      print("❌ 메시지 전송 취소: 입력창이 비어있음")
      return 
    }
    
    let actualRoomId = currentChatRoom?.roomId ?? roomId
    let messageText = input
    print("📝 메시지 전송 시작")
    print("🏠 Room ID: \(actualRoomId)")
    print("💬 Message: \(messageText)")
    print("👤 Current User ID: \(UserDefaultsHelper.shared.getUserId() ?? "없음")")
    
    input = ""
    
    let newMessage = Message(text: messageText, isMe: true, status: .sending)
    messages.append(newMessage)
    print("✅ UI에 메시지 추가 완료 (ID: \(newMessage.id))")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
      // Scroll handled by onChange
    }
    
    print("🔌 Socket 전송 시작...")
    chatService.sendMessageViaSocket(roomId: actualRoomId, content: messageText) { [self] success in
      print("🔌 Socket 전송 결과: \(success ? "성공" : "실패")")
      DispatchQueue.main.async {
        if let index = self.messages.firstIndex(where: { $0.id == newMessage.id }) {
          if success {
            self.messages[index].status = .sent
            print("✅ Socket 전송 성공 - 메시지 상태 업데이트")
          } else {
            print("❌ Socket 전송 실패")
          }
        } else {
          print("⚠️ 메시지 인덱스를 찾을 수 없음")
        }
      }
    }
    
    print("🌐 HTTP API 전송 시작...")
    Task {
      do {
        let _ = try await ChatService.shared.sendMessage(
          roomId: actualRoomId,
          content: messageText
        )
        print("✅ HTTP API 전송 성공")
        await MainActor.run {
          if let index = messages.firstIndex(where: { $0.id == newMessage.id }) {
            if messages[index].status == .sending {
              messages[index].status = .sent
              print("✅ HTTP API 성공 - 메시지 상태 업데이트")
            } else {
              print("ℹ️ 메시지 상태가 이미 업데이트됨 (현재: \(messages[index].status))")
            }
          } else {
            print("⚠️ HTTP API: 메시지 인덱스를 찾을 수 없음")
          }
        }
      } catch {
        print("❌ HTTP API 전송 실패: \(error.localizedDescription)")
        if let error = error as? ChatMessageError {
          print("🔍 Chat Error Details: \(error)")
        }
        await MainActor.run {
          if let index = messages.firstIndex(where: { $0.id == newMessage.id }) {
            if messages[index].status == .sending {
              messages[index].status = .failed
              print("❌ HTTP API 실패 - 메시지 상태를 실패로 업데이트")
            }
          }
        }
      }
    }
  }
  
  func handleSelectedPhotos(_ photos: [PhotosPickerItem]) {
    if photos.count > 5 {
      return
    }
    
    Task {
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
      
      await MainActor.run {
        selectedPhotos = []
      }
      
      if !imageURLs.isEmpty {
        uploadFiles(imageURLs)
      }
    }
  }
  
  func uploadFiles(_ urls: [URL]) {
    let actualRoomId = currentChatRoom?.roomId ?? roomId
    
    let fileMessage = Message(
      text: "📎 파일",
      isMe: true,
      status: .sending,
      files: []
    )
    messages.append(fileMessage)
    
    Task {
      do {
        let response = try await ChatService.shared.uploadFiles(roomId: actualRoomId, fileURLs: urls)
        await MainActor.run {
          if let index = messages.firstIndex(where: { $0.id == fileMessage.id }) {
            messages[index].status = .sent
            messages[index].files = response.files
          }
        }
        for url in urls {
          try? FileManager.default.removeItem(at: url)
        }
      } catch {
        await MainActor.run {
          if let index = messages.firstIndex(where: { $0.id == fileMessage.id }) {
            messages[index].status = .failed
          }
        }
      }
    }
  }
  
  private func compressImage(_ imageData: Data) -> Data? {
    guard let image = UIImage(data: imageData) else { return nil }
    let maxSize: CGFloat = 1920
    let resizedImage = resizeImage(image, maxSize: maxSize)
    var compressionQuality: CGFloat = 0.8
    var compressedData = resizedImage.jpegData(compressionQuality: compressionQuality)
    
    while let data = compressedData, data.count > 5 * 1024 * 1024 && compressionQuality > 0.1 {
      compressionQuality -= 0.1
      compressedData = resizedImage.jpegData(compressionQuality: compressionQuality)
    }
    
    return compressedData
  }
  
  private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
    let size = image.size
    let aspectRatio = size.width / size.height
    var newSize = size
    if size.width > maxSize || size.height > maxSize {
      if aspectRatio > 1 {
        newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
      } else {
        newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
      }
    }
    
    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { _ in
      image.draw(in: CGRect(origin: .zero, size: newSize))
    }
  }
}

struct DocumentPicker: UIViewControllerRepresentable {
  let onFilesSelected: ([URL]) -> Void
  
  func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
    let picker = UIDocumentPickerViewController(forOpeningContentTypes: [
      UTType.image,
      UTType.pdf,
      UTType.plainText,
      UTType.rtf,
      UTType.spreadsheet,
      UTType.presentation
    ], asCopy: true)
    picker.allowsMultipleSelection = true
    picker.delegate = context.coordinator
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UIDocumentPickerDelegate {
    let parent: DocumentPicker
    
    init(_ parent: DocumentPicker) {
      self.parent = parent
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
      parent.onFilesSelected(urls)
    }
  }
}

struct Message: Identifiable {
  let id = UUID()
  let text: String
  let isMe: Bool
  var status: MessageStatus
  var files: [String]? // File paths added
  
  init(text: String, isMe: Bool, status: MessageStatus = .sent, files: [String]? = nil) {
    self.text = text
    self.isMe = isMe
    self.status = status
    self.files = files
  }
}

struct MessageListView: View {
  let messages: [Message]
  let statusIconBuilder: (MessageStatus, Message) -> AnyView
  
  var body: some View {
    if messages.isEmpty {
      VStack(spacing: 16) {
        CVCImage.message.template
          .frame(width: 32, height: 32)
          .foregroundStyle(CVCColor.grayScale60)
          .padding(.top, 24)
        
        VStack(spacing: 4) {
          Text("아직 대화가 없어요")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(CVCColor.grayScale75)
          
          Text("첫 메시지를 보내보세요!")
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(CVCColor.grayScale60)
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    } else {
      VStack(spacing: 8) {
        ForEach(messages, id: \.id) { msg in
          MessageRowView(
            message: msg,
            statusIcon: statusIconBuilder
          )
          .padding(.horizontal)
          .id(msg.id)
        }
      }
      .padding(.vertical)
      
      Spacer()
        .frame(height: 1)
        .id("bottomSpacer")
    }
  }
}

struct MessageRowView: View {
  let message: Message
  let statusIcon: (MessageStatus, Message) -> AnyView
  
  var body: some View {
    HStack(spacing: 8) {
      if message.isMe {
        Spacer()
        statusIcon(message.status, message)
      }
      MessageContentView(message: message)
      if !message.isMe {
        Spacer()
      }
    }
  }
}

struct MessageContentView: View {
  let message: Message
  
  var body: some View {
    VStack(alignment: message.isMe ? .trailing : .leading, spacing: 8) {
      // 이미지가 있을 때는 이미지를 먼저 표시
      if let files = message.files, !files.isEmpty {
        let imageFiles = files.filter { isImageFile($0) }
        if !imageFiles.isEmpty {
          HStack(spacing: 4) {
            //                        if message.isMe {
            //                            Spacer()
            //                        }
            //
            if imageFiles.count == 1 {
              AsyncImageView(filePath: imageFiles[0])
                .frame(width: 160, height: 160)
                .cornerRadius(12)
                .clipped()
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(CVCColor.grayScale15, lineWidth: 1)
                )
            } else {
              HStack(spacing: 8) {
                ForEach(imageFiles, id: \.self) { filePath in
                  AsyncImageView(filePath: filePath)
                    .frame(width: 160 / CGFloat(min(imageFiles.count, 3)), height: 160)
                    .cornerRadius(12)
                    .clipped()
                    .overlay(
                      RoundedRectangle(cornerRadius: 12)
                        .stroke(CVCColor.grayScale15, lineWidth: 1)
                    )
                }
              }
            }
            
            //                        if !message.isMe {
            //                            Spacer()
            //                        }
          }
          //                    .frame(maxWidth: .infinity)
          .padding(.top, 4)
        }
      }
      
      // 텍스트 메시지 표시 (이미지와 함께 있어도 표시)
      if !message.text.isEmpty && message.text != "📎 파일" {
        Text(message.text)
          .font(.system(size: 13))
          .padding(12)
          .background(message.isMe ? CVCColor.primaryLight : CVCColor.grayScale30)
          .foregroundColor(CVCColor.grayScale90)
          .cornerRadius(16)
      }
    }
  }
  
  private func isImageFile(_ filePath: String) -> Bool {
    let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "webp"]
    let pathExtension: String
    if let url = URL(string: filePath) {
      pathExtension = url.pathExtension.lowercased()
    } else {
      pathExtension = String(filePath.split(separator: ".").last ?? "").lowercased()
    }
    return imageExtensions.contains(pathExtension)
  }
}

struct MessageInputView: View {
  @Binding var input: String
  @Binding var showingFilePicker: Bool
  @Binding var showingPhotosPicker: Bool
  @Binding var showingDocumentPicker: Bool
  let onSendMessage: () -> Void
  
  var body: some View {
    HStack(spacing: 12) {
      Button(action: {
        showingFilePicker = true
      }) {
        Image(systemName: "plus.circle")
          .font(.system(size: 20))
          .foregroundColor(CVCColor.grayScale60)
      }
      .confirmationDialog("파일 첨부", isPresented: $showingFilePicker) {
        Button("사진 선택") {
          showingPhotosPicker = true
        }
        Button("문서 선택") {
          showingDocumentPicker = true
        }
        Button("취소", role: .cancel) { }
      }
      
      HStack(spacing: 8) {
        TextField("메시지를 입력하세요", text: $input)
          .font(.system(size: 13))
          .foregroundColor(CVCColor.grayScale90)
          .padding(.horizontal, 16)
          .padding(.vertical, 12)
          .background(CVCColor.grayScale15)
          .cornerRadius(24)
          .overlay(
            RoundedRectangle(cornerRadius: 24)
              .stroke(CVCColor.grayScale30, lineWidth: 1)
          )
      }
      
      Button(action: onSendMessage) {
        CVCImage.arrowRight.template
          .frame(width: 20, height: 20)
          .foregroundColor(input.isEmpty ? CVCColor.grayScale60 : CVCColor.grayScale0)
          .padding(12)
          .background(
            Circle()
              .fill(input.isEmpty ? CVCColor.grayScale30 : CVCColor.primary)
          )
      }
      .disabled(input.isEmpty)
      .animation(.easeInOut(duration: 0.1), value: input.isEmpty)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(
      Rectangle()
        .fill(CVCColor.grayScale0)
        .ignoresSafeArea()
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -2)
    )
  }
}

struct AsyncImageView: View {
  let filePath: String
  @State private var image: UIImage? = nil
  @State private var isLoading: Bool = true
  
  var body: some View {
    ZStack {
      if let image = image {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 160, height: 160)
          .clipped()
      } else if isLoading {
        ProgressView()
          .frame(width: 160, height: 160)
          .background(CVCColor.grayScale30)
          .cornerRadius(12)
      } else {
        Image(systemName: "photo")
          .foregroundColor(CVCColor.grayScale60)
          .frame(width: 160, height: 160)
          .background(CVCColor.grayScale30)
          .cornerRadius(12)
      }
    }
    .background(CVCColor.grayScale30)
    .cornerRadius(12)
    .onAppear {
      loadImage()
    }
  }
  
  private func loadImage() {
    let endpoint = ChatEndpoint(requestType: .fetchMessages(roomId: "", next: nil))
    ImageLoadHelper.shared.loadCachedImage(path: filePath, endpoint: endpoint) { loadedImage in
      DispatchQueue.main.async {
        self.image = loadedImage
        self.isLoading = false
      }
    }
  }
}

struct ImagePreviewView: View {
  let images: [String]
  @Binding var currentIndex: Int
  @Binding var isPresented: Bool
  
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      
      VStack {
        HStack {
          Button("닫기") {
            isPresented = false
          }
          .foregroundColor(Color.white)
          .font(.system(size: 16))
          Spacer()
          Text("\(currentIndex + 1) / \(images.count)")
            .foregroundColor(Color.white)
            .font(.system(size: 16))
        }
        .padding()
        
        Spacer()
        
        TabView(selection: $currentIndex) {
          ForEach(Array(images.enumerated()), id: \.offset) { index, imagePath in
            AsyncImageView(filePath: imagePath)
              .aspectRatio(contentMode: .fit)
              .tag(index)
          }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .gesture(
          DragGesture()
            .onEnded { value in
              if value.translation.height > 100 {
                isPresented = false
              }
            }
        )
        
        Spacer()
        
        if images.count > 1 {
          HStack(spacing: 8) {
            ForEach(0..<images.count, id: \.self) { index in
              Circle()
                .fill(index == currentIndex ? Color.white : Color.white.opacity(0.5))
                .frame(width: 8, height: 8)
            }
          }
          .padding(.bottom, 30)
        }
      }
    }
  }
}
