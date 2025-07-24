//
//  CachedAsyncImage.swift
//  CoolVibeClub
//
//  Created by Claude on 2025.
//  Copyright © 2025 ClaireBluePark. All rights reserved.
//

import SwiftUI
import Kingfisher
import Alamofire

// MARK: - 캐싱된 비동기 이미지 컴포넌트
struct CachedAsyncImage<Placeholder: View>: View {
    let url: URL?
    let endpoint: Endpoint?
    let placeholder: () -> Placeholder
    let contentMode: SwiftUI.ContentMode
    
    @State private var image: UIImage?
    @State private var isLoading: Bool = true
    @State private var hasError: Bool = false
    
    init(
        url: URL?,
        endpoint: Endpoint? = nil,
        contentMode: SwiftUI.ContentMode = .fit,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.endpoint = endpoint
        self.contentMode = contentMode
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            } else if isLoading {
                placeholder()
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            } else if hasError {
                placeholder()
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            } else {
                placeholder()
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: url) { newURL in
            if newURL != nil {
                loadImage()
            }
        }
    }
    
    private func loadImage() {
        guard let url = url, let endpoint = endpoint else {
            isLoading = false
            hasError = true
            return
        }
        
        isLoading = true
        hasError = false
        
        // ImageLoadHelper를 사용하여 이미지 로딩
        ImageLoadHelper.shared.loadCachedImage(
            path: url.absoluteString,
            endpoint: endpoint
        ) { image in
            DispatchQueue.main.async {
                self.isLoading = false
                if let image = image {
                    self.image = image
                    self.hasError = false
                } else {
                    self.hasError = true
                }
            }
        }
    }
}

// MARK: - 편의 초기화자들은 필요시 사용법을 참고하여 직접 구현

// MARK: - String URL 지원
extension CachedAsyncImage {
    init(
        urlString: String?,
        endpoint: Endpoint? = nil,
        contentMode: SwiftUI.ContentMode = .fit,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        let url = urlString.flatMap { URL(string: $0) }
        self.init(
            url: url,
            endpoint: endpoint,
            contentMode: contentMode,
            placeholder: placeholder
        )
    }
}

// MARK: - Preview
#Preview {
    VStack {
        // 기본 사용법
        CachedAsyncImage(
            url: URL(string: "https://picsum.photos/300/200"),
            contentMode: .fill
        ) {
            Color.gray.opacity(0.3)
        }
        .frame(width: 300, height: 200)
        .cornerRadius(12)
        
        // 커스텀 플레이스홀더
        CachedAsyncImage(
            url: URL(string: "https://picsum.photos/200/150"),
            contentMode: .fill
        ) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    Image(systemName: "photo.fill")
                        .foregroundColor(.gray)
                )
        }
        .frame(width: 200, height: 150)
    }
    .padding()
}