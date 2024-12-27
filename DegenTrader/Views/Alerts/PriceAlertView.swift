import SwiftUI

struct PriceAlertView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var alertsManager = AlertsManager.shared
    let token: Token
    let existingAlert: Alert?
    @State private var alertMode: AlertMode
    @State private var priceCondition: PriceCondition
    @State private var price: String
    @State private var currency: Currency
    @State private var timeFrame: TimeFrame
    @State private var isRecurring = false
    @FocusState private var isPriceFieldFocused: Bool
    
    init(
        token: Token,
        existingAlert: Alert? = nil,
        alertMode: AlertMode = .price,
        priceCondition: PriceCondition = .under,
        price: String = "",
        currency: Currency = .usd,
        timeFrame: TimeFrame = .day
    ) {
        self.token = token
        self.existingAlert = existingAlert
        _alertMode = State(initialValue: existingAlert?.mode ?? alertMode)
        _priceCondition = State(initialValue: existingAlert?.condition ?? priceCondition)
        _price = State(initialValue: existingAlert != nil ? String(format: "%.2f", existingAlert!.value) : price)
        _currency = State(initialValue: currency)
        _timeFrame = State(initialValue: existingAlert?.timeFrame ?? timeFrame)
    }
    
    enum Currency: String {
        case usd = "USD"
        case sol = "SOL"
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
            .foregroundColor(.yellow)
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
                        HStack {
                            Circle()
                                .fill(Color(white: 0.01))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: priceCondition == .under ? "arrow.down" : "arrow.up")
                                        .foregroundColor(priceCondition == .under ? .red : .green)
                                        .font(.system(size: 24))
                                )
                                .onTapGesture {
                                    priceCondition = priceCondition == .under ? .over : .under
                                }
                            
                            HStack(alignment: .firstTextBaseline) {
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
                    if let value = Double(price) {
                        let alert = Alert(
                            token: token,
                            mode: alertMode,
                            condition: priceCondition,
                            value: value,
                            timeFrame: alertMode == .percentage ? timeFrame : nil,
                            isEnabled: existingAlert?.isEnabled ?? true
                        )
                        
                        if let existing = existingAlert {
                            alertsManager.updateAlert(alert)
                        } else {
                            alertsManager.addAlert(alert: alert)
                        }
                    }
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "bell.fill")
                        Text(existingAlert != nil ? "Update Alert" : "Set Alert")
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
    PriceAlertView(token: Token(
        symbol: "SOL",
        name: "Solana",
        price: 104.23,
        priceChange24h: 2.5,
        volume24h: 1_500_000
    ))
    .preferredColorScheme(.dark)
} 