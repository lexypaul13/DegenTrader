import SwiftUI

struct AlertCard: View {
    let alert: Alert
    @StateObject private var alertsManager = AlertsManager.shared
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Alert Info Section (Clickable)
            Button(action: {
                showingEditSheet = true
            }) {
                HStack {
                    // Alert Icon
                    Image(systemName: alert.condition == .over ? "arrow.up" : "arrow.down")
                        .foregroundColor(alert.condition == .over ? .green : .red)
                        .font(.system(size: 20))
                        .frame(width: 32, height: 32)
                        .background(Color(white: 0.01))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Alert Value
                        Text(alert.formattedValue)
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                        
                        // Timestamp
                        Text(alert.formattedTimestamp)
                            .font(.system(size: 13))
                            .foregroundColor(Color(white: 0.5))
                    }
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Toggle (Not Clickable)
            Toggle("", isOn: Binding(
                get: { alert.isEnabled },
                set: { _ in alertsManager.toggleAlert(alert) }
            ))
            .tint(.yellow)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(white: 0.12))
        .cornerRadius(12)
        .sheet(isPresented: $showingEditSheet) {
            PriceAlertView(token: alert.token, existingAlert: alert)
        }
    }
}

