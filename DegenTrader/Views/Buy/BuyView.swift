import SwiftUI

struct BuyView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var walletManager = WalletManager.shared
    @State private var amount: String = "0"
    @State private var isProcessing = false
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
                // Token Info
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
                            isAmountFocused = true
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
                
                
                Spacer()
                
                // Buy Button
                Button(action: handleBuy) {
                    if isProcessing {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Text("Buy")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                .disabled(isProcessing || amount == "0")
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppTheme.colors.accent)
                .cornerRadius(28)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .alert("Transaction Status", isPresented: $showingAlert) {
            Button("OK") {
                if alertMessage.contains("Successfully") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
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
        .onAppear {
            isAmountFocused = true
        }
    }
    
    private func handleBuy() {
        guard let dollarAmount = Double(amount), dollarAmount >= minAmount else {
            alertMessage = "Minimum amount is $\(minAmount)"
            showingAlert = true
            return
        }
        
        isProcessing = true
        
        Task {
            do {
                try await walletManager.buySol(usdAmount: dollarAmount)
                await MainActor.run {
                    alertMessage = "Successfully bought \(formattedTokenAmount) \(token.symbol)"
                    showingAlert = true
                    amount = "0"
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    alertMessage = error.localizedDescription
                    showingAlert = true
                    isProcessing = false
                }
            }
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
            volume24h: 1_500_000,
            logoURI: nil,
            address: "So11111111111111111111111111111111111111112"
        ))
    }
    .preferredColorScheme(.dark)
} 
