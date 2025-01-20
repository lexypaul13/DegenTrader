import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var showSwapView = false
    @State private var selectedToken: Token?
    
    // TODO: Replace with live data
    @State public var trendingTokens: [Token] = []
    @State public var recentTokens: [Token] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.colors.textSecondary)
                            .font(.system(size: 16))
                        
                        TextField("Search", text: $searchText)
                            .foregroundColor(AppTheme.colors.textPrimary)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(hex: "1C1C1E"))
                    .cornerRadius(16)
                    
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.colors.textPrimary)
                    .font(.system(size: 16))
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                ScrollView {
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
                            Text("Trending Tokens")
                                .font(.title2)
                                .foregroundColor(AppTheme.colors.textPrimary)
                                .padding(.horizontal)
                            
                            VStack(spacing: 1) {
                                ForEach(trendingTokens) { token in
                                    SearchTokenRow(token: token) {
                                        if !recentTokens.contains(where: { $0.id == token.id }) {
                                            recentTokens.insert(token, at: 0)
                                            if recentTokens.count > 5 {
                                                recentTokens.removeLast()
                                            }
                                        }
                                        selectedToken = token
                                        showSwapView = true
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .background(AppTheme.colors.background)
            .navigationDestination(isPresented: $showSwapView) {
                if let token = selectedToken {
                    SwapView(selectedFromToken: token)
                }
            }
        }
    }
}

struct RecentTokenPill: View {
    let token: Token
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: 24, height: 24)
                .overlay(
                    Image(token.symbol.lowercased())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.white)
                )
            
            Text(token.symbol)
                .foregroundColor(AppTheme.colors.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.colors.cardBackground)
        .cornerRadius(24)
    }
}

struct SearchTokenRow: View {
    let token: Token
    let onSwapTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Token Icon
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(token.symbol.lowercased())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                )
            
            // Token Info
            VStack(alignment: .leading, spacing: 4) {
                Text(token.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.colors.textPrimary)
                
                HStack(spacing: 8) {
                    Text(token.symbol)
                        .foregroundColor(AppTheme.colors.textSecondary)
                    Text("•")
                        .foregroundColor(AppTheme.colors.textSecondary)
                    if token.price < 0.01 {
                        Text("$\(token.price, specifier: "%.8f")")
                            .foregroundColor(AppTheme.colors.textSecondary)
                    } else {
                        Text("$\(token.price, specifier: "%.2f")")
                            .foregroundColor(AppTheme.colors.textSecondary)
                    }
                    Text("\(token.priceChange24h >= 0 ? "+" : "")\(token.priceChange24h, specifier: "%.2f")%")
                        .foregroundColor(token.priceChange24h >= 0 ? AppTheme.colors.positive : AppTheme.colors.negative)
                }
                .font(.system(size: 15))
            }
            
            Spacer()
            
            // Swap Button
            Button(action: onSwapTap) {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundColor(AppTheme.colors.textPrimary)
                    .padding(8)
                    .background(Circle().fill(AppTheme.colors.cardBackground))
            }
        }
        .padding()
        .background(AppTheme.colors.background)
    }
}

// MARK: - Preview
struct SearchView_Previews: PreviewProvider {
    static var previewTrendingTokens = [
        Token(symbol: "TRUMP", name: "OFFICIAL TRUMP", price: 49.00, priceChange24h: 41.95, volume24h: 0),
        Token(symbol: "MELANIA", name: "Melania Meme", price: 8.01, priceChange24h: 7.8, volume24h: 0),
        Token(symbol: "USA", name: "American Coin", price: 0.00001309, priceChange24h: 212.75, volume24h: 0),
        Token(symbol: "MR BEAST", name: "OFFICIAL MR BEAST", price: 0.00165924, priceChange24h: 21974.04, volume24h: 0),
        Token(symbol: "ELON", name: "Official Elon Coin", price: 0.0345, priceChange24h: -58.88, volume24h: 0),
        Token(symbol: "SATOSHI", name: "Official Satoshi Coin", price: 0.00257009, priceChange24h: 2190.45, volume24h: 0),
        Token(symbol: "$1", name: "just buy $1 worth of this coin", price: 0.0476, priceChange24h: 1781.16, volume24h: 0)
    ]
    
    static var previewRecentTokens = [
        Token(symbol: "SOL", name: "Solana", price: 228.62, priceChange24h: -3.5, volume24h: 1_000_000),
        Token(symbol: "USDT", name: "Tether USD", price: 1.00, priceChange24h: 0.01, volume24h: 500_000),
        Token(symbol: "JitoSOL", name: "Jito Staked SOL", price: 263.83, priceChange24h: -3.54, volume24h: 750_000)
    ]
    
    static var previews: some View {
        SearchView()
            .preferredColorScheme(.dark)
            .onAppear {
                if let view = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController?.view as? UIView,
                   let searchView = view.subviews.first?.subviews.first as? SearchView {
                    searchView.trendingTokens = previewTrendingTokens
                    searchView.recentTokens = previewRecentTokens
                }
            }
    }
} 
