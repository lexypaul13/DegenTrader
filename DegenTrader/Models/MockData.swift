import Foundation

struct MockData {
    static let tokens = [
        Token(
            address: "So11111111111111111111111111111111111111112",
            symbol: "SOL",
            name: "Solana",
            price: 1.18,
            priceChange24h: -2.41,
            volume24h: 1_000_000,
            logoURI: nil
        ),
        Token(
            address: "JFYJQqHzMz8gJrLpHQXqE7Zi4bJh3WYqYGHgBPzptEYg",
            symbol: "JIFFY",
            name: "Jiffy",
            price: 0.36,
            priceChange24h: -5.28,
            volume24h: 500_000,
            logoURI: nil
        ),
        Token(
            address: "PST1SWvG8LF7VdxGARyxKNYFifdYUNKGz58UEBKzg14",
            symbol: "PST",
            name: "pSt5mxG",
            price: 0.00,
            priceChange24h: 0.00,
            volume24h: 0,
            logoURI: nil
        ),
        Token(
            address: "JiZnMYVn8J6FrXoHiMXhEyGqh8YqyKCwNqUzfd8JDKp9",
            symbol: "JIZZ",
            name: "Jizzwel",
            price: 0.00,
            priceChange24h: 0.00,
            volume24h: 0,
            logoURI: nil
        ),
        Token(
            address: "9n4nbM75f5Ui33ZbPYXn59EwSgE8CGsHtAeTH5YFeJ9E",
            symbol: "BTC",
            name: "Bitcoin",
            price: 43250.82,
            priceChange24h: 2.15,
            volume24h: 25_000_000,
            logoURI: nil
        ),
        Token(
            address: "2FPyTwcZLUg1MDrwsyoP4D6s1tM7hAkHYRjkNb5w6Pxk",
            symbol: "ETH",
            name: "Ethereum",
            price: 2285.64,
            priceChange24h: 1.87,
            volume24h: 15_000_000,
            logoURI: nil
        ),
        Token(
            address: "CbNYA9n3927uXUukee2Hf4tm3xxkffJPPZvGazc2EAH5",
            symbol: "ADA",
            name: "Cardano",
            price: 0.58,
            priceChange24h: -3.42,
            volume24h: 2_000_000,
            logoURI: nil
        ),
        Token(
            address: "A9mmqFVqhyacPGiJ6GwgcFkRYPhasJGVHyNspWmXBtdY",
            symbol: "DOT",
            name: "Polkadot",
            price: 7.84,
            priceChange24h: -1.23,
            volume24h: 1_500_000,
            logoURI: nil
        ),
        Token(
            address: "AhqdWGjTQE4RsDwzYkJtCYuKBHQV4YDrRrWXaGPFbwfB",
            symbol: "AVAX",
            name: "Avalanche",
            price: 35.62,
            priceChange24h: 4.56,
            volume24h: 3_000_000,
            logoURI: nil
        ),
        Token(
            address: "3bRTivrVsitbmCTGtqwp7hxXPsybkjn4XLNtPsHqa3zR",
            symbol: "LINK",
            name: "Chainlink",
            price: 14.92,
            priceChange24h: 2.78,
            volume24h: 1_200_000,
            logoURI: nil
        ),
        Token(
            address: "Gz7VkD4MacbEB6yC5XD3HcumEiYx2EtDYYrfikGsvopG",
            symbol: "MATIC",
            name: "Polygon",
            price: 0.89,
            priceChange24h: -0.95,
            volume24h: 900_000,
            logoURI: nil
        ),
        Token(
            address: "ATLASXmbPQxBUYbxPsV97usA3fPQYEqzQBUHgiFCUsXx",
            symbol: "ATOM",
            name: "Cosmos",
            price: 9.76,
            priceChange24h: 1.45,
            volume24h: 800_000,
            logoURI: nil
        ),
        Token(
            address: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
            symbol: "UNI",
            name: "Uniswap",
            price: 6.23,
            priceChange24h: -2.31,
            volume24h: 700_000,
            logoURI: nil
        ),
        Token(
            address: "7vfCXTUXx5WJV5JADk17DUJ4ksgau7utNKj4b963voxs",
            symbol: "AAVE",
            name: "Aave",
            price: 89.45,
            priceChange24h: 3.67,
            volume24h: 600_000,
            logoURI: nil
        ),
        Token(
            address: "HZRCwxP2Vq9PCpPXooayhJ2bxTpo5xfpQrwB1svh332p",
            symbol: "ALGO",
            name: "Algorand",
            price: 0.17,
            priceChange24h: -1.82,
            volume24h: 400_000,
            logoURI: nil
        )
    ]
    
    static let searchTokens = [
        Token(
            address: "So11111111111111111111111111111111111111112",
            symbol: "SOL",
            name: "Solana",
            price: 228.62,
            priceChange24h: -3.5,
            volume24h: 1_000_000,
            logoURI: nil
        ),
        Token(
            address: "EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v",
            symbol: "USDC",
            name: "USD Coin",
            price: 1.00,
            priceChange24h: -0.02,
            volume24h: 500_000,
            logoURI: nil
        ),
        Token(
            address: "Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB",
            symbol: "USDT",
            name: "Tether USD",
            price: 1.00,
            priceChange24h: 0.01,
            volume24h: 750_000,
            logoURI: nil
        ),
        Token(
            address: "J1toso1uCk3RLmjorhTtrVwY9HJ7X8V9yYac6Y7kGCPn",
            symbol: "JitoSOL",
            name: "Jito Staked SOL",
            price: 263.83,
            priceChange24h: -3.54,
            volume24h: 300_000,
            logoURI: nil
        ),
        Token(
            address: "DezXAZ8z7PnrnRJjz3wXBoRgixCa6xjnB7YaB1pPB263",
            symbol: "BONK",
            name: "Bonk",
            price: 0.00001234,
            priceChange24h: 9.15,
            volume24h: 100_000,
            logoURI: nil
        ),
        Token(
            address: "4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R",
            symbol: "RAY",
            name: "Raydium",
            price: 4.12,
            priceChange24h: -0.09,
            volume24h: 200_000,
            logoURI: nil
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
