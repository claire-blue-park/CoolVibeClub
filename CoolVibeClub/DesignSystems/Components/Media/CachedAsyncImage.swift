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
import CoreLocation
import AVFoundation

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
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                    .clipped()
            } else if isLoading {
                placeholder()
            } else if hasError {
                placeholder()
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
