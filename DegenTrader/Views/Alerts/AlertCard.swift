import SwiftUI

struct AlertCard: View {
    let alert: Alert
    @StateObject private var alertsManager = AlertsManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Alert Icon
            Image(systemName: "chart.line.uptrend.xyaxis")
                .foregroundColor(.green)
                .font(.system(size: 20))
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                // Alert Value
                Text(alert.formattedValue)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                
                // Timestamp
                Text(alert.formattedTimestamp)
                    .font(.system(size: 13))
                    .foregroundColor(Color(white: 0.5))
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: Binding(
                get: { alert.isEnabled },
                set: { _ in alertsManager.toggleAlert(alert) }
            ))
            .tint(.blue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(white: 0.12))
        .cornerRadius(12)
    }
}

#Preview {
    let sampleToken = Token(
        symbol: "BTC",
        name: "Bitcoin",
        price: 50000.00,
        priceChange24h: 2.5,
        volume24h: 1_500_000
    )
    
    return VStack(spacing: 16) {
        // Price alert preview
        AlertCard(alert: Alert(
            token: sampleToken,
            mode: .price,
            condition: .over,
            value: 100000.00
        ))
        
        // Percentage alert preview
        AlertCard(alert: Alert(
            token: sampleToken,
            mode: .percentage,
            condition: .over,
            value: 300.0,
            timeFrame: .day
        ))
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
} 