import Foundation

// MARK: - Protocol
protocol MemeCoinServiceProtocol {
    func isMemeCoin(_ token: JupiterToken) -> Bool
    func filterMemeCoins(_ tokens: [JupiterToken]) -> [JupiterToken]
}

// MARK: - Implementation
final class MemeCoinService: MemeCoinServiceProtocol {
    // Configuration
    private let memeNamePatterns = [
        #"(?i)\b(trump|melania|maga|pepe|bonk|skibidi|elon|doge|slerf|kim jong|fart|pump|memecoin|derangement|tremp|solana|meme+|ai)\b"#,
        #"(?i)\b(official|unofficial|buy \$[0-9]+|to the moon|pump|dump)\b"#,
        #"🐸|🐶|🚀|💩|🦍|👑"# // Emoji detection
    ]
    
    private let memeSymbolPatterns = [
        #"\$?[0-9]+(worth)?"#,   // $1, $10
        #"(?i)\b(tf|mlt|savior|mafa|gme|pwny|elon)\b"#,
        #"^.{1-4}$"#             // Ultra-short symbols
    ]
    
    private let legitimacyTags = ["stablecoin", "wrapped", "governance"]
    private let hypeTags = ["birdeye-trending", "community"]
    private let whitelist = ["WBTC", "ETH", "USDC", "PYTH"]
    
    // MARK: - Public Interface
    func filterMemeCoins(_ tokens: [JupiterToken]) -> [JupiterToken] {
        tokens.filter { isMemeCoin($0) }
    }
    
    func isMemeCoin(_ token: JupiterToken) -> Bool {
        guard !isWhitelisted(token) else { return false }
        let score = calculateMemeScore(token)
        return score >= 45 // Adjusted threshold
    }
    
    // MARK: - Private Scoring Logic
    private func calculateMemeScore(_ token: JupiterToken) -> Int {
        var score = 0
        
        // 1. Name Analysis (35% weight)
        score += checkNamePatterns(token.name) * 35
        
        // 2. Symbol Analysis (20% weight)
        score += checkSymbolPatterns(token.symbol) * 20
        
        // 3. Tag Logic (20% weight)
        score += analyzeTags(token.tags) * 20
        
        // 4. Temporal Analysis (15% weight)
        score += checkCreationRecency(token.created_at) * 15
        
        // 5. Economic Indicators (10% weight)
        score += checkVolumeAnomalies(token) * 10
        
        // 6. Credibility Check
        score += (token.extensions?.coingeckoId == nil) ? 15 : -10
        
        return min(score, 100)
    }
    
    private func checkNamePatterns(_ name: String) -> Int {
        let matches = memeNamePatterns.reduce(0) { count, pattern in
            (try? name.range(of: pattern, options: .regularExpression)) != nil ? count + 1 : count
        }
        return min(matches, 3)
    }
    
    private func checkSymbolPatterns(_ symbol: String) -> Int {
        return memeSymbolPatterns.contains { pattern in
            (try? symbol.range(of: pattern, options: .regularExpression)) != nil
        } ? 1 : 0
    }
    
    private func analyzeTags(_ tags: [String]) -> Int {
        let hasHype = tags.contains { hypeTags.contains($0) }
        let lacksLegitimacy = !tags.contains { legitimacyTags.contains($0) }
        return (hasHype && lacksLegitimacy) ? 1 : 0
    }
    
    private func checkCreationRecency(_ dateString: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = formatter.date(from: dateString) else { return 0 }
        
        let isRecent = Calendar.current.dateComponents([.day], 
                                                     from: date, 
                                                     to: Date()).day! <= 30
        return isRecent ? 1 : 0
    }
    
    private func checkVolumeAnomalies(_ token: JupiterToken) -> Int {
        guard let volume = token.daily_volume else { return 0 }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let creationDate = formatter.date(from: token.created_at) else { return 0 }
        
        let ageDays = Calendar.current.dateComponents([.day], 
                                                    from: creationDate, 
                                                    to: Date()).day!
        let dailyVolumePerAge = volume / Double(max(ageDays, 1))
        return dailyVolumePerAge > 1_000_000 ? 1 : 0
    }
    
    private func isWhitelisted(_ token: JupiterToken) -> Bool {
        whitelist.contains(token.symbol) || 
        token.mint_authority != nil
    }
} 
