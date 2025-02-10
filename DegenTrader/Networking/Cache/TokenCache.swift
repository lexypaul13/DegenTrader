import Foundation

protocol CacheEntry {
    var expirationDate: Date { get }
}

struct TokenCacheEntry<T>: CacheEntry {
    let value: T
    let expirationDate: Date
}

protocol TokenCacheProtocol {
    func set<T>(_ value: T, forKey key: String, expirationIn seconds: TimeInterval)
    func get<T>(forKey key: String) -> T?
    func remove(forKey key: String)
    func removeExpired()
}

final class TokenCache: TokenCacheProtocol {
    static let shared = TokenCache()
    private let queue = DispatchQueue(label: "com.degentrader.tokencache")
    private var cache: [String: CacheEntry] = [:]
    
    private init() {}
    
    func set<T>(_ value: T, forKey key: String, expirationIn seconds: TimeInterval = 300) {
        queue.async {
            let entry = TokenCacheEntry(
                value: value,
                expirationDate: Date().addingTimeInterval(seconds)
            )
            self.cache[key] = entry
        }
    }
    
    func get<T>(forKey key: String) -> T? {
        queue.sync {
            guard let entry = cache[key] as? TokenCacheEntry<T> else {
                return nil
            }
            
            // Check if entry has expired
            if entry.expirationDate < Date() {
                cache.removeValue(forKey: key)
                return nil
            }
            
            return entry.value
        }
    }
    
    func remove(forKey key: String) {
        queue.async {
            self.cache.removeValue(forKey: key)
        }
    }
    
    func removeExpired() {
        queue.async {
            let now = Date()
            self.cache = self.cache.filter { $0.value.expirationDate > now }
        }
    }
} 