import SwiftUI

struct MarketView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding()
                
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
                        ForEach(MockData.tokens) { token in
                            TokenRowView(
                                symbol: token.symbol,
                                name: token.name,
                                price: token.price,
                                priceChange: token.priceChange24h
                            )
                        }
                    }
                    .padding()
                }
            }
            .background(AppTheme.colors.background)
            .navigationTitle("Market")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.colors.textSecondary)
            
            TextField("Search...", text: $text)
                .foregroundColor(AppTheme.colors.textPrimary)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.colors.textSecondary)
                }
            }
        }
        .padding()
        .background(AppTheme.colors.cardBackground)
        .cornerRadius(12)
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