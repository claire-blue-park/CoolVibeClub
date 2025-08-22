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
  @StateObject private var store: ChatStore

  init(roomId: String, opponentNick: String) {
    self.roomId = roomId
    self.opponentNick = opponentNick
    _store = StateObject(wrappedValue: ChatStore(roomId: roomId))
  }
  
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
              messages: store.state.messages,
              statusIconBuilder: { status, message in
                statusIcon(for: status, message: message)
              }
            )
          }
          .onTapGesture {
            self.hideKeyboard()
          }
          .onChange(of: store.state.messages.count) { _ in
            DispatchQueue.main.async {
              withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo("bottomSpacer", anchor: .bottom)
              }
            }
          }
          .onChange(of: store.state.isKeyboardVisible) { isVisible in
            if isVisible && !store.state.messages.isEmpty {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeOut(duration: 0.3)) {
                  proxy.scrollTo("bottomSpacer", anchor: .bottom)
                }
              }
            }
          }
        }
        
        MessageInputView(
          input: Binding(get: { store.state.input }, set: { store.send(.setInput($0)) }),
          showingFilePicker: Binding(get: { store.state.showingFilePicker }, set: { store.send(.setShowingFilePicker($0)) }),
          showingPhotosPicker: Binding(get: { store.state.showingPhotosPicker }, set: { store.send(.setShowingPhotosPicker($0)) }),
          showingDocumentPicker: Binding(get: { store.state.showingDocumentPicker }, set: { store.send(.setShowingDocumentPicker($0)) }),
          selectedPhotos: Binding(get: { store.state.selectedUIImages }, set: { store.send(.setSelectedUIImages($0)) }),
          onSendMessage: { store.send(.sendMessage) },
          onPhotoRemove: { photo in
            store.send(.removePhoto(photo))
          }
        )
      }
      .navigationBarHidden(true)
      .photosPicker(isPresented: Binding(get: { store.state.showingPhotosPicker }, set: { store.send(.setShowingPhotosPicker($0)) }), selection: Binding(get: { store.state.selectedPhotos }, set: { store.send(.setSelectedPhotos($0)) }), maxSelectionCount: 5)
      .sheet(isPresented: Binding(get: { store.state.showingDocumentPicker }, set: { store.send(.setShowingDocumentPicker($0)) })) {
        DocumentPicker { urls in
          if urls.count > 5 {
            return
          }
          store.send(.uploadFiles(urls))
        }
      }
      .onAppear {
        tabVisibilityStore.setVisibility(false)
        store.send(.loadInitial)
      }
      .onDisappear {
        let actualRoomId = store.state.currentChatRoom?.roomId ?? roomId
        ChatService.shared.leaveChatRoom(actualRoomId)
      }
          .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
        store.send(.setKeyboardVisible(true))
      }
      .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
        store.send(.setKeyboardVisible(false))
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
          store.send(.retryMessage(message))
        }) {
          Image(systemName: "exclamationmark.circle.fill")
            .font(.system(size: 12))
            .foregroundColor(Color.red)
        }
      )
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
  let timestamp: Date
  
  init(text: String, isMe: Bool, status: MessageStatus = .sent, files: [String]? = nil, timestamp: Date = Date()) {
    self.text = text
    self.isMe = isMe
    self.status = status
    self.files = files
    self.timestamp = timestamp
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
          ChatImageGrid(imageFiles: imageFiles)
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
      
      // 시간 표시
      Text(formatTime(message.timestamp))
        .font(.system(size: 11))
        .foregroundColor(CVCColor.grayScale45)
        .padding(.top, 2)
    }
  }
  
  private func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    
    let calendar = Calendar.current
    if calendar.isDateInToday(date) {
      formatter.dateFormat = "HH:mm"
    } else if calendar.isDateInYesterday(date) {
      formatter.dateFormat = "어제 HH:mm"
    } else {
      formatter.dateFormat = "M월 d일 HH:mm"
    }
    
    return formatter.string(from: date)
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
  @Binding var selectedPhotos: [UIImage]
  let onSendMessage: () -> Void
  let onPhotoRemove: (UIImage) -> Void
  
  var body: some View {
    VStack(spacing: 0) {
      // 선택된 사진들 표시
      if !selectedPhotos.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(Array(selectedPhotos.enumerated()), id: \.offset) { index, photo in
              ZStack(alignment: .topTrailing) {
                Image(uiImage: photo)
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 80, height: 80)
                  .clipped()
                  .cornerRadius(8)
                  .overlay {
                    RoundedRectangle(cornerRadius: 8)
                      .stroke(lineWidth: 1)
                      .foregroundStyle(CVCColor.grayScale30)
                  }
                
                Button(action: {
                  onPhotoRemove(photo)
                }) {
                  Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .background(CVCColor.grayScale60)
                    .clipShape(Circle())
                }
                .offset(x: 4, y: -4)
              }
              .padding(.vertical, 4)
            }
          }
          .padding(.horizontal, 16)
        }
        .background(CVCColor.grayScale0)
        .animation(.easeInOut(duration: 0.2), value: selectedPhotos.count)
      }
      
      // 메시지 입력 영역
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
            .foregroundColor((input.isEmpty && selectedPhotos.isEmpty) ? CVCColor.grayScale60 : CVCColor.grayScale0)
            .padding(12)
            .background(
              Circle()
                .fill((input.isEmpty && selectedPhotos.isEmpty) ? CVCColor.grayScale30 : CVCColor.primary)
            )
        }
        .disabled(input.isEmpty && selectedPhotos.isEmpty)
        .animation(.easeInOut(duration: 0.1), value: input.isEmpty && selectedPhotos.isEmpty)
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
            ChatAsyncImageView(filePath: imagePath)
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
