import SwiftUI

struct ContinueButton: View {
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isEnabled ? .white : AppTheme.colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isEnabled ? AppTheme.colors.accent : Color(hex: "1C1C1E"))
            .cornerRadius(12)
        }
        .disabled(!isEnabled || isLoading)
        .padding(.top, 12)
    }
} 