import XCTest
@testable import DegenTrader

final class SearchServiceTests: XCTestCase {
    // MARK: - Mock Services
    private class MockJupiterService: JupiterAPIServiceProtocol {
        var shouldFail = false
        var tokens: [JupiterToken] = []
        
        func fetchTrendingTokens() async throws -> [JupiterToken] {
            if shouldFail {
                throw NSError(domain: "MockError", code: -1)
            }
            return tokens
        }
    }
    
    private class MockMemeCoinService: MemeCoinServiceProtocol {
        // Known meme coins for testing
        private let memeSymbols = ["BONK", "SAMO", "MEME", "WIF"]
        
        func isMemeCoin(_ token: JupiterToken) -> Bool {
            return memeSymbols.contains(token.symbol)
        }
        
        func filterMemeCoins(_ tokens: [JupiterToken]) -> [JupiterToken] {
            return tokens.filter { isMemeCoin($0) }
        }
    }
    
    // MARK: - Properties
    private var searchService: SearchService!
    private var jupiterService: MockJupiterService!
    private var memeCoinService: MockMemeCoinService!
    
    // MARK: - Test Data
    private var mockTokens: [JupiterToken] = []
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        jupiterService = MockJupiterService()
        memeCoinService = MockMemeCoinService()
        
        // Initialize mock tokens
        mockTokens = [
            JupiterToken(
                address: "addr1",
                name: "Solana",
                symbol: "SOL",
                decimals: 9,
                logoURI: nil,
                tags: ["solana"],
                daily_volume: 1000000.0,
                created_at: "2023-01-01T00:00:00.000Z",
                freeze_authority: nil,
                mint_authority: nil,
                permanent_delegate: nil,
                minted_at: nil,
                extensions: nil
            ),
            JupiterToken(
                address: "addr2",
                name: "Bonk",
                symbol: "BONK",
                decimals: 9,
                logoURI: nil,
                tags: ["meme"],
                daily_volume: 500000.0,
                created_at: "2023-01-01T00:00:00.000Z",
                freeze_authority: nil,
                mint_authority: nil,
                permanent_delegate: nil,
                minted_at: nil,
                extensions: nil
            ),
            JupiterToken(
                address: "addr3",
                name: "Friend",
                symbol: "WIF",
                decimals: 9,
                logoURI: nil,
                tags: ["meme"],
                daily_volume: 300000.0,
                created_at: "2023-01-01T00:00:00.000Z",
                freeze_authority: nil,
                mint_authority: nil,
                permanent_delegate: nil,
                minted_at: nil,
                extensions: nil
            ),
            JupiterToken(
                address: "addr4",
                name: "Samoyedcoin",
                symbol: "SAMO",
                decimals: 9,
                logoURI: nil,
                tags: ["meme"],
                daily_volume: 200000.0,
                created_at: "2023-01-01T00:00:00.000Z",
                freeze_authority: nil,
                mint_authority: nil,
                permanent_delegate: nil,
                minted_at: nil,
                extensions: nil
            ),
            JupiterToken(
                address: "addr5",
                name: "Memecoin",
                symbol: "MEME",
                decimals: 9,
                logoURI: nil,
                tags: ["meme"],
                daily_volume: 100000.0,
                created_at: "2023-01-01T00:00:00.000Z",
                freeze_authority: nil,
                mint_authority: nil,
                permanent_delegate: nil,
                minted_at: nil,
                extensions: nil
            ),
            JupiterToken(
                address: "addr6",
                name: "Test Token",
                symbol: "TEST",
                decimals: 9,
                logoURI: nil,
                tags: ["test"],
                daily_volume: 50000.0,
                created_at: "2023-01-01T00:00:00.000Z",
                freeze_authority: nil,
                mint_authority: nil,
                permanent_delegate: nil,
                minted_at: nil,
                extensions: nil
            )
        ]
        
        jupiterService.tokens = mockTokens
        searchService = SearchService(jupiterService: jupiterService, memeCoinService: memeCoinService)
    }
    
    override func tearDown() {
        searchService = nil
        jupiterService = nil
        memeCoinService = nil
        mockTokens = []
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    func testInitialization() async throws {
        // Wait for initial cache setup
        try await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
        XCTAssertTrue(searchService.isInitialized)
    }
    
    func testInitializationFailure() async throws {
        // Create a new instance with failing service
        jupiterService.shouldFail = true
        let failingService = SearchService(jupiterService: jupiterService, memeCoinService: memeCoinService)
        
        // Wait for initialization attempt
        try await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
        
        // Verify service is not initialized
        XCTAssertFalse(failingService.isInitialized)
        
        // Try to search (should handle failure gracefully)
        let results = await failingService.search(query: "test")
        XCTAssertTrue(results.isEmpty)
    }
    
    // MARK: - Search Tests
    func testSearchWithExactMatch() async {
        // Wait for initialization
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let results = await searchService.search(query: "SOL")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.symbol, "SOL")
    }
    
    func testSearchWithPartialMatch() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let results = await searchService.search(query: "coin")
        XCTAssertEqual(results.count, 2)  // Should match Samoyedcoin and Memecoin
    }
    
    func testSearchWithShortQuery() async {
        let results = await searchService.search(query: "SO")  // Less than 3 characters
        XCTAssertTrue(results.isEmpty)
    }
    
    func testSearchResultLimit() async throws {
        // Wait for initialization
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Add more test tokens that would match "Token"
        let additionalTokens = [
            JupiterToken(
                address: "addr7",
                name: "Token One",
                symbol: "TOK1",
                decimals: 9,
                logoURI: nil,
                tags: ["test"],
                daily_volume: 10000.0,
                created_at: "2023-01-01T00:00:00.000Z",
                freeze_authority: nil,
                mint_authority: nil,
                permanent_delegate: nil,
                minted_at: nil,
                extensions: nil
            ),
            JupiterToken(
                address: "addr8",
                name: "Token Two",
                symbol: "TOK2",
                decimals: 9,
                logoURI: nil,
                tags: ["test"],
                daily_volume: 20000.0,
                created_at: "2023-01-01T00:00:00.000Z",
                freeze_authority: nil,
                mint_authority: nil,
                permanent_delegate: nil,
                minted_at: nil,
                extensions: nil
            ),
            JupiterToken(
                address: "addr9",
                name: "Token Three",
                symbol: "TOK3",
                decimals: 9,
                logoURI: nil,
                tags: ["test"],
                daily_volume: 30000.0,
                created_at: "2023-01-01T00:00:00.000Z",
                freeze_authority: nil,
                mint_authority: nil,
                permanent_delegate: nil,
                minted_at: nil,
                extensions: nil
            )
        ]
        
        // Update tokens and wait for cache refresh
        jupiterService.tokens.append(contentsOf: additionalTokens)
        try await searchService.retry()  // Force a refresh
        
        // Search and verify limit
        let results = await searchService.search(query: "Token")
        XCTAssertEqual(results.count, 5)  // Should be limited to 5 results
    }
    
    // MARK: - Meme Coin Tests
    func testMemeCoinFiltering() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        let results = await searchService.search(query: "coin")
        XCTAssertTrue(results.contains { $0.symbol == "SAMO" })  // Should include SAMO as it's a meme coin
    }
    
    // MARK: - Cache Tests
    func testCacheClear() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Verify initialization
        XCTAssertTrue(searchService.isInitialized)
        
        // Clear cache
        searchService.clearCache()
        
        // Verify cache is cleared
        XCTAssertFalse(searchService.isInitialized)
        XCTAssertNil(searchService.lastUpdateTime)
    }
    
    func testRetry() async throws {
        // Create a new service instance with failing service
        jupiterService = MockJupiterService()  // Fresh instance
        jupiterService.tokens = mockTokens     // Set tokens
        jupiterService.shouldFail = true       // Set to fail
        searchService = SearchService(jupiterService: jupiterService, memeCoinService: memeCoinService)
        
        // Wait for initial failed initialization
        try await Task.sleep(nanoseconds: 1_000_000_000)
        XCTAssertFalse(searchService.isInitialized)
        
        // Fix the service
        jupiterService.shouldFail = false
        
        // Retry and verify
        try await searchService.retry()
        XCTAssertTrue(searchService.isInitialized)
        
        // Verify we can search after retry
        let results = await searchService.search(query: "Token")
        XCTAssertEqual(results.count, 1)  // Should only match "Test Token"
        XCTAssertEqual(results.first?.symbol, "TEST")
    }
    
    // MARK: - Background State Tests
    func testBackgroundStateTransition() async {
        // Wait for initial setup
        try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second
        
        // Get initial state
        let initialUpdateTime = searchService.lastUpdateTime
        XCTAssertNotNil(initialUpdateTime)
        
        // Simulate background transition
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // Short wait to ensure notification is processed
        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds
        
        // Verify no refresh happens in background by checking update time hasn't changed
        let backgroundUpdateTime = searchService.lastUpdateTime
        XCTAssertEqual(initialUpdateTime, backgroundUpdateTime)
        
        // Simulate foreground transition
        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: nil)
        
        // Short wait to ensure notification is processed
        try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds
        
        // Verify state is updated
        XCTAssertNotNil(searchService.lastUpdateTime)
    }
    
    // MARK: - Debug Tests
    func testPrintJupiterTokens() async throws {
        // Use real Jupiter service instead of mock
        let realJupiterService = JupiterAPIService()
        
        // Fetch tokens
        let tokens = try await realJupiterService.fetchTrendingTokens()
        
        print("\n=== Jupiter API Tokens (First 80) ===\n")
        print("Total tokens fetched: \(tokens.count)")
        
        tokens.prefix(80).forEach { token in
            print("""
            
            Symbol: \(token.symbol)
            Name: \(token.name)
            Address: \(token.address)
            Volume: \(token.daily_volume.map { String(format: "$%.2f", $0) } ?? "N/A")
            Created: \(token.created_at)
            Tags: \(token.tags.joined(separator: ", "))
            Decimals: \(token.decimals)
            Has Logo: \(token.logoURI != nil)
            Has Extensions: \(token.extensions != nil)
            ----------------------------------------
            """)
        }
    }
} 
