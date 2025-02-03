import Foundation

// MARK: - Jupiter Price API V2 Models
struct JupiterPriceResponse: Codable {
    let data: [String: JupiterPriceData]
    let timeTaken: Double
}

struct JupiterPriceData: Codable {
    let id: String
    let mintSymbol: String
    let vsToken: String
    let vsTokenSymbol: String
    let price: Double
}

// MARK: - Errors
enum JupiterPriceError: LocalizedError {
    case invalidResponse
    case tokenNotFound
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from Jupiter API"
        case .tokenNotFound:
            return "Token not found"
        case .rateLimitExceeded:
            return "Rate limit exceeded (600 requests/min)"
        }
    }
} 