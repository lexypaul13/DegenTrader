import Foundation

// MARK: - DexScreener Models
struct DexScreenerResponse: Codable {
    let chainId: String
    let pairAddress: String
    let baseToken: BaseToken
    let priceNative: String
    let priceUsd: String
    
    struct BaseToken: Codable {
        let address: String
        let name: String
        let symbol: String
    }
    
    // Converting string prices to Double
    var nativePrice: Double {
        Double(priceNative) ?? 0.0
    }
    
    var usdPrice: Double {
        Double(priceUsd) ?? 0.0
    }
} 