import SwiftUI
import Kingfisher

struct CachedTokenImage: View {
    let url: URL
    
    var body: some View {
        KFImage.url(url)
            .placeholder {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
            }
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
    }
}

#Preview {
    CachedTokenImage(
        url: URL(string: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png")!
    )
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
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