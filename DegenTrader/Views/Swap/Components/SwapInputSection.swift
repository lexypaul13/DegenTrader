import SwiftUI

struct SwapInputSection: View {
    let title: String
    @Binding var amount: String
    @Binding var selectedToken: Token
    let onTokenSelect: () -> Void
    let onAmountFocus: () -> Void
    let isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.colors.textSecondary)
                    .padding(.bottom, 4)
                
                VStack(spacing: 4) {
                    HStack {
                        AmountInput(
                            amount: $amount,
                            onFocus: onAmountFocus
                        )
                        
                        Spacer()
                        
                        TokenButton(
                            token: selectedToken,
                            action: onTokenSelect
                        )
                    }
                    
                    TokenValueText(
                        amount: "23,629.89647",
                        symbol: selectedToken.symbol
                    )
                }
            }
            .padding(16)
            .background(Color(hex: "1C1C1E"))
            .cornerRadius(16)
        }
    }
}

private struct AmountInput: View {
    @Binding var amount: String
    let onFocus: () -> Void
    
    var body: some View {
        TextField("0", text: $amount)
            .font(.system(size: 32, weight: .medium))
            .foregroundColor(.white)
            .keyboardType(.decimalPad)
            .onTapGesture(perform: onFocus)
    }
}

private struct TokenValueText: View {
    let amount: String
    let symbol: String
    
    var body: some View {
        Text("\(amount) \(symbol)")
            .font(.system(size: 15))
            .foregroundColor(AppTheme.colors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .clipShape(Capsule())
    }
} 