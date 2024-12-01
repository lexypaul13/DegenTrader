import Foundation

struct MockData {
    static let tokens = [
        Token(
            symbol: "SOL",
            name: "Solana",
            price: 1.18,
            priceChange24h: -2.48,
            volume24h: 1_000_000
        ),
        Token(
            symbol: "JEFFY",
            name: "Jeffy",
            price: 0.36,
            priceChange24h: -5.23,
            volume24h: 500_000
        ),
        Token(
            symbol: "EMG",
            name: "potSemaG",
            price: 0.0,
            priceChange24h: 0.0,
            volume24h: 0
        ),
        Token(
            symbol: "JIZZRAEL",
            name: "Jizzrael",
            price: 0.0,
            priceChange24h: 0.0,
            volume24h: 0
        ),
        Token(
            symbol: "OMNI",
            name: "GPT-4o",
            price: 0.0,
            priceChange24h: 0.0,
            volume24h: 0
        )
    ]
    
    static let portfolio = Portfolio(
        totalBalance: 1.54,
        tokens: [
            PortfolioToken(token: tokens[0], amount: 0.00503),
            PortfolioToken(token: tokens[1], amount: 10411.76494),
            PortfolioToken(token: tokens[2], amount: 779184.78955),
            PortfolioToken(token: tokens[3], amount: 49547.88144),
            PortfolioToken(token: tokens[4], amount: 23629.89647)
        ],
        profitLoss: -3.36, profitLossPercentage: 123.47
    )
} 
