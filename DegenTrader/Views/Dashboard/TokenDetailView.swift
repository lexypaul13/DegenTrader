import SwiftUI

struct TokenDetailContainerView: View {
    let token: Token
    @StateObject private var viewModel: TokenDetailViewModel
    @ObservedObject var walletManager: WalletManager
    
    init(token: Token, walletManager: WalletManager) {
        self.token = token
        self.walletManager = walletManager
        self._viewModel = StateObject(wrappedValue: TokenDetailViewModel(apiService: DexScreenerAPIService()))
    }
    
    var body: some View {
        TokenDetailView(token: token)
            .environmentObject(viewModel)
            .environmentObject(walletManager)
    }
}

// Custom toolbar content - keeping for future reference if needed
/*
struct CustomToolbarContent: ToolbarContent {
    let title: String
    let onDismiss: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                onDismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .imageScale(.large)
            }
        }
    }
}
*/

struct TokenDetailView: View {
    let token: Token
    @EnvironmentObject private var walletManager: WalletManager
    @EnvironmentObject private var viewModel: TokenDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showPriceAlert = false
    
    init(token: Token) {
        print("🏗️ [TokenDetailView] Initializing with token: \(token.symbol)")
        self.token = token
    }
    
    private func logViewState() {
        if viewModel.isLoading {
            print("⏳ [TokenDetailView] Showing loading state")
        } else if viewModel.errorMessage != nil {
            print("❌ [TokenDetailView] Showing error: \(viewModel.errorMessage ?? "")")
        } else if viewModel.tokenDetails != nil {
            print("📊 [TokenDetailView] Displaying token details:")
            print("   Market Cap: \(viewModel.formattedMarketCap)")
            print("   Liquidity: \(viewModel.formattedLiquidity)")
            print("   Volume: \(viewModel.formattedVolume)")
            print("   Price Change: \(viewModel.formattedPriceChange)")
        }
    }
    
    var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Info")
                .font(.system(size: 24))
                .foregroundColor(.gray)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .onAppear { logViewState() }
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .onAppear { logViewState() }
            } else {
                VStack(spacing: 0) {
                    TokenInfoRow(title: "Address", value: token.address, isAddress: true)
                    Divider().background(Color.gray.opacity(0.3))
                    TokenInfoRow(
                        title: "Market Cap",
                        value: viewModel.formattedMarketCap
                    )
                    Divider().background(Color.gray.opacity(0.3))
                    TokenInfoRow(
                        title: "Liquidity",
                        value: viewModel.formattedLiquidity
                    )
                    Divider().background(Color.gray.opacity(0.3))
                    TokenInfoRow(
                        title: "Volume 24h",
                        value: viewModel.formattedVolume
                    )
                    Divider().background(Color.gray.opacity(0.3))
                    TokenInfoRow(
                        title: "Price Change 24h",
                        value: viewModel.formattedPriceChange,
                        isPriceChange: true
                    )
                }
                .padding(16)
                .background(AppTheme.colors.cardBackground)
                .cornerRadius(12)
                .onAppear { logViewState() }
            }
        }
        .padding(.horizontal)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 24) {
                // Chart Section
                TokenChartView(token: token)
                    .padding(.top, 16)
                
                // Action Buttons
                HStack(spacing: 30) {
                    // Swap Button
                    NavigationLink {
                        SwapView(selectedFromToken: token, fromAmount: String(format: "%.8f", walletManager.getBalance(for: token.symbol)))
                    } label: {
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
                    
                    // Alert Button
                    Button(action: { showPriceAlert = true }) {
                        VStack(spacing: 8) {
                            Capsule()
                                .fill(AppTheme.colors.cardBackground)
                                .frame(width: 100, height: 44)
                                .overlay(
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                )
                            Text("Set Alert")
                                .font(.system(size: 14))
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                .padding(.top, 8)
                
                // Balance Section
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
                                    Image(token.symbol.lowercased())
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(token.name)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("\(String(format: "%.5f", walletManager.getBalance(for: token.symbol))) \(token.symbol)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                        
                        // Price Info
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("$\(String(format: "%.2f", walletManager.getBalance(for: token.symbol) * token.price))")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            let priceChange = token.price * token.priceChange24h / 100.0
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
                
                // Info Section
                infoSection
            }
            .padding(.vertical, 24)
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
                Button {
                    dismiss()
                } label: {
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
        .onAppear {
            print("👀 [TokenDetailView] View appeared for token: \(token.symbol)")
            viewModel.fetchTokenDetails(chainId: "solana", pairId: token.address)
        }
        .onChange(of: viewModel.tokenDetails) { newValue in
            print("🔄 [TokenDetailView] Token details updated:")
            print("   Has Details: \(newValue != nil)")
            if let details = newValue {
                print("   Market Cap: \(details.marketCap ?? 0)")
                print("   Liquidity: \(details.liquidity.usd)")
                print("   Volume: \(details.volume?.h24 ?? 0)")
                print("   Price Change: \(details.priceChange.h24)")
            }
        }
    }
}

struct TokenInfoRow: View {
    let title: String
    let value: String
    let isPriceChange: Bool
    let isAddress: Bool
    @State private var showCopied = false
    
    init(title: String, value: String, isPriceChange: Bool = false, isAddress: Bool = false) {
        self.title = title
        self.value = value
        self.isPriceChange = isPriceChange
        self.isAddress = isAddress
    }
    
    private var isPositive: Bool {
        guard isPriceChange else { return false }
        return value.hasPrefix("+")
    }
    
    private var formattedAddress: String {
        guard isAddress else { return value }
        if value.count > 12 {
            let prefix = String(value.prefix(6))
            let suffix = String(value.suffix(4))
            return "\(prefix)...\(suffix)"
        }
        return value
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = value
        withAnimation {
            showCopied = true
        }
        
        // Hide the "Copied" message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopied = false
            }
        }
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            Spacer()
            if isAddress {
                HStack(spacing: 8) {
                    Button(action: copyToClipboard) {
                        HStack(spacing: 4) {
                            Text(formattedAddress)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    if showCopied {
                        Text("Copied!")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.colors.positive)
                            .transition(.opacity)
                    }
                }
            } else {
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(isPriceChange ? (isPositive ? AppTheme.colors.positive : AppTheme.colors.negative) : .white)
            }
        }
        .padding(.vertical, 12)
    }
}

struct TokenPerformanceRow: View {
    let title: String
    let value: String
    let change: Double
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            Spacer()
            HStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                Text("\(String(format: "%.2f", change))%")
                    .font(.system(size: 14))
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 12)
    }
}

