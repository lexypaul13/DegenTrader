import Foundation

struct TokenPrice: Codable {
    let price: Double
    let priceChange24h: Double
    let volume24h: Double?
    
    init(price: Double, priceChange24h: Double = 0.0, volume24h: Double? = nil) {
        self.price = price
        self.priceChange24h = priceChange24h
        self.volume24h = volume24h
    }
} 