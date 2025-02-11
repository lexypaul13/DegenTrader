import Foundation

class WalletManager: ObservableObject {
    static let shared = WalletManager()
    
    // MARK: - Published Properties
    @Published private(set) var balances: [String: Double] = [:]
    @Published var transactions: [Transaction] = []
    @Published private(set) var solPrice: Double = 0.0
    @Published private(set) var lastPriceUpdate: Date?
    
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
                    self.solPrice = solTokenPrice.price
                    self.lastPriceUpdate = Date()
                }
            }
        } catch {
            print("Failed to update SOL price: \(error)")
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
        let balance = balances["SOL"] ?? 0.0
        return String(format: "%.4f SOL", balance)
    }
    
    // Add helper to get SOL balance in USD
    var solBalanceInUSD: String {
        let balance = balances["SOL"] ?? 0.0
        let usdValue = balance * solPrice
        return String(format: "$%.2f", usdValue)
    }
} 