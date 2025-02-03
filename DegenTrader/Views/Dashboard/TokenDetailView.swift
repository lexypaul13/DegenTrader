import SwiftUI

struct TokenDetailView: View {
    let token: Token
    @StateObject private var viewModel: TokenDetailViewModel
    @StateObject private var walletManager = WalletManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showPriceAlert = false
    @State private var isRefreshing = false
    
    init(token: Token) {
        self.token = token
        let service = TokenDetailService(
            jupiterService: JupiterAPIService(),
            dexScreenerService: DexScreenerAPIService()
        )
        _viewModel = StateObject(wrappedValue: TokenDetailViewModel(tokenDetailService: service))
    }
    
    var body: some View {
        ScrollView {
            RefreshableScrollContent(
                isRefreshing: $isRefreshing,
                onRefresh: {
                    await refresh()
                }
            ) {
                Group {
                    switch viewModel.state {
                    case .loading:
                        loadingView
                    case .error:
                        errorView
                    case .loaded:
                        contentView
                    case .idle:
                        EmptyView()
                    case .loadingMore:
                        contentView // Show the content while loading more
                    }
                }
            }
        }
        .background(AppTheme.colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(token.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
            }
        }
        .sheet(isPresented: $showPriceAlert) {
            PriceAlertView(token: token)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.loadTokenDetails(address: token.address)
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 24) {
            ForEach(0..<4) { _ in
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.colors.cardBackground)
                    .frame(height: 200)
                    .redacted(reason: .placeholder)
                    .shimmering()
            }
        }
        .padding()
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.colors.negative)
            
            Text(viewModel.error?.localizedDescription ?? "An error occurred")
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.colors.textPrimary)
            
            Button(action: {
                Task {
                    await viewModel.retry(address: token.address)
                }
            }) {
                Text("Retry")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.colors.accent)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Content View
    private var contentView: some View {
        VStack(spacing: 24) {
            if let details = viewModel.tokenDetail {
                // Chart Section
                TokenChartView(token: token)
                    .padding(.top, 16)
                
                // Action Buttons
                actionButtons
                    .padding(.top, 8)
                
                // Balance Section
                balanceSection(details: details)
                
                // Info Section
                infoSection(details: details)
                
                // 24h Performance Section
                performanceSection(details: details)
            }
        }
        .padding(.vertical, 24)
    }
    
    // MARK: - Helper Views
    private var actionButtons: some View {
        HStack(spacing: 30) {
            // Swap Button
            NavigationLink {
                SwapView(selectedFromToken: token, fromAmount: String(format: "%.8f", walletManager.getBalance(for: token.symbol)))
            } label: {
                ActionButton(
                    imageName: "arrow.left.arrow.right",
                    title: "Swap"
                )
            }
            
            // Alert Button
            Button(action: { showPriceAlert = true }) {
                ActionButton(
                    imageName: "bell.fill",
                    title: "Set Alert"
                )
            }
            
            // More Button
            Button(action: {}) {
                ActionButton(
                    imageName: "ellipsis",
                    title: "More"
                )
            }
        }
    }
    
    private func balanceSection(details: TokenDetail) -> some View {
        VStack(spacing: 16) {
            Text("Your Balance")
                .font(.system(size: 24))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            // Balance Card
            HStack(spacing: 12) {
                // Token Icon and Info
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Group {
                                if let logoURI = details.metadata.logoURI,
                                   let url = URL(string: logoURI) {
                                    CachedTokenImage(url: url)
                                } else {
                                    Image(token.symbol.lowercased())
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                }
                            }
                            .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(details.metadata.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text("\(String(format: "%.5f", walletManager.getBalance(for: token.symbol))) \(details.metadata.symbol)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Price Info
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", walletManager.getBalance(for: token.symbol) * details.priceData.currentPrice))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    let priceChange = details.priceData.currentPrice * details.priceData.priceChange24h / 100.0
                    Text((priceChange >= 0 ? "+" : "") + "$\(String(format: "%.8f", abs(priceChange)))")
                        .font(.system(size: 14))
                        .foregroundColor(priceChange >= 0 ? .green : .red)
                }
            }
            .padding()
            .background(AppTheme.colors.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private func infoSection(details: TokenDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Info")
                .font(.system(size: 24))
                .foregroundColor(.gray)
            
            VStack(spacing: 0) {
                TokenInfoRow(title: "Mint", value: details.metadata.address.prefix(6) + "..." + details.metadata.address.suffix(4))
                Divider().background(Color.gray.opacity(0.3))
                TokenInfoRow(title: "Market Cap", value: details.marketData.marketCap.map { String(format: "$%.2f", $0) } ?? "N/A")
                Divider().background(Color.gray.opacity(0.3))
                TokenInfoRow(title: "Total Supply", value: details.metadata.totalSupply.map { String(format: "%.2f", $0) } ?? "N/A")
                Divider().background(Color.gray.opacity(0.3))
                TokenInfoRow(title: "Volume (24h)", value: details.marketData.volume24h.map { String(format: "$%.2f", $0) } ?? "N/A")
            }
            .padding(16)
            .background(AppTheme.colors.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private func performanceSection(details: TokenDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("24h Performance")
                .font(.system(size: 24))
                .foregroundColor(.gray)
            
            VStack(spacing: 0) {
                TokenPerformanceRow(
                    title: "Price",
                    value: String(format: "$%.8f", details.priceData.currentPrice),
                    change: details.priceData.priceChange24h
                )
                Divider().background(Color.gray.opacity(0.3))
                TokenPerformanceRow(
                    title: "Volume",
                    value: details.marketData.volume24h.map { String(format: "$%.2f", $0) } ?? "N/A",
                    change: 0 // TODO: Add volume change
                )
            }
            .padding(16)
            .background(AppTheme.colors.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Actions
    private func refresh() async {
        isRefreshing = true
        await viewModel.loadTokenDetails(address: token.address)
        isRefreshing = false
    }
}

// MARK: - Refreshable Scroll Content
//private struct RefreshableScrollContent<Content: View>: View {
//    @Binding var isRefreshing: Bool
//    let onRefresh: () async -> Void
//    let content: () -> Content
//    
//    var body: some View {
//        content()
//            .refreshable {
//                await onRefresh()
//            }
//    }
//}

#Preview {
    NavigationStack {
        TokenDetailView(
            token: Token(
                address: "So11111111111111111111111111111111111111112",
                symbol: "SOL",
                name: "Solana",
                price: 95.42,
                priceChange24h: 2.50,
                volume24h: 1_000_000,
                logoURI: nil
            )
        )
        .preferredColorScheme(.dark)
    }
} 
