import Foundation

struct MockData {
    static let tokens = [
        Token(
            symbol: "SOL",
            name: "Solana",
            price: 1.18,
            priceChange24h: -2.41,
            volume24h: 1_000_000, logoURI: nil
        ),
        Token(
            symbol: "JIFFY",
            name: "Jiffy",
            price: 0.36,
            priceChange24h: -5.28,
            volume24h: 500_000, logoURI: nil
        ),
        Token(
            symbol: "PST",
            name: "pSt5mxG",
            price: 0.00,
            priceChange24h: 0.00,
            volume24h: 0, logoURI: nil
        ),
        Token(
            symbol: "JIZZ",
            name: "Jizzwel",
            price: 0.00,
            priceChange24h: 0.00,
            volume24h: 0, logoURI: nil
        ),
        Token(
            symbol: "BTC",
            name: "Bitcoin",
            price: 43250.82,
            priceChange24h: 2.15,
            volume24h: 25_000_000, logoURI: nil
        ),
        Token(
            symbol: "ETH",
            name: "Ethereum",
            price: 2285.64,
            priceChange24h: 1.87,
            volume24h: 15_000_000, logoURI: nil
        ),
        Token(
            symbol: "ADA",
            name: "Cardano",
            price: 0.58,
            priceChange24h: -3.42,
            volume24h: 2_000_000, logoURI: nil
        ),
        Token(
            symbol: "DOT",
            name: "Polkadot",
            price: 7.84,
            priceChange24h: -1.23,
            volume24h: 1_500_000, logoURI: nil
        ),
        Token(
            symbol: "AVAX",
            name: "Avalanche",
            price: 35.62,
            priceChange24h: 4.56,
            volume24h: 3_000_000, logoURI: nil
        ),
        Token(
            symbol: "LINK",
            name: "Chainlink",
            price: 14.92,
            priceChange24h: 2.78,
            volume24h: 1_200_000, logoURI: nil
        ),
        Token(
            symbol: "MATIC",
            name: "Polygon",
            price: 0.89,
            priceChange24h: -0.95,
            volume24h: 900_000, logoURI: nil
        ),
        Token(
            symbol: "ATOM",
            name: "Cosmos",
            price: 9.76,
            priceChange24h: 1.45,
            volume24h: 800_000, logoURI: nil
        ),
        Token(
            symbol: "UNI",
            name: "Uniswap",
            price: 6.23,
            priceChange24h: -2.31,
            volume24h: 700_000, logoURI: nil
        ),
        Token(
            symbol: "AAVE",
            name: "Aave",
            price: 89.45,
            priceChange24h: 3.67,
            volume24h: 600_000, logoURI: nil
        ),
        Token(
            symbol: "ALGO",
            name: "Algorand",
            price: 0.17,
            priceChange24h: -1.82,
            volume24h: 400_000, logoURI: nil
        )
    ]
    
    static let searchTokens = [
        Token(
            symbol: "SOL",
            name: "Solana",
            price: 228.62,
            priceChange24h: -3.5,
            volume24h: 1_000_000, logoURI: nil
        ),
        Token(
            symbol: "USDC",
            name: "USD Coin",
            price: 1.00,
            priceChange24h: -0.02,
            volume24h: 500_000, logoURI: nil
        ),
        Token(
            symbol: "USDT",
            name: "Tether USD",
            price: 1.00,
            priceChange24h: 0.01,
            volume24h: 750_000, logoURI: nil
        ),
        Token(
            symbol: "JitoSOL",
            name: "Jito Staked SOL",
            price: 263.83,
            priceChange24h: -3.54,
            volume24h: 300_000, logoURI: nil
        ),
        Token(
            symbol: "BONK",
            name: "Bonk",
            price: 0.00001234,
            priceChange24h: 9.15,
            volume24h: 100_000, logoURI: nil
        ),
        Token(
            symbol: "RAY",
            name: "Raydium",
            price: 4.12,
            priceChange24h: -0.09,
            volume24h: 200_000, logoURI: nil
        )
    ]
    
    static let portfolio = Portfolio(
        totalBalance: 1.54,
        tokens: [
            PortfolioToken(token: tokens[0], amount: 0.00503),
            PortfolioToken(token: tokens[1], amount: 10411.76494),
            PortfolioToken(token: tokens[2], amount: 779184.78955),
            PortfolioToken(token: tokens[3], amount: 49547.88144),
            PortfolioToken(token: tokens[4], amount: 0.00012),
            PortfolioToken(token: tokens[5], amount: 0.00234),
            PortfolioToken(token: tokens[6], amount: 123.45),
            PortfolioToken(token: tokens[7], amount: 15.67),
            PortfolioToken(token: tokens[8], amount: 3.45),
            PortfolioToken(token: tokens[9], amount: 8.92),
            PortfolioToken(token: tokens[10], amount: 156.78),
            PortfolioToken(token: tokens[11], amount: 12.34),
            PortfolioToken(token: tokens[12], amount: 45.67),
            PortfolioToken(token: tokens[13], amount: 1.23),
            PortfolioToken(token: tokens[14], amount: 789.12)
        ],
        profitLoss: -3.35,
        profitLossPercentage: -23.47
    )
} 
