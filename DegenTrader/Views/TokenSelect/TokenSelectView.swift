import SwiftUI

struct TokenSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var walletManager = WalletManager.shared
    @Binding var selectedToken: Token
    @State private var searchText = ""
    
    private let tokens: [Token] = [
        Token(symbol: "SOL", name: "Solana", price: 1.18, priceChange24h: -2.41, volume24h: 1_000_000),
        Token(symbol: "BONK", name: "Bonk", price: 0.000001, priceChange24h: 15.28, volume24h: 500_000),
        Token(symbol: "JIFFY", name: "Jiffy", price: 0.36, priceChange24h: -5.23, volume24h: 300_000),
        Token(symbol: "PST", name: "pSt5mxG", price: 0.00, priceChange24h: 0.00, volume24h: 100_000),
        Token(symbol: "JIZZ", name: "Jizzwel", price: 0.00, priceChange24h: 0.00, volume24h: 50_000),
        Token(symbol: "BTC", name: "Bitcoin", price: 43250.82, priceChange24h: 2.15, volume24h: 2_000_000),
        Token(symbol: "ETH", name: "Ethereum", price: 2285.64, priceChange24h: 1.87, volume24h: 1_500_000),
        Token(symbol: "ADA", name: "Cardano", price: 0.58, priceChange24h: -3.42, volume24h: 800_000),
        Token(symbol: "USDC", name: "USD Coin", price: 1.00, priceChange24h: 0.01, volume24h: 750_000)
    ]
    
    private var filteredTokens: [Token] {
        if searchText.isEmpty {
            return tokens
        }
        return tokens.filter { $0.name.lowercased().contains(searchText.lowercased()) || 
                             $0.symbol.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    SearchBarView(text: $searchText, showFilterMenu: .constant(false), isFilterActive: .constant(false))
                        .padding()
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredTokens) { token in
                                Button(action: {
                                    selectedToken = token
                                    dismiss()
                                }) {
                                    HStack(spacing: 12) {
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
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            HStack(spacing: 4) {
                                                if let balance = walletManager.balances[token.symbol] {
                                                    Text(String(format: "%.4f", balance))
                                                        .foregroundColor(Color(white: 0.6))
                                                }
                                                Text(token.symbol)
                                                    .foregroundColor(Color(white: 0.6))
                                            }
                                            .font(.system(size: 14))
                                        }
                                        
                                        Spacer()
                                        
                                        // Price Info
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("$\(token.price, specifier: "%.2f")")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                            
                                            Text("\(token.priceChange24h, specifier: "%.2f")%")
                                                .font(.system(size: 14))
                                                .foregroundColor(token.priceChange24h >= 0 ? .green : .red)
                                        }
                                    }
                                    .padding()
                                    .background(Color(white: 0.1))
                                }
                                
                                if token.id != filteredTokens.last?.id {
                                    Divider()
                                        .background(Color(white: 0.2))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Token")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
} 
