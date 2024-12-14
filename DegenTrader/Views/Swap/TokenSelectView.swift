import SwiftUI

struct TokenSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedToken: Token
    @State private var searchText = ""
    
    var filteredTokens: [Token] {
        if searchText.isEmpty {
            return MockData.tokens
        }
        return MockData.tokens.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.symbol.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBarView(
                    text: $searchText,
                    showFilterMenu: .constant(false),
                    isFilterActive: .constant(false)
                )
                .padding()
                
                // Token List
                ScrollView {
                    LazyVStack(spacing: 1) {
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
                                            .foregroundColor(AppTheme.colors.textPrimary)
                                        
                                        Text(token.symbol)
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.colors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Price Info
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("$\(token.price, specifier: "%.2f")")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(AppTheme.colors.textPrimary)
                                        
                                        Text("\(token.priceChange24h, specifier: "%.2f")%")
                                            .font(.system(size: 14))
                                            .foregroundColor(token.priceChange24h >= 0 ? AppTheme.colors.positive : AppTheme.colors.negative)
                                    }
                                }
                                .padding()
                                .background(AppTheme.colors.cardBackground)
                            }
                        }
                    }
                }
            }
            .background(AppTheme.colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Select Token")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppTheme.colors.textPrimary)
                    }
                }
            }
        }
    }
}

#Preview {
    TokenSelectView(
        selectedToken: .constant(Token(
            symbol: "ETH",
            name: "Ethereum",
            price: 2285.64,
            priceChange24h: 1.87,
            volume24h: 15_000_000
        ))
    )
} 