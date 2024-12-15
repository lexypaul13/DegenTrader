import SwiftUI

struct SwapView: View {
    @State private var fromAmount: String = "0.001231039"
    @State private var toAmount: String = "0.000001"
    @State private var showFromTokenSelect = false
    @State private var showToTokenSelect = false
    @State private var selectedFromToken = Token(symbol: "OMNI", name: "Omni", price: 0.36, priceChange24h: -5.28, volume24h: 500_000)
    @State private var selectedToToken = Token(symbol: "USDC", name: "USD Coin", price: 1.00, priceChange24h: 0.01, volume24h: 750_000)
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    
    private var isModal: Bool {
        return presentationMode.wrappedValue.isPresented
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 24) {
                // You Pay Section
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("You Pay")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.colors.textSecondary)
                            .padding(.bottom, 4)
                        
                        VStack(spacing: 4) {
                            HStack {
                                TextField("0", text: $fromAmount)
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.white)
                                    .keyboardType(.decimalPad)
                                
                                Spacer()
                                
                                Button(action: { showFromTokenSelect = true }) {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color.black.opacity(0.3))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Image(selectedFromToken.symbol.lowercased())
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 20, height: 20)
                                            )
                                        
                                        Text(selectedFromToken.symbol)
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppTheme.colors.textSecondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(.gray.opacity(0.1))                                        .clipShape(Capsule())
                                }
                            }
                            
                            Text("23,629.89647 \(selectedFromToken.symbol)")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.colors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(16)
                    .background(Color(hex: "1C1C1E"))
                    .cornerRadius(16)
                }
                
                // Swap Button
                Button(action: swapTokens) {
                    Circle()
                        .fill(AppTheme.colors.accent)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "1C1C1E"))
                        )
                }
                .padding(.vertical, -12)
                .zIndex(1)
                
                // You Receive Section
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("You Receive")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.colors.textSecondary)
                            .padding(.bottom, 4)
                        
                        VStack(spacing: 4) {
                            HStack {
                                TextField("0", text: $toAmount)
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.white)
                                    .keyboardType(.decimalPad)
                                
                                Spacer()
                                
                                Button(action: { showToTokenSelect = true }) {
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(Color.black.opacity(0.3))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Image(selectedToToken.symbol.lowercased())
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 20, height: 20)
                                            )
                                        
                                        Text(selectedToToken.symbol)
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
                            
                            Text("1234244 \(selectedFromToken.symbol)")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.colors.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(16)
                    .background(Color(hex: "1C1C1E"))
                    .cornerRadius(16)
                }
                
                // Continue Button
                Button(action: {}) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(hex: "1C1C1E"))
                        .cornerRadius(12)
                }
                .padding(.top, 12)
            }
            .padding(20)
            
            Spacer()
        }
        .background(AppTheme.colors.background)
        .sheet(isPresented: $showFromTokenSelect) {
            TokenSelectView(selectedToken: $selectedFromToken)
        }
        .sheet(isPresented: $showToTokenSelect) {
            TokenSelectView(selectedToken: $selectedToToken)
        }
        .navigationTitle("Swap Tokens")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isModal)
        .toolbar {
            if isModal {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private func swapTokens() {
        let temp = selectedFromToken
        selectedFromToken = selectedToToken
        selectedToToken = temp
        
        let tempAmount = fromAmount
        fromAmount = toAmount
        toAmount = tempAmount
    }
}

#Preview {
    SwapView()
        .preferredColorScheme(.dark)
} 
