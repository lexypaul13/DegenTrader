import Foundation

// Represents a single data point in the chart
struct ChartPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let price: Double
}

// Represents different time intervals for the chart
enum ChartInterval: String, CaseIterable {
    case day = "1D"
    case week = "1W"
    case month = "1M"
    case threeMonths = "3M"
    case year = "1Y"
    case all = "ALL"
}

// Mock data generator for testing
class MockChartDataGenerator {
    static func generateMockData(for interval: ChartInterval, basePrice: Double) -> [ChartPoint] {
        let calendar = Calendar.current
        let now = Date()
        var points: [ChartPoint] = []
        
        // Configure data points based on interval
        let (numberOfPoints, timeIncrement): (Int, Calendar.Component) = {
            switch interval {
            case .day:
                return (24, .hour)
            case .week:
                return (7, .day)
            case .month:
                return (30, .day)
            case .threeMonths:
                return (90, .day)
            case .year:
                return (12, .month)
            case .all:
                return (24, .month)
            }
        }()
        
        // Generate mock price data
        for i in 0..<numberOfPoints {
            let date = calendar.date(byAdding: timeIncrement, value: -i, to: now) ?? now
            let randomVariation = Double.random(in: -0.1...0.1)
            let price = basePrice * (1 + randomVariation)
            points.append(ChartPoint(timestamp: date, price: price))
        }
        
        return points.reversed()
    }
} 