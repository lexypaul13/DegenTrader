import SwiftUI
struct BuyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = "0"
    @FocusState private var isAmountFocused: Bool
    let token: Token
    
    private let quickAmounts = [100, 500, 1000]
    
    var formattedTokenAmount: String {
        guard let dollarAmount = Double(amount) else { return "0.00" }
        let tokenAmount = dollarAmount / token.price
        return String(format: "%.2f", tokenAmount)
    }
    
    var body: some View {
        ZStack {
            AppTheme.colors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
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
            
                Button(action: {}) {
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
        .animation(.easeInOut(duration: 0.25), value: isAmountFocused)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
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
