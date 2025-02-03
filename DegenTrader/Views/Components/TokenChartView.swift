import SwiftUI

struct TokenChartView: View {
    let token: Token
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Price Chart")
                .font(.system(size: 24))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            // Placeholder chart view
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.colors.cardBackground)
                .frame(height: 200)
                .overlay(
                    Text("Chart Coming Soon")
                        .foregroundColor(.gray)
                )
                .padding(.horizontal)
        }
    }
}

#Preview {
    TokenChartView(
        token: Token(
            address: "So11111111111111111111111111111111111111112",
            symbol: "SOL",
            name: "Solana",
            price: 95.42,
            priceChange24h: 2.50,
            volume24h: 1_000_000,
            logoURI: nil
        )
    )
    .background(AppTheme.colors.background)
    .preferredColorScheme(.dark)
} 