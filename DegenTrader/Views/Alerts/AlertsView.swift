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
    @State private var alertMode: AlertMode
    @State private var priceCondition: PriceCondition
    @State private var price: String
    @State private var currency: Currency
    @State private var timeFrame: TimeFrame
    @State private var isRecurring = false
    @FocusState private var isPriceFieldFocused: Bool
    
    init(
        token: Token,
        alertMode: AlertMode = .price,
        priceCondition: PriceCondition = .under,
        price: String = "",
        currency: Currency = .usd,
        timeFrame: TimeFrame = .day
    ) {
        self.token = token
        _alertMode = State(initialValue: alertMode)
        _priceCondition = State(initialValue: priceCondition)
        _price = State(initialValue: price)
        _currency = State(initialValue: currency)
        _timeFrame = State(initialValue: timeFrame)
    }
    
    enum AlertMode: String, CaseIterable {
        case price = "Alert by Price"
        case percentage = "Alert by %"
    }
    
    enum PriceCondition {
        case under, over
        
        func description(for mode: AlertMode) -> String {
            switch self {
            case .under: return mode == .price ? "When price is under" : "When price drops"
            case .over: return mode == .price ? "When price is over" : "When price increases"
            }
        }
    }
    
    enum Currency: String {
        case usd = "USD"
        case sol = "SOL"
    }
    
    enum TimeFrame: String {
        case day = "24hr"
        case hour = "1hr"
    }
    
    private var isValidPrice: Bool {
        guard let inputValue = Double(price) else { return false }
        
        if alertMode == .price {
            let currentPrice = token.price
            let minDifference = currentPrice * 0.01
            let priceDifference = abs(inputValue - currentPrice)
            return priceDifference >= minDifference
        } else {
            // For percentage mode, allow any value between 1-100
            return inputValue >= 1 && inputValue <= 100
        }
    }
    
    private var displayPrice: String {
        if alertMode == .price {
            return price.isEmpty ? String(format: "%.3f", token.price) : price
        } else {
            return price.isEmpty ? "0" : "\(price)%"
        }
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
                        Button(action: { 
                            alertMode = mode
                            price = ""  // Reset price when switching modes
                        }) {
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
                
                // Price Input Section
                VStack(spacing: 24) {
                    if alertMode == .percentage {
                        // Trend Text
                        Text(priceCondition.description(for: alertMode))
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.colors.textSecondary)
                        
                        // Percentage Input Row
                        HStack(spacing: -8) {
                            Circle()
                                .fill(Color(white: 0.01))
                                .overlay(
                                    Image(systemName: priceCondition == .under ? "arrow.down" : "arrow.up")
                                        .foregroundColor(priceCondition == .under ? .red : .green)
                                        .font(.system(size: 24))
                                )
                                .onTapGesture {
                                    priceCondition = priceCondition == .under ? .over : .under
                                }
                            
                            HStack(alignment: .firstTextBaseline, spacing: -4) {
                                TextField("10", text: $price)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 72, weight: .medium))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    
                                Text("%")
                                    .font(.system(size: 48, weight: .medium))
                                    .foregroundColor(AppTheme.colors.textSecondary)
                            }
                            .fixedSize()
                            .padding(.horizontal)

                        }
                        .frame(maxWidth: 150)
                        .frame(maxWidth: .infinity)
                        
                        // Time Frame Toggle
                        HStack(spacing: 0) {
                            ForEach([TimeFrame.day, TimeFrame.hour], id: \.self) { frame in
                                Button(action: { timeFrame = frame }) {
                                    Text(frame.rawValue)
                                        .font(.system(size: 15))
                                        .foregroundColor(timeFrame == frame ? AppTheme.colors.textPrimary : AppTheme.colors.textSecondary)
                                        .frame(width: 60)
                                        .padding(.vertical, 8)
                                        .background(timeFrame == frame ? AppTheme.colors.cardBackground : Color.clear)
                                }
                            }
                        }
                        .background(AppTheme.colors.cardBackground.opacity(0.5))
                        .cornerRadius(20)
                        
                        // Recurring Alert Toggle
                        Toggle("Get recurring alert", isOn: $isRecurring)
                            .tint(AppTheme.colors.accent)
                            .padding(.horizontal, 20)
                    } else {
                        // Price mode content...
                        Text(priceCondition.description(for: alertMode))
                            .font(.system(size: 17))
                            .foregroundColor(AppTheme.colors.textSecondary)
                            
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
                    }
                }
                .padding(.horizontal, 20)
                
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

#Preview("Price Alert - Price Mode") {
    PriceAlertView(token: Token(
        symbol: "SOL",
        name: "Solana",
        price: 104.23,
        priceChange24h: 2.5,
        volume24h: 1_500_000
    ))
    .preferredColorScheme(.dark)
} 
