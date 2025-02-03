import SwiftUI
import Alamofire

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var walletManager = WalletManager.shared
    @State private var showSearch = false
    @State private var showBalance = false
    @State private var showBuyView =  false
    @State private var showSwapView = false
    @State private var selectedSwapToken: Token?
    
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
                                .foregroundColor(viewModel.portfolio.profitLoss == 0 ? Color(white: 0.5) : (viewModel.portfolio.profitLoss > 0 ? AppTheme.colors.positive : AppTheme.colors.negative))
                            
                            Text("\(viewModel.portfolio.profitLossPercentage >= 0 ? "+" : "")\(viewModel.portfolio.profitLossPercentage, specifier: "%.2f")%")
                                .foregroundColor(viewModel.portfolio.profitLossPercentage == 0 ? Color(white: 0.5) : (viewModel.portfolio.profitLossPercentage > 0 ? AppTheme.colors.positive : AppTheme.colors.negative))
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
        .onChange(of: walletManager.balances) { _ in
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
                        address: "So11111111111111111111111111111111111111112",
                        symbol: "SOL",
                        name: "Solana",
                        price: 100.0,
                        priceChange24h: 0,
                        volume24h: 0,
                        logoURI: nil
                    ))
                }
            }
            
        }
        .padding(.bottom, 32)
    }
    
    private var tokenList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Tokens")
                .font(.system(size: 24))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            ForEach(viewModel.portfolio.tokens) { token in
                NavigationLink {
                    TokenDetailView(token: token.token)
                } label: {
                    TokenListRow(token: token)
                        .padding(.leading)
                        .padding(.trailing)

                }
            }
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    DashboardView()
        .preferredColorScheme(.dark)
} 
