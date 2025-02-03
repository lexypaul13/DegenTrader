import SwiftUI

struct TokenListRow: View {
    let token: PortfolioToken
    
    var body: some View {
        HStack(spacing: 12) {
            // Token Icon
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(token.token.symbol.lowercased())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                )
            
            // Token Info
            VStack(alignment: .leading, spacing: 4) {
                Text(token.token.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.colors.textPrimary)
                
                Text("\(token.amount, specifier: "%.5f") \(token.token.symbol)")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.colors.textSecondary)
            }
            
            Spacer()
            
            // Price Info
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(token.value, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.colors.textPrimary)
                
                Text("\(token.token.priceChange24h, specifier: "%.2f")%")
                    .font(.system(size: 14))
                    .foregroundColor(token.token.priceChange24h >= 0 ? AppTheme.colors.positive : AppTheme.colors.negative)
            }
        }
        .padding()
        .background(AppTheme.colors.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    TokenListRow(
        token: PortfolioToken(
            token: Token(
                address: "So11111111111111111111111111111111111111112",
                symbol: "SOL",
                name: "Solana",
                price: 95.42,
                priceChange24h: 2.50,
                volume24h: 1_000_000,
                logoURI: nil
            ),
            amount: 1.5
        )
    )
    .padding()
    .background(AppTheme.colors.background)
    .preferredColorScheme(.dark)
} 