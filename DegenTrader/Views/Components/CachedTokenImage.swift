import SwiftUI

struct CachedTokenImage: View {
    let url: URL
    let size: CGFloat
    
    @State private var image: Image?
    @State private var isLoading = true
    @State private var loadingTask: Task<Void, Never>?
    
    private let imageService: ImageCacheServiceProtocol
    
    init(url: URL, size: CGFloat = 32, imageService: ImageCacheServiceProtocol = ImageCacheService.shared) {
        self.url = url
        self.size = size
        self.imageService = imageService
    }
    
    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
                    .opacity(isLoading ? 1 : 0)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            loadImage()
        }
        .onDisappear {
            loadingTask?.cancel()
        }
    }
    
    private func loadImage() {
        // Cancel any existing task
        loadingTask?.cancel()
        
        // Start new loading task
        loadingTask = Task {
            guard image == nil else { return }
            
            do {
                let loadedImage = try await imageService.getImage(from: url)
                if !Task.isCancelled {
                    image = loadedImage
                }
            } catch {
                print("Error loading image: \(error)")
            }
            if !Task.isCancelled {
                isLoading = false
            }
        }
    }
}

struct CachedAsyncImage: View {
    let url: URL?
    let scale: CGFloat
    
    @State private var image: Image?
    @State private var isLoading = true
    @State private var loadingTask: Task<Void, Never>?
    
    private let imageService: ImageCacheServiceProtocol
    
    init(url: URL?, scale: CGFloat = 1.0, imageService: ImageCacheServiceProtocol = ImageCacheService.shared) {
        self.url = url
        self.scale = scale
        self.imageService = imageService
    }
    
    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear {
            loadImage()
        }
        .onDisappear {
            loadingTask?.cancel()
        }
    }
    
    private func loadImage() {
        guard let url = url else {
            isLoading = false
            return
        }
        
        // Cancel any existing task
        loadingTask?.cancel()
        
        // Start new loading task
        loadingTask = Task {
            guard image == nil else { return }
            
            do {
                let loadedImage = try await imageService.getImage(from: url)
                if !Task.isCancelled {
                    image = loadedImage
                }
            } catch {
                print("DEBUG: Failed to load image: \(error.localizedDescription)")
            }
            if !Task.isCancelled {
                isLoading = false
            }
        }
    }
} 