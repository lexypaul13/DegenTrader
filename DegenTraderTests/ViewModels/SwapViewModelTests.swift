import XCTest
@testable import DegenTrader

// MARK: - Mock Price Service
 class MockDexScreenerService: DexScreenerAPIServiceProtocol {
    var mockPrices: [String: TokenPrice] = [:]
    var shouldFail = false
    var fetchCount = 0
    
    func fetchTokenPrices(addresses: [String]) async throws -> [String: TokenPrice] {
        if shouldFail {
            throw NetworkError.requestFailed(NSError(domain: "", code: -1))
        }
        fetchCount += 1
        return mockPrices
    }
    
    func fetchTokenDetails(chainId: String, pairId: String) async throws -> PairData? {
        return nil // Not needed for these tests
    }
}

final class SwapViewModelTests: XCTestCase {
    var viewModel: SwapViewModel!
    var mockPriceService: MockDexScreenerService!
    let testUpdateInterval: TimeInterval = 0.001 // Reduced to 1ms for testing
    
    override func setUp() {
        super.setUp()
        mockPriceService = MockDexScreenerService()
        viewModel = SwapViewModel(
            priceService: mockPriceService,
            priceUpdateInterval: testUpdateInterval,
            autoUpdate: false
        )
        
        // Verify initial state matches our test assumptions
        XCTAssertEqual(viewModel.selectedFromToken.price, 0.36)
        XCTAssertEqual(viewModel.selectedFromToken.priceChange24h, -5.28)
        XCTAssertEqual(viewModel.selectedToToken.price, 1.00)
        XCTAssertEqual(viewModel.selectedToToken.priceChange24h, 0.01)
    }
    
    override func tearDown() {
        viewModel = nil
        mockPriceService = nil
        super.tearDown()
    }
    
    // Helper method for short waits
    private func shortWait() async throws {
        try await Task.sleep(nanoseconds: UInt64(0.002 * 1_000_000_000)) // Reduced to 2ms
    }
    
    // MARK: - Price Update Tests
    
    func testUpdatePrices_ShouldUpdateTokenPrices() async throws {
        // Given
        let fromTokenAddress = "omni_token_address"
        let toTokenAddress = "usdc_token_address"
        mockPriceService.mockPrices = [
            fromTokenAddress: TokenPrice(price: 0.36, priceChange24h: -5.28),
            toTokenAddress: TokenPrice(price: 1.00, priceChange24h: 0.01)
        ]
        
        // When
        await viewModel.updatePrices()
        
        // Then - No need for shortWait since updatePrices is synchronous with our mock
        XCTAssertEqual(viewModel.selectedFromToken.price, 0.36)
        XCTAssertEqual(viewModel.selectedFromToken.priceChange24h, -5.28)
        XCTAssertEqual(viewModel.selectedToToken.price, 1.00)
        XCTAssertEqual(viewModel.selectedToToken.priceChange24h, 0.01)
    }
    
    func testUpdatePrices_ShouldRespectRateLimit() async throws {
        // Given
        let fromTokenAddress = "omni_token_address"
        mockPriceService.mockPrices = [
            fromTokenAddress: TokenPrice(price: 0.36, priceChange24h: -5.28)
        ]
        
        // When
        await viewModel.updatePrices() // First call
        let firstFetchCount = mockPriceService.fetchCount
        await viewModel.updatePrices() // Second call (should be rate limited)
        
        // Then
        XCTAssertEqual(mockPriceService.fetchCount, firstFetchCount, "Should not fetch again within rate limit period")
    }
    
    func testUpdatePrices_ShouldRecalculateAmounts() async throws {
        // Given
        let fromTokenAddress = "omni_token_address"
        let toTokenAddress = "usdc_token_address"
        mockPriceService.mockPrices = [
            fromTokenAddress: TokenPrice(price: 2.00, priceChange24h: 0),
            toTokenAddress: TokenPrice(price: 1.00, priceChange24h: 0)
        ]
        
        // Set the amount before updating prices
        viewModel.fromAmount = "1.0"
        viewModel.validateAmount("1.0") // This ensures initial calculation
        
        // Reset the lastPriceUpdateTime to bypass rate limiting
        viewModel.resetLastPriceUpdateTime()
        
        // When
        await viewModel.updatePrices()
        
        // Then
        XCTAssertEqual(viewModel.selectedFromToken.price, 2.00)
        XCTAssertEqual(viewModel.selectedToToken.price, 1.00)
        XCTAssertEqual(viewModel.toAmount, "2.00000000", "Should recalculate toAmount based on new prices")
    }
    
    // MARK: - Token Selection Tests
    
    func testUpdateSelectedTokens_ShouldUpdatePrices() async throws {
        // Given
        let newFromToken = Token(
            symbol: "TEST",
            name: "Test Token",
            price: 1.0,
            priceChange24h: 0,
            volume24h: 0,
            logoURI: nil,
            address: "test_token_address"
        )
        mockPriceService.mockPrices = [
            "test_token_address": TokenPrice(price: 1.0, priceChange24h: 0.0)
        ]
        
        // When
        viewModel.updateSelectedTokens(fromToken: newFromToken, toToken: nil)
        await viewModel.updatePrices()
        
        // Then
        XCTAssertEqual(viewModel.selectedFromToken.price, 1.0)
        XCTAssertEqual(viewModel.selectedFromToken.priceChange24h, 0.0)
    }
    
    func testUpdateSelectedTokens_ShouldRecalculateAmount() {
        // Given
        let newFromToken = Token(
            symbol: "TEST",
            name: "Test Token",
            price: 2.0,
            priceChange24h: 0,
            volume24h: 0,
            logoURI: nil,
            address: "test_token_address"
        )
        viewModel.fromAmount = "1.0"
        
        // When
        viewModel.updateSelectedTokens(fromToken: newFromToken, toToken: nil)
        
        // Then
        XCTAssertEqual(viewModel.toAmount, "2.00000000", "Should recalculate toAmount with new token price")
    }
    
    // MARK: - Amount Validation Tests
    
    func testValidateAmount_WithValidAmount_ShouldNotShowError() {
        // Given
        let validAmount = "0.5"
        
        // When
        viewModel.validateAmount(validAmount)
        
        // Then
        XCTAssertFalse(viewModel.showError)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testValidateAmount_WithAmountBelowMinimum_ShouldShowError() {
        // Given
        let belowMinAmount = "0.0000001"
        
        // When
        viewModel.validateAmount(belowMinAmount)
        
        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "Amount is below minimum of 1e-06")
    }
    
    func testValidateAmount_WithAmountAboveMaximum_ShouldShowError() {
        // Given
        let aboveMaxAmount = "2000000"
        
        // When
        viewModel.validateAmount(aboveMaxAmount)
        
        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "Amount exceeds maximum of 1000000.0")
    }
    
    func testValidateAmount_WithInsufficientBalance_ShouldShowError() {
        // Given
        let amount = "100.0"
        viewModel.selectedFromToken = Token(symbol: "OMNI", name: "Omni", price: 1.0, priceChange24h: 0, volume24h: 0, logoURI: nil, address: "omni_token_address")
        viewModel.fromAmount = amount
        
        // When
        viewModel.validateAmount(amount)
        
        // Then
        XCTAssertTrue(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "Insufficient OMNI balance")
    }
    
    // MARK: - Token Swap Validation Tests
    
    func testIsValidSwap_WithSameTokens_ShouldReturnFalse() {
        // Given
        let token = Token(symbol: "OMNI", name: "Omni", price: 1.0, priceChange24h: 0, volume24h: 0, logoURI: nil, address: "omni_token_address")
        viewModel.selectedFromToken = token
        viewModel.selectedToToken = token
        viewModel.fromAmount = "1.0"
        
        // Then
        XCTAssertFalse(viewModel.isValidSwap)
    }
    
    func testIsValidSwap_WithValidConditions_ShouldReturnTrue() {
        // Given
        viewModel.selectedFromToken = Token(symbol: "OMNI", name: "Omni", price: 1.0, priceChange24h: 0, volume24h: 0, logoURI: nil, address: "omni_token_address")
        viewModel.selectedToToken = Token(symbol: "USDC", name: "USD Coin", price: 1.0, priceChange24h: 0, volume24h: 0, logoURI: nil, address: "usdc_token_address")
        viewModel.fromAmount = "1.0"
        
        // Then
        XCTAssertTrue(viewModel.isValidSwap)
    }
    
    // MARK: - Price Calculation Tests
    
    func testCalculateToAmount_ShouldUpdateToAmountCorrectly() {
        // Given
        viewModel.selectedFromToken = Token(symbol: "OMNI", name: "Omni", price: 2.0, priceChange24h: 0, volume24h: 0, logoURI: nil, address: "omni_token_address")
        viewModel.selectedToToken = Token(symbol: "USDC", name: "USD Coin", price: 1.0, priceChange24h: 0, volume24h: 0, logoURI: nil, address: "usdc_token_address")
        
        // When
        viewModel.validateAmount("1.0") // This triggers calculateToAmount internally
        
        // Then
        XCTAssertEqual(viewModel.toAmount, "2.00000000")
    }
    
    // MARK: - USD Value Tests
    
    func testGetUSDValue_ShouldReturnCorrectFormattedValue() {
        // Given
        let token = Token(symbol: "TEST", name: "Test", price: 2.5, priceChange24h: 0, volume24h: 0, logoURI: nil)
        let amount = "2.0"
        
        // When
        let usdValue = viewModel.getUSDValue(amount: amount, token: token)
        
        // Then
        XCTAssertEqual(usdValue, "$5.00")
    }
    
    func testGetUSDValue_WithInvalidAmount_ShouldReturnZero() {
        // Given
        let token = Token(symbol: "TEST", name: "Test", price: 2.5, priceChange24h: 0, volume24h: 0, logoURI: nil)
        let invalidAmount = "invalid"
        
        // When
        let usdValue = viewModel.getUSDValue(amount: invalidAmount, token: token)
        
        // Then
        XCTAssertEqual(usdValue, "$0.00")
    }
    
    // MARK: - Error Handling Tests
    
//    func testUpdatePrices_WhenServiceFails_ShouldKeepOldPrices() async throws {
//        // Given
//        let initialFromPrice = viewModel.selectedFromToken.price
//        let initialToPrice = viewModel.selectedToToken.price
//        mockPriceService.shouldFail = true
//        
//        // When
//        viewModel.resetLastPriceUpdateTime()
//        await viewModel.updatePrices()
//        
//        // Then
//        XCTAssertEqual(viewModel.selectedFromToken.price, initialFromPrice)
//        XCTAssertEqual(viewModel.selectedToToken.price, initialToPrice)
//    }
//    
//    // MARK: - Price Update Task Tests
//    
//    func testPriceUpdateTask_ShouldUpdatePricesRegularly() async throws {
//        // Given
//        let backgroundViewModel = SwapViewModel(priceService: mockPriceService, priceUpdateInterval: testUpdateInterval, autoUpdate: true)
//        let fromTokenAddress = "omni_token_address"
//        let toTokenAddress = "usdc_token_address"
//        mockPriceService.mockPrices = [
//            fromTokenAddress: TokenPrice(price: 2.00, priceChange24h: 0),
//            toTokenAddress: TokenPrice(price: 1.00, priceChange24h: 0)
//        ]
//        
//        // When
//        await backgroundViewModel.resetLastPriceUpdateTime()
//        let initialFetchCount = mockPriceService.fetchCount
//        try await Task.sleep(nanoseconds: 10_000_000) // Wait for 10ms
//        
//        // Then
//        XCTAssertGreaterThan(mockPriceService.fetchCount, initialFetchCount)
//        backgroundViewModel.shutdown() // Explicitly shut down the background task
//    }
    
    // MARK: - Task Cancellation Tests
    
    func testShutdown_StopsBackgroundUpdates() async throws {
        // Given
        mockPriceService.fetchCount = 0
        let backgroundViewModel = SwapViewModel(
            priceService: mockPriceService,
            priceUpdateInterval: 0.001, // 1ms - still fast but not too fast
            autoUpdate: true,
            walletManager: WalletManager.shared
        )
        
        // Wait for the first update to occur
        let deadline = Date().addingTimeInterval(0.1)
        while mockPriceService.fetchCount == 0 && Date() < deadline {
            try await Task.sleep(nanoseconds: 100_000) // 0.1ms wait
        }
        
        // Verify updates are happening
        XCTAssertGreaterThan(mockPriceService.fetchCount, 0, "Background updates should have started")
        
        // When
        let fetchCountBeforeShutdown = mockPriceService.fetchCount
        backgroundViewModel.shutdown()
        
        // Wait a bit to ensure any in-flight updates complete
        try await Task.sleep(nanoseconds: 2_000_000) // 2ms wait
        
        // Then
        let finalFetchCount = mockPriceService.fetchCount
        XCTAssertEqual(
            finalFetchCount,
            fetchCountBeforeShutdown,
            "No more fetches should occur after shutdown (before: \(fetchCountBeforeShutdown), after: \(finalFetchCount))"
        )
    }
    
    func testShutdown_PreventsNewUpdates() async throws {
        // Given
        mockPriceService.fetchCount = 0
        let backgroundViewModel = SwapViewModel(
            priceService: mockPriceService,
            priceUpdateInterval: 0.0001, // 0.1ms
            autoUpdate: true
        )
        
        // When - immediately shutdown
        backgroundViewModel.shutdown()
        
        // Try to force an update
        backgroundViewModel.resetLastPriceUpdateTime()
        await backgroundViewModel.updatePrices()
        
        // Brief wait to ensure any potential updates would have occurred
        try await Task.sleep(nanoseconds: 500_000) // 0.5ms wait
        
        // Then
        XCTAssertEqual(
            mockPriceService.fetchCount,
            0,
            "Should not fetch prices after shutdown"
        )
    }
    
    // MARK: - Cache Integration Tests
    
    func testUpdatePrices_ShouldUseCachedPrices_WhenServiceFails() async throws {
        // Given
        let fromTokenAddress = "omni_token_address"
        let toTokenAddress = "usdc_token_address"
        mockPriceService.mockPrices = [
            fromTokenAddress: TokenPrice(price: 2.00, priceChange24h: 0),
            toTokenAddress: TokenPrice(price: 1.00, priceChange24h: 0)
        ]
        
        // First update to cache prices
        viewModel.resetLastPriceUpdateTime()
        await viewModel.updatePrices()
        try await shortWait()
        
        // Then make service fail
        mockPriceService.shouldFail = true
        
        // When
        viewModel.resetLastPriceUpdateTime()
        await viewModel.updatePrices()
        
        // Then
        XCTAssertEqual(viewModel.selectedFromToken.price, 2.00)
        XCTAssertEqual(viewModel.selectedToToken.price, 1.00)
    }
} 
