import SwiftUI

class SwapViewModel: ObservableObject {
    @Published var fromAmount: String = "0.001231039"
    @Published var toAmount: String = "0.000001"
    @Published var selectedFromToken = Token(symbol: "OMNI", name: "Omni", price: 0.36, priceChange24h: -5.28, volume24h: 500_000)
    @Published var selectedToToken = Token(symbol: "USDC", name: "USD Coin", price: 1.00, priceChange24h: 0.01, volume24h: 750_000)
    @Published var errorMessage: String? = nil
    
    // Mock wallet balances - In real app, these would come from wallet/API
    let walletBalances: [String: Double] = [
        "OMNI": 50.0,
        "USDC": 1000.0
    ]
    
    private let minimumAmount: Double = 0.000001
    private let maximumAmount: Double = 1000000.0
    
    var isValidAmount: Bool {
        guard let amount = Double(fromAmount) else { return false }
        return amount > 0
    }
    
    var hasInsufficientFunds: Bool {
        guard let amount = Double(fromAmount),
              let balance = walletBalances[selectedFromToken.symbol]
        else { return true }
        return amount > balance
    }
    
    var isValidSwap: Bool {
        guard let amount = Double(fromAmount) else { return false }
        return amount >= minimumAmount && amount <= maximumAmount && !hasInsufficientFunds
    }
    
    func validateAmount(_ amount: String) {
        guard let value = Double(amount) else {
            errorMessage = "Invalid amount"
            return
        }
        
        if value < minimumAmount {
            errorMessage = "Amount is below minimum of \(minimumAmount)"
        } else if value > maximumAmount {
            errorMessage = "Amount exceeds maximum of \(maximumAmount)"
        } else if hasInsufficientFunds {
            errorMessage = "Insufficient \(selectedFromToken.symbol) balance"
        } else {
            errorMessage = nil
        }
    }
    
    func swapTokens() {
        let temp = selectedFromToken
        selectedFromToken = selectedToToken
        selectedToToken = temp
        
        let tempAmount = fromAmount
        fromAmount = toAmount
        toAmount = tempAmount
        
        validateAmount(fromAmount)
    }
    
    func handleContinue() -> Bool {
        guard isValidSwap else { return false }
        // Proceed with swap
        return true
    }
    
    func getBalance(for token: Token) -> Double? {
        walletBalances[token.symbol]
    }
} 