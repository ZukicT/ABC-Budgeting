import SwiftUI

// MARK: - Professional Spacing System
struct AppPaddings {
    // MARK: - Base Spacing Scale (4px base unit)
    static let xs: CGFloat = 4      // Extra small spacing
    static let sm: CGFloat = 8      // Small spacing
    static let md: CGFloat = 12     // Medium spacing
    static let lg: CGFloat = 16     // Large spacing
    static let xl: CGFloat = 20     // Extra large spacing
    static let xxl: CGFloat = 24    // Double extra large spacing
    static let xxxl: CGFloat = 32   // Triple extra large spacing
    static let xxxxl: CGFloat = 40  // Quadruple extra large spacing
    
    // MARK: - Component-Specific Padding
    static let card: CGFloat = 16           // Card internal padding
    static let cardLarge: CGFloat = 24      // Large card padding
    static let cardSmall: CGFloat = 12      // Small card padding
    
    static let section: CGFloat = 24        // Section spacing
    static let sectionLarge: CGFloat = 32   // Large section spacing
    static let sectionSmall: CGFloat = 16   // Small section spacing
    
    static let screen: CGFloat = 20         // Screen edge padding
    static let screenLarge: CGFloat = 24    // Large screen padding
    static let screenSmall: CGFloat = 16    // Small screen padding
    
    // MARK: - Button Padding
    static let button: CGFloat = 12         // Standard button padding
    static let buttonLarge: CGFloat = 16    // Large button padding
    static let buttonSmall: CGFloat = 8     // Small button padding
    static let buttonTiny: CGFloat = 6      // Tiny button padding
    
    // MARK: - Form Elements
    static let inputField: CGFloat = 12     // Input field padding
    static let inputFieldLarge: CGFloat = 16 // Large input field padding
    static let inputFieldSmall: CGFloat = 8  // Small input field padding
    
    // MARK: - List and Grid
    static let listRow: CGFloat = 12        // List row padding
    static let listRowLarge: CGFloat = 16   // Large list row padding
    static let listRowSmall: CGFloat = 8    // Small list row padding
    
    static let gridSpacing: CGFloat = 16    // Grid item spacing
    static let gridSpacingLarge: CGFloat = 24 // Large grid spacing
    static let gridSpacingSmall: CGFloat = 12 // Small grid spacing
    
    // MARK: - Navigation
    static let tabBar: CGFloat = 8          // Tab bar padding
    static let navigationBar: CGFloat = 16  // Navigation bar padding
    
    // MARK: - Content Spacing
    static let contentVertical: CGFloat = 16    // Vertical content spacing
    static let contentHorizontal: CGFloat = 20  // Horizontal content spacing
    static let contentLarge: CGFloat = 24       // Large content spacing
    static let contentSmall: CGFloat = 12       // Small content spacing
    
    // MARK: - Section Headers
    static let sectionTitleTop: CGFloat = 16    // Section title top spacing
    static let sectionTitleBottom: CGFloat = 8  // Section title bottom spacing
    
    // MARK: - Floating Elements
    static let fabTrailing: CGFloat = 20    // Floating action button trailing
    static let fabBottom: CGFloat = 24      // Floating action button bottom
    static let fabPadding: CGFloat = 16     // Floating action button internal padding
}

// MARK: - Border Radius System
struct AppRadius {
    static let none: CGFloat = 0            // No radius
    static let xs: CGFloat = 2              // Extra small radius
    static let sm: CGFloat = 4              // Small radius
    static let md: CGFloat = 6              // Medium radius
    static let lg: CGFloat = 8              // Large radius
    static let xl: CGFloat = 12             // Extra large radius
    static let xxl: CGFloat = 16            // Double extra large radius
    static let xxxl: CGFloat = 20           // Triple extra large radius
    static let round: CGFloat = 999         // Fully rounded
    
    // MARK: - Component-Specific Radius
    static let card: CGFloat = 12           // Card radius
    static let cardLarge: CGFloat = 16      // Large card radius
    static let cardSmall: CGFloat = 8       // Small card radius
    
    static let button: CGFloat = 8          // Button radius
    static let buttonLarge: CGFloat = 12    // Large button radius
    static let buttonSmall: CGFloat = 6     // Small button radius
    
    static let inputField: CGFloat = 8      // Input field radius
    static let inputFieldLarge: CGFloat = 12 // Large input field radius
    static let inputFieldSmall: CGFloat = 6  // Small input field radius
    
    static let chip: CGFloat = 16           // Chip/tag radius
    static let badge: CGFloat = 12          // Badge radius
}

// MARK: - Size System
struct AppSizes {
    // MARK: - Icon Sizes
    static let iconTiny: CGFloat = 12       // Tiny icons
    static let iconSmall: CGFloat = 16      // Small icons
    static let iconMedium: CGFloat = 20     // Medium icons
    static let iconLarge: CGFloat = 24      // Large icons
    static let iconXLarge: CGFloat = 32     // Extra large icons
    static let iconXXLarge: CGFloat = 40    // Double extra large icons
    static let iconXXXLarge: CGFloat = 48   // Triple extra large icons
    
    // MARK: - Avatar Sizes
    static let avatarTiny: CGFloat = 24     // Tiny avatars
    static let avatarSmall: CGFloat = 32    // Small avatars
    static let avatarMedium: CGFloat = 40   // Medium avatars
    static let avatarLarge: CGFloat = 48    // Large avatars
    static let avatarXLarge: CGFloat = 64   // Extra large avatars
    static let avatarXXLarge: CGFloat = 80  // Double extra large avatars
    
    // MARK: - Card Sizes
    static let cardHeight: CGFloat = 120    // Standard card height
    static let cardHeightLarge: CGFloat = 160 // Large card height
    static let cardHeightSmall: CGFloat = 80  // Small card height
    
    static let cardWidth: CGFloat = 160     // Standard card width
    static let cardWidthLarge: CGFloat = 200 // Large card width
    static let cardWidthSmall: CGFloat = 120  // Small card width
    
    // MARK: - Chart Sizes
    static let chartHeight: CGFloat = 200   // Standard chart height
    static let chartHeightLarge: CGFloat = 300 // Large chart height
    static let chartHeightSmall: CGFloat = 150 // Small chart height
    
    // MARK: - Button Sizes
    static let buttonHeight: CGFloat = 44   // Standard button height
    static let buttonHeightLarge: CGFloat = 52 // Large button height
    static let buttonHeightSmall: CGFloat = 36 // Small button height
    static let buttonHeightTiny: CGFloat = 28  // Tiny button height
    
    // MARK: - Input Field Sizes
    static let inputFieldHeight: CGFloat = 44   // Standard input field height
    static let inputFieldHeightLarge: CGFloat = 52 // Large input field height
    static let inputFieldHeightSmall: CGFloat = 36 // Small input field height
    
    // MARK: - List Row Sizes
    static let listRowHeight: CGFloat = 56  // Standard list row height
    static let listRowHeightLarge: CGFloat = 72 // Large list row height
    static let listRowHeightSmall: CGFloat = 44 // Small list row height
    
    // MARK: - Tab Bar Sizes
    static let tabBarHeight: CGFloat = 80   // Tab bar height
    static let tabBarItemHeight: CGFloat = 48 // Tab bar item height
    
    // MARK: - Navigation Sizes
    static let navigationBarHeight: CGFloat = 44 // Navigation bar height
    static let statusBarHeight: CGFloat = 20     // Status bar height
    static let safeAreaTop: CGFloat = 44         // Safe area top
    static let safeAreaBottom: CGFloat = 34      // Safe area bottom
}

// MARK: - Shadow System
struct AppShadows {
    static let none: CGFloat = 0            // No shadow
    static let xs: CGFloat = 1              // Extra small shadow
    static let sm: CGFloat = 2              // Small shadow
    static let md: CGFloat = 4              // Medium shadow
    static let lg: CGFloat = 8              // Large shadow
    static let xl: CGFloat = 12             // Extra large shadow
    static let xxl: CGFloat = 16            // Double extra large shadow
    
    // MARK: - Component-Specific Shadows
    static let card: CGFloat = 2            // Card shadow
    static let cardHover: CGFloat = 4       // Card hover shadow
    static let button: CGFloat = 1          // Button shadow
    static let buttonPressed: CGFloat = 0   // Button pressed shadow
    static let modal: CGFloat = 8           // Modal shadow
    static let dropdown: CGFloat = 4        // Dropdown shadow
}

// MARK: - Animation Durations
struct AppAnimations {
    static let instant: Double = 0.0        // Instant animation
    static let fast: Double = 0.15          // Fast animation
    static let normal: Double = 0.25        // Normal animation
    static let slow: Double = 0.35          // Slow animation
    static let slower: Double = 0.5         // Slower animation
    
    // MARK: - Easing Curves
    static let easeIn = Animation.easeIn(duration: normal)
    static let easeOut = Animation.easeOut(duration: normal)
    static let easeInOut = Animation.easeInOut(duration: normal)
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.8)
} 
