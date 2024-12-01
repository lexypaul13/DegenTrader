import SwiftUI
import Foundation

struct AppTheme {
    static let colors = ColorTheme()
    static let fonts = FontTheme()
    static let layout = LayoutTheme()
}

struct ColorTheme {
    let background = Color("Background") // Dark theme background
    let accent = Color.yellow // The yellow accent from the design
    let cardBackground = Color("CardBackground") // Darker card background
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
