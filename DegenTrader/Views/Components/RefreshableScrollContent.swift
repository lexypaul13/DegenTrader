import SwiftUI

struct RefreshableScrollContent<Content: View>: View {
    @Binding var isRefreshing: Bool
    let onRefresh: () async -> Void
    let content: () -> Content
    
    var body: some View {
        content()
            .refreshable {
                await onRefresh()
            }
    }
}

#Preview {
    ScrollView {
        RefreshableScrollContent(
            isRefreshing: .constant(false),
            onRefresh: {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        ) {
            VStack(spacing: 16) {
                ForEach(0..<5) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppTheme.colors.cardBackground)
                        .frame(height: 100)
                }
            }
            .padding()
        }
    }
    .background(AppTheme.colors.background)
    .preferredColorScheme(.dark)
} 