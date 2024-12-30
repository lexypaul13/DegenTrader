import SwiftUI

struct AlertsView: View {
    @StateObject private var alertsManager = AlertsManager.shared
    @State private var selectedToken: Token?
    @State private var showingPriceAlert = false
    
    // Get unique tokens that have alerts
    private var tokensWithAlerts: [Token] {
        let uniqueTokens = Set(alertsManager.alerts.map { $0.token })
        return Array(uniqueTokens).sorted(by: { $0.symbol < $1.symbol })
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.colors.background.ignoresSafeArea()
                
                if tokensWithAlerts.isEmpty {
                    // Empty state content
                    VStack(spacing: 16) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Color(white: 0.5))
                        
                        VStack(spacing: 8) {
                            Text("You haven't set any alerts yet")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("Visit any token and tap the bell icon to set price alerts")
                                .font(.system(size: 15))
                                .foregroundColor(Color(white: 0.5))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 32)
                } else {
                    List {
                        ForEach(tokensWithAlerts) { token in
                            Section {
                                // Custom header row with Add button
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(token.name)
                                            .font(.system(size: 17))
                                            .foregroundColor(.white)
                                        Text(token.symbol)
                                            .font(.system(size: 13))
                                            .foregroundColor(Color(white: 0.5))
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        selectedToken = token
                                        showingPriceAlert = true
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "plus")
                                            Text("Add")
                                        }
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 15))
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                
                                // Alert cards
                                ForEach(alertsManager.alertsForToken(token)) { alert in
                                    AlertCard(alert: alert)
                                        .listRowInsets(EdgeInsets())
                                        .listRowBackground(Color.clear)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                            Button(role: .destructive) {
                                                withAnimation {
                                                    alertsManager.deleteAlert(alert)
                                                }
                                            } label: {
                                                Text("Delete")
                                                    .font(.system(size: 17))
                                            }
                                            .tint(.red)
                                        }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Price Alerts")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingPriceAlert, onDismiss: { selectedToken = nil }) {
            if let token = selectedToken {
                PriceAlertView(
                    token: token,
                    existingAlert: nil,
                    alertMode: .price,
                    priceCondition: .over
                )
            }
        }
    }
}

#Preview {
    AlertsView()
        .preferredColorScheme(.dark)
} 
