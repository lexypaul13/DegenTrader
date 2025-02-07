import SwiftUI

struct TokenChartView: View {
    let token: Token
    let chartData: [ChartDataPoint]
    @State private var selectedPeriod: TimePeriod = .day
    
    enum TimePeriod: String, CaseIterable {
        case day = "1D"
        case week = "1W"
        case month = "1M"
        case threeMonths = "3M"
        case year = "1Y"
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Price Display
            Text("$\(String(format: "%.2f", token.price))")
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(.white)
            
            // Price Change Info
            HStack(spacing: 8) {
                Text("$\(String(format: "%.2f", abs(token.price * token.priceChange24h / 100.0)))")
                    .foregroundColor(.red)
                Text("\(String(format: "%.2f", token.priceChange24h))%")
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(4)
            }
            .font(.system(size: 16))
            
            // Chart
            Path { path in
                // Example chart path - replace with actual chart data rendering
                let width = UIScreen.main.bounds.width - 32
                let height: CGFloat = 200
                let points = 100
                
                for i in 0..<points {
                    let x = CGFloat(i) * (width / CGFloat(points - 1))
                    let angle = Double(i) * .pi * 2 / Double(points)
                    let y = height/2 + sin(angle) * height/4
                    
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.yellow, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            .frame(height: 200)
            .padding(.vertical, 24)
            
            // Time Period Selectors
            HStack(spacing: 0) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period
                    }) {
                        Text(period.rawValue)
                            .font(.system(size: 16))
                            .foregroundColor(selectedPeriod == period ? .white : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .background(selectedPeriod == period ? Color.yellow.opacity(0.2) : Color.clear)
                }
            }
            .background(AppTheme.colors.cardBackground)
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}

#Preview {
    TokenChartView(
        token: Token(
            address: "JFYJQqHzMz8gJrLpHQXqE7Zi4bJh3WYqYGHgBPzptEYg",
            symbol: "JIFFY",
            name: "Jiffy",
            price: 0.36,
            priceChange24h: -5.28,
            volume24h: 500_000,
            logoURI: nil
        ),
        chartData: []
    )
    .background(AppTheme.colors.background)
    .preferredColorScheme(.dark)
} 