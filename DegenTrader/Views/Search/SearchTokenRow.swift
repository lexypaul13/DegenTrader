import SwiftUI

struct SearchTokenRow: View {
    let token: Token
    let onSwapTap: () -> Void
    
    var body: some View {
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
                
                HStack(spacing: 8) {
                    Text(token.symbol)
                        .foregroundColor(AppTheme.colors.textSecondary)
                    Text("•")
                        .foregroundColor(AppTheme.colors.textSecondary)
                    if token.price < 0.01 {
                        Text("$\(token.price, specifier: "%.8f")")
                            .foregroundColor(AppTheme.colors.textSecondary)
                    } else {
                        Text("$\(token.price, specifier: "%.2f")")
                            .foregroundColor(AppTheme.colors.textSecondary)
                    }
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
