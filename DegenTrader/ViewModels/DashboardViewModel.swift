import Foundation
import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published private(set) var portfolio: Portfolio
    @Published private(set) var trendingTokens: [Token]
    private let walletManager = WalletManager.shared
    
    private let solToken = Token(
        symbol: "SOL",
        name: "Solana",
        price: 0.0,
        priceChange24h: 0.0,
        volume24h: 0.0, logoURI: nil
    )
    
    init() {
        // Initialize with empty portfolio
        self.portfolio = Portfolio(totalBalance: 0, tokens: [], profitLoss: 0, profitLossPercentage: 0)
        self.trendingTokens = []
        
        // Update portfolio with real wallet data
        updatePortfolio()
    }
    
    func updatePortfolio() {
        let balance = walletManager.getBalance(for: solToken.symbol)
        let portfolioToken = PortfolioToken(token: solToken, amount: balance)
        
        portfolio = Portfolio(
            totalBalance: balance * solToken.price,
            tokens: [portfolioToken],
            profitLoss: 0,
            profitLossPercentage: 0
        )
    }
} 
