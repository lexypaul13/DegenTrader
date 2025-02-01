import Foundation
import Combine
import UIKit

@MainActor
final class SearchViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var searchResults: [JupiterToken] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published var searchText = ""
    @Published private(set) var tokenPrices: [String: TokenPrice] = [:]
    
    // MARK: - Private Properties
    private let searchService: SearchServiceProtocol
    private let priceService: DexScreenerAPIServiceProtocol
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    private var priceUpdateTask: Task<Void, Never>?
    private let debounceInterval: TimeInterval = 0.5 // 500ms
    
    // MARK: - Initialization
    init(searchService: SearchServiceProtocol, 
         priceService: DexScreenerAPIServiceProtocol = DexScreenerAPIService()) {
        self.searchService = searchService
        self.priceService = priceService
        
        setupSearchSubscription()
    }
    
    // MARK: - Private Methods
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                Task {
                    await self?.performSearch(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) async {
        // Cancel any existing search
        searchTask?.cancel()
        
        // Clear results if query is too short
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        // Create new search task
        searchTask = Task {
            do {
                isLoading = true
                error = nil
                
                // Perform search
                let results = await searchService.search(query: query)
                
                // Check if task was cancelled
                if !Task.isCancelled {
                    searchResults = results
                    
                    // Fetch prices for search results
                    if !results.isEmpty {
                        await updatePrices(for: results)
                    }
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error
                }
            }
            isLoading = false
        }
    }
    
    private func updatePrices(for tokens: [JupiterToken]) async {
        do {
            let addresses = tokens.map { $0.address }
            let prices = try await priceService.fetchTokenPrices(addresses: addresses)
            tokenPrices = prices
        } catch {
            print("DEBUG: Failed to fetch prices: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public Methods
    func getPrice(for token: JupiterToken) -> Double {
        tokenPrices[token.address]?.price ?? 0.0
    }
    
    func getPriceChange(for token: JupiterToken) -> Double {
        tokenPrices[token.address]?.priceChange24h ?? 0.0
    }
    
    func retry() {
        Task {
            await performSearch(query: searchText)
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        error = nil
    }
    
    deinit {
        searchTask?.cancel()
        priceUpdateTask?.cancel()
        cancellables.removeAll()
    }
} 
