import SwiftUI

struct SwapButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(AppTheme.colors.accent)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "1C1C1E"))
                )
        }
        .padding(.vertical, -12)
        .zIndex(1)
    }
} 