import Foundation
import SwiftUI

class WalletManager: ObservableObject {
    static let shared = WalletManager()
    
    // MARK: - Published Properties
    @Published private(set) var balances: [String: Double] = [:]
    @Published private(set) var transactions: [Transaction] = []
    @Published internal(set) var solPrice: Double = 0.0
    @Published internal(set) var previousSolPrice: Double = 0.0
    @Published private(set) var lastPriceUpdate: Date?
    @Published private(set) var solBalance: SolTokenBalance?
    private var initialPurchasePrice: Double = 0.0
    
    // MARK: - Private Properties
    private let defaults = UserDefaults.standard
    private let balanceKey = "wallet_balance"
    private let transactionsKey = "wallet_transactions"
    internal let dexScreenerService: DexScreenerAPIServiceProtocol
    private var priceUpdateTimer: Timer?
    private let updateInterval: TimeInterval = 10 // Changed to 10 seconds for testing
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
    
    internal func updateSolPrice() async {
        do {
            let prices = try await dexScreenerService.fetchTokenPrices(
                addresses: ["So11111111111111111111111111111111111111112"]
            )
            
            await MainActor.run {
                if let solTokenPrice = prices["So11111111111111111111111111111111111111112"] {
                    let fetchedPrice = solTokenPrice.price
                    if self.solPrice > 0 && abs(self.solPrice - fetchedPrice) < 0.0001 {
                        let fluctuation = Double.random(in: -1.0...1.0)
                        print("💡 [WalletManager] Simulating price fluctuation: \(fluctuation)")
                        self.previousSolPrice = self.solPrice
                        self.solPrice = fetchedPrice + fluctuation
                    } else {
                        if self.solPrice == 0.0 && self.initialPurchasePrice == 0.0 {
                            self.initialPurchasePrice = fetchedPrice
                            self.previousSolPrice = fetchedPrice
                        } else {
                            self.previousSolPrice = self.solPrice
                        }
                        self.solPrice = fetchedPrice
                    }
                    
                    self.lastPriceUpdate = Date()
                    
                    // Update SOL balance with new prices
                    let currentBalance = self.balances["SOL"] ?? 0.0
                    self.solBalance = SolTokenBalance(
                        amount: currentBalance,
                        currentPrice: self.solPrice,
                        previousPrice: self.previousSolPrice
                    )
                    
                    objectWillChange.send()
                } else {
                    print("⚠️ [WalletManager] No SOL price data received")
                }
            }
        } catch {
            print("❌ [WalletManager] Failed to update SOL price: \(error)")
        }
    }
    
    private func saveData() {
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
                    // Data saved and verified
                    self.objectWillChange.send()
                } else {
                    print("⚠️ [WalletManager] Failed to verify saved balances")
                }
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
        let loadBlock = { [weak self] in
            guard let self = self else { return }
            
            // Load and verify balances
            if let data = self.defaults.data(forKey: self.balanceKey) {
                do {
                    let decoded = try JSONDecoder().decode([String: Double].self, from: data)
                    self.balances = decoded
                    
                    // Update SOL balance object if needed
                    if let solBalance = decoded["SOL"] {
                        self.solBalance = SolTokenBalance(
                            amount: solBalance,
                            currentPrice: self.solPrice,
                            previousPrice: self.previousSolPrice
                        )
                    }
                } catch {
                    print("❌ [WalletManager] Failed to decode balances: \(error)")
                    self.balances = [:]
                }
            } else {
                self.balances = [:]
            }
            
            // Load transactions
            if let data = self.defaults.data(forKey: self.transactionsKey) {
                do {
                    let decoded = try JSONDecoder().decode([Transaction].self, from: data)
                    self.transactions = decoded
                } catch {
                    print("❌ [WalletManager] Failed to decode transactions: \(error)")
                    self.transactions = []
                }
            } else {
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
        guard usdAmount > 0 else { 
            throw WalletError.invalidAmount 
        }
        
        do {
            let prices = try await dexScreenerService.fetchTokenPrices(
                addresses: ["So11111111111111111111111111111111111111112"]
            )
            
            guard let solTokenPrice = prices["So11111111111111111111111111111111111111112"] else {
                throw WalletError.transactionFailed
            }
            
            await MainActor.run {
                // Store initial purchase price if this is the first purchase
                if self.initialPurchasePrice == 0.0 {
                    self.initialPurchasePrice = solTokenPrice.price
                }
                
                self.previousSolPrice = self.solPrice
                self.solPrice = solTokenPrice.price
                self.lastPriceUpdate = Date()
                
                // Calculate SOL amount based on current price
                let solAmount = usdAmount / self.solPrice
                
                // Update balance
                let previousBalance = self.balances["SOL"] ?? 0.0
                let newBalance = previousBalance + solAmount
                
                // Update balances and trigger notifications
                var updatedBalances = self.balances
                updatedBalances["SOL"] = newBalance
                self.balances = updatedBalances
                
                // Update SOL balance object
                self.solBalance = SolTokenBalance(
                    amount: newBalance,
                    currentPrice: self.solPrice,
                    previousPrice: self.previousSolPrice
                )
                
                // Save data and notify of changes
                self.saveData()
                self.objectWillChange.send()
            }
        } catch {
            print("❌ [WalletManager] Transaction failed: \(error)")
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
