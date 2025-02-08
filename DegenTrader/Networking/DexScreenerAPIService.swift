import Foundation
import Alamofire

// MARK: - Protocol
protocol DexScreenerAPIServiceProtocol {
    func fetchTokenPrices(addresses: [String]) async throws -> [String: TokenPrice]
    func fetchTokenDetails(chainId: String, pairId: String) async throws -> PairData?
}

// MARK: - Implementation
final class DexScreenerAPIService: NetworkRequestable, DexScreenerAPIServiceProtocol {
    private let baseURL = "https://api.dexscreener.com"
    private let chainId = "solana"
    
    func performRequest<T: Decodable>(_ endpoint: String, 
                                     method: HTTPMethod,
                                     parameters: Parameters?) async throws -> T {
        let url = "\(baseURL)\(endpoint)"
        print("Performing request to URL: \(url)")
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url,
                      method: method,
                      parameters: parameters)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        continuation.resume(returning: value)
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        continuation.resume(throwing: NetworkError.requestFailed(error))
                    }
                }
        }
    }
    
    func fetchTokenPrices(addresses: [String]) async throws -> [String: TokenPrice] {
        // Update endpoint format to match API documentation
        let endpoint = "/latest/dex/tokens/\(addresses.joined(separator: ","))"
        
        let response: DexScreenerResponse = try await performRequest(endpoint, 
                                                                   method: .get,
                                                                   parameters: nil)
        
        print("\n=== DexScreener Raw Response \(response)===")

        // Convert responses to TokenPrice dictionary using baseToken.address as key
        var prices: [String: TokenPrice] = [:]
        for pair in response.pairs {
            prices[pair.baseToken.address] = TokenPrice(
                price: Double(pair.priceUsd) ?? 0.0,
                priceChange24h: pair.priceChange.h24
            )
        }
        
        return prices
    }
    
    func fetchTokenDetails(chainId: String, pairId: String) async throws -> PairData? {
        // First get the pair address using the token address
        let tokenEndpoint = "/latest/dex/tokens/\(pairId)"
        
        print("Fetching token pairs from URL: \(baseURL)\(tokenEndpoint)")
        
        let tokenResponse: DexScreenerResponse = try await performRequest(tokenEndpoint, 
                                                                        method: .get,
                                                                        parameters: nil)
        
        // Find the pair for the token on the specified chain
        guard let pair = tokenResponse.pairs.first(where: { $0.chainId.lowercased() == chainId.lowercased() }) else {
            return nil
        }
        
        // Now fetch the specific pair details using the pair address
        let pairEndpoint = "/latest/dex/pairs/\(chainId)/\(pair.pairAddress)"
        
        print("Fetching pair details from URL: \(baseURL)\(pairEndpoint)")
        
        let pairResponse: DexScreenerResponse = try await performRequest(pairEndpoint, 
                                                                       method: .get,
                                                                       parameters: nil)
        
        return pairResponse.pairs.first
    }
} 
