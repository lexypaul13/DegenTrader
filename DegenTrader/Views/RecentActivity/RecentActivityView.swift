import SwiftUI

struct RecentActivityView: View {
    @StateObject private var walletManager = WalletManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.colors.background.ignoresSafeArea()
                
                if walletManager.transactions.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(Color(white: 0.5))
                        
                        VStack(spacing: 8) {
                            Text("No Recent Activity")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Your recent transactions will appear here")
                                .font(.system(size: 15))
                                .foregroundColor(Color(white: 0.5))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 32)
                } else {
                    List {
                        ForEach(walletManager.transactions.groupedByDate, id: \.0) { date, transactions in
                            Section {
                                ForEach(transactions) { transaction in
                                    RecentActivityRow(transaction: transaction)
                                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                        .listRowBackground(Color.clear)
                                }
                            } header: {
                                Text(date)
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .textCase(nil)
                                    .padding(.leading, 16)
                                    .padding(.bottom, 8)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Recent Activity")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RecentActivityRow: View {
    let transaction: Transaction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row: "Swapped via Jupiter"
            HStack(spacing: 4) {
                Text("Swapped")
                    .foregroundColor(.white)
                Text("via \(transaction.source)")
                    .foregroundColor(.gray)
            }
            .font(.system(size: 15))
            
            // Bottom row: Transaction details
            HStack(alignment: .center) {
                // Left side: Transaction icon
                ZStack {
                    Circle()
                        .fill(transaction.status == .succeeded ? Color(white: 0.15) : Color.red.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: transaction.status == .succeeded ? "arrow.left.arrow.right" : "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(transaction.status == .succeeded ? .white : .red)
                }
                
                // Middle: Amount details
                HStack(spacing: 4) {
                    Text(formatAmount(transaction.fromAmount))
                        .foregroundColor(.white)
                    Text(transaction.fromToken.symbol)
                        .foregroundColor(.gray)
                    Text("→")
                        .foregroundColor(.gray)
                    Text(formatAmount(transaction.toAmount))
                        .foregroundColor(.white)
                    Text(transaction.toToken.symbol)
                        .foregroundColor(.gray)
                }
                .font(.system(size: 15))
                
                Spacer()
                
                // Right: Failed badge if needed
                if transaction.status == .failed {
                    Text("Failed")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(6)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(white: 0.1))
        .cornerRadius(12)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount >= 1_000_000 {
            return String(format: "%.2f", amount/1_000_000) + "M"
        } else if amount >= 1_000 {
            return String(format: "%.2f", amount/1_000) + "K"
        } else if amount >= 1 {
            return String(format: "%.4f", amount)
        } else {
            return String(format: "%.8f", amount)
        }
    }
}

#Preview {
    RecentActivityView()
        .preferredColorScheme(.dark)
} 