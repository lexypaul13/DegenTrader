import Foundation
import Alamofire

final class TokenDetailService: TokenDetailServiceProtocol {
    private let jupiterService: JupiterAPIServiceProtocol
    private let dexScreenerService: DexScreenerAPIServiceProtocol
    private let baseURL = "https://price.jup.ag/v2"
    
    init(jupiterService: JupiterAPIServiceProtocol, dexScreenerService: DexScreenerAPIServiceProtocol) {
        self.jupiterService = jupiterService
        self.dexScreenerService = dexScreenerService
    }
    
    func fetchTokenDetails(address: String) async throws -> TokenDetail {
        // Fetch data concurrently
        async let metadata = fetchJupiterMetadata(address: address)
        async let priceData = fetchJupiterPrice(address: address)
        async let marketData = fetchDexScreenerData(address: address)
        
        // Wait for all requests to complete and combine data
        let (metadataResult, priceDataResult, marketDataResult) = try await (metadata, priceData, marketData)
        
        // Create final price data with DexScreener's price change
        let finalPriceData = TokenPriceData(
            currentPrice: priceDataResult.currentPrice,
            priceChange24h: marketDataResult.priceChange24h ?? 0,
            lastUpdated: priceDataResult.lastUpdated
        )
        
        return TokenDetail(
            metadata: metadataResult,
            priceData: finalPriceData,
            marketData: marketDataResult
        )
    }
    
    private func fetchJupiterMetadata(address: String) async throws -> TokenMetadata {
        let tokens = try await jupiterService.fetchTrendingTokens()
        guard let token = tokens.first(where: { $0.address == address }) else {
            throw TokenDetailError.tokenNotFound
        }
        
        return TokenMetadata(
            address: token.address,
            name: token.name,
            symbol: token.symbol,
            totalSupply: nil, // TODO: Fetch from additional API
            decimals: token.decimals,
            tags: token.tags,
            logoURI: token.logoURI,
            extensions: nil // TODO: Map Jupiter extensions
        )
    }
    
    private func fetchJupiterPrice(address: String) async throws -> TokenPriceData {
        return try await withCheckedThrowingContinuation { continuation in
            let endpoint = "\(baseURL)/price?ids=\(address)"
            
            AF.request(endpoint)
                .validate()
                .responseDecodable(of: JupiterPriceResponse.self) { response in
                    switch response.result {
                    case .success(let priceResponse):
                        guard let tokenPrice = priceResponse.data[address] else {
                            continuation.resume(throwing: JupiterPriceError.tokenNotFound)
                            return
                        }
                        
                        let priceData = TokenPriceData(
                            currentPrice: tokenPrice.price,
                            priceChange24h: 0, // Will be updated with DexScreener data
                            lastUpdated: Date()
                        )
                        continuation.resume(returning: priceData)
                        
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode, statusCode == 429 {
                            continuation.resume(throwing: JupiterPriceError.rateLimitExceeded)
                        } else {
                            continuation.resume(throwing: error)
                        }
                    }
                }
        }
    }
    
    private func fetchDexScreenerData(address: String) async throws -> TokenMarketData {
        let prices = try await dexScreenerService.fetchTokenPrices(addresses: [address])
        guard let tokenPrice = prices[address] else {
            throw TokenDetailError.tokenNotFound
        }
        
        return TokenMarketData(
            marketCap: nil, // TODO: Calculate from total supply and price
            volume24h: tokenPrice.volume24h,
            holders: nil,   // TODO: Fetch from additional API
            topHolders: nil,
            mintable: false,
            mutableInfo: false,
            updateAuthority: nil,
            priceChange24h: tokenPrice.priceChange24h
        )
    }
}

// MARK: - Errors
enum TokenDetailError: LocalizedError {
    case tokenNotFound
    case notImplemented
    
    var errorDescription: String? {
        switch self {
        case .tokenNotFound:
            return "Token not found"
        case .notImplemented:
            return "This feature is not implemented yet"
        }
    }
} 