import Foundation

struct TokenPrice: Codable {
    let price: Double
    let priceChange24h: Double
    
    init(price: Double, priceChange24h: Double = 0.0) {
        self.price = price
        self.priceChange24h = priceChange24h
    }
} 