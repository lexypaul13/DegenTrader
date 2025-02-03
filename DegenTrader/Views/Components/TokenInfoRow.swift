import SwiftUI

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
        .padding(.vertical, 12)
    }
}

#Preview {
    VStack(spacing: 0) {
        TokenInfoRow(title: "Mint", value: "8v2W...pump")
        Divider().background(Color.gray.opacity(0.3))
        TokenInfoRow(title: "Market Cap", value: "$18.23K")
        Divider().background(Color.gray.opacity(0.3))
        TokenInfoRow(title: "Total Supply", value: "999.11M")
    }
    .padding()
    .background(AppTheme.colors.cardBackground)
    .preferredColorScheme(.dark)
} 