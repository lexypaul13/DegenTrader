import SwiftUI

struct ActionButton: View {
    let imageName: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(AppTheme.colors.cardBackground)
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: imageName)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                )
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    HStack(spacing: 30) {
        ActionButton(imageName: "arrow.left.arrow.right", title: "Swap")
        ActionButton(imageName: "dollarsign.circle", title: "Buy")
        ActionButton(imageName: "bell.fill", title: "Alert")
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
} 