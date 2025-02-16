import Foundation
import SwiftUI

class WalletManager: ObservableObject {
    static let shared = WalletManager()
    
    // MARK: - Published Properties
    @Published private(set) var balances: [String: Double] = [:]
    @Published var transactions: [Transaction] = []
    @Published private(set) var solPrice: Double = 0.0
    @Published private(set) var previousSolPrice: Double = 0.0
    @Published private(set) var lastPriceUpdate: Date?
    @Published private(set) var solBalance: SolTokenBalance?
    
    // MARK: - Private Properties
    private let defaults = UserDefaults.standard
    private let balanceKey = "wallet_balance"
    private let transactionsKey = "wallet_transactions"
    private let dexScreenerService: DexScreenerAPIServiceProtocol
    private var priceUpdateTimer: Timer?
    private let updateInterval: TimeInterval = 30 // 30 seconds
    private var connection: Bool = false
    
    // MARK: - Public Properties
    var isConnected: Bool {
        return connection
    }
    
    // MARK: - Initialization
    init(dexScreenerService: DexScreenerAPIServiceProtocol = DexScreenerAPIService()) {
        self.dexScreenerService = dexScreenerService
        loadData()
        setupPriceUpdates()
    }
    
    deinit {
        priceUpdateTimer?.invalidate()
    }
    
    // MARK: - Private Methods
    private func setupPriceUpdates() {
        // Initial update
        Task {
            await updateSolPrice()
        }
        
        // Setup timer for regular updates
        priceUpdateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.updateSolPrice()
            }
        }
    }
    
    private func updateSolPrice() async {
        do {
            let prices = try await dexScreenerService.fetchTokenPrices(
                addresses: ["So11111111111111111111111111111111111111112"]
            )
            
            await MainActor.run {
                if let solTokenPrice = prices["So11111111111111111111111111111111111111112"] {
                    // Store the previous price before updating
                    self.previousSolPrice = self.solPrice
                    self.solPrice = solTokenPrice.price
                    self.lastPriceUpdate = Date()
                    
                    // Update SOL balance with new prices
                    let currentBalance = self.balances["SOL"] ?? 0.0
                    self.solBalance = SolTokenBalance(
                        amount: currentBalance,
                        currentPrice: self.solPrice,
                        previousPrice: self.previousSolPrice
                    )
                    
                    objectWillChange.send()
                }
            }
        } catch {
            print("Failed to update SOL price: \(error)")
        }
    }
    
    private func saveData() {
        print("💾 [WalletManager] Saving data...")
        print("Current balances before save: \(balances)")
        
        if balances.isEmpty {
            print("⚠️ [WalletManager] Warning: Attempting to save empty balances")
        }
        
        let saveBlock = { [weak self] in
            guard let self = self else { return }
            do {
                let encodedBalances = try JSONEncoder().encode(self.balances)
                self.defaults.set(encodedBalances, forKey: self.balanceKey)
                
                let encodedTransactions = try JSONEncoder().encode(self.transactions)
                self.defaults.set(encodedTransactions, forKey: self.transactionsKey)
                
                // Force immediate synchronization
                self.defaults.synchronize()
                
                if let savedData = self.defaults.data(forKey: self.balanceKey),
                   let savedBalances = try? JSONDecoder().decode([String: Double].self, from: savedData) {
                    print("✅ [WalletManager] Balances saved and verified: \(savedBalances)")
                } else {
                    print("⚠️ [WalletManager] Failed to verify saved balances")
                }
                
                print("✅ [WalletManager] Transactions saved")
                
                self.objectWillChange.send()
                print("📢 [WalletManager] Notified observers after save")
            } catch {
                print("❌ [WalletManager] Failed to save data: \(error)")
            }
        }
        
        if Thread.isMainThread {
            saveBlock()
        } else {
            DispatchQueue.main.sync(execute: saveBlock)
        }
    }
    
    private func loadData() {
        print("📂 [WalletManager] Loading data...")
        
        let loadBlock = { [weak self] in
            guard let self = self else { return }
            
            // Load and verify balances
            if let data = self.defaults.data(forKey: self.balanceKey) {
                do {
                    let decoded = try JSONDecoder().decode([String: Double].self, from: data)
                    print("✅ [WalletManager] Successfully decoded balances: \(decoded)")
                    
                    self.balances = decoded
                    
                    // Update SOL balance object if needed
                    if let solBalance = decoded["SOL"] {
                        self.solBalance = SolTokenBalance(
                            amount: solBalance,
                            currentPrice: self.solPrice,
                            previousPrice: self.previousSolPrice
                        )
                    }
                    
                    print("✅ [WalletManager] Balances updated: \(decoded)")
                } catch {
                    print("❌ [WalletManager] Failed to decode balances: \(error)")
                    self.balances = [:]
                }
            } else {
                print("ℹ️ [WalletManager] No saved balances found, initializing empty")
                self.balances = [:]
            }
            
            // Load transactions
            if let data = self.defaults.data(forKey: self.transactionsKey) {
                do {
                    let decoded = try JSONDecoder().decode([Transaction].self, from: data)
                    self.transactions = decoded
                    print("✅ [WalletManager] Loaded \(decoded.count) transactions")
                } catch {
                    print("❌ [WalletManager] Failed to decode transactions: \(error)")
                    self.transactions = []
                }
            } else {
                print("ℹ️ [WalletManager] No saved transactions found")
                self.transactions = []
            }
            
            self.objectWillChange.send()
        }
        
        if Thread.isMainThread {
            loadBlock()
        } else {
            DispatchQueue.main.sync(execute: loadBlock)
        }
    }
    
    // MARK: - Public Methods
    func getBalance(for symbol: String) -> Double {
        return balances[symbol] ?? 0.0
    }
    
    func getUSDValue(for symbol: String) -> Double {
        let balance = balances[symbol] ?? 0.0
        if symbol == "SOL" {
            return balance * solPrice
        }
        // For other tokens, we'll need their prices from DexScreener
        return 0.0
    }
    
    func validateSwap(fromSymbol: String, amount: Double) -> Bool {
        guard let balance = balances[fromSymbol] else { return false }
        return balance >= amount
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.insert(transaction, at: 0)
        saveData()
        objectWillChange.send()
    }
    
    func buy(amount: Double, symbol: String) -> Bool {
        guard amount > 0 else { return false }
        
        // Update the balance
        balances[symbol] = (balances[symbol] ?? 0.0) + amount
        
        // Save immediately
        saveData()
        objectWillChange.send()
        
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
        guard validateSwap(fromSymbol: fromSymbol, amount: fromAmount) else {
            throw SwapError.insufficientBalance
        }
        
        // Update balances
        balances[fromSymbol] = (balances[fromSymbol] ?? 0) - abs(fromAmount)
        balances[toSymbol] = (balances[toSymbol] ?? 0) + abs(toAmount)
        
        saveData()
        objectWillChange.send()
    }
    
    func connect() {
        connection = true
    }
    
    func disconnect() {
        connection = false
    }
    
    // MARK: - Swap Operations
    func swapSolForToken(tokenAddress: String, amount: Double) async throws {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Simulate network delay
        try await updateBalances(fromSymbol: "SOL", 
                               toSymbol: tokenAddress, 
                               fromAmount: amount,
                               toAmount: amount)
    }
    
    func swapTokenForSol(tokenAddress: String, amount: Double) async throws {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Simulate network delay
        try await updateBalances(fromSymbol: tokenAddress,
                               toSymbol: "SOL",
                               fromAmount: amount,
                               toAmount: amount)
    }
    
    func swapTokenForToken(fromTokenAddress: String, toTokenAddress: String, amount: Double) async throws {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Simulate network delay
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
    
    // Add helper to check if user has any SOL
    var hasSolBalance: Bool {
        return (balances["SOL"] ?? 0.0) > 0
    }
    
    // Add helper to get formatted SOL balance
    var formattedSolBalance: String {
        solBalance?.formattedAmount ?? "0.00000 SOL"
    }
    
    // Add helper to get SOL balance in USD
    var solBalanceInUSD: String {
        let balance = balances["SOL"] ?? 0.0
        let usdValue = balance * solPrice
        return String(format: "$%.2f", usdValue)
    }
    
    func buySol(usdAmount: Double) async throws {
        print("🚀 [WalletManager] Starting buySol with USD amount: \(usdAmount)")
        guard usdAmount > 0 else { 
            print("❌ [WalletManager] Invalid amount: \(usdAmount)")
            throw WalletError.invalidAmount 
        }
        
        // First fetch latest SOL price to ensure accuracy
        do {
            print("🔍 [WalletManager] Fetching latest SOL price...")
            let prices = try await dexScreenerService.fetchTokenPrices(
                addresses: ["So11111111111111111111111111111111111111112"]
            )
            
            guard let solTokenPrice = prices["So11111111111111111111111111111111111111112"] else {
                print("❌ [WalletManager] Failed to get SOL price")
                throw WalletError.transactionFailed
            }
            
            await MainActor.run {
                print("💰 [WalletManager] Updating prices and balance...")
                print("Previous SOL price: \(self.solPrice)")
                print("New SOL price: \(solTokenPrice.price)")
                print("Current balances before update: \(self.balances)")
                
                // Update prices first
                self.previousSolPrice = self.solPrice
                self.solPrice = solTokenPrice.price
                self.lastPriceUpdate = Date()
                
                // Calculate SOL amount based on current price
                let solAmount = usdAmount / self.solPrice
                print("📊 [WalletManager] Calculated SOL amount: \(solAmount)")
                
                // Update balance
                let previousBalance = self.balances["SOL"] ?? 0.0
                let newBalance = previousBalance + solAmount
                print("💳 [WalletManager] Updating balance from \(previousBalance) to \(newBalance)")
                
                // Instead of updating in-place, create a new dictionary to trigger the publisher update
                var updatedBalances = self.balances
                updatedBalances["SOL"] = newBalance
                self.balances = updatedBalances

                // Explicitly trigger an update
                self.objectWillChange.send()
                
                print("Current balances after update: \(self.balances)")
                
                // Add to transactions
                let transaction = Transaction(
                    date: Date(),
                    fromToken: Token(symbol: "USD", name: "US Dollar", price: 1.0, priceChange24h: 0, volume24h: 0, logoURI: nil),
                    toToken: Token(symbol: "SOL", name: "Solana", price: self.solPrice, priceChange24h: solTokenPrice.priceChange24h, volume24h: 0, logoURI: nil),
                    fromAmount: usdAmount,
                    toAmount: solAmount,
                    status: .succeeded,
                    source: "Buy"
                )
                self.addTransaction(transaction)
                print("📝 [WalletManager] Added transaction to history")
                
                // Update SOL balance with latest price info
                self.solBalance = SolTokenBalance(
                    amount: newBalance,
                    currentPrice: self.solPrice,
                    previousPrice: self.previousSolPrice
                )
                print("✅ [WalletManager] Updated SOL balance object: \(String(describing: self.solBalance))")
                
                // Save data and notify of changes
                self.saveData()
            }
        } catch {
            print("❌ [WalletManager] Transaction failed with error: \(error)")
            throw WalletError.transactionFailed
        }
    }
    
    // MARK: - Helper Methods
    var formattedSolUSDValue: String {
        solBalance?.formattedUSDValue ?? "$0.00"
    }
    
    var formattedSolPriceChange: String {
        solBalance?.formattedPriceChange ?? "0.00%"
    }
    
    var solPriceChangeColor: Color {
        guard let change = solBalance?.priceChangePercentage else { return .gray }
        return change >= 0 ? .green : .red
    }
    
    // MARK: - Error Handling
    enum WalletError: Error, LocalizedError {
        case invalidAmount
        case insufficientBalance
        case transactionFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidAmount:
                return "Please enter a valid amount"
            case .insufficientBalance:
                return "Insufficient balance"
            case .transactionFailed:
                return "Transaction failed. Please try again"
            }
        }
    }
} 
