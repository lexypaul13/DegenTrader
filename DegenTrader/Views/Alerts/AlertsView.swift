import SwiftUI

struct AlertsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.colors.background.ignoresSafeArea()
                
                // Empty state content
                VStack(spacing: 16) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.colors.textSecondary)
                    
                    VStack(spacing: 8) {
                        Text("You haven't set any alerts yet")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(AppTheme.colors.textPrimary)
                        
                        Text("Visit any token and tap the bell icon to set price alerts")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Alerts")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct PriceAlertView: View {
    @Environment(\.dismiss) private var dismiss
    let token: Token
    @State private var alertMode: AlertMode = .price
    @State private var priceCondition: PriceCondition = .under
    @State private var price: String = ""
    @State private var currency: Currency = .usd
    @FocusState private var isPriceFieldFocused: Bool
    
    enum AlertMode: String, CaseIterable {
        case price = "Alert by Price"
        case percentage = "Alert by %"
    }
    
    enum PriceCondition {
        case under, over
        
        var description: String {
            switch self {
            case .under: return "When price is under"
            case .over: return "When price is over"
            }
        }
    }
    
    enum Currency: String {
        case usd = "USD"
        case sol = "SOL"
    }
    
    private var isValidPrice: Bool {
        guard let inputPrice = Double(price) else { return false }
        let currentPrice = token.price
        
        // Prevent alerts too close to current price (within 1%)
        let minDifference = currentPrice * 0.01
        let priceDifference = abs(inputPrice - currentPrice)
        
        return priceDifference >= minDifference
    }
    
    private var displayPrice: String {
        price.isEmpty ? String(format: "%.3f", token.price) : price
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag Indicator
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 20)
            
            // Close Button
            Button("Close") {
                dismiss()
            }
            .font(.system(size: 17))
            .foregroundColor(AppTheme.colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // Content
            VStack(spacing: 24) {
                // Mode Selection
                HStack(spacing: 0) {
                    ForEach(AlertMode.allCases, id: \.self) { mode in
                        Button(action: { alertMode = mode }) {
                            Text(mode.rawValue)
                                .font(.system(size: 17))
                                .foregroundColor(alertMode == mode ? AppTheme.colors.textPrimary : AppTheme.colors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(alertMode == mode ? AppTheme.colors.cardBackground : Color.clear)
                        }
                    }
                }
                .background(AppTheme.colors.cardBackground.opacity(0.5))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                // Price Condition Text
                Text(priceCondition.description)
                    .font(.system(size: 17))
                    .foregroundColor(AppTheme.colors.textSecondary)
                
                // Price Input
                TextField(String(format: "%.3f", token.price), text: $price)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(AppTheme.colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .focused($isPriceFieldFocused)
                    .overlay(
                        Text(displayPrice)
                            .font(.system(size: 48, weight: .medium))
                            .foregroundColor(AppTheme.colors.textPrimary)
                            .opacity(isPriceFieldFocused ? 0 : 1)
                    )
                
                // Currency Toggle
                HStack(spacing: 0) {
                    ForEach([Currency.usd, Currency.sol], id: \.self) { curr in
                        Button(action: { currency = curr }) {
                            Text(curr.rawValue)
                                .font(.system(size: 15))
                                .foregroundColor(currency == curr ? AppTheme.colors.textPrimary : AppTheme.colors.textSecondary)
                                .frame(width: 60)
                                .padding(.vertical, 8)
                                .background(currency == curr ? AppTheme.colors.cardBackground : Color.clear)
                        }
                    }
                }
                .background(AppTheme.colors.cardBackground.opacity(0.5))
                .cornerRadius(20)
                
                // Current Price
                Text("Current Price \(String(format: "$%.3f", token.price))")
                    .font(.system(size: 15))
                    .foregroundColor(AppTheme.colors.textSecondary)
                
                // Set Alert Button
                Button(action: {
                    // Handle alert creation
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("Set Alert")
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(isValidPrice ? AppTheme.colors.accent : Color.gray)
                    .cornerRadius(28)
                }
                .disabled(!isValidPrice)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .background(AppTheme.colors.background)
        .onAppear {
            isPriceFieldFocused = true
        }
    }
}

#Preview {
    AlertsView()
        .preferredColorScheme(.dark)
}

#Preview("Price Alert") {
    PriceAlertView(token: Token(
        symbol: "SOL",
        name: "Solana",
        price: 104.23,
        priceChange24h: 2.5,
        volume24h: 1_500_000
    ))
    .preferredColorScheme(.dark)
} 