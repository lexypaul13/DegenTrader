import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(0)
                    .toolbar(.hidden, for: .tabBar)
                
                MarketView()
                    .tag(1)
                    .toolbar(.hidden, for: .tabBar)
                
                AlertsView()
                    .tag(2)
                    .toolbar(.hidden, for: .tabBar)
                
                SettingsView()
                    .tag(3)
                    .toolbar(.hidden, for: .tabBar)
            }
            
            // Custom Tab Bar
            VStack(spacing: 0) {
                Divider()
                    .background(Color.black.opacity(0.3))
                
                HStack(spacing: 0) {
                    ForEach(0..<4) { index in
                        Button {
                            selectedTab = index
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: getIcon(for: index))
                                    .font(.system(size: 20))
                                Text(getTitle(for: index))
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(selectedTab == index ? AppTheme.colors.accent : AppTheme.colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    }
                }
                .background(AppTheme.colors.cardBackground)
            }
            .ignoresSafeArea(.keyboard)
        }
        .background(AppTheme.colors.background)
    }
    
    private func getIcon(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "chart.line.uptrend.xyaxis"
        case 2: return "bell.fill"
        case 3: return "gear"
        default: return ""
        }
    }
    
    private func getTitle(for index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "Market"
        case 2: return "Alerts"
        case 3: return "Settings"
        default: return ""
        }
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
} 
