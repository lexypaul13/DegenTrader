import Foundation
import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    @Published private(set) var portfolio: Portfolio
    @Published private(set) var trendingTokens: [Token]
    private let walletManager: WalletManager
    private var cancellables = Set<AnyCancellable>()
    
    init(walletManager: WalletManager) {
        print("🏗️ [DashboardViewModel] Initializing...")
        self.walletManager = walletManager
        self.portfolio = Portfolio(
            totalBalance: 0,
            tokens: [],
            profitLoss: 0,
            profitLossPercentage: 0,
            priceChangeUSD: 0
        )
        self.trendingTokens = []
        
        setupObservers()
    }
    
    private func setupObservers() {
        print("👀 [DashboardViewModel] Setting up wallet observation")
        
        // Combine multiple publishers into a single update trigger
        Publishers.CombineLatest3(
            walletManager.$balances,
            walletManager.$solPrice,
            walletManager.$solBalance
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] balances, price, solBalance in
            print("📊 [DashboardViewModel] State Update:")
            print("   Balance: \(balances["SOL"] ?? 0) SOL")
            print("   Price: $\(price)")
            print("   24h Change: \(solBalance?.priceChangePercentage ?? 0)%")
            print("   USD Value: \(solBalance?.formattedUSDValue ?? "$0.00")")
            self?.updatePortfolio()
        }
        .store(in: &cancellables)
    }
    
    func updatePortfolio() {
        let rawBalance = walletManager.balances["SOL"] ?? 0.0
        let currentPrice = walletManager.solPrice
        let previousPrice = walletManager.previousSolPrice
        let priceChangeUSD = currentPrice - previousPrice
        let priceChangePercentage = previousPrice > 0 
            ? ((currentPrice - previousPrice) / previousPrice) * 100 
            : 0
        
        let solToken = Token(
            symbol: "SOL",
            name: "Solana",
            price: currentPrice,
            priceChange24h: priceChangePercentage,
            volume24h: 0.0,
            logoURI: nil,
            address: "So11111111111111111111111111111111111111112"
        )
        
        let portfolioToken = PortfolioToken(
            token: solToken,
            amount: rawBalance,
            priceChangeUSD: priceChangeUSD
        )
        
        let totalValue = rawBalance * currentPrice
        let profitLoss = totalValue - (rawBalance * previousPrice)
        
        DispatchQueue.main.async {
            self.portfolio = Portfolio(
                totalBalance: totalValue,
                tokens: [portfolioToken],
                profitLoss: profitLoss,
                profitLossPercentage: priceChangePercentage,
                priceChangeUSD: priceChangeUSD
            )
            
            print("💼 [DashboardViewModel] Portfolio Updated:")
            print("   Total Value: \(self.portfolio.formattedTotalBalance)")
            print("   P/L: \(self.portfolio.formattedProfitLoss) (\(self.portfolio.formattedProfitLossPercentage))")
            print("   Price Change: \(self.portfolio.formattedPriceChangeUSD)")
            
            self.objectWillChange.send()
        }
    }
} 
