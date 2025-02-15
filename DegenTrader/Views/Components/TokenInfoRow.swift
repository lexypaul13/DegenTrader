import SwiftUI

struct TokenInfoRow: View {
    let title: String
    let value: String
    let isPriceChange: Bool
    let isAddress: Bool
    @State private var showCopied = false
    
    init(title: String, value: String, isPriceChange: Bool = false, isAddress: Bool = false) {
        self.title = title
        self.value = value
        self.isPriceChange = isPriceChange
        self.isAddress = isAddress
    }
    
    private var isPositive: Bool {
        guard isPriceChange else { return false }
        return value.hasPrefix("+")
    }
    
    private var formattedAddress: String {
        guard isAddress else { return value }
        if value.count > 12 {
            let prefix = String(value.prefix(6))
            let suffix = String(value.suffix(4))
            return "\(prefix)...\(suffix)"
        }
        return value
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = value
        withAnimation {
            showCopied = true
        }
        
        // Hide the "Copied" message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopied = false
            }
        }
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.white)
            Spacer()
            if isAddress {
                HStack(spacing: 8) {
                    Button(action: copyToClipboard) {
                        HStack(spacing: 4) {
                            Text(formattedAddress)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    
                    if showCopied {
                        Text("Copied!")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.colors.positive)
                            .transition(.opacity)
                    }
                }
            } else {
                Text(value)
                    .font(.system(size: 16))
                    .foregroundColor(isPriceChange ? (isPositive ? AppTheme.colors.positive : AppTheme.colors.negative) : .white)
            }
        }
        .padding(.vertical, 12)
    }
} 