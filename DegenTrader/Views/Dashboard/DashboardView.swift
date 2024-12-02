import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showSearch = false
    @State private var showBalance = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Search Button
                    HStack {
                        Spacer()
                        Button(action: {
                            showSearch.toggle()
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppTheme.colors.textPrimary)
                                .font(.system(size: 20))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                    
                    // Balance Section
                    VStack(spacing: 24) {
                        Text("Available Balance")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(AppTheme.colors.textPrimary)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .preference(
                                            key: ScrollOffsetPreferenceKey.self,
                                            value: proxy.frame(in: .global).minY
                                        )
                                }
                            )
                        
                        Text("$\(viewModel.portfolio.totalBalance, specifier: "%.2f")")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(AppTheme.colors.textPrimary)
                        
                        HStack(spacing: 24) {
                            Text("$\(abs(viewModel.portfolio.profitLoss), specifier: "%.2f")")
                                .foregroundColor(viewModel.portfolio.profitLoss >= 0 ? AppTheme.colors.positive : AppTheme.colors.negative)
                            
                            Text("\(viewModel.portfolio.profitLossPercentage >= 0 ? "+" : "")\(viewModel.portfolio.profitLossPercentage, specifier: "%.2f")%")
                                .foregroundColor(viewModel.portfolio.profitLossPercentage >= 0 ? AppTheme.colors.positive : AppTheme.colors.negative)
                        }
                        .font(.system(size: 18))
                    }
                    .padding(.bottom, 40)
                    
                    // Action Buttons
                    HStack(spacing: 60) {
                        // Swap Button
                        Button(action: {}) {
                            VStack(spacing: 8) {
                                Capsule()
                                    .fill(AppTheme.colors.cardBackground)
                                    .frame(width: 100, height: 44)
                                    .overlay(
                                        Image(systemName: "arrow.left.arrow.right")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                    )
                                Text("Swap")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.gray)
                            }
                        }
                        
                        // Buy Button
                        Button(action: {}) {
                            VStack(spacing: 8) {
                                Capsule()
                                    .fill(AppTheme.colors.cardBackground)
                                    .frame(width: 100, height: 44)
                                    .overlay(
                                        Image(systemName: "dollarsign.circle")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                    )
                                Text("Buy")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                    
                    // Token List
                    VStack(spacing: 12) {
                        ForEach(viewModel.portfolio.tokens) { token in
                            TokenListRow(token: token)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
            .background(AppTheme.colors.background)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                withAnimation {
                    showBalance = value > -100 // Show balance by default, change to Home when scrolled down
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(showBalance ? "Home" : "$\(viewModel.portfolio.totalBalance, specifier: "%.2f")")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .fullScreenCover(isPresented: $showSearch) {
            SearchView()
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct TokenListRow: View {
    let token: PortfolioToken
    
    var body: some View {
        HStack(spacing: 12) {
            // Token Icon
            Circle()
                .fill(Color.black.opacity(0.3))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(token.token.symbol.lowercased())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                )
            
            // Token Info
            VStack(alignment: .leading, spacing: 4) {
                Text(token.token.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.colors.textPrimary)
                
                Text("\(token.amount, specifier: "%.5f") \(token.token.symbol)")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.colors.textSecondary)
            }
            
            Spacer()
            
            // Price Info
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(token.token.price, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppTheme.colors.textPrimary)
                
                Text("\(token.token.priceChange24h, specifier: "%.2f")%")
                    .font(.system(size: 14))
                    .foregroundColor(token.token.priceChange24h >= 0 ? AppTheme.colors.positive : AppTheme.colors.negative)
            }
        }
        .padding()
        .background(AppTheme.colors.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    DashboardView()
        .preferredColorScheme(.dark)
} 
