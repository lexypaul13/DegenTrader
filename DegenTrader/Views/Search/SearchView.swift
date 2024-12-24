import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var showSwapView = false
    @State private var selectedToken: Token?
    
    // Mock recent tokens
    let recentTokens = [
        Token(symbol: "SOL", name: "Solana", price: 228.62, priceChange24h: -3.5, volume24h: 1_000_000),
        Token(symbol: "USDT", name: "Tether USD", price: 1.00, priceChange24h: 0.01, volume24h: 500_000),
        Token(symbol: "JitoSOL", name: "Jito Staked SOL", price: 263.83, priceChange24h: -3.54, volume24h: 750_000)
    ]
    
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
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Recents")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.colors.textPrimary)
                                    .padding(.vertical, 2)
                                
                                Spacer()
                                
                                Button("Clear") {
                                    // Clear action
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
                        
                        // Tokens List
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Tokens")
                                .font(.title2)
                                .foregroundColor(AppTheme.colors.textPrimary)
                                .padding(.horizontal)
                            
                            VStack(spacing: 1) {
                                ForEach(MockData.searchTokens) { token in
                                    SearchTokenRow(token: token) {
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
            Image(token.symbol.lowercased())
                .resizable()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
            
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
            Image(token.symbol.lowercased())
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
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
                    Text("$\(token.price, specifier: "%.2f")")
                        .foregroundColor(AppTheme.colors.textSecondary)
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

#Preview {
    SearchView()
        .preferredColorScheme(.dark)
} 
