import Foundation

enum TimeFrame: String {
    case day = "24hr"
    case hour = "1hr"
}

struct Alert: Identifiable {
    let id = UUID()
    let token: Token
    let mode: AlertMode
    let condition: PriceCondition
    let value: Double
    let timeFrame: TimeFrame?  // Only for percentage alerts
    let createdAt: Date
    var isEnabled: Bool
    
    var formattedValue: String {
        switch mode {
        case .price:
            return String(format: "Above $%.2f", value)
        case .percentage:
            let timeFrameText = timeFrame?.rawValue ?? ""
            return String(format: "Move up %.1f%% / %@", value, timeFrameText)
        }
    }
    
    var formattedTimestamp: String {
        let minutes = Int(-createdAt.timeIntervalSinceNow / 60)
        if minutes < 1 {
            return "Created Just now"
        } else if minutes == 1 {
            return "Created 1min ago"
        } else {
            return "Created \(minutes)min ago"
        }
    }
    
    init(token: Token, mode: AlertMode, condition: PriceCondition, value: Double, timeFrame: TimeFrame? = nil, isEnabled: Bool = true) {
        self.token = token
        self.mode = mode
        self.condition = condition
        self.value = value
        self.timeFrame = timeFrame
        self.createdAt = Date()
        self.isEnabled = isEnabled
    }
}

enum AlertMode: String, CaseIterable {
    case price = "Alert by Price"
    case percentage = "Alert by %"
}

enum PriceCondition {
    case under, over
    
    func description(for mode: AlertMode) -> String {
        switch self {
        case .under: return mode == .price ? "When price is under" : "When price drops"
        case .over: return mode == .price ? "When price is over" : "When price increases"
        }
    }
} 