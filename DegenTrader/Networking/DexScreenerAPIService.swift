import Foundation
import Alamofire

// MARK: - Protocol
protocol DexScreenerAPIServiceProtocol {
    func fetchTokenPrices(addresses: [String]) async throws -> [String: TokenPrice]
}

// MARK: - Implementation
final class DexScreenerAPIService: NetworkRequestable, DexScreenerAPIServiceProtocol {
    private let baseURL = "https://api.dexscreener.com"
    private let chainId = "solana"
    
    func performRequest<T: Decodable>(_ endpoint: String, 
                                     method: HTTPMethod,
                                     parameters: Parameters?) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request("\(baseURL)\(endpoint)",
                      method: method,
                      parameters: parameters)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        continuation.resume(throwing: NetworkError.requestFailed(error))
                    }
                }
        }
    }
    
    func fetchTokenPrices(addresses: [String]) async throws -> [String: TokenPrice] {
        let addressList = addresses.joined(separator: ",")
        let endpoint = "/tokens/v1/\(chainId)/\(addressList)"
        
        let responses: [DexScreenerResponse] = try await performRequest(endpoint, 
                                                                      method: .get,
                                                                      parameters: nil)
        
        // Convert responses to TokenPrice dictionary using baseToken.address as key
        var prices: [String: TokenPrice] = [:]
        for response in responses {
            prices[response.baseToken.address] = TokenPrice(
                price: response.usdPrice,
                priceChange24h: response.priceChange.h24,
                volume24h: response.volume24h
            )
        }
        
        return prices
    }
} 