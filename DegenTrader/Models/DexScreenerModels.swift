import Foundation

// MARK: - DexScreener Models
struct DexScreenerResponse: Codable {
    let chainId: String
    let pairAddress: String
    let baseToken: BaseToken
    let priceNative: String
    let priceUsd: String
    let priceChange: PriceChange
    let volume24h: Double?
    
    struct BaseToken: Codable {
        let address: String
        let name: String
        let symbol: String
    }
    
    struct PriceChange: Codable {
        let h24: Double
        
        enum CodingKeys: String, CodingKey {
            case h24 = "h24"
        }
    }
    
    // Converting string prices to Double
    var nativePrice: Double {
        Double(priceNative) ?? 0.0
    }
    
    var usdPrice: Double {
        Double(priceUsd) ?? 0.0
    }
}