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
                price: Double(pair.priceUsd) ?? 0.0,
                priceChange24h: pair.priceChange.h24
            )
        }
        
        return prices
    }
    
    func fetchTokenDetails(chainId: String, pairId: String) async throws -> PairData? {
        let cacheKey = "token_details_\(chainId)_\(pairId)"
        
        // Check cache first
        if let cached: PairData = cache.get(forKey: cacheKey) {
            return cached
        }
        
        // First get the pair address using the token address
        let tokenEndpoint = "/latest/dex/tokens/\(pairId)"
        
        let tokenResponse: DexScreenerResponse = try await performRequestWithRetry(
            tokenEndpoint,
            method: .get,
            parameters: nil
        )
        
        // Find the pair for the token on the specified chain
        guard let pair = tokenResponse.pairs?.first(where: { $0.chainId.lowercased() == chainId.lowercased() }) else {
            return nil
        }
        
        // Now fetch the specific pair details using the pair address
        let pairEndpoint = "/latest/dex/pairs/\(chainId)/\(pair.pairAddress)"
        
        let pairResponse: DexScreenerResponse = try await performRequestWithRetry(
            pairEndpoint,
            method: .get,
            parameters: nil
        )
        
        let details = pairResponse.pairs?.first
        
        // Cache the result if we got one
        if let details = details {
            cache.set(details, forKey: cacheKey)
        }
        
        return details
    }
} 
