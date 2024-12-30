import Foundation
import SwiftUI

struct Transaction: Identifiable, Codable {
    var id: UUID
    let date: Date
    let fromToken: Token
    let toToken: Token
    let fromAmount: Double
    let toAmount: Double
    let status: TransactionStatus
    let source: String
    
    init(id: UUID = UUID(), date: Date, fromToken: Token, toToken: Token, fromAmount: Double, toAmount: Double, status: TransactionStatus, source: String) {
        self.id = id
        self.date = date
        self.fromToken = fromToken
        self.toToken = toToken
        self.fromAmount = fromAmount
        self.toAmount = toAmount
        self.status = status
        self.source = source
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    enum TransactionStatus: String, Codable {
        case succeeded
        case failed
        
        var text: String {
            switch self {
            case .succeeded:
                return "Swapped"
            case .failed:
                return "Failed app interaction"
            }
        }
        
        var color: Color {
            switch self {
            case .succeeded:
                return .green
            case .failed:
                return .red
            }
        }
    }
}

// Extension for grouping transactions by date
extension Transaction {
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

// Extension for sorting and grouping
extension Array where Element == Transaction {
    var groupedByDate: [(String, [Transaction])] {
        let grouped = Dictionary(grouping: self) { $0.dateString }
        return grouped.sorted { $0.key > $1.key }
    }
} 
