import SwiftUI

struct SearchTokenRow: View {
    let token: Token
    let onSwapTap: () -> Void
    let onRowTap: () -> Void
    
    private var formattedPrice: String {
        if token.price < 0.00001 {
            return String(format: "$%.8f", token.price)
        } else if token.price < 0.01 {
            return String(format: "$%.6f", token.price)
        } else if token.price < 1 {
            return String(format: "$%.4f", token.price)
        } else if token.price < 1000 {
            return String(format: "$%.2f", token.price)
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: token.price)) ?? "$\(token.price)"
        }
    }
    
    private var formattedPriceChange: String {
        if abs(token.priceChange24h) < 0.01 {
            return String(format: "%.3f", token.priceChange24h)
        } else {
            return String(format: "%.2f", token.priceChange24h)
        }
    }
    
    var body: some View {
        Button(action: onRowTap) {
            HStack(spacing: 16) {
                // Token Icon with AsyncImage
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Group {
                            if let logoURI = token.logoURI {
                                CachedAsyncImage(url: URL(string: logoURI))
                                    .frame(width: 24, height: 24)
                            } else {
                                Image(token.symbol.lowercased())
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .foregroundColor(.white)
                    )
                
                // Token Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(token.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.colors.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(token.symbol)
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.colors.textSecondary)
                            .lineLimit(1)
                        
                        Text("•")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.colors.textSecondary)
                        
                        Text(formattedPrice)
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.colors.textSecondary)
                            .lineLimit(1)
                        
                        Text("\(token.priceChange24h >= 0 ? "+" : "")\(formattedPriceChange)%")
                            .font(.system(size: 15))
                            .foregroundColor(token.priceChange24h >= 0 ? AppTheme.colors.positive : AppTheme.colors.negative)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer(minLength: 16)
                
                // Swap Button
                Button(action: onSwapTap) {
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundColor(AppTheme.colors.textPrimary)
                        .padding(8)
                        .background(Circle().fill(AppTheme.colors.cardBackground))
                }
                .padding(.leading, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppTheme.colors.background)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
