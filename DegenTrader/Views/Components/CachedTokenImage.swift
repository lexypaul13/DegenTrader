import SwiftUI

struct CachedTokenImage: View {
    let url: URL
    let size: CGFloat
    
    @State private var image: Image?
    @State private var isLoading = true
    
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
        .task {
            do {
                image = try await imageService.getImage(from: url)
            } catch {
                print("Error loading image: \(error)")
            }
            isLoading = false
        }
    }
}

struct CachedAsyncImage: View {
    let url: URL?
    let scale: CGFloat
    
    @State private var image: Image?
    @State private var isLoading = true
    
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
        .task {
            guard let url = url else {
                isLoading = false
                return
            }
            
            do {
                image = try await imageService.getImage(from: url)
            } catch {
                print("DEBUG: Failed to load image: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
} 