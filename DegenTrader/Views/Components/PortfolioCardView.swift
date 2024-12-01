import SwiftUI
import Charts

struct PortfolioCardView: View {
    let balance: Double
    let profitLoss: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.layout.spacing) {
            // Header
            Text("Portfolio")
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.textSecondary)
            
            // Balance
            HStack(alignment: .center) {
                Text("$\(balance, specifier: "%.2f")")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(AppTheme.colors.textPrimary)
                
                ProfitLossPill(percentage: profitLoss)
            }
            
            // Chart
            ChartView()
                .frame(height: 200)
        }
        .padding(20)
        .background(AppTheme.colors.cardBackground)
        .cornerRadius(20)
    }
}

struct ProfitLossPill: View {
    let percentage: Double
    
    var body: some View {
        Text("\(percentage, specifier: "+%.2f")%")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(AppTheme.colors.background)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppTheme.colors.accent)
            .cornerRadius(12)
    }
}

struct ChartView: View {
    // Mock data for the chart
    let data: [(Date, Double)] = [
        (Calendar.current.date(byAdding: .hour, value: -6, to: Date())!, 14000),
        (Calendar.current.date(byAdding: .hour, value: -5, to: Date())!, 15000),
        (Calendar.current.date(byAdding: .hour, value: -4, to: Date())!, 14500),
        (Calendar.current.date(byAdding: .hour, value: -3, to: Date())!, 15500),
        (Calendar.current.date(byAdding: .hour, value: -2, to: Date())!, 14800),
        (Calendar.current.date(byAdding: .hour, value: -1, to: Date())!, 15200),
        (Date(), 14742.78)
    ]
    
    var body: some View {
        Chart {
            ForEach(data, id: \.0) { item in
                LineMark(
                    x: .value("Time", item.0),
                    y: .value("Price", item.1)
                )
                .foregroundStyle(AppTheme.colors.accent)
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom) { _ in
                AxisGridLine()
                    .foregroundStyle(AppTheme.colors.textSecondary.opacity(0.1))
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                    .foregroundStyle(AppTheme.colors.textSecondary.opacity(0.1))
            }
        }
    }
}

#Preview {
    ZStack {
        AppTheme.colors.background
        
        PortfolioCardView(
            balance: 23403.92,
            profitLoss: 4.78
        )
        .padding()
    }
    .preferredColorScheme(.dark)
} 