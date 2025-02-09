import Foundation
import Combine

final class TokenDetailViewModel: ObservableObject {
    @Published var tokenDetails: PairData?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let apiService: DexScreenerAPIServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(apiService: DexScreenerAPIServiceProtocol) {
        self.apiService = apiService
    }
    
    var formattedMarketCap: String {
        guard let marketCap = tokenDetails?.marketCap else { return "N/A" }
        return "$\(String(format: "%.2f", marketCap))"
    }
    
    var formattedLiquidity: String {
        guard let liquidity = tokenDetails?.liquidity else { return "N/A" }
        return "$\(String(format: "%.2f", liquidity.usd))"
    }
    
    var formattedVolume: String {
        guard let volume = tokenDetails?.volume?.h24 else { return "N/A" }
        return "$\(String(format: "%.2f", volume))"
    }
    
    var formattedPriceChange: String {
        guard let priceChange = tokenDetails?.priceChange else { return "N/A" }
        return "\(String(format: "%.2f", priceChange.h24))%"
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
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let details = try await apiService.fetchTokenDetails(chainId: chainId, pairId: pairId)
                
                DispatchQueue.main.async {
                    self.tokenDetails = details
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
} 