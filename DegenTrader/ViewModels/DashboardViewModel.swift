import Foundation
import SwiftUI
class DashboardViewModel: ObservableObject {
    @Published private(set) var portfolio: Portfolio
    @Published private(set) var trendingTokens: [Token]
    
    init() {
        // Initialize with mock data for now
        self.portfolio = MockData.portfolio
        self.trendingTokens = MockData.tokens
    }
} 
