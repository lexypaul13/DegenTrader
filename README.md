# DegenTrader

A Solana-based decentralized trading application for cryptocurrency trading and portfolio management.

## Features
- Real-time token price tracking
- Portfolio management
- Token swapping
- Price alerts
- Recent activity tracking
- Market overview
- Token details and analytics

## API Architecture

### Core APIs

1. **CoinGecko API**
- Base URL: `https://api.coingecko.com/api/v3`
- Rate Limit: 50 calls/minute (free tier)
- No API key required
- Used for:
  - Token prices and market data
  - Historical price data
  - Market statistics
  - Token metadata

Key Endpoints:
```typescript
GET /simple/price
GET /coins/{id}/market_chart
GET /coins/{id}
```

2. **Jupiter API**
- Base URL: `https://quote-api.jup.ag/v4`
- No rate limits
- No API key required
- Used for:
  - Swap functionality
  - Price routing
  - Liquidity data
  - Price impact calculations

Key Endpoints:
```typescript
GET /quote
GET /swap
GET /price
```

3. **DexScreener API**
- Base URL: `https://api.dexscreener.com/latest/dex`
- Rate Limit: 300 calls/minute
- No API key required
- Used for:
  - Token pairs data
  - Market overview
  - Trading volume
  - Basic market data

Key Endpoints:
```typescript
GET /tokens/{tokenAddresses}
GET /search?q={query}
GET /pairs/{chainId}/{pairId}
```

4. **Solscan API**
- Base URL: `https://public-api.solscan.io`
- Rate Limit: 30 calls/minute (free tier)
- Used for:
  - Token metadata
  - Transaction history
  - Holder information
  - Token verification

Key Endpoints:
```typescript
GET /token/{token_address}
GET /token/holders/{token_address}
GET /token/meta/{token_address}
```

### Implementation Details

#### Data Flow
1. Market Data:
   - Primary: CoinGecko
   - Backup: DexScreener
   - Update frequency: 1 minute
   - Caching: 30 seconds

2. Swap Operations:
   - Primary: Jupiter
   - Price impact calculation: Real-time
   - Route optimization: Automatic

3. Token Details:
   - Metadata: Solscan
   - Market Data: CoinGecko + DexScreener
   - Caching: 5 minutes

#### Rate Limit Management
```swift
struct RateLimiter {
    static let coinGecko = 50  // per minute
    static let dexScreener = 300  // per minute
    static let solscan = 30   // per minute
}
```

#### Caching Strategy
- In-memory cache for frequent data
- Persistent cache for historical data
- Cache invalidation based on data type:
  - Prices: 30 seconds
  - Token metadata: 1 hour
  - Market stats: 5 minutes

### Models

```swift
struct Token {
    let symbol: String
    let name: String
    let price: Double
    let priceChange24h: Double
    let volume24h: Double
}

struct Transaction {
    let date: Date
    let fromToken: Token
    let toToken: Token
    let fromAmount: Double
    let toAmount: Double
    let status: TransactionStatus
    let source: String
}
```

### Error Handling
- Automatic retry for failed API calls
- Fallback to secondary data sources
- Rate limit monitoring and throttling
- Error logging and monitoring

### Optimization Strategies
1. **API Call Optimization**
   - Batch requests where possible
   - Use WebSocket for real-time data
   - Implement request queuing

2. **Data Management**
   - Local caching
   - Background refresh
   - Lazy loading for non-critical data

3. **Failover System**
   - Multiple RPC nodes
   - API fallback hierarchy
   - Circuit breaker pattern

## Setup and Configuration

### Prerequisites
- Xcode 14+
- iOS 15.0+
- Swift 5.5+

### Installation
1. Clone the repository
```bash
git clone https://github.com/yourusername/DegenTrader.git
```

2. Install dependencies
```bash
pod install
```

3. Open `DegenTrader.xcworkspace`

4. Build and run

### Configuration
Create a `Config.swift` file with your API endpoints:
```swift
struct APIConfig {
    static let coinGeckoBaseURL = "https://api.coingecko.com/api/v3"
    static let jupiterBaseURL = "https://quote-api.jup.ag/v4"
    static let dexScreenerBaseURL = "https://api.dexscreener.com/latest/dex"
    static let solscanBaseURL = "https://public-api.solscan.io"
}
```

## Development Guidelines

### API Integration
1. Always implement rate limiting
2. Use caching where appropriate
3. Implement proper error handling
4. Add retry logic for failed requests

### Data Management
1. Use appropriate caching strategies
2. Implement background refresh
3. Handle offline scenarios
4. Maintain data consistency

### UI/UX Guidelines
1. Follow system design patterns
2. Implement loading states
3. Handle error states gracefully
4. Maintain responsive UI

## Future Improvements
1. Implement WebSocket connections for real-time updates
2. Add advanced analytics features
3. Implement custom caching solution
4. Add more token pairs and trading options

## Contributing
Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details 