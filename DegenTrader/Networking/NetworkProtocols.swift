import Foundation
import Alamofire

// MARK: - Protocols
protocol NetworkRequestable {
    func performRequest<T: Decodable>(_ endpoint: String, 
                                     method: HTTPMethod,
                                     parameters: Parameters?) async throws -> T
}

// MARK: - Errors
enum NetworkError: LocalizedError {
    case requestFailed(Error)
    case invalidResponse
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Invalid data received"
        }
    }
} 