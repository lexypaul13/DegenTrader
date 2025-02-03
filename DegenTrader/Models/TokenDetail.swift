import Foundation

struct TokenDetail {
    let metadata: TokenMetadata
    let priceData: TokenPriceData
    let marketData: TokenMarketData
}

// MARK: - Token Metadata
struct TokenMetadata {
    let address: String
    let name: String
    let symbol: String
    let totalSupply: Double?
    let decimals: Int
    let tags: [String]
    let logoURI: String?
    let extensions: [String: String]?
}

// MARK: - Price Data
struct TokenPriceData {
    let currentPrice: Double
    let priceChange24h: Double
    let lastUpdated: Date
}

// MARK: - Market Data
struct TokenMarketData {
    let marketCap: Double?
    let volume24h: Double?
    let holders: Int?
    let topHolders: [String: Double]? // address: percentage
    let mintable: Bool
    let mutableInfo: Bool
    let updateAuthority: String?
    let priceChange24h: Double? // Added for DexScreener price change data
} 