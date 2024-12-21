import SwiftUI

struct TokenSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedToken: Token
    @State private var searchText = ""
    @State private var keyboardHeight: CGFloat = 0
    
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
                                TokenSelectRow(token: token, isSelected: token.id == selectedToken.id)
                            }
                        }
                    }
                    .padding(.bottom, keyboardHeight)
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
                            .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        keyboardHeight = keyboardFrame.height
                    }
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    keyboardHeight = 0
                }
            }
        }
    }
}

struct TokenSelectRow: View {
    let token: Token
    let isSelected: Bool
    
    var body: some View {
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
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(AppTheme.colors.accent)
                    .font(.system(size: 16, weight: .bold))
                    .padding(.leading, 8)
            }
        }
        .padding()
        .background(AppTheme.colors.cardBackground)
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