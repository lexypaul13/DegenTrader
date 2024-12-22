import SwiftUI
import UIKit

struct SwapView: View {
    @State private var fromAmount: String
    @State private var toAmount: String = "0.000001"
    @State private var showFromTokenSelect = false
    @State private var showToTokenSelect = false
    @State private var selectedFromToken: Token
    @State private var selectedToToken = Token(symbol: "USDC", name: "USD Coin", price: 1.00, priceChange24h: 0.01, volume24h: 750_000)
    @State private var isSwapping = false
    @State private var rotationAngle: Double = 0
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @FocusState private var focusedField: Field?
    
    enum Field {
        case from, to
    }

    init(selectedFromToken: Token = Token(symbol: "OMNI", name: "Omni", price: 0.36, priceChange24h: -5.28, volume24h: 500_000),
         fromAmount: String = "0.001231039") {
        _selectedFromToken = State(initialValue: selectedFromToken)
        _fromAmount = State(initialValue: fromAmount)
    }

    private var isModal: Bool {
        presentationMode.wrappedValue.isPresented
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppTheme.colors.background.ignoresSafeArea()
                
                // Main content
                ScrollView {
                    VStack(spacing: 16) {
                        youPaySection
                        swapButton
                            .padding(.vertical, -8)
                        youReceiveSection
                    }
                    .padding(20)
                }
                
                // Continue button positioned at absolute bottom
                VStack {
                    Spacer()
                    continueButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }
                .ignoresSafeArea(.keyboard)  // This ensures it stays behind keyboard
            }
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
    
    private var mainContent: some View {
        VStack(spacing: 24) {
            youPaySection
            swapButton
            youReceiveSection
            Spacer(minLength: 200)
        }
        .padding(20)
    }
    
    private var youPaySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("You Pay")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.colors.textSecondary)
                    .padding(.bottom, 4)

                VStack(spacing: 4) {
                    HStack {
                        CustomTextField(text: $fromAmount, field: .from, focusedField: $focusedField)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: { showFromTokenSelect = true }) {
                            TokenButton(token: selectedFromToken, action: { showFromTokenSelect = true })
                        }
                    }
                    .offset(x: isSwapping ? UIScreen.main.bounds.width : 0)
                    .opacity(isSwapping ? 0 : 1)
                    .animation(.easeInOut(duration: 0.3), value: isSwapping)

                    Text("23,629.89647 \(selectedFromToken.symbol)")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                }
            }
            .padding(16)
            .background(Color(hex: "1C1C1E"))
            .cornerRadius(16)
        }
    }
    
    private var youReceiveSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("You Receive")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.colors.textSecondary)
                    .padding(.bottom, 4)

                VStack(spacing: 4) {
                    HStack {
                        CustomTextField(text: $toAmount, field: .to, focusedField: $focusedField)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: { showToTokenSelect = true }) {
                            TokenButton(token: selectedToToken, action: { showToTokenSelect = true })
                        }
                    }
                    .offset(x: isSwapping ? -UIScreen.main.bounds.width : 0)
                    .opacity(isSwapping ? 0 : 1)
                    .animation(.easeInOut(duration: 0.3), value: isSwapping)

                    Text("1234244 \(selectedToToken.symbol)")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                }
            }
            .padding(16)
            .background(Color(hex: "1C1C1E"))
            .cornerRadius(16)
        }
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
        .background(Color(hex: "3A3A3C"))
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
            let maxAmount = selectedFromToken.price * 100  // Using 100 as example max balance
            fromAmount = String(format: "%.8f", maxAmount * percentage)
        } else if focusedField == .to {
            let maxAmount = selectedToToken.price * 100  // Using 100 as example max balance
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
        
        // Create and set the input accessory view
        let percentageView = UIHostingController(rootView: 
            PercentageButtonsView(handlePercentage: { percentage in
                if field == .from {
                    // Calculate max amount for "from" field
                    let maxAmount = 100.0 // Example max amount
                    text = String(format: "%.8f", maxAmount * percentage)
                } else {
                    // Calculate max amount for "to" field
                    let maxAmount = 100.0 // Example max amount
                    text = String(format: "%.8f", maxAmount * percentage)
                }
            })
        )
        percentageView.view.backgroundColor = .clear
        textField.inputAccessoryView = percentageView.view
        
        // Set a fixed size for the input accessory view
        let size = percentageView.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        percentageView.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: size.height)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if focusedField.wrappedValue == field {
            uiView.becomeFirstResponder()
        } else if uiView.isFirstResponder {
            uiView.resignFirstResponder()
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
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.focusedField.wrappedValue = parent.field
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            if parent.focusedField.wrappedValue == parent.field {
                parent.focusedField.wrappedValue = nil
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            parent.text = updatedText
            return false
        }
    }
}

struct PercentageButtonsView: View {
    let handlePercentage: (Double) -> Void
    
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
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
        SwapView(selectedFromToken: Token(symbol: "OMNI", name: "Omni", price: 0.36, priceChange24h: -5.28, volume24h: 500_000),
                fromAmount: "0.001231039")
    }
    .preferredColorScheme(.dark)
}

