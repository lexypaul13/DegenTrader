import SwiftUI

struct TokenDetailView: View {
    let token: Token
    @StateObject private var walletManager = WalletManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showPriceAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Balance Section Header
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
                    
                    // More Button
                    Button(action: {}) {
                        VStack(spacing: 8) {
                            Capsule()
                                .fill(AppTheme.colors.cardBackground)
                                .frame(width: 100, height: 44)
                                .overlay(
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                )
                            Text("More")
                                .font(.system(size: 14))
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                .padding(.top, 8)
                
                // Info Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Info")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 0) {
                        TokenInfoRow(title: "Mint", value: "8v2W...pump")
                        Divider().background(Color.gray.opacity(0.3))
                        TokenInfoRow(title: "Market Cap", value: "$18.23K")
                        Divider().background(Color.gray.opacity(0.3))
                        TokenInfoRow(title: "Total Supply", value: "999.11M")
                        Divider().background(Color.gray.opacity(0.3))
                        TokenInfoRow(title: "Circulating Supply", value: "999.11M")
                        Divider().background(Color.gray.opacity(0.3))
                        TokenInfoRow(title: "Holders", value: "13,315")
                    }
                    .padding(16)
                    .background(AppTheme.colors.cardBackground)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // 24h Performance Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("24h Performance")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 0) {
                        TokenPerformanceRow(title: "Volume", value: "$101.19", change: 106.87)
                        Divider().background(Color.gray.opacity(0.3))
                        TokenPerformanceRow(title: "Trades", value: "11", change: 10.00)
                        Divider().background(Color.gray.opacity(0.3))
                        TokenPerformanceRow(title: "Traders", value: "11", change: 37.50)
                    }
                    .padding(16)
                    .background(AppTheme.colors.cardBackground)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Security Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Security")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 0) {
                        TokenInfoRow(title: "Top 10 Holders", value: "68.58%")
                        Divider().background(Color.gray.opacity(0.3))
                        TokenInfoRow(title: "Mintable", value: "No")
                        Divider().background(Color.gray.opacity(0.3))
                        TokenInfoRow(title: "Mutable Info", value: "No")
                        Divider().background(Color.gray.opacity(0.3))
                        TokenInfoRow(title: "Ownership Renounced", value: "No")
                        Divider().background(Color.gray.opacity(0.3))
                        TokenInfoRow(title: "Update Authority", value: "TSLvd...1eokM")
                    }
                    .padding(16)
                    .background(AppTheme.colors.cardBackground)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
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
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showPriceAlert) {
            PriceAlertView(token: token)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

struct TokenInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.white)
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

#Preview {
    NavigationView {
        TokenDetailView(
            token: Token(
                symbol: "JEFFY",
                name: "Jeffy",
                price: 0.00003851,
                priceChange24h: 29.05,
                volume24h: 1_000_000
            )
        )
    }
} 
