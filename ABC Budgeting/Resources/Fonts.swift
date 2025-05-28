import SwiftUI

// MARK: - App Font Sizes, Weights, and Padding
struct AppFonts {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headline = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let subheadline = Font.system(size: 16, weight: .medium, design: .rounded)
    static let body = Font.system(size: 16, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 13, weight: .regular, design: .rounded)
    static let button = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let tab = Font.system(size: 12, weight: .medium, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    // Padding
    static let verticalPadding: CGFloat = 12
    static let horizontalPadding: CGFloat = 20
    static let cardPadding: CGFloat = 24
}

// MARK: - App Text Styles
struct AppTextStyles {
    static let title = AppFonts.title
    static let headline = AppFonts.headline
    static let subheadline = AppFonts.subheadline
    static let body = AppFonts.body
    static let caption = AppFonts.caption
    static let button = AppFonts.button
    static let tab = AppFonts.tab
} 