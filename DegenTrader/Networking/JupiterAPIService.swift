import Foundation
import Alamofire

// MARK: - Protocol
protocol JupiterAPIServiceProtocol {
    func fetchTrendingTokens() async throws -> [JupiterToken]
}

// MARK: - Implementation
final class JupiterAPIService: NetworkRequestable {
    private let baseURL = "https://tokens.jup.ag"
    
    func performRequest<T: Decodable>(_ endpoint: String, 
                                     method: HTTPMethod = .get,
                                     parameters: Parameters? = nil) async throws -> T {
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
}

// MARK: - Jupiter API Implementation
extension JupiterAPIService: JupiterAPIServiceProtocol {
    func fetchTrendingTokens() async throws -> [JupiterToken] {
        let parameters: Parameters = ["tags": "birdeye-trending"]
        return try await performRequest("/tokens", 
                                      method: .get,
                                      parameters: parameters)
    }
}

