//
//  CachedAsyncImage.swift
//  SuperNews
//
//  Created by Nazar on 15.11.2025.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    @State private var hasError = false
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if hasError {
                placeholder()
            } else if let image = loadedImage {
                content(Image(uiImage: image))
            } else {
                placeholder()
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = url else {
            hasError = true
            isLoading = false
            return
        }
        
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(forKey: url.absoluteString) {
            await MainActor.run {
                loadedImage = cachedImage
                isLoading = false
            }
            return
        }
        
        // Load from network
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let image = UIImage(data: data) else {
                await MainActor.run {
                    hasError = true
                    isLoading = false
                }
                return
            }
            
            // Cache the image
            ImageCache.shared.setImage(image, forKey: url.absoluteString)
            
            await MainActor.run {
                loadedImage = image
                isLoading = false
                hasError = false
            }
        } catch {
            await MainActor.run {
                hasError = true
                isLoading = false
            }
        }
    }
}

// Simple in-memory image cache
actor ImageCache {
    static let shared = ImageCache()
    
    private var cache: [String: UIImage] = [:]
    private let maxCacheSize = 100 // Maximum number of images to cache
    
    private init() {}
    
    func getImage(forKey key: String) -> UIImage? {
        return cache[key]
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        // If cache is too large, remove oldest entries
        if cache.count >= maxCacheSize {
            let keysToRemove = Array(cache.keys.prefix(maxCacheSize / 2))
            for key in keysToRemove {
                cache.removeValue(forKey: key)
            }
        }
        cache[key] = image
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

// Convenience initializer for common use cases
extension CachedAsyncImage where Content == Image, Placeholder == ProgressView<EmptyView, EmptyView> {
    init(url: URL?) {
        self.init(
            url: url,
            content: { $0 },
            placeholder: { ProgressView() }
        )
    }
}

