import Foundation
import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published private(set) var portfolio: Portfolio
    @Published private(set) var trendingTokens: [Token]
    private let walletManager = WalletManager.shared
    
    private let mockTokens = [
        Token(symbol: "SOL", name: "Solana", price: 95.42, priceChange24h: 2.5, volume24h: 1_500_000),
        Token(symbol: "JIFFY", name: "Jiffy", price: 0.36, priceChange24h: -5.28, volume24h: 500_000),
        Token(symbol: "PST", name: "pSt5mxG", price: 0.00, priceChange24h: 0.00, volume24h: 750_000),
        Token(symbol: "JIZZ", name: "Jizzwel", price: 0.00, priceChange24h: 0.00, volume24h: 250_000)
    ]
    
    init() {
        // Initialize with empty portfolio
        self.portfolio = Portfolio(totalBalance: 0, tokens: [], profitLoss: 0, profitLossPercentage: 0)
        self.trendingTokens = MockData.tokens
        
        // Update portfolio with real wallet data
        updatePortfolio()
    }
    
    func updatePortfolio() {
        let portfolioTokens = mockTokens.map { token in
            let balance = walletManager.getBalance(for: token.symbol)
            return PortfolioToken(token: token, amount: balance)
        }
        
        let totalBalance = portfolioTokens.reduce(0) { $0 + ($1.token.price * $1.amount) }
        
        // For now, we'll use mock profit/loss data
        // In a real app, these would be calculated from historical data
        let profitLoss = -3.35 // Mock value
        let profitLossPercentage = -23.47 // Mock value
        
        portfolio = Portfolio(
            totalBalance: totalBalance,
            tokens: portfolioTokens,
            profitLoss: profitLoss,
            profitLossPercentage: profitLossPercentage
        )
    }
} 
