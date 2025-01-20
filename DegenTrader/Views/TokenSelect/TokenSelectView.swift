import SwiftUI

struct TokenSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var walletManager = WalletManager.shared
    @Binding var selectedToken: Token
    @State private var searchText = ""
    
    private let tokens: [Token] = [
        Token(symbol: "SOL", name: "Solana", price: 0.0, priceChange24h: 0.0, volume24h: 0.0)
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
