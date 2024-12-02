import SwiftUI

struct AlertsView: View {
    var body: some View {
        NavigationView {
            VStack {
                // Placeholder for alerts list
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(0..<3) { _ in
                            AlertCardView()
                        }
                    }
                    .padding()
                }
            }
            .background(AppTheme.colors.background)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Alerts")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .foregroundColor(AppTheme.colors.accent)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AlertCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(AppTheme.colors.accent)
                Text("Price Alert")
                    .font(AppTheme.fonts.headline)
                    .foregroundColor(AppTheme.colors.textPrimary)
                Spacer()
                Toggle("", isOn: .constant(true))
                    .tint(AppTheme.colors.accent)
            }
            
            Text("Alert when ETH price reaches $3,500")
                .font(AppTheme.fonts.body)
                .foregroundColor(AppTheme.colors.textSecondary)
        }
        .padding()
        .background(AppTheme.colors.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    AlertsView()
        .preferredColorScheme(.dark)
} 