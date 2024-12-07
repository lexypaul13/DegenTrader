import Foundation

struct Transaction: Identifiable {
    let id = UUID()
    let date: Date
    let type: TransactionType
    let fromToken: Token
    let toToken: Token
    let fromAmount: Double
    let toAmount: Double
    
    enum TransactionType {
        case swapped
    }
}

extension Transaction {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
} 