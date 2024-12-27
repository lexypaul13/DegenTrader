import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    init() {
        // Customize TabBar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.colors.cardBackground)
        
        // Customize unselected item appearance
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.colors.textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.colors.textSecondary)
        ]
        
        // Customize selected item appearance
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.colors.accent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.colors.accent)
        ]
        
        // Apply the appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Remove TabBar border
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            MarketView()
                .tabItem {
                    Label("Market", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)
            
            NavigationStack {
                SwapView()
            }
            .tabItem {
                Label("Swap", systemImage: "arrow.left.arrow.right")
            }
            .tag(2)
            
            AlertsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
                .tag(3)
        }
        .tint(AppTheme.colors.accent)
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
} 
