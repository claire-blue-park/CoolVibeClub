//
//  TextInputField.swift
//  CoolVibeClub
//
//  아이콘 없는 간단한 텍스트 입력 필드
//  🔥 새로운 컴포넌트: 일반적인 TextField 스타일
//

import SwiftUI

/// 🔥 간단한 텍스트 입력 필드
/// 아이콘 없이 제목, 입력 필드, 검증 아이콘만 포함
struct TextInputField: View {
  let title: String
  let placeholder: String
  @Binding var text: String
  let isValid: Bool
  let isSecure: Bool
  let keyboardType: UIKeyboardType
  
  init(
    title: String,
    placeholder: String,
    text: Binding<String>,
    isValid: Bool,
    isSecure: Bool = false,
    keyboardType: UIKeyboardType = .default
  ) {
    self.title = title
    self.placeholder = placeholder
    self._text = text
    self.isValid = isValid
    self.isSecure = isSecure
    self.keyboardType = keyboardType
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .foregroundStyle(CVCColor.grayScale90)
        .font(.system(size: 14, weight: .bold))
        .padding(.leading, 4)
      
      HStack {
        Group {
          if isSecure {
            SecureField(placeholder, text: $text)
          } else {
            TextField(placeholder, text: $text)
              .keyboardType(keyboardType)
              .autocapitalization(.none)
          }
        }
        .font(.system(size: 13))
        
        // 검증 아이콘 (텍스트가 있을 때만 표시)
        if !text.isEmpty {
          Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
            .foregroundColor(isValid ? CVCColor.primary : CVCColor.like)
            .font(.system(size: 16))
        }
      }
      .padding(16)
      .background(
        RoundedRectangle(cornerRadius: 32)
          .stroke(
            text.isEmpty ? CVCColor.grayScale30 :
              isValid ? CVCColor.primary : CVCColor.like,
            lineWidth: 1
          )
      )
    }
    .padding(.horizontal)
  }
}

#Preview {
  VStack(spacing: 16) {
    TextInputField(
      title: "이메일",
      placeholder: "이메일을 입력해주세요",
      text: .constant("test@example.com"),
      isValid: true,
      keyboardType: .emailAddress
    )
    
    TextInputField(
      title: "비밀번호",
      placeholder: "비밀번호를 입력해주세요",
      text: .constant("password"),
      isValid: false,
      isSecure: true
    )
    
    TextInputField(
      title: "빈 필드",
      placeholder: "입력해주세요",
      text: .constant(""),
      isValid: false
    )
  }
}
