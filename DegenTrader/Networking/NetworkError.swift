import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case rateLimitExceeded
    case serverError(Int)
    case noData
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .serverError(let code):
            return "Server error occurred (Code: \(code))"
        case .noData:
            return "No data received"
        case .networkUnavailable:
            return "Network connection unavailable"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .rateLimitExceeded:
            return "Please wait a moment before trying again"
        case .networkUnavailable:
            return "Please check your internet connection"
        case .serverError:
            return "Please try again later"
        default:
            return "Please try again"
        }
    }
} 