import Foundation
import Combine

@MainActor
final class TokenDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var state: LoadingState = .idle
    @Published private(set) var tokenDetail: TokenDetail?
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    private let tokenDetailService: TokenDetailServiceProtocol
    private var refreshTask: Task<Void, Never>?
    private let refreshInterval: TimeInterval = 30 // 30 seconds
    
    // MARK: - Initialization
    init(tokenDetailService: TokenDetailServiceProtocol) {
        self.tokenDetailService = tokenDetailService
    }
    
    // MARK: - Public Methods
    func loadTokenDetails(address: String) async {
        state = .loading
        
        do {
            tokenDetail = try await tokenDetailService.fetchTokenDetails(address: address)
            setupRefreshTimer(address: address)
            state = .loaded
        } catch {
            self.error = error
            state = .error
        }
    }
    
    func retry(address: String) async {
        await loadTokenDetails(address: address)
    }
    
    // MARK: - Private Methods
    private func setupRefreshTimer(address: String) {
        // Cancel any existing refresh task
        refreshTask?.cancel()
        
        // Create new refresh task
        refreshTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(refreshInterval * 1_000_000_000))
                await loadTokenDetails(address: address)
            }
        }
    }
    
    deinit {
        refreshTask?.cancel()
    }
} 