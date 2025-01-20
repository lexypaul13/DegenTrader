import XCTest
@testable import DegenTrader

final class JupiterAPITests: XCTestCase {
    
    var apiService: JupiterAPIService!
    var viewModel: TrendingTokensViewModel!
    
    @MainActor
    override func setUpWithError() throws {
        apiService = JupiterAPIService()
        viewModel = TrendingTokensViewModel(apiService: apiService)
    }
    
    override func tearDownWithError() throws {
        apiService = nil
        viewModel = nil
    }
    
    @MainActor
    func testFetchTrendingTokens() async throws {
        // Test API Service directly
        let tokens = try await apiService.fetchTrendingTokens()
        
        // Validate response
        XCTAssertFalse(tokens.isEmpty, "Tokens array should not be empty")
        
        if let firstToken = tokens.first {
            XCTAssertFalse(firstToken.address.isEmpty, "Token address should not be empty")
            XCTAssertFalse(firstToken.symbol.isEmpty, "Token symbol should not be empty")
        }
        
        // Print results
        print("\n=== API Test Results ===")
        print("Total tokens fetched: \(tokens.count)")
        print("\nToken Data:")
        tokens.forEach { token in
            print("""
            
            Symbol: \(token.symbol)
            Name: \(token.name)
            Volume: \(token.daily_volume.map { String(format: "$%.2f", $0) } ?? "N/A")
            Address: \(token.address)
            Created: \(token.created_at)
            Tags: \(token.tags.joined(separator: ", "))
            """)
        }
    }
    
    @MainActor
    func testViewModelIntegration() async throws {
        // Test ViewModel
        await viewModel.fetchTrendingTokens()
        
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.tokens.isEmpty)
        
        // Print ViewModel results
        print("\n=== ViewModel Test Results ===")
        print("Total tokens in ViewModel: \(viewModel.tokens.count)")
        print("Meme coins detected: \(viewModel.memeCoins.count)")
        
        print("\nMeme Coins:")
        viewModel.memeCoins.prefix(5).forEach { token in
            print("""
            
            Symbol: \(token.symbol)
            Name: \(token.name)
            Volume: \(token.daily_volume.map { String(format: "$%.2f", $0) } ?? "N/A")
            Address: \(token.address)
            Created: \(token.created_at)
            Tags: \(token.tags.joined(separator: ", "))
            """)
        }
        
        print("\nNon-Meme Coins:")
        let nonMemeCoins = Set(viewModel.tokens).subtracting(Set(viewModel.memeCoins))
        nonMemeCoins.prefix(5).forEach { token in
            print("""
            
            Symbol: \(token.symbol)
            Name: \(token.name)
            Volume: \(token.daily_volume.map { String(format: "$%.2f", $0) } ?? "N/A")
            Address: \(token.address)
            Created: \(token.created_at)
            Tags: \(token.tags.joined(separator: ", "))
            """)
        }
    }
} 
