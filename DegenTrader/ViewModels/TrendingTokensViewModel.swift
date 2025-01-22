import Foundation
import Combine

// MARK: - View Model Protocol
protocol TrendingTokensViewModelProtocol: ObservableObject {
    var tokens: [JupiterToken] { get }
    var memeCoins: [JupiterToken] { get }
    var state: LoadingState { get }
    var errorMessage: String? { get }
    var lastUpdateText: String { get }
    var hasMorePages: Bool { get }
    var currentPage: Int { get }
    
    func fetchTrendingTokens() async
    func loadNextPage() async
}

// MARK: - Loading State
enum LoadingState {
    case idle
    case loading
    case loaded
    case error
}

// MARK: - View Model Implementation
@MainActor
final class TrendingTokensViewModel: ObservableObject, @preconcurrency TrendingTokensViewModelProtocol {
    @Published private(set) var tokens: [JupiterToken] = []
    @Published private(set) var memeCoins: [JupiterToken] = []
    @Published private(set) var state: LoadingState = .idle
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastUpdateText: String = "Not updated"
    @Published private(set) var hasMorePages = true
    @Published private(set) var currentPage = 1
    
    private let apiService: JupiterAPIServiceProtocol
    private let memeCoinService: MemeCoinServiceProtocol
    private var lastFetchTime: Date?
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    private var autoUpdateTask: Task<Void, Never>?
    
    private let tokensPerPage = 10
    private let maxPages = 3
    private var allTokens: [JupiterToken] = []
    
    init(apiService: JupiterAPIServiceProtocol = JupiterAPIService(),
         memeCoinService: MemeCoinServiceProtocol = MemeCoinService()) {
        self.apiService = apiService
        self.memeCoinService = memeCoinService
        setupAutoUpdate()
    }
    
    deinit {
        autoUpdateTask?.cancel()
    }
    
    private func setupAutoUpdate() {
        autoUpdateTask = Task {
            while !Task.isCancelled {
                await fetchTrendingTokens()
                try? await Task.sleep(nanoseconds: UInt64(cacheTimeout * 1_000_000_000))
            }
        }
    }
    
    func fetchTrendingTokens() async {
        // Check if we have cached data that's still fresh
        if let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheTimeout,
           !tokens.isEmpty {
            return
        }
        
        state = .loading
        errorMessage = nil
        currentPage = 1
        
        do {
            allTokens = try await apiService.fetchTrendingTokens()
            let allMemeCoins = memeCoinService.filterMemeCoins(allTokens)
            
            // Get first page
            memeCoins = Array(allMemeCoins.prefix(tokensPerPage))
            hasMorePages = allMemeCoins.count > tokensPerPage
            
            lastFetchTime = Date()
            updateLastUpdateText()
            state = .loaded
        } catch {
            errorMessage = error.localizedDescription
            state = .error
        }
    }
    
    func loadNextPage() async {
        print("\nDEBUG: loadNextPage called")
        print("DEBUG: Current page: \(currentPage), Has more pages: \(hasMorePages)")
        
        guard hasMorePages, state == .loaded, currentPage < maxPages else {
            print("DEBUG: Cannot load next page - hasMorePages: \(hasMorePages), state: \(state), currentPage: \(currentPage), maxPages: \(maxPages)")
            return
        }
        
        let nextPage = currentPage + 1
        let startIndex = (nextPage - 1) * tokensPerPage
        let allMemeCoins = memeCoinService.filterMemeCoins(allTokens)
        
        print("DEBUG: Loading page \(nextPage) - Starting from index \(startIndex)")
        print("DEBUG: Total meme coins available: \(allMemeCoins.count)")
        
        let newTokens = Array(allMemeCoins.dropFirst(startIndex).prefix(tokensPerPage))
        print("DEBUG: New tokens found: \(newTokens.count)")
        
        guard !newTokens.isEmpty else {
            print("DEBUG: No new tokens found, disabling pagination")
            hasMorePages = false
            return
        }
        
        currentPage = nextPage
        memeCoins.append(contentsOf: newTokens)
        hasMorePages = currentPage < maxPages
        print("DEBUG: Page \(currentPage) loaded - Total tokens: \(memeCoins.count)")
        print("DEBUG: Has more pages: \(hasMorePages)\n")
    }
    
    private func updateLastUpdateText() {
        guard let lastFetch = lastFetchTime else {
            lastUpdateText = "Not updated"
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        lastUpdateText = "Updated at \(formatter.string(from: lastFetch))"
    }
}

// MARK: - Token Display Model
extension JupiterToken {
    var displayVolume: String {
        String(format: "$%.2f", daily_volume ?? 0.0)
    }
    
    var creationDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = formatter.date(from: created_at) else { return "Unknown" }
        
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
} 
