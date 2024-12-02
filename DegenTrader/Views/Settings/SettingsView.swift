import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    SettingsRow(icon: "person.fill", title: "Account", color: .blue)
                    SettingsRow(icon: "bell.fill", title: "Notifications", color: .yellow)
                    SettingsRow(icon: "lock.fill", title: "Security", color: .green)
                }
                
                Section {
                    SettingsRow(icon: "questionmark.circle.fill", title: "Help", color: .purple)
                    SettingsRow(icon: "info.circle.fill", title: "About", color: .orange)
                }
                
                Section {
                    Button(action: {}) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .background(AppTheme.colors.background)
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            Text(title)
                .foregroundColor(AppTheme.colors.textPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppTheme.colors.textSecondary)
                .font(.system(size: 14))
        }
        .padding(.vertical, 4)
        .listRowBackground(AppTheme.colors.cardBackground)
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
} 