import SwiftUI

class SwapViewModel: ObservableObject {
    @Published var fromAmount: String = ""
    @Published var toAmount: String = ""
    @Published var selectedFromToken = Token(symbol: "OMNI", name: "Omni", price: 0.36, priceChange24h: -5.28, volume24h: 500_000, logoURI: nil)
    @Published var selectedToToken = Token(symbol: "USDC", name: "USD Coin", price: 1.00, priceChange24h: 0.01, volume24h: 750_000, logoURI: nil)
    @Published var errorMessage: String? = nil
    @Published var showError = false
    @Published var isLoading = false
    
    // Mock wallet balances - In real app, these would come from wallet/API
    let walletBalances: [String: Double] = [
        "OMNI": 50.0,
        "USDC": 1000.0,
        "ETH": 10.0
    ]
    
    private let minimumAmount: Double = 0.000001
    private let maximumAmount: Double = 1000000.0
    
    var hasInsufficientFunds: Bool {
        guard let amount = Double(fromAmount),
              let balance = walletBalances[selectedFromToken.symbol]
        else { return false }
        return amount > balance
    }
    
    var isValidSwap: Bool {
        guard let amount = Double(fromAmount) else { return false }
        return amount >= minimumAmount && 
               amount <= maximumAmount && 
               !hasInsufficientFunds &&
               selectedFromToken.symbol != selectedToToken.symbol &&
               isTokenTradingEnabled(selectedFromToken) &&
               isTokenTradingEnabled(selectedToToken)
    }
    
    func validateAmount(_ amount: String) {
        guard !amount.isEmpty else {
            errorMessage = nil
            showError = false
            return
        }
        
        guard let value = Double(amount) else {
            errorMessage = "Invalid amount"
            showError = true
            return
        }
        
        if value < minimumAmount {
            errorMessage = "Amount is below minimum of \(minimumAmount)"
            showError = true
        } else if value > maximumAmount {
            errorMessage = "Amount exceeds maximum of \(maximumAmount)"
            showError = true
        } else if hasInsufficientFunds {
            errorMessage = "Insufficient \(selectedFromToken.symbol) balance"
            showError = true
        } else if selectedFromToken.symbol == selectedToToken.symbol {
            errorMessage = "Cannot swap same token"
            showError = true
        } else if !isTokenTradingEnabled(selectedFromToken) {
            errorMessage = "Trading is currently disabled for \(selectedFromToken.symbol)"
            showError = true
        } else if !isTokenTradingEnabled(selectedToToken) {
            errorMessage = "Trading is currently disabled for \(selectedToToken.symbol)"
            showError = true
        } else {
            errorMessage = nil
            showError = false
            calculateToAmount(from: value)
        }
    }
    
    private func calculateToAmount(from value: Double) {
        // In a real app, this would use actual exchange rates and liquidity pools
        let fromTokenPrice = selectedFromToken.price
        let toTokenPrice = selectedToToken.price
        let convertedAmount = value * (fromTokenPrice / toTokenPrice)
        toAmount = String(format: "%.8f", convertedAmount)
    }
    
    func handleContinue() -> Bool {
        guard isValidSwap else {
            showError = true
            return false
        }
        
        isLoading = true
        // In a real app, perform the swap transaction here
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isLoading = false
            // Handle success/failure
        }
        return true
    }
    
    func getBalance(for token: Token) -> Double? {
        walletBalances[token.symbol]
    }
    
    private func isTokenTradingEnabled(_ token: Token) -> Bool {
        // In a real app, check if trading is enabled for this token
        return true
    }
    
    func getUSDValue(amount: String, token: Token) -> String {
        guard let value = Double(amount) else { return "$0.00" }
        let usdValue = value * token.price
        return String(format: "$%.2f", usdValue)
    }
} 
