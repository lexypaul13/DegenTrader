import Foundation

struct Token: Identifiable, Codable, Hashable {
    let symbol: String
    let name: String
    let price: Double
    let priceChange24h: Double
    let volume24h: Double
    let logoURI: String?
    
    var id: String { symbol }
    
    init(symbol: String, name: String, price: Double, priceChange24h: Double, volume24h: Double, logoURI: String?) {
        self.symbol = symbol
        self.name = name
        self.price = price
        self.priceChange24h = priceChange24h
        self.volume24h = volume24h
        self.logoURI = logoURI
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Token, rhs: Token) -> Bool {
        lhs.id == rhs.id
    }
}

struct PortfolioToken: Identifiable {
    let id = UUID()
    let token: Token
    let amount: Double
    
    var value: Double {
        token.price * amount
    }
}

struct Portfolio {
    let totalBalance: Double
    let tokens: [PortfolioToken]
    let profitLoss: Double
    let profitLossPercentage: Double

}
