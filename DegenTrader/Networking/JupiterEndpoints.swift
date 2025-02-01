import Foundation

enum JupiterEndpoints {
    private static let baseURL = "https://tokens.jup.ag"
    
    static func tokenList(tags: String = "birdeye-trending") -> (baseURL: String, endpoint: String) {
        (baseURL, "/tokens?tags=\(tags)")
    }
} 