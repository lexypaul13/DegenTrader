import SwiftUI

struct TokenRowView: View {
    let symbol: String
    let name: String
    let price: Double
    let priceChange: Double
    
    var body: some View {
        HStack {
            // Token icon
            Image(symbol.lowercased())
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            // Token info
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(AppTheme.colors.textPrimary)
                Text(symbol)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.colors.textSecondary)
            }
            
            Spacer()
            
            // Price info
            VStack(alignment: .trailing) {
                Text("$\(price, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(AppTheme.colors.textPrimary)
                Text("\(priceChange, specifier: "%.2f")%")
                    .foregroundColor(priceChange >= 0 ? AppTheme.colors.positive : AppTheme.colors.negative)
            }
        }
        .padding()
        .background(AppTheme.colors.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 12) {
        TokenRowView(
            symbol: "ETH",
            name: "Ethereum",
            price: 3329.38,
            priceChange: 2.83
        )
        
        TokenRowView(
            symbol: "BTC",
            name: "Bitcoin",
            price: 1897.84,
            priceChange: -0.20
        )
    }
    .padding()
    .background(AppTheme.colors.background)
    .preferredColorScheme(.dark)
} 
