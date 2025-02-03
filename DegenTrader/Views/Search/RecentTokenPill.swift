import SwiftUI

struct RecentTokenPill: View {
    let token: Token
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: 24, height: 24)
                .overlay(
                    Group {
                        if let logoURI = token.logoURI,
                           let url = URL(string: logoURI) {
                            CachedTokenImage(url: url)
                        } else {
                            Image(token.symbol.lowercased())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        }
                    }
                    .foregroundColor(.white)
                )
            
            Text(token.symbol)
                .foregroundColor(AppTheme.colors.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.colors.cardBackground)
        .cornerRadius(24)
    }
}
