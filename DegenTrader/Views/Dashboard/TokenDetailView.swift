import SwiftUI

struct TokenDetailView: View {
    let token: Token
    let amount: Double
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Token Amount Section
                VStack(spacing: 8) {
                    Text("\(amount.formatted(.number.grouping(.automatic))) \(token.symbol)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(String(format: "$%.2f", amount * token.price))
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                // Action Buttons
                HStack(spacing: 30) {
                    // Swap Button
                    Button(action: {}) {
                        VStack(spacing: 8) {
                            Capsule()
                                .fill(AppTheme.colors.cardBackground)
                                .frame(width: 100, height: 44)
                                .overlay(
                                    Image(systemName: "arrow.left.arrow.right")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                )
                            Text("Swap")
                                .font(.system(size: 14))
                                .foregroundColor(Color.gray)
                        }
                    }
                    
                    // More Button
                    Button(action: {}) {
                        VStack(spacing: 8) {
                            Capsule()
                                .fill(AppTheme.colors.cardBackground)
                                .frame(width: 100, height: 44)
                                .overlay(
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                )
                            Text("More")
                                .font(.system(size: 14))
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                
                // Price Detail Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Price Detail")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 0) {
                        // Token Header
                        HStack {
                            // Token Icon
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 40)
                            
                            Text(token.name)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("24h Price")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        // Price Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(String(format: "$%.8f", token.price))
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 8) {
                                Text(String(format: "+$%.8f", abs(token.priceChange24h)))
                                    .font(.system(size: 18))
                                    .foregroundColor(.green)
                                
                                Text(String(format: "+%.2f%%", token.priceChange24h))
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(6)
                            }
                            
                            // Price Chart Placeholder
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 100)
                                .cornerRadius(8)
                        }
                        .padding(16)
                    }
                    .background(AppTheme.colors.cardBackground)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // About Token Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("About \(token.name)")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 24) {
                        TokenInfoRow(title: "Token Name", value: "\(token.name) (\(token.symbol))")
                        TokenInfoRow(title: "Network", value: "Solana")
                        TokenInfoRow(title: "Mint", value: "8v2W...pump")
                    }
                    .padding(16)
                    .background(AppTheme.colors.cardBackground)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Transaction History Section
                TransactionHistorySection(transactions: [
                    Transaction(
                        date: Date(),
                        type: .swapped,
                        fromToken: Token(symbol: "SOL", name: "Solana", price: 1.18, priceChange24h: -2.41, volume24h: 1_000_000),
                        toToken: token,
                        fromAmount: 0.04291,
                        toAmount: 7133.29855
                    ),
                    Transaction(
                        date: Date().addingTimeInterval(-3600),
                        type: .swapped,
                        fromToken: Token(symbol: "SOL", name: "Solana", price: 1.18, priceChange24h: -2.41, volume24h: 1_000_000),
                        toToken: token,
                        fromAmount: 0.02145,
                        toAmount: 3278.46639
                    )
                ])
            }
            .padding(.bottom, 70)
        }
        .background(AppTheme.colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(token.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct TokenInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    NavigationView {
        TokenDetailView(
            token: Token(
                symbol: "JEFFY",
                name: "Jeffy",
                price: 0.00003851,
                priceChange24h: 29.05,
                volume24h: 1_000_000
            ),
            amount: 10411.76494
        )
    }
} 
