import Foundation
import SwiftUI

protocol ImageCacheServiceProtocol {
    func getImage(from url: URL) async throws -> Image
    func clearCache()
}

final class ImageCacheService: ImageCacheServiceProtocol {
    static let shared = ImageCacheService()
    
    private let cache = NSCache<NSURL, UIImage>()
    private let memoryLimit = 100 // Maximum number of images to cache
    private var cacheOrder: [URL] = [] // Track order of cache entries
    private var totalDownloaded: Int = 0
    private var cacheHits: Int = 0
    private var cacheMisses: Int = 0
    
    private init() {
        cache.countLimit = memoryLimit
        print("DEBUG: ImageCacheService initialized with memory limit: \(memoryLimit)")
    }
    
    func getImage(from url: URL) async throws -> Image {
        print("\nDEBUG: 🖼 Fetching image: \(url.lastPathComponent)")
        
        // Check cache first
        if let cachedImage = cache.object(forKey: url as NSURL) {
            cacheHits += 1
            // Update access order for cached image
            if let index = cacheOrder.firstIndex(of: url) {
                cacheOrder.remove(at: index)
                print("DEBUG: ♻️ Reordering cached image")
            }
            cacheOrder.append(url)
            print("DEBUG: ✅ CACHE HIT [\(cacheHits) hits / \(cacheMisses) misses] - Found: \(url.lastPathComponent)")
            return Image(uiImage: cachedImage)
        }
        
        cacheMisses += 1
        print("DEBUG: ❌ CACHE MISS [\(cacheHits) hits / \(cacheMisses) misses] - Downloading: \(url.lastPathComponent)")
        
        // Download if not cached
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let uiImage = UIImage(data: data) else {
            print("DEBUG: ⚠️ Failed to decode image data for: \(url.lastPathComponent)")
            throw URLError(.cannotDecodeContentData)
        }
        
        totalDownloaded += 1
        print("DEBUG: ⬇️ Download successful - Total downloads: \(totalDownloaded)")
        
        // Remove oldest entry if cache is full
        if cacheOrder.count >= memoryLimit {
            if let oldestURL = cacheOrder.first {
                cache.removeObject(forKey: oldestURL as NSURL)
                cacheOrder.removeFirst()
                print("DEBUG: 🗑 Removed oldest image: \(oldestURL.lastPathComponent)")
            }
        }
        
        // Cache the downloaded image
        cache.setObject(uiImage, forKey: url as NSURL)
        cacheOrder.append(url)
        print("DEBUG: 💾 Cached new image - Cache size: [\(cacheOrder.count)/\(memoryLimit)]")
        print("DEBUG: Cache efficiency: \(Int((Double(cacheHits) / Double(cacheHits + cacheMisses) * 100)))% hit rate")
        
        return Image(uiImage: uiImage)
    }
    
    func clearCache() {
        let count = cacheOrder.count
        cache.removeAllObjects()
        cacheOrder.removeAll()
        cacheHits = 0
        cacheMisses = 0
        print("\nDEBUG: 🧹 Cache cleared - Removed \(count) images")
        print("DEBUG: Cache stats reset to 0")
    }
} 