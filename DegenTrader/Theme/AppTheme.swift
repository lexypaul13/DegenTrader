import SwiftUI
import Foundation

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct AppTheme {
    static let colors = ColorTheme()
    static let fonts = FontTheme()
    static let layout = LayoutTheme()
}

struct ColorTheme {
    let background = Color.black // Dark theme background
    let accent = Color.yellow // The yellow accent from the design
    let cardBackground = Color(hex: "1C1C1E") // Darker card background
    let textPrimary = Color.white
    let textSecondary = Color.gray
    let positive = Color.green
    let negative = Color.red
}

struct FontTheme {
    let title = Font.system(size: 34, weight: .bold)
    let headline = Font.system(size: 17, weight: .semibold)
    let body = Font.system(size: 15)
    let caption = Font.system(size: 13)
}

struct LayoutTheme {
    let padding: CGFloat = 16
    let cornerRadius: CGFloat = 12
    let spacing: CGFloat = 8
} 
