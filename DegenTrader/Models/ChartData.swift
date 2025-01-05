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
        
        // Generate mock price data with more volatility
        var currentPrice = basePrice
        let volatility = 0.15 // Increased volatility factor
        let trend = 0.02 // Slight upward trend
        
        for i in 0..<numberOfPoints {
            let date = calendar.date(byAdding: timeIncrement, value: -i, to: now) ?? now
            
            // Random walk with momentum
            let momentum = Double.random(in: -1.0...1.0)
            let randomVariation = Double.random(in: -volatility...volatility)
            let trendComponent = trend * Double(i) / Double(numberOfPoints)
            
            // Apply changes with momentum
            currentPrice *= (1.0 + randomVariation + momentum * 0.05 + trendComponent)
            
            // Ensure price doesn't go too far from base price
            let maxChange = calculateMaxAllowedPriceChange(for: interval)
            let minPrice = basePrice * (1.0 - maxChange)
            let maxPrice = basePrice * (1.0 + maxChange)
            currentPrice = min(max(currentPrice, minPrice), maxPrice)
            
            points.append(ChartPoint(timestamp: date, price: currentPrice))
        }
        
        return points.reversed()
    }
    
    private static func calculateMaxAllowedPriceChange(for interval: ChartInterval) -> Double {
        switch interval {
        case .day:
            return 0.20 // 20% max change for 24h
        case .week:
            return 0.35 // 35% max change for week
        case .month:
            return 0.50 // 50% max change for month
        case .threeMonths:
            return 0.75 // 75% max change for 3 months
        case .year:
            return 1.50 // 150% max change for year
        case .all:
            return 3.00 // 300% max change for all time
        }
    }
} 