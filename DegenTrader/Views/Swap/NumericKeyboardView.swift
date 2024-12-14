import SwiftUI

struct NumericKeyboardView: View {
    @Binding var text: String
    let maxValue: Double?
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Percentage buttons row
            HStack(spacing: 12) {
                percentageButton("25%")
                percentageButton("50%")
                percentageButton("Max")
                
                Button(action: onDismiss) {
                    Text("Done")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            // Number pad
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    numericButton("1")
                    numericButton("2", letters: "ABC")
                    numericButton("3", letters: "DEF")
                }
                
                HStack(spacing: 12) {
                    numericButton("4", letters: "GHI")
                    numericButton("5", letters: "JKL")
                    numericButton("6", letters: "MNO")
                }
                
                HStack(spacing: 12) {
                    numericButton("7", letters: "PQRS")
                    numericButton("8", letters: "TUV")
                    numericButton("9", letters: "WXYZ")
                }
                
                HStack(spacing: 12) {
                    numericButton(".")
                    numericButton("0")
                    
                    Button(action: { backspace() }) {
                        Image(systemName: "delete.left")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
            
            // Bottom home indicator padding
            Color.clear
                .frame(height: 20)
        }
        .padding(.top, 12)
        .background(Color(hex: "1C1C1E"))
    }
    
    private func percentageButton(_ text: String) -> some View {
        Button(action: { handlePercentage(text) }) {
            Text(text)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(Color.black.opacity(0.3))
                .cornerRadius(18)
        }
    }
    
    private func numericButton(_ number: String, letters: String? = nil) -> some View {
        Button(action: { appendNumber(number) }) {
            VStack(spacing: 2) {
                Text(number)
                    .font(.system(size: 28, weight: .regular))
                if let letters = letters {
                    Text(letters)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
        }
    }
    
    private func appendNumber(_ number: String) {
        if number == "." {
            if !text.contains(".") {
                text += number
            }
        } else {
            text += number
        }
    }
    
    private func backspace() {
        if !text.isEmpty {
            text.removeLast()
        }
    }
    
    private func handlePercentage(_ percentage: String) {
        guard let maxValue = maxValue else { return }
        
        switch percentage {
        case "25%":
            text = String(format: "%.8f", maxValue * 0.25)
        case "50%":
            text = String(format: "%.8f", maxValue * 0.50)
        case "Max":
            text = String(format: "%.8f", maxValue)
        default:
            break
        }
    }
} 