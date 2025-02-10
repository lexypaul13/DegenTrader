import Foundation
import Combine

final class TokenDetailViewModel: ObservableObject {
    @Published private(set) var tokenDetails: PairData? {
        willSet {
            print("📝 [ViewModel] tokenDetails will change to: \(newValue != nil ? "non-nil" : "nil")")
        }
        didSet {
            print("✅ [ViewModel] tokenDetails did change from: \(oldValue != nil ? "non-nil" : "nil")")
        }
    }
    
    @Published private(set) var isLoading: Bool = false {
        didSet {
            print("🔄 [ViewModel] isLoading changed to: \(isLoading)")
        }
    }
    
    @Published private(set) var errorMessage: String? {
        didSet {
            if let error = errorMessage {
                print("⚠️ [ViewModel] Error set: \(error)")
            } else {
                print("🆗 [ViewModel] Error cleared")
            }
        }
    }
    
    private let apiService: DexScreenerAPIServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var refreshTimer: Timer?
    private var currentChainId: String?
    private var currentPairId: String?
    
    init(apiService: DexScreenerAPIServiceProtocol) {
        self.apiService = apiService
        print("🎯 [ViewModel] Initialized with default values")
    }
    
    deinit {
        stopRefreshTimer()
    }
    
    private func startRefreshTimer() {
        stopRefreshTimer()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            guard let self = self,
                  let chainId = self.currentChainId,
                  let pairId = self.currentPairId else { return }
            
            print("⏰ [ViewModel] Refreshing token details")
            self.fetchTokenDetails(chainId: chainId, pairId: pairId)
        }
    }
    
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    // MARK: - Formatting Helpers
    private func formatLargeNumber(_ value: Double) -> String {
        let billion = 1_000_000_000.0
        let million = 1_000_000.0
        let thousand = 1_000.0
        
        switch value {
        case let x where x >= billion:
            return String(format: "$%.2fB", x / billion)
        case let x where x >= million:
            return String(format: "$%.2fM", x / million)
        case let x where x >= thousand:
            return String(format: "$%.2fK", x / thousand)
        default:
            return String(format: "$%.2f", value)
        }
    }
    
    private func formatPercentage(_ value: Double) -> String {
        let formatted = String(format: "%.2f", abs(value))
        return value >= 0 ? "+\(formatted)%" : "-\(formatted)%"
    }
    
    // MARK: - Public Properties
    var formattedMarketCap: String {
        guard let marketCap = tokenDetails?.marketCap else { return "N/A" }
        return formatLargeNumber(marketCap)
    }
    
    var formattedLiquidity: String {
        guard let liquidity = tokenDetails?.liquidity else { return "N/A" }
        return formatLargeNumber(liquidity.usd)
    }
    
    var formattedVolume: String {
        guard let volume = tokenDetails?.volume?.h24 else { return "N/A" }
        return formatLargeNumber(volume)
    }
    
    var formattedPriceChange: String {
        guard let priceChange = tokenDetails?.priceChange else { return "N/A" }
        return formatPercentage(priceChange.h24)
    }
    
    // Performance metrics
    var volume24h: (value: String, change: Double) {
        guard let volume = tokenDetails?.volume?.h24 else {
            return ("N/A", 0.0)
        }
        // Note: Since DexScreener API doesn't provide volume change %,
        // we'll just show the absolute value for now
        return ("$\(String(format: "%.2f", volume))", 0.0)
    }
    
    var trades24h: (value: String, change: Double)? {
        // Add when API provides trades data
        return nil
    }
    
    var traders24h: (value: String, change: Double)? {
        // Add when API provides traders data
        return nil
    }
    
    func fetchTokenDetails(chainId: String, pairId: String) {
        print("🔄 [ViewModel] Starting fetch for token \(pairId)")
        currentChainId = chainId
        currentPairId = pairId
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                print("📡 [ViewModel] Making API request")
                let details = try await apiService.fetchTokenDetails(chainId: chainId, pairId: pairId)
                
                DispatchQueue.main.async {
                    print("💾 [ViewModel] Updating state with details: \(details != nil)")
                    if let details = details {
                        print("   - Market Cap: \(details.marketCap ?? 0)")
                        print("   - Liquidity: \(details.liquidity.usd)")
                        print("   - Volume 24h: \(details.volume?.h24 ?? 0)")
                        // Start refresh timer when we get successful data
                        self.startRefreshTimer()
                    } else {
                        print("⚠️ [ViewModel] No details available, stopping refresh timer")
                        self.stopRefreshTimer()
                    }
                    self.tokenDetails = details
                    self.isLoading = false
                }
            } catch {
                print("❌ [ViewModel] Error fetching details: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    self.stopRefreshTimer()
                }
            }
        }
    }
} 