import Foundation
import Combine

// MARK: - View Model Protocol
protocol TrendingTokensViewModelProtocol: ObservableObject {
    var tokens: [JupiterToken] { get }
    var memeCoins: [JupiterToken] { get }
    var tokenPrices: [String: TokenPrice] { get }
    var state: LoadingState { get }
    var errorMessage: String? { get }
    var lastUpdateText: String { get }
    var hasMorePages: Bool { get }
    var currentPage: Int { get }
    
    func fetchTrendingTokens() async
    func loadNextPage() async
    func getPrice(for token: JupiterToken) -> Double
    func getPriceChange(for token: JupiterToken) -> Double
}

// MARK: - Loading State
enum LoadingState {
    case idle
    case loading
    case loaded
    case loadingMore
    case error
}

// MARK: - View Model Implementation
@MainActor
final class TrendingTokensViewModel: ObservableObject, TrendingTokensViewModelProtocol {
    @Published private(set) var tokens: [JupiterToken] = []
    @Published private(set) var memeCoins: [JupiterToken] = []
    @Published private(set) var tokenPrices: [String: TokenPrice] = [:]
    @Published private(set) var state: LoadingState = .idle
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastUpdateText: String = "Not updated"
    @Published private(set) var hasMorePages = true
    @Published private(set) var currentPage = 1
    
    private let jupiterService: JupiterAPIServiceProtocol
    private let priceService: DexScreenerAPIServiceProtocol
    private let memeCoinService: MemeCoinServiceProtocol
    private var lastFetchTime: Date?
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    private var autoUpdateTask: Task<Void, Never>?
    private var priceUpdateTask: Task<Void, Never>?
    
    private let tokensPerPage = 10
    private let maxPages = 3
    private var allTokens: [JupiterToken] = []
    
    init(jupiterService: JupiterAPIServiceProtocol = JupiterAPIService(),
         priceService: DexScreenerAPIServiceProtocol = DexScreenerAPIService(),
         memeCoinService: MemeCoinServiceProtocol = MemeCoinService()) {
        self.jupiterService = jupiterService
        self.priceService = priceService
        self.memeCoinService = memeCoinService
        setupAutoUpdate()
    }
    
    deinit {
        autoUpdateTask?.cancel()
        priceUpdateTask?.cancel()
    }
    
    private func setupAutoUpdate() {
        autoUpdateTask = Task {
            while !Task.isCancelled {
                await fetchTrendingTokens()
                try? await Task.sleep(nanoseconds: UInt64(cacheTimeout * 1_000_000_000))
            }
        }
        
        // Update prices more frequently
        priceUpdateTask = Task {
            while !Task.isCancelled {
                await updatePrices()
                try? await Task.sleep(nanoseconds: UInt64(30 * 1_000_000_000)) // 30 seconds
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
            allTokens = try await jupiterService.fetchTrendingTokens()
            let allMemeCoins = memeCoinService.filterMemeCoins(allTokens)
            
            // Get first page
            memeCoins = Array(allMemeCoins.prefix(tokensPerPage))
            hasMorePages = allMemeCoins.count > tokensPerPage
            
            // Update prices for the first page
            await updatePrices()
            
            lastFetchTime = Date()
            updateLastUpdateText()
            state = .loaded
        } catch {
            errorMessage = error.localizedDescription
            state = .error
        }
    }
    
    private func updatePrices() async {
        guard !memeCoins.isEmpty else { return }
        
        do {
            let addresses = memeCoins.map { $0.address }
            tokenPrices = try await priceService.fetchTokenPrices(addresses: addresses)
            objectWillChange.send()
        } catch {
            print("DEBUG: Failed to update prices: \(error.localizedDescription)")
        }
    }
    
    func getPrice(for token: JupiterToken) -> Double {
        tokenPrices[token.address]?.price ?? 0.0
    }
    
    func getPriceChange(for token: JupiterToken) -> Double {
        tokenPrices[token.address]?.priceChange24h ?? 0.0
    }
    
    func loadNextPage() async {
        guard hasMorePages, 
              (state == .loaded || state == .loadingMore), 
              currentPage < maxPages else { 
            return 
        }
        
        state = .loadingMore
        
        let nextPage = currentPage + 1
        let startIndex = (nextPage - 1) * tokensPerPage
        let allMemeCoins = memeCoinService.filterMemeCoins(allTokens)
        
        let newTokens = Array(allMemeCoins.dropFirst(startIndex).prefix(tokensPerPage))
        guard !newTokens.isEmpty else {
            hasMorePages = false
            state = .loaded
            return
        }
        
        memeCoins.append(contentsOf: newTokens)
        currentPage = nextPage
        hasMorePages = allMemeCoins.count > memeCoins.count && currentPage < maxPages
        
        // Update prices for new tokens
        await updatePrices()
        state = .loaded
    }
    
    private func updateLastUpdateText() {
        if let lastFetch = lastFetchTime {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            lastUpdateText = "Updated " + formatter.localizedString(for: lastFetch, relativeTo: Date())
        }
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
