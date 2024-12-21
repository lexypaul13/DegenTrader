import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var walletManager = WalletManager.shared
    @State private var showSearch = false
    @State private var showBalance = false
    @State private var showBuyView = false
    
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
                    VStack(spacing: 10) {
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
                        
                        HStack(spacing: 14) {
                            Text("$\(abs(viewModel.portfolio.profitLoss), specifier: "%.2f")")
                                .foregroundColor(viewModel.portfolio.profitLoss >= 0 ? AppTheme.colors.positive : AppTheme.colors.negative)
                            
                            Text("\(viewModel.portfolio.profitLossPercentage >= 0 ? "+" : "")\(viewModel.portfolio.profitLossPercentage, specifier: "%.2f")%")
                                .foregroundColor(viewModel.portfolio.profitLossPercentage >= 0 ? AppTheme.colors.positive : AppTheme.colors.negative)
                        }
                        .font(.system(size: 18))
                    }
                    .padding(.bottom, 20)
                    
                    // Action Buttons
                    actionButtons
                    
                    // Token List
                    tokenList
                }
            }
            .background(AppTheme.colors.background)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                withAnimation {
                    showBalance = value > -100
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
        .onChange(of: walletManager.balance) { _ in
            viewModel.updatePortfolio()
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 30) {
            // Swap Button
            NavigationLink(destination: SwapView()) {
                ActionButton(
                    imageName: "arrow.left.arrow.right",
                    title: "Swap"
                )
            }
            
            // Buy Button
            Button(action: { showBuyView = true }) {
                ActionButton(
                    imageName: "dollarsign.circle",
                    title: "Buy"
                )
            }
            .fullScreenCover(isPresented: $showBuyView) {
                NavigationView {
                    BuyView(token: Token(
                        symbol: "SOL",
                        name: "Solana",
                        price: 95.42,
                        priceChange24h: 2.5,
                        volume24h: 1_500_000
                    ))
                }
            }
        }
        .padding(.bottom, 40)
    }
    
    private var tokenList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.portfolio.tokens) { portfolioToken in
                NavigationLink(
                    destination: TokenDetailView(token: portfolioToken.token)
                ) {
                    TokenListRow(token: portfolioToken)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 100)
    }
}

struct ActionButton: View {
    let imageName: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Capsule()
                .fill(AppTheme.colors.cardBackground)
                .frame(width: 100, height: 44)
                .overlay(
                    Image(systemName: imageName)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                )
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(Color.gray)
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
