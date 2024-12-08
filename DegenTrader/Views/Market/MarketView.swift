import SwiftUI

struct MarketView: View {
    @State private var searchText = ""
    @State private var showFilterMenu = false
    @State private var isFilterActive = false
    @State private var selectedSortOption: FilterMenuView.SortOption = .rank
    @State private var selectedTimeFrame: FilterMenuView.TimeFrame = .hour24
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBarView(
                    text: $searchText,
                    showFilterMenu: $showFilterMenu,
                    isFilterActive: $isFilterActive
                )
                .padding(.horizontal)
                .padding(.vertical, 8)
                .padding(.bottom)
                
                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterPill(title: "Trending", isSelected: true)
                        FilterPill(title: "Hot", isSelected: false)
                        FilterPill(title: "New Listings", isSelected: false)
                        FilterPill(title: "Gainers", isSelected: false)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
                
                // Token List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(sortedTokens) { token in
                            TokenListRow(token: PortfolioToken(token: token, amount: 0))
                        }
                    }
                    .padding()
                }
            }
            .background(AppTheme.colors.background)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Market")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showFilterMenu) {
                FilterMenuView(
                    selectedSortOption: $selectedSortOption,
                    selectedTimeFrame: $selectedTimeFrame,
                    isFilterActive: $isFilterActive
                )
            }
        }
    }
    
    private var sortedTokens: [Token] {
        var tokens = MockData.tokens
        
        if isFilterActive {
            switch selectedSortOption {
            case .rank:
                // Keep original order
                break
            case .volume:
                tokens.sort { $0.volume24h > $1.volume24h }
            case .price:
                tokens.sort { $0.price > $1.price }
            case .priceChange:
                // Use the selected time frame's price change
                tokens.sort { $0.priceChange24h > $1.priceChange24h }
            case .marketCap:
                // Assuming we'll add marketCap to Token model later
                break
            }
        }
        
        return tokens
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? AppTheme.colors.background : AppTheme.colors.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? AppTheme.colors.accent : AppTheme.colors.cardBackground)
            .cornerRadius(20)
    }
}

#Preview {
    MarketView()
        .preferredColorScheme(.dark)
} 
