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
    private let queue = DispatchQueue(label: "com.degentrader.imagecache")
    private var activeDownloads: [URL: Task<Image, Error>] = [:]
    
    private init() {
        cache.countLimit = memoryLimit
        print("DEBUG: ImageCacheService initialized with memory limit: \(memoryLimit)")
    }
    
    func getImage(from url: URL) async throws -> Image {
        print("\nDEBUG: 🖼 Fetching image: \(url.lastPathComponent)")
        
        // Check cache first
        if let cachedImage = queue.sync(execute: { cache.object(forKey: url as NSURL) }) {
            queue.async {
                self.cacheHits += 1
                // Update access order for cached image
                if let index = self.cacheOrder.firstIndex(of: url) {
                    self.cacheOrder.remove(at: index)
                }
                self.cacheOrder.append(url)
                print("DEBUG: ✅ CACHE HIT [\(self.cacheHits) hits / \(self.cacheMisses) misses] - Found: \(url.lastPathComponent)")
            }
            return Image(uiImage: cachedImage)
        }
        
        // Check if there's already an active download for this URL
        if let existingTask = queue.sync(execute: { activeDownloads[url] }) {
            return try await existingTask.value
        }
        
        // Create a new download task
        let downloadTask = Task<Image, Error> {
            queue.async { self.cacheMisses += 1 }
            print("DEBUG: ❌ CACHE MISS [\(self.cacheHits) hits / \(self.cacheMisses) misses] - Downloading: \(url.lastPathComponent)")
            
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else {
                print("DEBUG: ⚠️ Failed to decode image data for: \(url.lastPathComponent)")
                throw URLError(.cannotDecodeContentData)
            }
            
            queue.async {
                self.totalDownloaded += 1
                print("DEBUG: ⬇️ Download successful - Total downloads: \(self.totalDownloaded)")
                
                // Remove oldest entry if cache is full
                if self.cacheOrder.count >= self.memoryLimit {
                    if let oldestURL = self.cacheOrder.first {
                        self.cache.removeObject(forKey: oldestURL as NSURL)
                        self.cacheOrder.removeFirst()
                        print("DEBUG: 🗑 Removed oldest image: \(oldestURL.lastPathComponent)")
                    }
                }
                
                // Cache the downloaded image
                self.cache.setObject(uiImage, forKey: url as NSURL)
                self.cacheOrder.append(url)
                print("DEBUG: 💾 Cached new image - Cache size: [\(self.cacheOrder.count)/\(self.memoryLimit)]")
                print("DEBUG: Cache efficiency: \(Int((Double(self.cacheHits) / Double(self.cacheHits + self.cacheMisses) * 100)))% hit rate")
                
                // Remove the task from active downloads
                self.activeDownloads.removeValue(forKey: url)
            }
            
            return Image(uiImage: uiImage)
        }
        
        // Store the task in active downloads
        queue.sync { activeDownloads[url] = downloadTask }
        
        return try await downloadTask.value
    }
    
    func clearCache() {
        queue.async {
            let count = self.cacheOrder.count
            self.cache.removeAllObjects()
            self.cacheOrder.removeAll()
            self.activeDownloads.removeAll()
            self.cacheHits = 0
            self.cacheMisses = 0
            print("\nDEBUG: 🧹 Cache cleared - Removed \(count) images")
            print("DEBUG: Cache stats reset to 0")
        }
    }
} 