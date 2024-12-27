import SwiftUI

class AlertsManager: ObservableObject {
    static let shared = AlertsManager()
    @Published private(set) var alerts: [Alert] = []
    
    private init() {}
    
    func addAlert(alert: Alert) {
        alerts.append(alert)
    }
    
    func updateAlert(_ updatedAlert: Alert) {
        if let index = alerts.firstIndex(where: { $0.id == updatedAlert.id }) {
            alerts[index] = updatedAlert
        }
    }
    
    func deleteAlert(_ alert: Alert) {
        alerts.removeAll { $0.id == alert.id }
    }
    
    func toggleAlert(_ alert: Alert) {
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index].isEnabled.toggle()
        }
    }
    
    func alertsForToken(_ token: Token) -> [Alert] {
        alerts.filter { $0.token.symbol == token.symbol }
    }
    
    func hasAlertsForToken(_ token: Token) -> Bool {
        !alertsForToken(token).isEmpty
    }
} 