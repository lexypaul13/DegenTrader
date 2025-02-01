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
    
    // MARK: - Private Properties
    private let searchService: SearchServiceProtocol
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    private let debounceInterval: TimeInterval = 0.5 // 500ms
    
    // MARK: - Initialization
    init(searchService: SearchServiceProtocol) {
        self.searchService = searchService
        setupSearchSubscription()
    }
    
    // MARK: - Private Methods
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .seconds(debounceInterval), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                Task { [weak self] in
                    await self?.performSearch()
                }
            }
            .store(in: &cancellables)
    }
    
    private func performSearch() async {
        // Cancel any existing search
        searchTask?.cancel()
        
        // Clear results if query is too short
        guard searchText.count >= 3 else {
            searchResults = []
            return
        }
        
        // Create new search task
        searchTask = Task {
            do {
                isLoading = true
                error = nil
                
                // Perform search
                let results = await searchService.search(query: searchText)
                
                // Check if task was cancelled
                if !Task.isCancelled {
                    searchResults = results
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error
                }
            }
            isLoading = false
        }
    }
    
    // MARK: - Public Methods
    func retry() {
        Task {
            do {
                try await searchService.retry()
                await performSearch()
            } catch {
                self.error = error
            }
        }
    }
    
    func clearSearch() {
        searchText = ""
        searchResults = []
        error = nil
    }
    
    deinit {
        searchTask?.cancel()
        cancellables.removeAll()
    }
} 
