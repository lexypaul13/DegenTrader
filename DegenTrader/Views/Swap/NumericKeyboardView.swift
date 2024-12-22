import SwiftUI

struct NumericKeyboardView: View {
    @Binding var text: String
    var onDismiss: () -> Void
    
    private let percentages = ["25%", "50%", "Max"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Percentage buttons
            HStack(spacing: 8) {
                ForEach(percentages, id: \.self) { percentage in
                    Button(action: {
                        // Handle percentage tap
                    }) {
                        Text(percentage)
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(Color(hex: "2C2C2E"))
                            .cornerRadius(16)
                    }
                }
                
                Button("Done", action: onDismiss)
                    .font(.system(size: 17))
                    .foregroundColor(.white)
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
                    Button(action: {
                        if !text.contains(".") {
                            text += "."
                        }
                    }) {
                        Text(".")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color(hex: "2C2C2E"))
                            .cornerRadius(12)
                    }
                    
                    numericButton("0")
                    
                    Button(action: {
                        if !text.isEmpty {
                            text.removeLast()
                        }
                    }) {
                        Image(systemName: "delete.left")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color(hex: "2C2C2E"))
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
            
            // Bottom row with globe and mic
            HStack {
                Button(action: {}) {
                    Image(systemName: "globe")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "mic")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .padding(.top, 12)
        .background(Color(hex: "1C1C1E"))
    }
    
    private func numericButton(_ number: String, letters: String? = nil) -> some View {
        Button(action: {
            if text == "0" {
                text = number
            } else {
                text += number
            }
        }) {
            VStack(spacing: 2) {
                Text(number)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                
                if let letters = letters {
                    Text(letters)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(Color(hex: "2C2C2E"))
            .cornerRadius(12)
        }
    }
} 