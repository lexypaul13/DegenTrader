import SwiftUI

struct TokenPerformanceRow: View {
    let title: String
    let value: String
    let change: Double
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            Spacer()
            
            HStack(spacing: 12) {
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Text((change >= 0 ? "+" : "") + String(format: "%.2f%%", change))
                    .font(.system(size: 14))
                    .foregroundColor(change >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 12)
    }
}

#Preview {
    VStack(spacing: 0) {
        TokenPerformanceRow(title: "Volume", value: "$101.19", change: 106.87)
        Divider().background(Color.gray.opacity(0.3))
        TokenPerformanceRow(title: "Trades", value: "11", change: -10.00)
        Divider().background(Color.gray.opacity(0.3))
        TokenPerformanceRow(title: "Traders", value: "11", change: 37.50)
    }
    .padding()
    .background(AppTheme.colors.cardBackground)
    .preferredColorScheme(.dark)
} 