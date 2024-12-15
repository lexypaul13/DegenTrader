import Foundation

struct Token: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: Double
    let priceChange24h: Double
    let volume24h: Double
    
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
