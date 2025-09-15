import SwiftUI

// MARK: - Layout Constants

struct LayoutConstants {
    // MARK: - Spacing
    static let extraSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let extraLarge: CGFloat = 20
    static let huge: CGFloat = 24
    static let extraHuge: CGFloat = 32
    
    // MARK: - Corner Radius
    static let smallRadius: CGFloat = 8
    static let mediumRadius: CGFloat = 12
    static let largeRadius: CGFloat = 16
    static let extraLargeRadius: CGFloat = 24
    
    // MARK: - Icon Sizes
    static let smallIcon: CGFloat = 16
    static let mediumIcon: CGFloat = 22
    static let largeIcon: CGFloat = 32
    static let extraLargeIcon: CGFloat = 48
    
    // MARK: - Card Heights
    static let balanceCardHeight: CGFloat = 160
    static let compactCardHeight: CGFloat = 100
    static let standardCardHeight: CGFloat = 120
    
    // MARK: - Image Sizes
    static let emptyStateImage: CGFloat = 220
    static let smallImage: CGFloat = 64
    static let mediumImage: CGFloat = 120
    
    // MARK: - Shadow Properties
    static let lightShadowRadius: CGFloat = 4
    static let mediumShadowRadius: CGFloat = 8
    static let heavyShadowRadius: CGFloat = 12
    static let shadowOffset: CGFloat = 2
    
    // MARK: - Chart Dimensions
    static let chartHeight: CGFloat = 160
    static let donutChartSize: CGFloat = 240
    static let donutInnerRadius: CGFloat = 80
    static let donutOuterRadius: CGFloat = 120
    
    // MARK: - Grid Layouts
    static let twoColumnGrid: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    static let threeColumnGrid: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
}

// MARK: - Animation Constants

struct AnimationConstants {
    static let quick: Double = 0.2
    static let standard: Double = 0.3
    static let slow: Double = 0.5
    static let springResponse: Double = 0.35
    static let springDamping: Double = 0.85
}

// MARK: - Business Logic Constants

struct BusinessConstants {
    // MARK: - Time Calculations
    static let daysInMonth: Double = 30.0
    static let weeksInMonth: Double = 4.33
    static let monthsInYear: Double = 12.0
    static let weeksInYear: Double = 52.0
    static let hoursInYear: Double = 2080.0
    
    // MARK: - Financial Thresholds
    static let minimumSpendingThreshold: Double = 0.01
    static let smallCategoryThreshold: Double = 0.02 // 2% of total spending
    
    // MARK: - Display Limits
    static let maxGoalsDisplayed: Int = 4
    static let maxTransactionsDisplayed: Int = 5
    static let maxTransactionTitleLength: Int = 1
    static let maxTransactionSubtitleLength: Int = 1
}

// MARK: - Opacity Constants

struct OpacityConstants {
    static let light: Double = 0.1
    static let medium: Double = 0.3
    static let heavy: Double = 0.5
    static let veryHeavy: Double = 0.8
    static let almostOpaque: Double = 0.9
}
