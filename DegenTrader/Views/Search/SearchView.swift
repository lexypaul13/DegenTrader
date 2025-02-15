import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var walletManager: WalletManager
    @StateObject private var searchViewModel: SearchViewModel
    @StateObject private var trendingViewModel = TrendingTokensViewModel()
    @State private var showSwapView = false
    @State private var showTokenDetail = false
    @State private var selectedToken: Token?
    @State public var recentTokens: [Token] = []
    
    init() {
        let searchService = SearchService(
            jupiterService: JupiterAPIService(),
            memeCoinService: MemeCoinService()
        )
        _searchViewModel = StateObject(wrappedValue: SearchViewModel(searchService: searchService))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.colors.textSecondary)
                            .font(.system(size: 16))
                        
                        TextField("Search", text: $searchViewModel.searchText)
                            .foregroundColor(AppTheme.colors.textPrimary)
                            .font(.system(size: 16))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(hex: "1C1C1E"))
                    .cornerRadius(16)
                    
                    Button("Cancel") {
                        searchViewModel.clearSearch()
                        dismiss()
                    }
                    .foregroundColor(AppTheme.colors.textPrimary)
                    .font(.system(size: 16))
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                ScrollView {
                    if searchViewModel.searchText.isEmpty {
                        defaultContent
                    } else {
                        searchResultsContent
                    }
                }
            }
            .background(AppTheme.colors.background)
            .navigationDestination(isPresented: $showSwapView) {
                if let token = selectedToken {
                    SwapView(
                        selectedFromToken: Token(
                            symbol: "SOL",
                            name: "Solana",
                            price: 0.0,
                            priceChange24h: 0.0,
                            volume24h: 0,
                            logoURI: nil,
                            address: "So11111111111111111111111111111111111111112"
                        ),
                        selectedToToken: token
                    )
                }
            }
            .navigationDestination(isPresented: $showTokenDetail) {
                if let token = selectedToken {
                    TokenDetailContainerView(token: token, walletManager: walletManager)
                }
            }
            .task {
                await trendingViewModel.fetchTrendingTokens()
            }
        }
    }
    
    // MARK: - Content Views
    private var defaultContent: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Recents Section
            if !recentTokens.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Recents")
                            .font(.title2)
                            .foregroundColor(AppTheme.colors.textPrimary)
                            .padding(.vertical, 2)
                        
                        Spacer()
                        
                        Button("Clear") {
                            recentTokens.removeAll()
                        }
                        .foregroundColor(AppTheme.colors.textSecondary)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(recentTokens) { token in
                                RecentTokenPill(token: token)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            // Trending Tokens List
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Trending Meme Coins")
                        .font(.title2)
                        .foregroundColor(AppTheme.colors.textPrimary)
                    
                    Spacer()
                    
                    if case .loaded = trendingViewModel.state {
                        Text(trendingViewModel.lastUpdateText)
                            .font(.caption)
                            .foregroundColor(AppTheme.colors.textSecondary)
                    }
                }
                .padding(.horizontal)
                
                TrendingTokensContent(
                    viewModel: trendingViewModel,
                    recentTokens: $recentTokens,
                    selectedToken: $selectedToken,
                    showSwapView: $showSwapView,
                    showTokenDetail: $showTokenDetail
                )
            }
        }
        .padding(.top)
    }
    
    private var searchResultsContent: some View {
        VStack {
            if searchViewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let error = searchViewModel.error {
                VStack(spacing: 16) {
                    Text(error.localizedDescription)
                        .foregroundColor(AppTheme.colors.negative)
                        .multilineTextAlignment(.center)
                    
                    Button("Retry") {
                        searchViewModel.retry()
                    }
                    .foregroundColor(AppTheme.colors.accent)
                }
                .padding()
            } else if searchViewModel.searchText.count < 3 {
                Text("Enter at least 3 characters to search")
                    .foregroundColor(AppTheme.colors.textSecondary)
                    .padding()
            } else if searchViewModel.searchResults.isEmpty {
                Text("No results found")
                    .foregroundColor(AppTheme.colors.textSecondary)
                    .padding()
            } else {
                LazyVStack(spacing: 1) {
                    ForEach(searchViewModel.searchResults) { token in
                        let price = searchViewModel.getPrice(for: token)
                        let priceChange = searchViewModel.getPriceChange(for: token)
                        let newToken = Token(
                            symbol: token.symbol,
                            name: token.name,
                            price: price,
                            priceChange24h: priceChange,
                            volume24h: token.daily_volume ?? 0,
                            logoURI: token.logoURI,
                            address: token.address
                        )
                        
                        SearchTokenRow(
                            token: newToken,
                            onSwapTap: {
                                selectedToken = newToken
                                showSwapView = true
                            },
                            onRowTap: {
                                selectedToken = newToken
                                showTokenDetail = true
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func handleTokenSelection(_ token: JupiterToken, price: Double, priceChange: Double) {
        let newToken = Token(
            symbol: token.symbol,
            name: token.name,
            price: price,
            priceChange24h: priceChange,
            volume24h: token.daily_volume ?? 0,
            logoURI: token.logoURI,
            address: token.address
        )
        
        if !recentTokens.contains(where: { $0.id == newToken.id }) {
            recentTokens.insert(newToken, at: 0)
            if recentTokens.count > 5 {
                recentTokens.removeLast()
            }
        }
        selectedToken = newToken
        showSwapView = true
    }
}

// MARK: - Trending Tokens Content
private struct TrendingTokensContent: View {
    @ObservedObject var viewModel: TrendingTokensViewModel
    @Binding var recentTokens: [Token]
    @Binding var selectedToken: Token?
    @Binding var showSwapView: Bool
    @Binding var showTokenDetail: Bool
    
    var body: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding()
            
        case .loaded, .loadingMore:
            LazyVStack(spacing: 1) {
                ForEach(viewModel.memeCoins) { token in
                    let price = viewModel.getPrice(for: token)
                    let priceChange = viewModel.getPriceChange(for: token)
                    let newToken = Token(
                        symbol: token.symbol,
                        name: token.name,
                        price: price,
                        priceChange24h: priceChange,
                        volume24h: token.daily_volume ?? 0,
                        logoURI: token.logoURI,
                        address: token.address
                    )
                    
                    SearchTokenRow(
                        token: newToken,
                        onSwapTap: {
                            selectedToken = newToken
                            showSwapView = true
                        },
                        onRowTap: {
                            selectedToken = newToken
                            showTokenDetail = true
                        }
                    )
                }
                
                if viewModel.hasMorePages {
                    HStack {
                        Spacer()
                        ProgressView()
                            .opacity(viewModel.state == .loadingMore ? 1 : 0)
                        Spacer()
                    }
                    .frame(height: 50)
                    .onAppear {
                        if viewModel.state == .loaded {
                            Task {
                                await viewModel.loadNextPage()
                            }
                        }
                    }
                }
            }
            
        case .error:
            Text(viewModel.errorMessage ?? "Failed to load trending tokens")
                .foregroundColor(AppTheme.colors.negative)
                .frame(maxWidth: .infinity)
                .padding()
        }
    }
    
    private func handleTokenSelection(_ token: JupiterToken, price: Double, priceChange: Double) {
        let newToken = Token(
            symbol: token.symbol,
            name: token.name,
            price: price,
            priceChange24h: priceChange,
            volume24h: token.daily_volume ?? 0,
            logoURI: token.logoURI,
            address: token.address
        )
        
        if !recentTokens.contains(where: { $0.id == newToken.id }) {
            recentTokens.insert(newToken, at: 0)
            if recentTokens.count > 5 {
                recentTokens.removeLast()
            }
        }
        selectedToken = newToken
        showSwapView = true
    }
}

// MARK: - Preview
struct SearchView_Previews: PreviewProvider {
    static var previewTrendingTokens = [
        Token(symbol: "TRUMP", name: "OFFICIAL TRUMP", price: 49.00, priceChange24h: 41.95, volume24h: 0, logoURI: nil),
        Token(symbol: "MELANIA", name: "Melania Meme", price: 8.01, priceChange24h: 7.8, volume24h: 0, logoURI: nil),
        Token(symbol: "USA", name: "American Coin", price: 0.00001309, priceChange24h: 212.75, volume24h: 0, logoURI: nil),
        Token(symbol: "MR BEAST", name: "OFFICIAL MR BEAST", price: 0.00165924, priceChange24h: 21974.04, volume24h: 0, logoURI: nil),
        Token(symbol: "ELON", name: "Official Elon Coin", price: 0.0345, priceChange24h: -58.88, volume24h: 0, logoURI: nil),
        Token(symbol: "SATOSHI", name: "Official Satoshi Coin", price: 0.00257009, priceChange24h: 2190.45, volume24h: 0, logoURI: nil),
        Token(symbol: "$1", name: "just buy $1 worth of this coin", price: 0.0476, priceChange24h: 1781.16, volume24h: 0, logoURI: nil)
    ]
    
    static var previewRecentTokens = [
        Token(symbol: "SOL", name: "Solana", price: 228.62, priceChange24h: -3.5, volume24h: 1_000_000, logoURI: nil),
        Token(symbol: "USDT", name: "Tether USD", price: 1.00, priceChange24h: 0.01, volume24h: 500_000, logoURI: nil),
        Token(symbol: "JitoSOL", name: "Jito Staked SOL", price: 263.83, priceChange24h: -3.54, volume24h: 750_000, logoURI: nil)
    ]
    
    static var previews: some View {
        SearchView()
            .preferredColorScheme(.dark)
            .onAppear {
                if let view = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController?.view as? UIView,
                   let searchView = view.subviews.first?.subviews.first as? SearchView {
                   // searchView.trendingTokens = previewTrendingTokens
                    searchView.recentTokens = previewRecentTokens
                }
            }
    }
} 
