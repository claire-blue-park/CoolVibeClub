//
//  BorderLineSearchBar.swift
//  CoolVibeClub
//
//  Created by Claire on 8/4/25.
//

import SwiftUI

struct BorderLineSearchBar: View {
  @Binding var searchText: String
  let placeholder: String
  let onSearchTextChanged: (String) -> Void
  
  init(
    searchText: Binding<String>,
    placeholder: String = "검색",
    onSearchTextChanged: @escaping (String) -> Void = { _ in }
  ) {
    self._searchText = searchText
    self.placeholder = placeholder
    self.onSearchTextChanged = onSearchTextChanged
  }
  
  var body: some View {
    HStack(spacing: 12) {
      CVCImage.search.template
        .foregroundStyle(CVCColor.grayScale60)
        .frame(width: 20, height: 20)
      
      TextField(placeholder, text: $searchText)
        .font(.system(size: 14))
        .foregroundStyle(CVCColor.grayScale90)
        .onChange(of: searchText) { newValue in
          onSearchTextChanged(newValue)
        }
      
      // 검색어가 있을 때 지우기 버튼 표시
      if !searchText.isEmpty {
        Button {
          searchText = ""
          onSearchTextChanged("")
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(CVCColor.grayScale60)
            .frame(width: 16, height: 16)
        }
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(CVCColor.grayScale15)
    .cornerRadius(24)
    .overlay(
      RoundedRectangle(cornerRadius: 24)
        .stroke(CVCColor.grayScale30, lineWidth: 1)
    )
  }
}
//
//#Preview {
//  @State var searchText = ""
//  
//  return VStack(spacing: 20) {
//    BorderLineSearchBar(
//      searchText: $searchText,
//      placeholder: "채팅방 검색"
//    ) { text in
//      print("검색어: \(text)")
//    }
//    
//    BorderLineSearchBar(
//      searchText: $searchText,
//      placeholder: "액티비티 검색"
//    ) { text in
//      print("검색어: \(text)")
//    }
//  }
//  .padding()
//}
