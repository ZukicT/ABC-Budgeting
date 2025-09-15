import SwiftUI

// MARK: - Robinhood Design System
struct RobinhoodColors {
    // Robinhood's exact brand colors
    static let robinNeon = Color(red: 0.0196, green: 0.8118, blue: 0.2980) // New green primary color #05CF4C
    static let primary = Color(red: 0.0196, green: 0.8118, blue: 0.2980) // New green primary color #05CF4C
    static let secondary = Color(red: 0.0196, green: 0.8118, blue: 0.2980) // New green primary color #05CF4C
    static let background = Color.black // Dark background like Robinhood
    static let cardBackground = Color(red: 0.1, green: 0.11, blue: 0.11) // Dark card background
    static let textPrimary = Color.white // White text on dark background
    static let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.7) // Light gray
    static let textTertiary = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    static let success = robinNeon // Use Robin Neon for positive values
    static let error = Color(red: 1.0, green: 0.2, blue: 0.2) // Red for negative values
    static let warning = Color(red: 1.0, green: 0.6, blue: 0.0) // Orange for warnings
    static let border = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark border
    static let chartLine = robinNeon // Robin Neon for chart lines
    static let chartBackground = Color(red: 0.02, green: 0.02, blue: 0.02) // Very dark chart background
}

struct RobinhoodTypography {
    static let largeTitle = Font.system(size: 28, weight: .bold, design: .default)
    static let title1 = Font.system(size: 22, weight: .bold, design: .default)
    static let title2 = Font.system(size: 20, weight: .semibold, design: .default)
    static let title3 = Font.system(size: 18, weight: .semibold, design: .default)
    static let headline = Font.system(size: 16, weight: .semibold, design: .default)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let callout = Font.system(size: 14, weight: .medium, design: .default)
    static let subheadline = Font.system(size: 14, weight: .regular, design: .default)
    static let footnote = Font.system(size: 12, weight: .regular, design: .default)
    static let caption = Font.system(size: 11, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 10, weight: .regular, design: .default)
}
