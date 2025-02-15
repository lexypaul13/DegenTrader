import SwiftUI

class SwapViewModel: ObservableObject {
    // MARK: - Constants
    private let SOL_ADDRESS = "So11111111111111111111111111111111111111112"
    private let minimumAmount: Double = 0.000001
    private let maximumAmount: Double = 1000000.0
    
    // MARK: - Published Properties
    @Published var fromAmount: String = ""
    @Published var toAmount: String = ""
    @Published var selectedFromToken = Token(symbol: "SOL", name: "Solana", price: 0.0, priceChange24h: 0.0, volume24h: 0, logoURI: nil, address: "So11111111111111111111111111111111111111112")
    @Published var selectedToToken = Token(symbol: "USDC", name: "USD Coin", price: 1.00, priceChange24h: 0.01, volume24h: 750_000, logoURI: nil, address: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v")
    @Published var errorMessage: String? = nil
    @Published var showError = false
    @Published var isLoading = false
    @Published private(set) var tokenPrices: [String: TokenPrice] = [:]
    @Published private(set) var solPrice: Double = 0.0
    
    // MARK: - Swap State
    @Published var swapInProgress = false
    @Published var swapSuccess = false
    @Published var swapError: String? = nil
    
    // MARK: - Private Properties
    private let walletManager: WalletManager
    private let priceService: DexScreenerAPIServiceProtocol
    private let cache = TokenCache.shared
    private var priceUpdateTask: Task<Void, Never>?
    private var lastPriceUpdateTime: Date?
    let priceUpdateInterval: TimeInterval
    private var isCancelled = false
    private let taskLock = NSLock()
    
    // MARK: - Initialization
    init(priceService: DexScreenerAPIServiceProtocol = DexScreenerAPIService(),
         priceUpdateInterval: TimeInterval = 30,
         autoUpdate: Bool = true,
         walletManager: WalletManager) {
        self.priceService = priceService
        self.priceUpdateInterval = priceUpdateInterval
        self.walletManager = walletManager
        
        // Fetch initial SOL price
        Task {
            await updateSolPrice()
            if autoUpdate {
                setupPriceUpdates()
            }
        }
    }
    
    deinit {
        print("DEBUG: SwapViewModel deinit started")
        cancelPriceUpdates()
        print("DEBUG: SwapViewModel deinit completed")
    }
    
    private func cancelPriceUpdates() {
        taskLock.lock()
        defer { taskLock.unlock() }
        
        print("DEBUG: Cancelling price updates")
        isCancelled = true
        priceUpdateTask?.cancel()
        priceUpdateTask = nil
    }
    
    private func setupPriceUpdates() {
        taskLock.lock()
        defer { taskLock.unlock() }
        
        print("DEBUG: Setting up price updates")
        // Cancel any existing task first
        cancelPriceUpdates()
        
        // Reset cancellation flag
        isCancelled = false
        
        priceUpdateTask = Task { [weak self] in
            guard let self = self else {
                print("DEBUG: Self is nil, exiting price update task")
                return
            }
            
            print("DEBUG: Starting price update task")
            
            while !Task.isCancelled && !self.isCancelled {
                do {
                    print("DEBUG: Price update loop iteration starting")
                    await self.updatePrices()
                    
                    guard !Task.isCancelled && !self.isCancelled else {
                        print("DEBUG: Task cancelled before sleep")
                        break
                    }
                    
                    try await Task.sleep(nanoseconds: UInt64(self.priceUpdateInterval * 1_000_000_000))
                    
                } catch is CancellationError {
                    print("DEBUG: Task cancelled via CancellationError")
                    break
                } catch {
                    print("DEBUG: Price update iteration error: \(error)")
                    if !Task.isCancelled && !self.isCancelled {
                        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
                    }
                }
            }
            print("DEBUG: Price update task completed")
        }
    }
    
    private func updateSolPrice() async {
        do {
            let prices = try await priceService.fetchTokenPrices(addresses: [SOL_ADDRESS])
            if let solTokenPrice = prices[SOL_ADDRESS] {
                await MainActor.run {
                    self.solPrice = solTokenPrice.price
                    self.selectedFromToken = Token(
                        symbol: "SOL",
                        name: "Solana",
                        price: solTokenPrice.price,
                        priceChange24h: solTokenPrice.priceChange24h,
                        volume24h: self.selectedFromToken.volume24h,
                        logoURI: self.selectedFromToken.logoURI,
                        address: self.SOL_ADDRESS
                    )
                }
            }
        } catch {
            print("Failed to update SOL price: \(error)")
        }
    }
    
    func updatePrices() async {
        guard !Task.isCancelled && !isCancelled else { 
            print("DEBUG: Update prices cancelled")
            return 
        }
        
        do {
            // Basic rate limiting check
            if let lastUpdate = lastPriceUpdateTime,
               Date().timeIntervalSince(lastUpdate) < priceUpdateInterval {
                print("DEBUG: Update prices skipped due to rate limiting")
                return
            }
            
            // Set last update time before making the request
            lastPriceUpdateTime = Date()
            
            // Always include SOL in the price update
            var addresses = [SOL_ADDRESS]
            if selectedFromToken.address != SOL_ADDRESS {
                addresses.append(selectedFromToken.address)
            }
            if selectedToToken.address != SOL_ADDRESS {
                addresses.append(selectedToToken.address)
            }
            
            print("DEBUG: Fetching prices for addresses: \(addresses)")
            
            guard !Task.isCancelled && !isCancelled else {
                print("DEBUG: Update cancelled before network call")
                return
            }
            
            print("DEBUG: Fetching fresh prices from service")
            tokenPrices = try await priceService.fetchTokenPrices(addresses: addresses)
            
            // Update token prices
            await MainActor.run { [weak self] in
                guard let self = self, !Task.isCancelled && !self.isCancelled else { return }
                
                // Update SOL price first
                if let solPrice = self.tokenPrices[SOL_ADDRESS] {
                    self.solPrice = solPrice.price
                }
                
                // Update selected tokens relative to SOL
                if let fromPrice = self.tokenPrices[self.selectedFromToken.address] {
                    self.selectedFromToken = Token(
                        symbol: self.selectedFromToken.symbol,
                        name: self.selectedFromToken.name,
                        price: fromPrice.price,
                        priceChange24h: fromPrice.priceChange24h,
                        volume24h: self.selectedFromToken.volume24h,
                        logoURI: self.selectedFromToken.logoURI,
                        address: self.selectedFromToken.address
                    )
                }
                
                if let toPrice = self.tokenPrices[self.selectedToToken.address] {
                    self.selectedToToken = Token(
                        symbol: self.selectedToToken.symbol,
                        name: self.selectedToToken.name,
                        price: toPrice.price,
                        priceChange24h: toPrice.priceChange24h,
                        volume24h: self.selectedToToken.volume24h,
                        logoURI: self.selectedToToken.logoURI,
                        address: self.selectedToToken.address
                    )
                }
                
                // Recalculate amounts if needed
                if let amount = Double(self.fromAmount) {
                    self.calculateToAmount(from: amount)
                }
            }
        } catch {
            print("DEBUG: Failed to update prices: \(error.localizedDescription)")
        }
    }
    
    var hasInsufficientFunds: Bool {
        guard let amount = Double(fromAmount),
              let balance = walletBalances[selectedFromToken.symbol]
        else { return false }
        return amount > balance
    }
    
    var isValidSwap: Bool {
        guard isWalletConnected else { return false }
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
        // Use latest prices from cache or token objects
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
    
    func updateSelectedTokens(fromToken: Token?, toToken: Token?) {
        if let fromToken = fromToken {
            selectedFromToken = fromToken
        }
        if let toToken = toToken {
            selectedToToken = toToken
        }
        
        // Trigger price update for new tokens
        Task {
            await updatePrices()
        }
        
        // Recalculate amounts if needed
        if let amount = Double(fromAmount) {
            calculateToAmount(from: amount)
        }
    }
    
    // For testing purposes only
    func resetLastPriceUpdateTime() {
        lastPriceUpdateTime = nil
    }
    
    // For testing purposes: Shutdown background updates
    func shutdown() {
        cancelPriceUpdates()
    }
    
    // Add swap execution method
    func executeSwap() async throws {
        guard isValidSwap else {
            throw SwapError.invalidSwap
        }
        
        swapInProgress = true
        swapError = nil
        
        do {
            // Convert amount to proper decimal places
            guard let amount = Double(fromAmount) else {
                throw SwapError.invalidAmount
            }
            
            // If swapping from SOL to token
            if selectedFromToken.symbol == "SOL" {
                try await walletManager.swapSolForToken(
                    tokenAddress: selectedToToken.address,
                    amount: amount
                )
            }
            // If swapping from token to SOL
            else if selectedToToken.symbol == "SOL" {
                try await walletManager.swapTokenForSol(
                    tokenAddress: selectedFromToken.address,
                    amount: amount
                )
            }
            // If swapping between tokens
            else {
                try await walletManager.swapTokenForToken(
                    fromTokenAddress: selectedFromToken.address,
                    toTokenAddress: selectedToToken.address,
                    amount: amount
                )
            }
            
            swapSuccess = true
            // Trigger price updates after successful swap
            await updatePrices()
            
        } catch {
            swapError = error.localizedDescription
            swapSuccess = false
        }
        
        swapInProgress = false
    }
    
    // Add error enum
    enum SwapError: Error {
        case invalidSwap
        case invalidAmount
        case insufficientBalance
        case walletNotConnected
        
        var localizedDescription: String {
            switch self {
            case .invalidSwap:
                return "Invalid swap parameters"
            case .invalidAmount:
                return "Invalid amount"
            case .insufficientBalance:
                return "Insufficient balance"
            case .walletNotConnected:
                return "Wallet not connected"
            }
        }
    }
    
    // Add helper method to check wallet connection
    var isWalletConnected: Bool {
        return walletManager.isConnected
    }
    
    // MARK: - Mock wallet balances
    let walletBalances: [String: Double] = [
        "OMNI": 50.0,
        "USDC": 1000.0,
        "ETH": 10.0
    ]
} 
