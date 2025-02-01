import Foundation
import UIKit

// MARK: - Protocol
protocol SearchServiceProtocol {
    func initialize() async throws
    func search(query: String) async -> [JupiterToken]
    func clearCache()
    func retry() async throws
    var isInitialized: Bool { get }
    var lastUpdateTime: Date? { get }
}

// MARK: - Implementation
final class SearchService: SearchServiceProtocol {
    // MARK: - Properties
    private let jupiterService: JupiterAPIServiceProtocol
    private let memeCoinService: MemeCoinServiceProtocol
    private var cachedTokens: [JupiterToken] = []
    internal var lastUpdateTime: Date?
    private let cacheConfig = CacheConfig()
    private var error: Error?
    private var isInBackground = false
    private var refreshTask: Task<Void, Never>?
    
    // MARK: - Cache Configuration
    private struct CacheConfig {
        let baseCacheDuration: TimeInterval = 10 * 60 // 10 minutes
        let backgroundExtension: TimeInterval = 5 * 60 // 5 minutes
        let maxCacheDuration: TimeInterval = 30 * 60   // 30 minutes
        let refreshInterval: TimeInterval = 5 * 60     // Refresh every 5 minutes
        
        func getDuration(isBackground: Bool) -> TimeInterval {
            isBackground ? baseCacheDuration + backgroundExtension : baseCacheDuration
        }
    }
    
    // MARK: - Initialization
    init(jupiterService: JupiterAPIServiceProtocol, memeCoinService: MemeCoinServiceProtocol) {
        self.jupiterService = jupiterService
        self.memeCoinService = memeCoinService
        setupNotifications()
        setupInitialCache()
        setupPeriodicRefresh()
    }
    
    private func setupInitialCache() {
        Task {
            do {
                try await initialize()
            } catch {
                print("DEBUG: Failed to initialize cache: \(error.localizedDescription)")
            }
        }
    }
    
    private func setupPeriodicRefresh() {
        refreshTask = Task {
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: UInt64(cacheConfig.refreshInterval * 1_000_000_000))
                    if !isInBackground {
                        try await refreshCache()
                    }
                } catch {
                    print("DEBUG: Failed to refresh cache: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Public Interface
    var isInitialized: Bool {
        !cachedTokens.isEmpty && isCacheValid
    }
    
    func initialize() async throws {
        try await refreshCache()
    }
    
    func search(query: String) async -> [JupiterToken] {
        // Validate query first to avoid unnecessary initialization
        guard query.count >= 3 else { return [] }
        
        // Check initialization
        if !isInitialized {
            do {
                try await initialize()
            } catch {
                self.error = error
                return []
            }
        }
        
        let lowercasedQuery = query.lowercased()
        
        // First find exact matches
        let exactMatches = cachedTokens.filter { token in
            token.symbol.lowercased() == lowercasedQuery || 
            token.name.lowercased() == lowercasedQuery
        }
        
        // Then find partial matches
        let partialMatches = cachedTokens.filter { token in
            !exactMatches.contains(token) && (
                token.symbol.lowercased().contains(lowercasedQuery) || 
                token.name.lowercased().contains(lowercasedQuery)
            )
        }
        
        // Combine results, limiting to 5 total
        return (exactMatches + partialMatches).prefix(5).map { $0 }
    }
    
    func clearCache() {
        cachedTokens.removeAll()
        lastUpdateTime = nil
        error = nil
    }
    
    func retry() async throws {
        error = nil
        try await refreshCache()
    }
    
    // MARK: - Private Methods
    private var isCacheValid: Bool {
        guard let lastUpdate = lastUpdateTime else { return false }
        return Date().timeIntervalSince(lastUpdate) < cacheConfig.getDuration(isBackground: isInBackground)
    }
    
    private func refreshCache() async throws {
        do {
            let newTokens = try await jupiterService.fetchTrendingTokens()
            cachedTokens = newTokens
            lastUpdateTime = Date()
            error = nil
        } catch {
            self.error = error
            throw error
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func handleMemoryWarning() {
        clearCache()
    }
    
    @objc private func handleDidEnterBackground() {
        isInBackground = true
    }
    
    @objc private func handleWillEnterForeground() {
        isInBackground = false
    }
    
    deinit {
        refreshTask?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
} 
