import Foundation
import SwiftUI
enum TransactionType {
    case swapped
    case sent
    case received
}

enum TransactionStatus {
    case succeeded
    case failed
    
    var color: Color {
        switch self {
        case .succeeded:
            return .green
        case .failed:
            return .red
        }
    }
    
    var text: String {
        switch self {
        case .succeeded:
            return "Succeeded"
        case .failed:
            return "Failed"
        }
    }
}

struct Transaction: Identifiable {
    let id = UUID()
    let date: Date
    let type: TransactionType
    let fromToken: Token
    let toToken: Token
    let fromAmount: Double
    let toAmount: Double
    let status: TransactionStatus
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Default initializer with status parameter
    init(date: Date, type: TransactionType, fromToken: Token, toToken: Token, fromAmount: Double, toAmount: Double, status: TransactionStatus = .succeeded) {
        self.date = date
        self.type = type
        self.fromToken = fromToken
        self.toToken = toToken
        self.fromAmount = fromAmount
        self.toAmount = toAmount
        self.status = status
    }
} 
