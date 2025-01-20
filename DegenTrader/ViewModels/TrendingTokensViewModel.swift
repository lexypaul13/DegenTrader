import Foundation
import Combine

// MARK: - View Model Protocol
protocol TrendingTokensViewModelProtocol: ObservableObject {
    var tokens: [JupiterToken] { get }
    var memeCoins: [JupiterToken] { get }
    var state: LoadingState { get }
    var errorMessage: String? { get }
    
    func fetchTrendingTokens() async
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
    
    private let apiService: JupiterAPIServiceProtocol
    private let memeCoinService: MemeCoinServiceProtocol
    
    init(apiService: JupiterAPIServiceProtocol = JupiterAPIService(),
         memeCoinService: MemeCoinServiceProtocol = MemeCoinService()) {
        self.apiService = apiService
        self.memeCoinService = memeCoinService
    }
    
    func fetchTrendingTokens() async {
        state = .loading
        errorMessage = nil
        
        do {
            tokens = try await apiService.fetchTrendingTokens()
            memeCoins = memeCoinService.filterMemeCoins(tokens)
            state = .loaded
        } catch {
            errorMessage = error.localizedDescription
            state = .error
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
