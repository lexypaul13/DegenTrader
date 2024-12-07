import SwiftUI

struct TransactionHistorySection: View {
    let transactions: [Transaction]
    @State private var displayedTransactions: Int = 5 // Initial number of transactions to show
    @State private var selectedTransaction: Transaction?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Transaction History")
                .font(.system(size: 24))
                .foregroundColor(.gray)
            
            VStack(spacing: 1) {
                ForEach(Array(transactions.prefix(displayedTransactions).enumerated()), id: \.element.id) { index, transaction in
                    Button(action: {
                        selectedTransaction = transaction
                    }) {
                        TransactionRow(
                            transaction: transaction,
                            isLastItem: index == displayedTransactions - 1 || index == transactions.count - 1
                        )
                    }
                }
                
                if displayedTransactions < transactions.count {
                    Button(action: {
                        withAnimation {
                            displayedTransactions += 5
                        }
                    }) {
                        Text("Show More")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.colors.accent)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.colors.cardBackground)
                    }
                }
            }
            .background(AppTheme.colors.cardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailView(transaction: transaction)
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    let isLastItem: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Token Icons
                HStack(spacing: -8) {
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(transaction.fromToken.symbol.lowercased())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        )
                    
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(transaction.toToken.symbol.lowercased())
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Swapped")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: "+%.5f %@", transaction.toAmount, transaction.toToken.symbol))
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                    
                    Text(String(format: "%.5f %@", -transaction.fromAmount, transaction.fromToken.symbol))
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            }
            .padding(16)
            
            if !isLastItem {
                Divider()
                    .background(Color.gray.opacity(0.3))
            }
        }
    }
}

#Preview {
    NavigationView {
        TransactionHistorySection(transactions: [
            Transaction(
                date: Date(),
                type: .swapped,
                fromToken: Token(symbol: "SOL", name: "Solana", price: 1.18, priceChange24h: -2.41, volume24h: 1_000_000),
                toToken: Token(symbol: "JEFFY", name: "Jeffy", price: 0.36, priceChange24h: -5.28, volume24h: 500_000),
                fromAmount: 0.04291,
                toAmount: 7133.29855
            )
        ])
        .preferredColorScheme(.dark)
        .background(AppTheme.colors.background)
    }
} 
