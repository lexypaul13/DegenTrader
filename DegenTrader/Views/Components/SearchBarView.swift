import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    @Binding var showFilterMenu: Bool
    @Binding var isFilterActive: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.colors.textSecondary)
                .font(.system(size: 16))
            
            TextField("Search", text: $text)
                .foregroundColor(AppTheme.colors.textPrimary)
                .font(.system(size: 16))
                .focused($isFocused)
                .submitLabel(.done)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.colors.textSecondary)
                }
            }
            
            Button(action: {
                isFocused = false
                showFilterMenu = true
            }) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(isFilterActive ? AppTheme.colors.accent : AppTheme.colors.textSecondary)
                        .font(.system(size: 16, weight: .medium))
                    
                    if isFilterActive {
                        Circle()
                            .fill(AppTheme.colors.accent)
                            .frame(width: 8, height: 8)
                            .offset(x: 4, y: -4)
                    }
                }
            }
            .padding(.leading, 4)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(hex: "1C1C1E"))
        .cornerRadius(16)
        .onTapGesture {
            isFocused = true
        }
    }
}

#Preview {
    SearchBarView(
        text: .constant(""),
        showFilterMenu: .constant(false),
        isFilterActive: .constant(true)
    )
    .padding()
    .preferredColorScheme(.dark)
    .background(AppTheme.colors.background)
} 