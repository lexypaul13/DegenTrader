import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            MarketView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Market")
                }
            
            AlertsView()
                .tabItem {
                    Image(systemName: "bell.fill")
                    Text("Alerts")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(AppTheme.colors.accent)
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
} 
