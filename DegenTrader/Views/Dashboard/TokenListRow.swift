import SwiftUI

//struct TokenListRow: View {
//    let token: Token
//    @State private var isPressed = false
//    
//    var body: some View {
//        HStack {
//            // Token Info
//            VStack(alignment: .leading, spacing: 4) {
//                Text(token.name)
//                    .font(.system(size: 16))
//                    .foregroundColor(isPressed ? AppTheme.colors.highlight : .white)
//                Text(token.symbol)
//                    .font(.system(size: 12))
//                    .foregroundColor(.gray)
//            }
//            
//            Spacer()
//            
//            // Price Info
//            VStack(alignment: .trailing, spacing: 4) {
//                Text("$\(token.price, specifier: "%.2f")")
//                    .font(.system(size: 16))
//                    .foregroundColor(isPressed ? AppTheme.colors.highlight : .white)
//                Text("\(token.priceChange24h >= 0 ? "+" : "")\(token.priceChange24h, specifier: "%.2f")%")
//                    .font(.system(size: 12))
//                    .foregroundColor(token.priceChange24h >= 0 ? AppTheme.colors.positive : AppTheme.colors.negative)
//            }
//        }
//        .padding(12)
//        .background(Color.black.opacity(0.3))
//        .cornerRadius(8)
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(isPressed ? AppTheme.colors.highlight : Color.clear, lineWidth: 1)
//        )
//        .contentShape(Rectangle())
//        .onTapGesture {
//            withAnimation(.easeInOut(duration: 0.2)) {
//                isPressed = true
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    withAnimation {
//                        isPressed = false
//                    }
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    TokenListRow(token: MockData.tokens[0])
//        .preferredColorScheme(.dark)
//        .padding()
//        .background(AppTheme.colors.background)
//} 
