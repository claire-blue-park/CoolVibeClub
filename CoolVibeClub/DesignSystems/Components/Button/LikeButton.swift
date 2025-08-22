//
//  LikeButton.swift
//  CoolVibeClub
//
//  Created by Claire on 7/29/25.
//

import SwiftUI
import Lottie

struct LikeButton: View {
  @State private var isLiked: Bool
  @State private var showLottie: Bool = false
  let onTap: (Bool) -> Void
  
  init(isLiked: Bool = false, onTap: @escaping (Bool) -> Void = { _ in }) {
    self._isLiked = State(initialValue: isLiked)
    self.onTap = onTap
  }
  
  var body: some View {
    Button(action: {
      withAnimation(.easeInOut(duration: 0.2)) {
        isLiked.toggle()
        onTap(isLiked)
        
        if isLiked {
          showLottie = true
          // Lottie 애니메이션 후 숨기기
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showLottie = false
          }
        }
      }
    }) {
      ZStack {
        // 기본 하트 아이콘
        Image(systemName: isLiked ? "heart.fill" : "heart")
          .renderingMode(.template)
          .foregroundColor(isLiked ? CVCColor.like : CVCColor.grayScale0)
          .font(.system(size: 20, weight: .medium))
          .scaleEffect(isLiked ? 1.1 : 1.0)
          .animation(.easeInOut(duration: 0.1), value: isLiked)
        
        // Lottie 애니메이션 오버레이
        if showLottie {
          LottieView(animation: .named("like"))
            .playing()
            .animationSpeed(1.2)
            .frame(width: 40, height: 40)
            .allowsHitTesting(false)
        }
      }
      .frame(width: 24, height: 24)
//      .padding(8)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

struct LikeCircleButton: View {
  @State private var isLiked: Bool
  @State private var showLottie: Bool = false
  let onTap: (Bool) -> Void
  
  init(isLiked: Bool = false, onTap: @escaping (Bool) -> Void = { _ in }) {
    self._isLiked = State(initialValue: isLiked)
    self.onTap = onTap
  }
  
  var body: some View {
    Button(action: {
      withAnimation(.easeInOut(duration: 0.2)) {
        isLiked.toggle()
        onTap(isLiked)
        
        if isLiked {
          showLottie = true
          // Lottie 애니메이션 후 숨기기
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showLottie = false
          }
        }
      }
    }) {
      ZStack {
        // 기본 하트 아이콘
        Image(systemName: isLiked ? "heart.fill" : "heart")
          .renderingMode(.template)
          .foregroundColor(isLiked ? CVCColor.like : CVCColor.grayScale90)
          .font(.system(size: 20, weight: .medium))
          .scaleEffect(isLiked ? 1.1 : 1.0)
          .animation(.easeInOut(duration: 0.1), value: isLiked)
        
        // Lottie 애니메이션 오버레이
        if showLottie {
          LottieView(animation: .named("like"))
            .playing()
            .animationSpeed(1.2)
            .frame(width: 40, height: 40)
            .allowsHitTesting(false)
        }
      }
      .frame(width: 24, height: 24)
      .padding(8)
      .background(
        Circle()
          .fill(CVCColor.translucent60)
      )
      .clipShape(Circle())
    }
    .buttonStyle(PlainButtonStyle())
  }
}


// MARK: - Large Style
struct LikeBigButton: View {
  @State private var isLiked: Bool
  @State private var showLottie: Bool = false
  let onTap: (Bool) -> Void
  
  init(isLiked: Bool = false, onTap: @escaping (Bool) -> Void = { _ in }) {
    self._isLiked = State(initialValue: isLiked)
    self.onTap = onTap
  }
  
  var body: some View {
    Button(action: {
      withAnimation(.easeInOut(duration: 0.2)) {
        isLiked.toggle()
        onTap(isLiked)
        
        if isLiked {
          showLottie = true
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showLottie = false
          }
        }
      }
    }) {
      ZStack {
        // 기본 하트 아이콘
        Image(systemName: isLiked ? "heart.fill" : "heart")
          .renderingMode(.template)
          .foregroundColor(isLiked ? CVCColor.like : CVCColor.grayScale60)
          .font(.system(size: 24, weight: .medium))
          .scaleEffect(isLiked ? 1.1 : 1.0)
          .animation(.easeInOut(duration: 0.1), value: isLiked)
        
        // Lottie 애니메이션 오버레이
        if showLottie {
          LottieView(animation: .named("like"))
            .playing()
            .animationSpeed(1.2)
            .frame(width: 60, height: 60)
            .allowsHitTesting(false)
        }
      }
      .frame(width: 48, height: 48)
      .background(
        Circle()
          .fill(CVCColor.grayScale0)
//          .shadow(color: CVCColor.grayScale30.opacity(0.15), radius: 4, x: 0, y: 2)
      )
    }
    .buttonStyle(PlainButtonStyle())
  }
}

// MARK: - Compact Style (텍스트와 함께)
struct LikeCompactButton: View {
  @State private var isLiked: Bool
  @State private var showLottie: Bool = false
  let likeCount: Int
  let onTap: (Bool) -> Void
  
  init(isLiked: Bool = false, likeCount: Int = 0, onTap: @escaping (Bool) -> Void = { _ in }) {
    self._isLiked = State(initialValue: isLiked)
    self.likeCount = likeCount
    self.onTap = onTap
  }
  
  var body: some View {
    Button(action: {
      withAnimation(.easeInOut(duration: 0.2)) {
        isLiked.toggle()
        onTap(isLiked)
        
        if isLiked {
          showLottie = true
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showLottie = false
          }
        }
      }
    }) {
      HStack(spacing: 4) {
        ZStack {
          // 기본 하트 아이콘
          Image(systemName: isLiked ? "heart.fill" : "heart")
            .renderingMode(.template)
            .foregroundColor(isLiked ? CVCColor.like : CVCColor.grayScale60)
            .font(.system(size: 16, weight: .medium))
            .scaleEffect(isLiked ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLiked)
          
          // Lottie 애니메이션 오버레이
          if showLottie {
            LottieView(animation: .named("like"))
              .playing()
              .animationSpeed(1.2)
              .frame(width: 32, height: 32)
              .allowsHitTesting(false)
          }
        }
        
        // 좋아요 개수
        if likeCount > 0 {
          Text("\(likeCount + (isLiked ? 1 : 0))")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isLiked ? CVCColor.primary : CVCColor.grayScale60)
            .animation(.easeInOut(duration: 0.2), value: isLiked)
        }
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

// MARK: - Preview
struct LikeButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 24) {
      Text("기본 LikeButton")
      LikeButton(isLiked: false) { isLiked in
        print("Like status changed: \(isLiked)")
      }
      
      Text("큰 LikeButton")
      LikeBigButton(isLiked: true) { isLiked in
        print("Big like status changed: \(isLiked)")
      }
      
      Text("숫자와 함께")
      LikeCompactButton(isLiked: false, likeCount: 24) { isLiked in
        print("Compact like status changed: \(isLiked)")
      }
    }
    .padding()
  }
}
