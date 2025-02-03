import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Navigation Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                
                Spacer()
                
                Text("Token Swap")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Invisible button for centering
                Image(systemName: "xmark")
                    .opacity(0)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            VStack(spacing: 16) {
                // Token Logos at the top
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(transaction.fromToken.symbol.lowercased())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        )
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Circle()
                        .fill(Color.black)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(transaction.toToken.symbol.lowercased())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        )
                }
                
                // Large Token Symbols
                HStack(spacing: 40) {
                    Text(transaction.fromToken.symbol)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(transaction.toToken.symbol)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 20)
            
            // Transaction Details
            VStack(spacing: 1) {
                TransactionDetailRow(title: "Date", value: transaction.formattedDate)
                
                TransactionDetailRow(
                    title: "Status",
                    value: transaction.status.text,
                    valueColor: transaction.status.color
                )
                
                TransactionDetailRow(title: "Network", value: "Solana")
                
                TransactionDetailRow(
                    title: "Network Fee",
                    value: String(format: "-%.5f SOL", 0.00211)
                )
                
                TransactionDetailRow(
                    title: "You Paid",
                    value: String(format: "-%.5f %@", transaction.fromAmount, transaction.fromToken.symbol)
                )
                
                TransactionDetailRow(
                    title: "You Received",
                    value: String(format: "+%.5f %@", transaction.toAmount, transaction.toToken.symbol),
                    valueColor: .green
                )
            }
            .background(AppTheme.colors.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            // Swap Again Button
            Button(action: {}) {
                Text("Swap Again")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppTheme.colors.accent)
                    .cornerRadius(28)
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .background(AppTheme.colors.background)
    }
}

struct TransactionDetailRow: View {
    let title: String
    let value: String
    var valueColor: Color = .white
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(valueColor)
        }
        .padding(16)
    }
}

#Preview {
    NavigationView {
        TransactionDetailView(
            transaction: Transaction(
                date: Date(),
                fromToken: Token(address: "swdwdwd", symbol: "SOL", name: "Solana", price: 1.18, priceChange24h: -2.41, volume24h: 1_000_000, logoURI: nil),
                toToken: Token(address:"ceedscds", symbol: "OMNI", name: "Omni", price: 0.36, priceChange24h: -5.28, volume24h: 500_000, logoURI: nil),
                fromAmount: 0.06725,
                toAmount: 23629.89647,
                status: .succeeded,
                source: "Phantom"
            )
        )
    }
} 
