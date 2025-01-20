# DegenTrader Development Notes
*This file is for development tracking only - DO NOT COMMIT TO GITHUB*

## Project Overview
DegenTrader is a Solana meme coin trading simulator focusing on providing real-time trending token data and trading functionality.

## Current Implementation Status

### Dashboard
- ✅ Initialized with only SOL token (0 balance)
- ✅ Removed sample transactions
- ✅ Set profit/loss text to grey when value is 0
- ✅ Cleaned up mock data

### Search View
- ✅ Connected to Jupiter API for trending tokens
- ✅ Successfully fetching and decoding token data
- ✅ Implemented volume-based sorting
- ✅ Added detailed token information display

### API Integration Progress
1. **Jupiter API Integration**
   - ✅ Successfully connected to token list endpoint
   - ✅ Created response models for different endpoints:
     - `JupiterToken`
     - `JupiterPriceResponse`
     - `JupiterTokenV6`
     - `JupiterListToken`
   - ✅ Implemented trending tokens fetch with volume sorting
   - ✅ Added proper error handling and debugging output

2. **Shyft API Models**
   - ✅ Created response models:
     - `ShyftTrendingResponse`
     - `ShyftToken`

## Current Focus
We are working on implementing real-time trending token data in the SearchView using Jupiter's API. The current implementation fetches the top 15 trending tokens sorted by daily volume.

## Next Steps

### Immediate Tasks
1. Transform Jupiter API response into UI-ready format
2. Update SearchView UI to display live token data
3. Implement token filtering for meme coins
4. Add price change data to token display

### Future Enhancements
1. Implement real-time price updates
2. Add token search functionality
3. Enhance token categorization
4. Implement swap functionality with Jupiter SDK
5. Add market data visualization

## API Endpoints in Use
- Jupiter Token List: `https://tokens.jup.ag/tokens?tags=birdeye-trending`
  - Returns trending tokens with volume data
  - No API key required
  - Includes detailed token metadata

## Notes
- Currently focusing on Jupiter API due to better token discovery features
- Need to implement proper error handling for network issues
- Consider adding caching for token data
- May need to implement rate limiting

## Questions to Address
1. How to effectively filter meme coins from regular tokens?
2. Best approach for real-time price updates?
3. How to handle token images/logos efficiently?

## Last Updated
- Successfully decoded Jupiter API response
- Implemented volume-based sorting
- Added detailed token information display
- Next focus is on filtering and UI integration Test change
