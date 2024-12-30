# DegenTrader

A modern iOS trading app for the Solana ecosystem, built with SwiftUI. DegenTrader provides a seamless experience for trading tokens, managing portfolios, and tracking market movements.

## Features

### 1. Dashboard
- Real-time portfolio overview with total balance
- Profit/loss tracking with percentage changes
- Quick action buttons for Swap, Buy, and More options
- List of owned tokens with current values and price changes
- Search functionality for quick token access

### 2. Market View
- Comprehensive token listing with real-time prices
- Price change indicators (24h)
- Advanced filtering options:
  - Trending
  - Hot
  - New Listings
  - Gainers
- Sort by rank, volume, price, price change, or market cap
- Search functionality with token filtering

### 3. Swap Feature
- Token-to-token swapping functionality
- Real-time price quotes
- Support for multiple token pairs
- Integration with Jupiter aggregator
- Slippage tolerance settings
- Transaction confirmation and history

### 4. Price Alerts
- Custom price alert creation
- Support for multiple alerts per token
- Alert activation toggles
- Price threshold notifications
- Easy alert management and editing

### 5. Recent Activity
- Chronological transaction history
- Transaction categorization by date
- Detailed swap information:
  - Token amounts
  - Token pairs
  - Transaction status (Success/Failed)
  - Source (e.g., Jupiter)
- Transaction amount formatting for better readability

## Technical Details

### Architecture
- Built with SwiftUI for modern iOS UI
- MVVM architecture pattern
- Observable state management
- Modular view components
- Persistent storage using UserDefaults

### Key Components

#### Models
- `Token`: Represents cryptocurrency tokens with properties like symbol, name, price
- `Transaction`: Handles swap transaction details and status
- `PortfolioToken`: Manages token holdings and calculations
- `PriceAlert`: Handles price alert configurations

#### Managers
- `WalletManager`: Handles balance management and transactions
- `AlertsManager`: Manages price alerts and notifications

#### Views
1. Main Views:
   - `MainTabView`: Tab-based navigation
   - `DashboardView`: Portfolio overview
   - `MarketView`: Token listings
   - `SwapView`: Token swapping interface
   - `AlertsView`: Price alerts management
   - `RecentActivityView`: Transaction history

2. Components:
   - `TokenListRow`: Reusable token display component
   - `SearchBarView`: Universal search component
   - `ActionButton`: Styled action buttons
   - `FilterMenuView`: Market filter interface

### Styling
- Dark mode optimized
- Consistent color scheme using `AppTheme`
- Responsive layouts
- Custom UI components
- Smooth animations and transitions

## User Experience

### Navigation
- Tab-based main navigation
- Modal presentations for detailed views
- Seamless transitions between features
- Consistent back navigation
- Search accessibility from key views

### Visual Feedback
- Color-coded price changes (green/red)
- Transaction status indicators
- Loading states
- Alert badges
- Interactive buttons and controls

### Data Formatting
- Smart number formatting for large values
- Consistent decimal place handling
- Clear date and time presentation
- Token amount normalization
- Currency symbol display

## Future Enhancements
1. Live price updates via WebSocket
2. Additional trading pairs and tokens
3. Advanced charting capabilities
4. Portfolio analytics
5. Multiple wallet support
6. Transaction export functionality
7. Custom token lists
8. Enhanced alert options

## Getting Started

### Requirements
- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

### Installation
1. Clone the repository
2. Open `DegenTrader.xcodeproj`
3. Build and run on simulator or device

### Configuration
- Set up API keys in configuration
- Configure network endpoints
- Set up alert notifications

## Contributing
Contributions are welcome! Please read our contributing guidelines and submit pull requests for any enhancements. 