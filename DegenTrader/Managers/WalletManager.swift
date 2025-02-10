import Foundation

class WalletManager: ObservableObject {
    static let shared = WalletManager()
    
    @Published private(set) var balances: [String: Double] = [:]
    @Published var transactions: [Transaction] = []
    
    private let defaults = UserDefaults.standard
    private let balanceKey = "wallet_balance"
    private let transactionsKey = "wallet_transactions"
    
    private var connection: Bool = false // In real app, this would be actual wallet connection
    
    var isConnected: Bool {
        return connection
    }
    
    init() {
        loadData()
        if balances.isEmpty {
            // Initialize with only SOL balance
            balances = [
                "SOL": 0.0
            ]
            saveData()
        }
        
        // Remove sample transactions initialization
        if transactions.isEmpty {
            transactions = []
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
    
    private func updateBalances(fromSymbol: String, toSymbol: String, fromAmount: Double, toAmount: Double) async throws {
        guard let fromBalance = balances[fromSymbol],
              fromBalance >= abs(fromAmount) else {
            throw SwapError.insufficientBalance
        }
        
        // Update balances
        balances[fromSymbol] = fromBalance - abs(fromAmount)
        balances[toSymbol] = (balances[toSymbol] ?? 0.0) + abs(toAmount)
        
        saveData()
        objectWillChange.send()
    }
    
    func connect() {
        // In real app, this would handle wallet connection
        connection = true
    }
    
    func disconnect() {
        connection = false
    }
    
    // MARK: - Swap Operations
    
    func swapSolForToken(tokenAddress: String, amount: Double) async throws {
        // In real implementation, this would:
        // 1. Get the best route from Jupiter aggregator
        // 2. Create the swap transaction
        // 3. Sign the transaction with connected wallet
        // 4. Send the transaction
        // 5. Wait for confirmation
        
        // For now, simulate network delay and update balances
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        try await updateBalances(fromSymbol: "SOL", 
                               toSymbol: tokenAddress, 
                               fromAmount: amount,
                               toAmount: amount) // In real app, this would be the actual received amount
    }
    
    func swapTokenForSol(tokenAddress: String, amount: Double) async throws {
        // Similar to swapSolForToken but in reverse
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        try await updateBalances(fromSymbol: tokenAddress,
                               toSymbol: "SOL",
                               fromAmount: amount,
                               toAmount: amount)
    }
    
    func swapTokenForToken(fromTokenAddress: String, toTokenAddress: String, amount: Double) async throws {
        // Similar to above but between two tokens
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        try await updateBalances(fromSymbol: fromTokenAddress,
                               toSymbol: toTokenAddress,
                               fromAmount: amount,
                               toAmount: amount)
    }
    
    enum SwapError: Error {
        case insufficientBalance
        
        var localizedDescription: String {
            switch self {
            case .insufficientBalance:
                return "Insufficient balance for swap"
            }
        }
    }
} 