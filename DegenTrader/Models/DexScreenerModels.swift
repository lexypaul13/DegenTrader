import Foundation

// MARK: - DexScreener Models
struct DexScreenerResponse: Codable {
    let schemaVersion: String
    let pairs: [PairData]
}

struct PairData: Codable {
    let chainId: String
    let dexId: String
    let url: String
    let pairAddress: String
    let baseToken: BaseToken
    let quoteToken: BaseToken
    let priceNative: String
    let priceUsd: String
    let liquidity: Liquidity
    let volume: Volume?
    let priceChange: PriceChange
    let fdv: Double?
    let marketCap: Double?
    
    struct BaseToken: Codable {
        let address: String
        let name: String
        let symbol: String
    }
    
    struct Liquidity: Codable {
        let usd: Double
        let base: Double
        let quote: Double
    }
    
    struct Volume: Codable {
        let h24: Double?
        
        enum CodingKeys: String, CodingKey {
            case h24 = "h24"
        }
    }
    
    struct PriceChange: Codable {
        let h24: Double
        
        enum CodingKeys: String, CodingKey {
            case h24 = "h24"
        }
    }
    
    // Helper computed properties
    var nativePrice: Double {
        Double(priceNative) ?? 0.0
    }
    
    var usdPrice: Double {
        Double(priceUsd) ?? 0.0
    }
}