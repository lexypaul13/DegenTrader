import Foundation
import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    @Published private(set) var portfolio: Portfolio
    @Published private(set) var trendingTokens: [Token]
    private let walletManager: WalletManager
    private var cancellables = Set<AnyCancellable>()
    
    init(walletManager: WalletManager) {
        print("🏗️ [DashboardViewModel] Initializing with WalletManager")
        self.walletManager = walletManager
        self.portfolio = Portfolio(totalBalance: 0, tokens: [], profitLoss: 0, profitLossPercentage: 0)
        self.trendingTokens = []
        
        // Update portfolio with real wallet data
        updatePortfolio()
        
        // Set up observation of specific wallet properties
        print("👀 [DashboardViewModel] Setting up wallet observation")
        
        // Combine multiple publishers into a single update trigger
        Publishers.CombineLatest3(
            walletManager.$balances,
            walletManager.$solPrice,
            walletManager.$solBalance
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] balances, price, solBalance in
            print("🔄 [DashboardViewModel] Received combined update:")
            print("Balances: \(balances)")
            print("Price: \(price)")
            print("SOL Balance: \(solBalance?.amount ?? 0.0)")
            self?.updatePortfolio()
        }
        .store(in: &cancellables)
    }
    
    func updatePortfolio() {
        print("🔄 [DashboardViewModel] Starting portfolio update")
        
        // Access balances directly from walletManager.balances
        let rawBalance = walletManager.balances["SOL"] ?? 0.0
        print("💰 [DashboardViewModel] Raw SOL balance from walletManager.balances: \(rawBalance)")
        
        let currentPrice = walletManager.solPrice
        let priceChange = ((currentPrice - walletManager.previousSolPrice) / walletManager.previousSolPrice) * 100
        
        print("📊 [DashboardViewModel] Current values:")
        print("Balance: \(rawBalance) SOL")
        print("Current Price: $\(currentPrice)")
        print("Price Change: \(priceChange)%")
        
        let solToken = Token(
            symbol: "SOL",
            name: "Solana",
            price: currentPrice,
            priceChange24h: priceChange,
            volume24h: 0.0,
            logoURI: nil,
            address: "So11111111111111111111111111111111111111112"
        )
        
        let portfolioToken = PortfolioToken(token: solToken, amount: rawBalance)
        let totalValue = rawBalance * currentPrice
        
        DispatchQueue.main.async {
            self.portfolio = Portfolio(
                totalBalance: totalValue,
                tokens: [portfolioToken],
                profitLoss: totalValue - (rawBalance * self.walletManager.previousSolPrice),
                profitLossPercentage: priceChange
            )
            
            print("✅ [DashboardViewModel] Portfolio updated:")
            print("Total Value: $\(totalValue)")
            print("Profit/Loss: $\(self.portfolio.profitLoss)")
            print("P/L %: \(self.portfolio.profitLossPercentage)%")
            
            self.objectWillChange.send()
        }
    }
} 
