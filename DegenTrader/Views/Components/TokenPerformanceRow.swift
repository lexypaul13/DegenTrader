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
            HStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                Text("\(String(format: "%.2f", change))%")
                    .font(.system(size: 14))
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 12)
    }
} 