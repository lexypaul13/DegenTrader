import Foundation

class WalletManager: ObservableObject {
    static let shared = WalletManager()
    
    @Published private(set) var balances: [String: Double] = [:]
    @Published var transactions: [Transaction] = []
    
    private let defaults = UserDefaults.standard
    private let balanceKey = "wallet_balance"
    private let transactionsKey = "wallet_transactions"
    
    private init() {
        loadData()
        if balances.isEmpty {
            // Initialize with default balances if none exist
            balances = [
                "SOL": 1.5,
                "USDC": 100.0,
                "BONK": 1_000_000.0
            ]
            saveData()
        }
        
        // Add sample transactions
        let sampleTransactions = [
            Transaction(
                date: Date(),
                fromToken: Token(symbol: "SOL", name: "Solana", price: 95.42, priceChange24h: 2.5, volume24h: 1_500_000),
                toToken: Token(symbol: "BONK", name: "Bonk", price: 0.000012, priceChange24h: 15.2, volume24h: 500_000),
                fromAmount: 1.5,
                toAmount: 12500000,
                status: .succeeded,
                source: "Jupiter"
            ),
            Transaction(
                date: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
                fromToken: Token(symbol: "USDC", name: "USD Coin", price: 1.0, priceChange24h: 0.01, volume24h: 2_000_000),
                toToken: Token(symbol: "SOL", name: "Solana", price: 95.42, priceChange24h: 2.5, volume24h: 1_500_000),
                fromAmount: 500,
                toAmount: 5.24,
                status: .succeeded,
                source: "Jupiter"
            ),
            Transaction(
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                fromToken: Token(symbol: "SOL", name: "Solana", price: 95.42, priceChange24h: 2.5, volume24h: 1_500_000),
                toToken: Token(symbol: "JUP", name: "Jupiter", price: 0.85, priceChange24h: -1.2, volume24h: 800_000),
                fromAmount: 2.0,
                toAmount: 220.5,
                status: .failed,
                source: "Jupiter"
            ),
            Transaction(
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                fromToken: Token(symbol: "BONK", name: "Bonk", price: 0.000012, priceChange24h: 15.2, volume24h: 500_000),
                toToken: Token(symbol: "USDC", name: "USD Coin", price: 1.0, priceChange24h: 0.01, volume24h: 2_000_000),
                fromAmount: 8500000,
                toAmount: 102,
                status: .succeeded,
                source: "Jupiter"
            )
        ]
        
        // Only set sample transactions if there are no existing ones
        if transactions.isEmpty {
            transactions = sampleTransactions
            saveData()
        }
    }
    
    private func loadData() {
        // Load balances
        if let data = defaults.data(forKey: balanceKey),
           let decoded = try? JSONDecoder().decode([String: Double].self, from: data) {
            balances = decoded
        }
        
        // Load transactions
        if let data = defaults.data(forKey: transactionsKey),
           let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = decoded
        }
    }
    
    private func saveData() {
        // Save balances
        if let encoded = try? JSONEncoder().encode(balances) {
            defaults.set(encoded, forKey: balanceKey)
        }
        
        // Save transactions
        if let encoded = try? JSONEncoder().encode(transactions) {
            defaults.set(encoded, forKey: transactionsKey)
        }
    }
    
    func getBalance(for symbol: String) -> Double {
        return balances[symbol] ?? 0.0
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.insert(transaction, at: 0)
        saveData()
        objectWillChange.send()
    }
    
    func buy(amount: Double, symbol: String) -> Bool {
        guard amount > 0 else { return false }
        balances[symbol] = (balances[symbol] ?? 0.0) + amount
        saveData()
        return true
    }
    
    func sell(amount: Double, symbol: String) -> Bool {
        guard let balance = balances[symbol], balance >= amount else {
            return false
        }
        balances[symbol] = balance - amount
        saveData()
        return true
    }
    
    func swap(fromToken: Token, toToken: Token, fromAmount: Double, toAmount: Double) -> Bool {
        guard let fromBalance = balances[fromToken.symbol],
              fromBalance >= abs(fromAmount) else {
            // Add failed transaction
            addTransaction(Transaction(
                date: Date(),
                fromToken: fromToken,
                toToken: toToken,
                fromAmount: fromAmount,
                toAmount: toAmount,
                status: .failed,
                source: "Phantom"
            ))
            return false
        }
        
        // Update balances
        balances[fromToken.symbol] = fromBalance - abs(fromAmount)
        balances[toToken.symbol] = (balances[toToken.symbol] ?? 0.0) + abs(toAmount)
        
        // Add successful transaction
        addTransaction(Transaction(
            date: Date(),
            fromToken: fromToken,
            toToken: toToken,
            fromAmount: fromAmount,
            toAmount: toAmount,
            status: .succeeded,
            source: "Phantom"
        ))
        
        saveData()
        return true
    }
    
    func resetBalance() {
        balances = [
            "SOL": 1.5,
            "USDC": 100.0,
            "BONK": 1_000_000.0
        ]
        transactions = []
        saveData()
    }
} 