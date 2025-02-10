import Foundation

// MARK: - DexScreener Models
struct DexScreenerResponse: Codable {
    let schemaVersion: String
    let pairs: [PairData]?
    
    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case pairs
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decodeIfPresent(String.self, forKey: .schemaVersion) ?? "1.0.0"
        pairs = try container.decodeIfPresent([PairData].self, forKey: .pairs)
    }
}

struct PairData: Codable, Sendable, Equatable {
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
    
    struct BaseToken: Codable, Sendable, Equatable {
        let address: String
        let name: String
        let symbol: String
    }
    
    struct Liquidity: Codable, Sendable, Equatable {
        let usd: Double
        let base: Double
        let quote: Double
    }
    
    struct Volume: Codable, Sendable, Equatable {
        let h24: Double?
        
        enum CodingKeys: String, CodingKey {
            case h24 = "h24"
        }
    }
    
    struct PriceChange: Codable, Sendable, Equatable {
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