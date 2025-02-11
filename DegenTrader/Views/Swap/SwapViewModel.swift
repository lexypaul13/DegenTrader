import SwiftUI

class SwapViewModel: ObservableObject {
    // MARK: - Constants
    private let SOL_ADDRESS = "So11111111111111111111111111111111111111112"
    private let minimumAmount: Double = 0.000001
    private let maximumAmount: Double = 1000000.0
    
    // MARK: - Published Properties
    @Published var fromAmount: String = ""
    @Published var toAmount: String = ""
    @Published var selectedFromToken: Token
    @Published var selectedToToken: Token
    @Published var errorMessage: String? = nil
    @Published var showError = false
    @Published var isLoading = false
    @Published private(set) var tokenPrices: [String: TokenPrice] = [:]
    
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
    
    // MARK: - Computed Properties
    var solPrice: Double {
        walletManager.solPrice
    }
    
    var fromTokenBalance: Double {
        walletManager.getBalance(for: selectedFromToken.symbol)
    }
    
    var toTokenBalance: Double {
        walletManager.getBalance(for: selectedToToken.symbol)
    }
    
    var fromTokenUSDValue: String {
        let usdValue = walletManager.getUSDValue(for: selectedFromToken.symbol)
        return String(format: "$%.2f", usdValue)
    }
    
    var toTokenUSDValue: String {
        let usdValue = walletManager.getUSDValue(for: selectedToToken.symbol)
        return String(format: "$%.2f", usdValue)
    }
    
    // MARK: - Initialization
    init(priceService: DexScreenerAPIServiceProtocol = DexScreenerAPIService(),
         priceUpdateInterval: TimeInterval = 30,
         autoUpdate: Bool = true,
         walletManager: WalletManager = .shared) {
        self.priceService = priceService
        self.priceUpdateInterval = priceUpdateInterval
        self.walletManager = walletManager
        
        // Initialize with SOL as default "from" token
        self.selectedFromToken = Token(
            symbol: "SOL",
            name: "Solana",
            price: walletManager.solPrice,
            priceChange24h: 0.0,
            volume24h: 0,
            logoURI: nil,
            address: SOL_ADDRESS
        )
        
        // Initialize with USDC as default "to" token
        self.selectedToToken = Token(
            symbol: "USDC",
            name: "USD Coin",
            price: 1.00,
            priceChange24h: 0.01,
            volume24h: 750_000,
            logoURI: nil,
            address: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v"
        )
        
        if autoUpdate {
            setupPriceUpdates()
        }
        
        // Initial price update
        Task {
            await updatePrices()
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
    
    private func updatePrices() async {
        do {
            // Get addresses to fetch prices for
            var addresses = [SOL_ADDRESS]
            if selectedFromToken.address != SOL_ADDRESS {
                addresses.append(selectedFromToken.address)
            }
            if selectedToToken.address != SOL_ADDRESS {
                addresses.append(selectedToToken.address)
            }
            
            let prices = try await priceService.fetchTokenPrices(addresses: addresses)
            
            await MainActor.run {
                // Update token prices dictionary
                self.tokenPrices = prices
                
                // Update token objects with new prices
                if let solPrice = prices[SOL_ADDRESS] {
                    // Update SOL price in WalletManager
                    if selectedFromToken.symbol == "SOL" {
                        self.selectedFromToken = Token(
                            symbol: "SOL",
                            name: "Solana",
                            price: solPrice.price,
                            priceChange24h: solPrice.priceChange24h,
                            volume24h: self.selectedFromToken.volume24h,
                            logoURI: self.selectedFromToken.logoURI,
                            address: SOL_ADDRESS
                        )
                    }
                    if selectedToToken.symbol == "SOL" {
                        self.selectedToToken = Token(
                            symbol: "SOL",
                            name: "Solana",
                            price: solPrice.price,
                            priceChange24h: solPrice.priceChange24h,
                            volume24h: self.selectedToToken.volume24h,
                            logoURI: self.selectedToToken.logoURI,
                            address: SOL_ADDRESS
                        )
                    }
                }
                
                // Update other token prices if needed
                if let fromPrice = prices[selectedFromToken.address] {
                    self.selectedFromToken = Token(
                        symbol: selectedFromToken.symbol,
                        name: selectedFromToken.name,
                        price: fromPrice.price,
                        priceChange24h: fromPrice.priceChange24h,
                        volume24h: selectedFromToken.volume24h,
                        logoURI: selectedFromToken.logoURI,
                        address: selectedFromToken.address
                    )
                }
                
                if let toPrice = prices[selectedToToken.address] {
                    self.selectedToToken = Token(
                        symbol: selectedToToken.symbol,
                        name: selectedToToken.name,
                        price: toPrice.price,
                        priceChange24h: toPrice.priceChange24h,
                        volume24h: selectedToToken.volume24h,
                        logoURI: selectedToToken.logoURI,
                        address: selectedToToken.address
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
        guard let amount = Double(fromAmount) else { return false }
        return !walletManager.validateSwap(fromSymbol: selectedFromToken.symbol, amount: amount)
    }
    
    var isValidSwap: Bool {
        // First check if user has any SOL balance
        guard walletManager.hasSolBalance else { return false }
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
        
        // Check if user has any SOL first
        guard walletManager.hasSolBalance else {
            errorMessage = "You need to buy SOL first"
            showError = true
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
        // Get the latest prices from the wallet manager for SOL or token objects for others
        let fromTokenPrice = selectedFromToken.symbol == "SOL" ? walletManager.solPrice : selectedFromToken.price
        let toTokenPrice = selectedToToken.symbol == "SOL" ? walletManager.solPrice : selectedToToken.price
        
        guard fromTokenPrice > 0, toTokenPrice > 0 else {
            toAmount = "0"
            return
        }
        
        let convertedAmount = value * (fromTokenPrice / toTokenPrice)
        toAmount = String(format: "%.8f", convertedAmount)
    }
    
    func handleContinue() async {
        guard isValidSwap else {
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            try await executeSwap()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func getBalance(for token: Token) -> Double {
        return walletManager.getBalance(for: token.symbol)
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
            // Add transaction record
            walletManager.addTransaction(Transaction(
                date: Date(),
                fromToken: selectedFromToken,
                toToken: selectedToToken,
                fromAmount: amount,
                toAmount: Double(toAmount) ?? 0,
                status: .succeeded,
                source: "Swap"
            ))
            
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
} 
