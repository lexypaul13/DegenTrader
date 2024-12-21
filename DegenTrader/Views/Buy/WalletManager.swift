import Foundation

class WalletManager: ObservableObject {
    static let shared = WalletManager()
    
    @Published private(set) var balance: [String: Double] = [:]
    private let defaults = UserDefaults.standard
    private let balanceKey = "wallet_balance"
    
    private init() {
        loadBalance()
        if balance.isEmpty {
            // Initialize with 100 SOL if no balance exists
            balance["SOL"] = 100.0
            saveBalance()
        }
    }
    
    private func loadBalance() {
        if let data = defaults.data(forKey: balanceKey),
           let decoded = try? JSONDecoder().decode([String: Double].self, from: data) {
            balance = decoded
        }
    }
    
    private func saveBalance() {
        if let encoded = try? JSONEncoder().encode(balance) {
            defaults.set(encoded, forKey: balanceKey)
        }
    }
    
    func getBalance(for symbol: String) -> Double {
        return balance[symbol] ?? 0.0
    }
    
    func canBuy(amount: Double, symbol: String) -> Bool {
        return amount <= getBalance(for: symbol)
    }
    
    @discardableResult
    func buy(amount: Double, symbol: String) -> Bool {
        guard amount > 0 else { return false }
        
        let currentBalance = getBalance(for: symbol)
        balance[symbol] = currentBalance + amount
        saveBalance()
        return true
    }
    
    func resetBalance() {
        balance = ["SOL": 100.0]
        saveBalance()
    }
} 
