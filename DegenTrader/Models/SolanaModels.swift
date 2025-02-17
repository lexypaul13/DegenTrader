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
    
    var priceChangeUSD: Double {
        currentPrice - previousPrice
    }
    
    var priceChangePercentage: Double {
        previousPrice > 0 ? ((currentPrice - previousPrice) / previousPrice) * 100 : 0
    }
    
    var formattedAmount: String {
        String(format: "%.5f SOL", amount)
    }
    
    var formattedUSDValue: String {
        String(format: "$%.2f", amount * currentPrice)
    }
    
    var formattedPriceChange: String {
        String(format: "%.2f%%", priceChangePercentage)
    }
    
    var formattedPriceChangeUSD: String {
        String(format: "$%.4f", abs(priceChangeUSD))
    }
} 
