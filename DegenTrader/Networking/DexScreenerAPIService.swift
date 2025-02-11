import Foundation
import Alamofire

// MARK: - Protocol
protocol DexScreenerAPIServiceProtocol {
    func fetchTokenPrices(addresses: [String]) async throws -> [String: TokenPrice]
    func fetchTokenDetails(chainId: String, pairId: String) async throws -> PairData?
}

// MARK: - Implementation
final class DexScreenerAPIService: DexScreenerAPIServiceProtocol, @unchecked Sendable {
    private let baseURL = "https://api.dexscreener.com"
    private let chainId = "solana"
    private let cache = TokenCache.shared
    private let rateLimiter = RateLimiter()
    private let maxRetries = 3
    
    private func performRequestWithRetry<T: Decodable>(
        _ endpoint: String,
        method: HTTPMethod,
        parameters: Parameters?,
        retryCount: Int = 0
    ) async throws -> T {
        // Check cache first
        if let cached: T = cache.get(forKey: endpoint) {
            return cached
        }
        
        // Wait for rate limiter
        try await rateLimiter.waitForNextAllowedRequest()
        
        let url = "\(baseURL)\(endpoint)"
        
        do {
            return try await withCheckedThrowingContinuation { continuation in
                AF.request(url, method: method, parameters: parameters)
                    .validate()
                    .responseDecodable(of: T.self) { [weak self] response in
                        guard let self = self else { return }
                        
                        switch response.result {
                        case .success(let value):
                            // Cache the successful response
                            self.cache.set(value, forKey: endpoint)
                            continuation.resume(returning: value)
                            
                        case .failure(let error):
                            if let statusCode = response.response?.statusCode {
                                switch statusCode {
                                case 429: // Rate limit exceeded
                                    continuation.resume(throwing: NetworkError.rateLimitExceeded)
                                case 500...599: // Server errors
                                    continuation.resume(throwing: NetworkError.serverError(statusCode))
                                default:
                                    continuation.resume(throwing: NetworkError.requestFailed(error))
                                }
                            } else {
                                continuation.resume(throwing: NetworkError.requestFailed(error))
                            }
                        }
                    }
            }
        } catch {
            // Handle retries
            if retryCount < maxRetries {
                // Exponential backoff: 2^retryCount seconds
                let delay = pow(2.0, Double(retryCount))
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await performRequestWithRetry(
                    endpoint,
                    method: method,
                    parameters: parameters,
                    retryCount: retryCount + 1
                )
            }
            throw error
        }
    }
    
    func fetchTokenPrices(addresses: [String]) async throws -> [String: TokenPrice] {
        let endpoint = "/latest/dex/tokens/\(addresses.joined(separator: ","))"
        
        let response: DexScreenerResponse = try await performRequestWithRetry(
            endpoint,
            method: .get,
            parameters: nil
        )
        
        // Convert responses to TokenPrice dictionary using baseToken.address as key
        var prices: [String: TokenPrice] = [:]
        for pair in response.pairs ?? [] {
            prices[pair.baseToken.address] = TokenPrice(
                price: pair.usdPrice,
                priceChange24h: pair.priceChange.h24
            )
        }
        
        return prices
    }
    
    func fetchTokenDetails(chainId: String, pairId: String) async throws -> PairData? {
        let cacheKey = "token_details_\(chainId)_\(pairId)"
        
        // Check cache first
        if let cached: PairData = cache.get(forKey: cacheKey) {
            print("🎯 [Cache Hit] Found cached details for \(pairId)")
            return cached
        }
        
        print("🔍 [API] Fetching token pairs for \(pairId)")
        // First get the pair address using the token address
        let tokenEndpoint = "/latest/dex/tokens/\(pairId)"
        
        let tokenResponse: DexScreenerResponse = try await performRequestWithRetry(
            tokenEndpoint,
            method: .get,
            parameters: nil
        )
        
        print("📦 [API] Token pairs response: \(tokenResponse.pairs?.count ?? 0) pairs found")
        
        // Find the pair for the token on the specified chain
        guard let pair = tokenResponse.pairs?.first(where: { $0.chainId.lowercased() == chainId.lowercased() }) else {
            print("⚠️ [API] No pairs found for chain \(chainId)")
            return nil
        }
        
        // Now fetch the specific pair details using the pair address
        let pairEndpoint = "/latest/dex/pairs/\(chainId)/\(pair.pairAddress)"
        print("🔍 [API] Fetching pair details for address: \(pair.pairAddress)")
        
        let pairResponse: DexScreenerResponse = try await performRequestWithRetry(
            pairEndpoint,
            method: .get,
            parameters: nil
        )
        
        let details = pairResponse.pairs?.first
        
        if let details = details {
            print("✅ [API] Successfully fetched pair details")
            print("   - Market Cap: \(details.marketCap ?? 0)")
            print("   - Liquidity: \(details.liquidity.usd)")
            print("   - Volume 24h: \(details.volume?.h24 ?? 0)")
            // Cache the result with a shorter TTL (30 seconds)
            cache.set(details, forKey: cacheKey, expirationIn: 30)
        } else {
            print("⚠️ [API] No pair details found in response")
        }
        
        return details
    }
} 
