import SwiftUI
import Charts

struct TokenChartView: View {
    let token: Token
    @State private var selectedInterval: ChartInterval = .day
    @State private var chartData: [ChartPoint] = []
    @State private var selectedPoint: ChartPoint?
    
    var body: some View {
        VStack(spacing: 24) {
            // Price Display
            VStack(alignment: .leading, spacing: 8) {
                if let selectedPoint = selectedPoint {
                    Text("$\(String(format: "%.2f", selectedPoint.price))")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(selectedPoint.timestamp.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                } else {
                    Text("$\(String(format: "%.2f", token.price))")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Current Price")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            // Interval Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(ChartInterval.allCases, id: \.self) { interval in
                        Button(action: {
                            selectedInterval = interval
                            updateChartData()
                        }) {
                            Text(interval.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedInterval == interval ? .white : .gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedInterval == interval ?
                                    AppTheme.colors.accent.opacity(0.2) :
                                    Color.clear
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Chart
            Chart {
                ForEach(chartData) { point in
                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Price", point.price)
                    )
                    .foregroundStyle(AppTheme.colors.accent.gradient)
                    
                    if let selectedPoint = selectedPoint,
                       selectedPoint.id == point.id {
                        PointMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Price", point.price)
                        )
                        .foregroundStyle(AppTheme.colors.accent)
                        .symbolSize(100)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(formatAxisDate(date))
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let price = value.as(Double.self) {
                            Text("$\(String(format: "%.2f", price))")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let currentX = value.location.x
                                    guard currentX >= 0,
                                          currentX <= geometry.size.width,
                                          let date = proxy.value(atX: currentX) as Date?
                                    else {
                                        return
                                    }
                                    
                                    // Find closest point
                                    if let closest = chartData.min(by: {
                                        abs($0.timestamp.timeIntervalSince(date)) <
                                        abs($1.timestamp.timeIntervalSince(date))
                                    }) {
                                        selectedPoint = closest
                                    }
                                }
                                .onEnded { _ in
                                    selectedPoint = nil
                                }
                        )
                }
            }
            .frame(height: 300)
            .padding()
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
    
    private func formatAxisDate(_ date: Date) -> String {
        switch selectedInterval {
        case .day:
            return date.formatted(.dateTime.hour())
        case .week, .month:
            return date.formatted(.dateTime.month().day())
        case .threeMonths, .year:
            return date.formatted(.dateTime.month())
        case .all:
            return date.formatted(.dateTime.year())
        }
    }
} 