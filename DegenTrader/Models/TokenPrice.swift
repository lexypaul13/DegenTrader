import Foundation

struct TokenPrice: Codable {
    let price: Double
    let priceChange24h: Double
    
    enum CodingKeys: String, CodingKey {
        case price
        case priceChange24h = "priceChange"
    }
    
    init(price: Double, priceChange24h: Double = 0.0) {
        self.price = price
        self.priceChange24h = priceChange24h
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        price = try container.decode(Double.self, forKey: .price)
        
        // Handle nested priceChange structure
        let priceChangeContainer = try container.nestedContainer(keyedBy: PriceChangeKeys.self, forKey: .priceChange24h)
        priceChange24h = try priceChangeContainer.decode(Double.self, forKey: .h24)
    }
    
    private enum PriceChangeKeys: String, CodingKey {
        case h24
    }
} 