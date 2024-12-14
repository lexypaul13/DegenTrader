import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var portfolio: Portfolio
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var isLoading = false
    
    init() {
        self.portfolio = Portfolio(
            totalBalance: 23629.89,
            profitLoss: 1234.56,
            profitLossPercentage: 5.23,
            tokens: [
                PortfolioToken(
                    token: Token(symbol: "OMNI", name: "Omni", price: 0.36, priceChange24h: -5.28, volume24h: 500_000),
                    amount: 65432.1
                ),
                PortfolioToken(
                    token: Token(symbol: "USDC", name: "USD Coin", price: 1.00, priceChange24h: 0.01, volume24h: 750_000),
                    amount: 10000.0
                )
            ]
        )
    }
    
    // MARK: - Validation Methods
    
    func canPerformSwap(amount: Double, token: Token) -> Bool {
        guard !isLoading else {
            errorMessage = "Please wait for the current operation to complete"
            return false
        }
        
        guard amount > 0 else {
            errorMessage = "Amount must be greater than 0"
            return false
        }
        
        if let portfolioToken = portfolio.tokens.first(where: { $0.token.symbol == token.symbol }) {
            guard portfolioToken.amount >= amount else {
                errorMessage = "Insufficient \(token.symbol) balance"
                return false
            }
        } else {
            errorMessage = "Token not found in portfolio"
            return false
        }
        
        // Check if network is available
        guard isNetworkAvailable() else {
            errorMessage = "No internet connection"
            return false
        }
        
        // Check if trading is enabled for this token
        guard isTokenTradingEnabled(token) else {
            errorMessage = "Trading is currently disabled for \(token.symbol)"
            return false
        }
        
        return true
    }
    
    func getTokenBalance(_ symbol: String) -> Double? {
        portfolio.tokens.first(where: { $0.token.symbol == symbol })?.amount
    }
    
    // MARK: - Helper Methods
    
    private func isNetworkAvailable() -> Bool {
        // In a real app, implement actual network check
        return true
    }
    
    private func isTokenTradingEnabled(_ token: Token) -> Bool {
        // In a real app, check if trading is enabled for this token
        return true
    }
    
    // MARK: - Error Handling
    
    func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    func clearError() {
        errorMessage = nil
        showError = false
    }
    
    // MARK: - Portfolio Updates
    
    func refreshPortfolio() {
        isLoading = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isLoading = false
            // In a real app, update portfolio with fresh data
        }
    }
    
    func updateTokenAmount(_ token: Token, newAmount: Double) {
        if let index = portfolio.tokens.firstIndex(where: { $0.token.symbol == token.symbol }) {
            portfolio.tokens[index].amount = newAmount
            // Recalculate total balance
            calculateTotalBalance()
        }
    }
    
    private func calculateTotalBalance() {
        let newTotal = portfolio.tokens.reduce(0.0) { sum, token in
            sum + (token.amount * token.token.price)
        }
        portfolio.totalBalance = newTotal
    }
} 