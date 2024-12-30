import SwiftUI

struct BuyView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var walletManager = WalletManager.shared
    @State private var amount: String = "0"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @FocusState private var isAmountFocused: Bool
    let token: Token
    
    private let quickAmounts = [100, 500, 1000]
    private let minAmount = 1.0
    
    var formattedTokenAmount: String {
        guard let dollarAmount = Double(amount) else { return "0.00" }
        let tokenAmount = dollarAmount / token.price
        return String(format: "%.4f", tokenAmount)
    }
    
    var body: some View {
        ZStack {
            AppTheme.colors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Balance Display
                Text("Balance: \(String(format: "%.4f", walletManager.getBalance(for: token.symbol))) \(token.symbol)")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                
                // Amount Display
                VStack(spacing: 8) {
                    Text("$\(amount == "0" ? "0" : amount)")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("\(formattedTokenAmount) \(token.symbol)")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                
                // Quick Amount Buttons
                HStack(spacing: 16) {
                    ForEach(quickAmounts, id: \.self) { value in
                        Button(action: {
                            amount = "\(value)"
                        }) {
                            Text("$\(value)")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color(hex: "2C2C2E"))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 24)
            
                Button(action: handleBuy) {
                    Text("Buy")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppTheme.colors.accent)
                        .cornerRadius(28)
                }
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            
            // Hidden TextField for keyboard input
            TextField("0", text: $amount)
                .keyboardType(.decimalPad)
                .focused($isAmountFocused)
                .opacity(0)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Buy \(token.symbol)")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            }
        }
        .alert("Transaction", isPresented: $showingAlert) {
            Button("OK") { 
                if alertMessage.contains("Successfully") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            isAmountFocused = true
        }
    }
    
    private func handleBuy() {
        guard let dollarAmount = Double(amount) else {
            alertMessage = "Invalid amount"
            showingAlert = true
            return
        }
        
        let tokenAmount = dollarAmount / token.price
        
        // Update the balance first
        if walletManager.buy(amount: tokenAmount, symbol: token.symbol) {
            // If buy succeeds, add the transaction
            walletManager.addTransaction(Transaction(
                date: Date(),
                fromToken: Token(symbol: "USD", name: "US Dollar", price: 1.0, priceChange24h: 0, volume24h: 0),
                toToken: token,
                fromAmount: dollarAmount,
                toAmount: tokenAmount,
                status: .succeeded,
                source: "Buy"
            ))
            
            alertMessage = "Successfully bought \(String(format: "%.4f", tokenAmount)) \(token.symbol)"
            showingAlert = true
            amount = "0"
        } else {
            alertMessage = "Transaction failed"
            showingAlert = true
        }
    }
}


#Preview {
    NavigationView {
        BuyView(token: Token(
            symbol: "SOL",
            name: "Solana",
            price: 95.42,
            priceChange24h: 2.5,
            volume24h: 1_500_000
        ))
    }
    .preferredColorScheme(.dark)
} 
