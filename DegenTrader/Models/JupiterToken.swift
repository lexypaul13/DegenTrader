import Foundation

struct JupiterToken: Codable, Identifiable, Hashable {
    let address: String
    let name: String
    let symbol: String
    let decimals: Int
    let logoURI: String?
    let tags: [String]
    let daily_volume: Double?
    let created_at: String
    let freeze_authority: String?
    let mint_authority: String?
    let permanent_delegate: String?
    let minted_at: String?
    let extensions: JupiterTokenExtensions?
    
    var id: String { address }
    
    // Implement hash(into:) using address as unique identifier
    func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }
    
    // Implement equality based on address
    static func == (lhs: JupiterToken, rhs: JupiterToken) -> Bool {
        lhs.address == rhs.address
    }
}

struct JupiterTokenExtensions: Codable, Hashable {
    let coingeckoId: String?
} 
