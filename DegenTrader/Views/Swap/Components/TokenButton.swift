import SwiftUI

struct TokenButton: View {
    let token: Token
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(token.symbol.lowercased())
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    )
                
                Text(token.symbol)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                
                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.colors.textSecondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.gray.opacity(0.1))
            .clipShape(Capsule())
        }
    }
} 