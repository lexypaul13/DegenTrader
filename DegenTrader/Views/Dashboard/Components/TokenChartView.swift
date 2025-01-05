import SwiftUI
import Charts

struct TokenChartView: View {
    let token: Token
    @State private var selectedInterval: ChartInterval = .day
    @State private var selectedPoint: ChartPoint?
    @State private var chartData: [ChartPoint] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Price Display
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedPoint?.formattedPrice ?? "$\(String(format: "%.2f", token.price))")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text("+$\(String(format: "%.2f", token.price * token.priceChange24h / 100.0))")
                        .foregroundColor(Color.green)
                    
                    Text("+\(String(format: "%.2f", token.priceChange24h))%")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(Color.green)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            // Chart
            Chart {
                ForEach(chartData) { point in
                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Price", point.price)
                    )
                    .foregroundStyle(Color.green)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                }
                
                if let selectedPoint = selectedPoint {
                    PointMark(
                        x: .value("Time", selectedPoint.timestamp),
                        y: .value("Price", selectedPoint.price)
                    )
                    .foregroundStyle(Color.white)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartPlotStyle { content in
                content
                    .background(AppTheme.colors.background)
                    .padding([.bottom, .top], 0)
            }
            .frame(height: 250)
            .padding(.bottom, -32)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        updateSelectedPoint(at: value.location)
                    }
                    .onEnded { _ in
                        selectedPoint = nil
                    }
            )
            
            // Interval Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(ChartInterval.allCases, id: \.self) { interval in
                        Button(action: {
                            selectedInterval = interval
                            updateChartData()
                        }) {
                            Text(interval.title)
                                .foregroundColor(selectedInterval == interval ? .white : .gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                                .background(
                                    selectedInterval == interval ?
                                    AppTheme.colors.cardBackground : Color.clear
                                )
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            updateChartData()
        }
    }
    
    private func updateChartData() {
        chartData = MockChartDataGenerator.generateMockData(
            for: selectedInterval,
            basePrice: token.price
        )
    }
    
    private func updateSelectedPoint(at location: CGPoint) {
        guard !chartData.isEmpty else { return }
        
        let step = 250.0 / CGFloat(chartData.count - 1)
        let index = min(
            max(
                Int(location.x / step),
                0
            ),
            chartData.count - 1
        )
        selectedPoint = chartData[index]
    }
}

extension ChartPoint {
    var formattedPrice: String {
        "$\(String(format: "%.2f", price))"
    }
}

extension ChartInterval {
    var title: String {
        switch self {
        case .day: return "1D"
        case .week: return "1W"
        case .month: return "1M"
        case .threeMonths: return "3M"
        case .year: return "1Y"
        case .all: return "ALL"
        }
    }
} 
