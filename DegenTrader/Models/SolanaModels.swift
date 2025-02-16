import Foundation

struct SolTransaction: Codable, Identifiable {
    let id: UUID
    let amount: Double        // Amount in SOL
    let usdAmount: Double     // USD amount paid
    let priceAtPurchase: Double
    let date: Date
    
    var currentValue: Double {
        // This will be calculated using current SOL price from WalletManager
        WalletManager.shared.solPrice * amount
    }
    
    var profitLoss: Double {
        currentValue - usdAmount
    }
    
    var profitLossPercentage: Double {
        guard usdAmount > 0 else { return 0 }
        return (profitLoss / usdAmount) * 100
    }
    
    init(amount: Double, usdAmount: Double, priceAtPurchase: Double, date: Date = Date()) {
        self.id = UUID()
        self.amount = amount
        self.usdAmount = usdAmount
        self.priceAtPurchase = priceAtPurchase
        self.date = date
    }
}

// Helper struct for token list display
struct SolTokenBalance {
    let amount: Double
    let currentPrice: Double
    let previousPrice: Double
    
    var formattedAmount: String {
        String(format: "%.5f SOL", amount)  // Shows "2.50000 SOL"
    }
    
    var formattedUSDValue: String {
        String(format: "$%.2f", usdValue)   // Shows "$0.00"
    }
    
    var formattedPriceChange: String {
        String(format: "%.2f%%", priceChangePercentage)  // Shows "0.00%"
    }
    
    var usdValue: Double {
        amount * currentPrice
    }
    
    var priceChangePercentage: Double {
        guard previousPrice > 0 else { return 0 }
        return ((currentPrice - previousPrice) / previousPrice) * 100
    }
} 