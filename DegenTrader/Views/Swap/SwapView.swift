import SwiftUI
import UIKit

struct SwapView: View {
    @State private var fromAmount: String
    @State private var toAmount: String = "0.000001"
    @State private var showFromTokenSelect = false
    @State private var showToTokenSelect = false
    @State private var selectedFromToken: Token
    @State private var selectedToToken: Token
    @State private var isSwapping = false
    @State private var rotationAngle: Double = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @FocusState private var focusedField: Field?
    @StateObject private var walletManager = WalletManager.shared
    
    enum Field {
        case from, to
    }

    init(selectedFromToken: Token = Token(symbol: "OMNI", name: "Omni", price: 0.36, priceChange24h: -5.28, volume24h: 500_000, logoURI: nil),
         selectedToToken: Token = Token(symbol: "USDC", name: "USD Coin", price: 1.00, priceChange24h: 0.01, volume24h: 750_000, logoURI: nil),
         fromAmount: String = "0.001231039") {
        _selectedFromToken = State(initialValue: selectedFromToken)
        _selectedToToken = State(initialValue: selectedToToken)
        _fromAmount = State(initialValue: fromAmount)
    }

    private var isModal: Bool {
        presentationMode.wrappedValue.isPresented
    }

    var body: some View {
            ZStack {
                AppTheme.colors.background.ignoresSafeArea()
                    VStack{
                        youPaySection
                            
                        swapButton
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                        youReceiveSection
                            .padding(.bottom, 40)
                        continueButton
                            .ignoresSafeArea(.keyboard)

                    }
                    .padding(.horizontal, 10)
                   
            }
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
    

    
    private var youPaySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("You Pay")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.colors.textSecondary)
                .padding(.bottom, 4)

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    CustomTextField(text: $fromAmount, field: .from, focusedField: $focusedField)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                    
                    Button(action: { showFromTokenSelect = true }) {
                        TokenButton(token: selectedFromToken, action: { showFromTokenSelect = true })
                    }
                    .frame(width: 140)
                }
                .frame(height: 40)
                .offset(x: isSwapping ? UIScreen.main.bounds.width : 0)
                .opacity(isSwapping ? 0 : 1)
                .animation(.easeInOut(duration: 0.3), value: isSwapping)

                HStack {
                    Spacer()
                    Text("\(walletManager.balances[selectedFromToken.symbol] ?? 0) \(selectedFromToken.symbol)")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                }
                .padding(.trailing, 16)
            }
        }
        .padding(16)
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(16)
    }
    
    private var youReceiveSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("You Receive")
                .font(.system(size: 16))
                .foregroundColor(AppTheme.colors.textSecondary)
                .padding(.bottom, 4)

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    CustomTextField(text: $toAmount, field: .to, focusedField: $focusedField)
                        .frame(maxWidth: .infinity, maxHeight: 40)
                    
                    Button(action: { showToTokenSelect = true }) {
                        TokenButton(token: selectedToToken, action: { showToTokenSelect = true })
                    }
                    .frame(width: 140)
                }
                .frame(height: 40)
                .offset(x: isSwapping ? -UIScreen.main.bounds.width : 0)
                .opacity(isSwapping ? 0 : 1)
                .animation(.easeInOut(duration: 0.3), value: isSwapping)

                HStack {
                    Spacer()
                    Text("\(walletManager.balances[selectedToToken.symbol] ?? 0) \(selectedToToken.symbol)")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                }
                .padding(.trailing, 16)
            }
        }
        .padding(16)
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(16)
    }
    
    private var swapButton: some View {
        Button(action: animateSwap) {
            Circle()
                .fill(AppTheme.colors.accent)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "1C1C1E"))
                        .rotationEffect(.degrees(rotationAngle))
                )
        }
        .padding(.vertical, -12)
        .zIndex(1)
    }
    
    private var continueButton: some View {
        Button("Continue") {
            // Action
        }
        .font(.system(size: 16, weight: .semibold))
        .foregroundColor(Color(hex: "1C1C1E"))
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(AppTheme.colors.accent)
        .cornerRadius(28)
    }

    private func animateSwap() {
        withAnimation(.easeInOut(duration: 0.3)) {
            rotationAngle += 180
        }
        withAnimation(.easeInOut(duration: 0.15)) {
            isSwapping = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            swapTokens()
            withAnimation(.easeInOut(duration: 0.15)) {
                isSwapping = false
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
    
    private func handlePercentage(_ percentage: Double) {
        if focusedField == .from {
            let maxAmount = selectedFromToken.price * 100
            fromAmount = String(format: "%.8f", maxAmount * percentage)
        } else if focusedField == .to {
            let maxAmount = selectedToToken.price * 100
            toAmount = String(format: "%.8f", maxAmount * percentage)
        }
    }
}

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    let field: SwapView.Field
    let focusedField: FocusState<SwapView.Field?>.Binding
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.delegate = context.coordinator
        textField.text = text
        textField.font = .systemFont(ofSize: 32, weight: .medium)
        textField.textColor = .white
        textField.textAlignment = .left
        textField.backgroundColor = .clear
        
        // Configure text field
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 16
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        
        let percentageView = UIHostingController(rootView:
            PercentageButtonsView(handlePercentage: { percentage in
                let maxAmount = 100.0 // Example max amount
                text = String(format: "%.8f", maxAmount * percentage)
            }, onDone: {
                textField.resignFirstResponder()
            })
        )
        percentageView.view.backgroundColor = .clear
        textField.inputAccessoryView = percentageView.view
        
        let size = CGSize(width: UIScreen.main.bounds.width, height: 50)
        percentageView.view.frame = CGRect(origin: .zero, size: size)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
            let newPosition = uiView.endOfDocument
            uiView.selectedTextRange = uiView.textRange(from: newPosition, to: newPosition)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField
        
        init(_ parent: CustomTextField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            // Only allow one decimal point
            let components = updatedText.components(separatedBy: ".")
            if components.count > 2 {
                return false
            }
            
            // Count total digits (excluding decimal point)
            let totalDigits = updatedText.filter { $0.isNumber }.count
            if totalDigits > 18 {
                return false
            }
            
            // Only allow numbers and decimal point
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            let characterSet = CharacterSet(charactersIn: string)
            guard allowedCharacters.isSuperset(of: characterSet) else {
                return false
            }
            
            DispatchQueue.main.async {
                self.parent.text = updatedText
            }
            
            return true
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            self.parent.focusedField.wrappedValue = self.parent.field
        }
    }
}

struct PercentageButtonsView: View {
    let handlePercentage: (Double) -> Void
    let onDone: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(["25%", "50%", "Max"], id: \.self) { percentage in
                Button(action: {
                    switch percentage {
                    case "25%": handlePercentage(0.25)
                    case "50%": handlePercentage(0.5)
                    case "Max": handlePercentage(1.0)
                    default: break
                    }
                }) {
                    Text(percentage)
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(Color(white: 0.2))
                        .cornerRadius(8)
                }
            }
            
            Button("Done") {
                onDone()
            }
            .font(.system(size: 17))
            .foregroundColor(.white)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color(white: 0.1))
    }
}

#Preview {
    NavigationView {
        SwapView(selectedFromToken: Token(symbol: "OMNI", name: "Omni", price: 0.36, priceChange24h: -5.28, volume24h: 500_000, logoURI: nil ),
                selectedToToken: Token(symbol: "USDC", name: "USD Coin", price: 1.00, priceChange24h: 0.01, volume24h: 750_000, logoURI: nil),
                fromAmount: "0.001231039")
    }
    .preferredColorScheme(.dark)
}

