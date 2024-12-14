import SwiftUI

struct TokenInputView: View {
    let title: String
    @Binding var amount: String
    @Binding var selectedToken: Token
    let balance: Double?
    let usdValue: String
    let hasError: Bool
    let errorMessage: String?
    var onAmountTap: () -> Void
    var onTokenSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.colors.textSecondary)
                    .padding(.bottom, 4)
                
                VStack(spacing: 4) {
                    HStack {
                        Button(action: onAmountTap) {
                            TextField("0", text: $amount)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(hasError ? .red : .white)
                                .disabled(true)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Spacer()
                        
                        Button(action: onTokenSelect) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.black.opacity(0.3))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(selectedToken.symbol.lowercased())
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                    )
                                
                                Text(selectedToken.symbol)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.colors.textSecondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.gray.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                    
                    HStack {
                        if let balance = balance {
                            Text("Balance: \(String(format: "%.8f", balance)) \(selectedToken.symbol)")
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Text(usdValue)
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.colors.textSecondary)
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }
                }
            }
            .padding(16)
            .background(Color(hex: "1C1C1E"))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(hasError ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
    }
} 