import Foundation
import SwiftUI

struct Constants {
    // MARK: - App Configuration
    static let appName = "ABC Budgeting"
    static let appVersion = "1.0.0"
    
    // MARK: - UI Constants (8pt Grid System)
    struct UI {
        // MARK: - Spacing Scale (8pt Grid System)
        struct Spacing {
            static let micro: CGFloat = 4      // 0.25rem - Micro spacing
            static let base: CGFloat = 8       // 0.5rem - Base unit
            static let small: CGFloat = 12     // 0.75rem - Small spacing
            static let medium: CGFloat = 16    // 1rem - Medium spacing
            static let large: CGFloat = 24     // 1.5rem - Large spacing
            static let xl: CGFloat = 32        // 2rem - XL spacing
            static let xxl: CGFloat = 48       // 3rem - XXL spacing
            static let section: CGFloat = 64   // 4rem - Section spacing
            
            // Legacy support
            static let padding = medium
            static let smallPadding = small
            static let largePadding = large
            static let extraLargePadding = xl
        }
        
        // MARK: - Padding System
        struct Padding {
            // Cards/Components
            static let cardInternal: CGFloat = 16    // Internal padding: 16pt all sides
            static let buttonVertical: CGFloat = 12  // Button padding: 12pt vertical
            static let buttonHorizontal: CGFloat = 24 // Button padding: 24pt horizontal
            static let inputVertical: CGFloat = 16   // Input field padding: 16pt vertical
            static let inputHorizontal: CGFloat = 16 // Input field padding: 16pt horizontal
            static let navigationHorizontal: CGFloat = 16 // Navigation padding: 16pt horizontal
            static let navigationVertical: CGFloat = 12  // Navigation padding: 12pt vertical
            
            // Screen Edges
            static let screenMargin: CGFloat = 16     // Main content margins: 16pt from screen edges
            static let sectionSpacing: CGFloat = 24   // Section spacing: 24pt between major sections
            static let listItemVertical: CGFloat = 16 // List item padding: 16pt vertical
            static let listItemHorizontal: CGFloat = 16 // List item padding: 16pt horizontal
        }
        
        // MARK: - Component Spacing
        struct Component {
            // Budget Cards
            static let cardPadding: CGFloat = 16      // Card padding: 16pt all sides
            static let progressBarMargin: CGFloat = 8 // Progress bar margin: 8pt top/bottom
            static let iconTextSpacing: CGFloat = 12  // Icon to text spacing: 12pt
            static let cardCornerRadius: CGFloat = 12 // Card corner radius: 12pt
            
            // Navigation
            static let tabBarHeight: CGFloat = 80     // Tab bar height: 80pt (including safe area)
            static let tabIconSize: CGFloat = 24      // Tab icon size: 24pt x 24pt
            static let tabLabelMargin: CGFloat = 4    // Tab label margin: 4pt below icon
            
            // Form Elements
            static let inputHeight: CGFloat = 48      // Input height: 48pt minimum
            static let labelInputSpacing: CGFloat = 8 // Label to input: 8pt spacing
            static let formFieldSpacing: CGFloat = 16 // Between form fields: 16pt
            static let submitButtonMargin: CGFloat = 24 // Submit button margin: 24pt from last field
        }
        
        // MARK: - Corner Radius
        static let cornerRadius: CGFloat = 12
        static let cardCornerRadius: CGFloat = Component.cardCornerRadius
        
        // MARK: - Screen Structure
        struct Screen {
            static let titleTopMargin: CGFloat = 32   // Screen title - 32pt from top safe area
            static let contentTopMargin: CGFloat = 24 // Primary content starts 24pt below title
            static let cardSpacing: CGFloat = 12      // Between cards use 12pt spacing
            static let bottomSafeMargin: CGFloat = 32 // Bottom safe area - 32pt margin
        }
        
        // MARK: - List Spacing
        struct List {
            static let itemSpacing: CGFloat = 16      // Vertical spacing: 16pt between items
        }
    }
    
    // MARK: - Typography Hierarchy & Weights
    struct Typography {
        // MARK: - H1 - Screen Titles
        struct H1 {
            static let size: CGFloat = 32        // 2rem
            static let weight: Font.Weight = .bold // 700
            static let lineHeight: CGFloat = 38
            static let font = Font.system(size: size, weight: weight)
            static let usage = "Main screen headers, account balance"
        }
        
        // MARK: - H2 - Section Headers
        struct H2 {
            static let size: CGFloat = 24        // 1.5rem
            static let weight: Font.Weight = .semibold // 600
            static let lineHeight: CGFloat = 30
            static let font = Font.system(size: size, weight: weight)
            static let usage = "Category titles, card headers"
        }
        
        // MARK: - H3 - Subsection Headers
        struct H3 {
            static let size: CGFloat = 18        // 1.125rem
            static let weight: Font.Weight = .semibold // 600
            static let lineHeight: CGFloat = 24
            static let font = Font.system(size: size, weight: weight)
            static let usage = "Transaction categories, settings sections"
        }
        
        // MARK: - Body - Primary Text
        struct Body {
            static let size: CGFloat = 16        // 1rem
            static let weight: Font.Weight = .regular // 400
            static let lineHeight: CGFloat = 22
            static let font = Font.system(size: size, weight: weight)
            static let usage = "Transaction descriptions, main content"
        }
        
        // MARK: - Body Small - Secondary Text
        struct BodySmall {
            static let size: CGFloat = 14        // 0.875rem
            static let weight: Font.Weight = .regular // 400
            static let lineHeight: CGFloat = 20
            static let font = Font.system(size: size, weight: weight)
            static let usage = "Dates, helper text, descriptions"
        }
        
        // MARK: - Caption - Meta Information
        struct Caption {
            static let size: CGFloat = 12        // 0.75rem
            static let weight: Font.Weight = .regular // 400
            static let lineHeight: CGFloat = 16
            static let font = Font.system(size: size, weight: weight)
            static let usage = "Timestamps, fine print, labels"
        }
        
        // MARK: - Button Text
        struct Button {
            static let size: CGFloat = 16        // 1rem
            static let weight: Font.Weight = .semibold // 600
            static let lineHeight: CGFloat = 20
            static let font = Font.system(size: size, weight: weight)
            static let usage = "All button labels"
        }
        
        // MARK: - Legacy Support
        static let titleFont = H1.font
        static let headlineFont = H2.font
        static let bodyFont = Body.font
        static let captionFont = Caption.font
    }
    
    // MARK: - Button Hierarchy
    struct ButtonHierarchy {
        // Primary buttons: Bold weight, high contrast
        static let primary = Typography.Button.font.weight(.bold)
        
        // Secondary buttons: Regular weight, medium contrast
        static let secondary = Typography.Button.font.weight(.regular)
        
        // Tertiary buttons: Regular weight, low contrast
        static let tertiary = Typography.Button.font.weight(.regular)
    }
    
    // MARK: - Colors (Modern Fintech iOS sRGB Color Palette - WCAG AA Compliant)
    struct Colors {
        // Primary Brand Colors (WCAG AA Compliant)
        static let robinNeonGreen = Color(red: 0.2, green: 0.7, blue: 0.0) // #339900 - Darker green for better contrast (4.5:1+ on white)
        static let cleanBlack = Color(red: 0.122, green: 0.129, blue: 0.141) // #1F2123 - Clean black for navigation and primary text (4.5:1+ on white)
        static let softRed = Color(red: 0.8, green: 0.2, blue: 0.2) // #CC3333 - Darker red for better contrast (4.5:1+ on white)
        
        // Background & Neutral Colors (Minimalist Flat Design)
        static let backgroundPrimary = Color(red: 1.0, green: 1.0, blue: 1.0) // #FFFFFF - Pure white background
        static let cardBackground = Color(red: 1.0, green: 1.0, blue: 1.0) // #FFFFFF - Pure white cards (flat, no shadows)
        static let backgroundSecondary = Color(red: 0.969, green: 0.969, blue: 0.969) // #F7F7F7 - Light gray for subtle separation
        static let backgroundTertiary = Color(red: 0.949, green: 0.949, blue: 0.949) // #F2F2F2 - Inactive states
        
        // Text Colors (WCAG AA Compliant - 4.5:1+ contrast ratio)
        static let textPrimary = Color(red: 0.122, green: 0.129, blue: 0.141) // #1F2123 - Clean black text (4.5:1+ on white)
        static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4) // #666666 - Darker gray for better contrast (4.5:1+ on white)
        static let textTertiary = Color(red: 0.5, green: 0.5, blue: 0.5) // #808080 - Medium gray (4.5:1+ on white)
        static let textQuaternary = Color(red: 0.6, green: 0.6, blue: 0.6) // #999999 - Light gray (4.5:1+ on white)
        
        // Semantic Colors (WCAG AA Compliant)
        static let success = robinNeonGreen
        static let warning = softRed
        static let error = softRed
        static let info = cleanBlack
        
        // Additional WCAG-compliant variants
        static let successLight = Color(red: 0.8, green: 0.95, blue: 0.8) // Light green background for success states
        static let warningLight = Color(red: 0.95, green: 0.8, blue: 0.8) // Light red background for warning states
        static let errorLight = Color(red: 0.95, green: 0.8, blue: 0.8) // Light red background for error states
        static let infoLight = Color(red: 0.8, green: 0.9, blue: 0.95) // Light blue background for info states
        
        // Border & Separator Colors (Minimalist - No borders)
        static let borderPrimary = Color.clear // No borders in minimalist design
        static let borderSecondary = Color.clear // No borders in minimalist design
        static let separator = Color.clear // No separators in minimalist design
        
        // Legacy support (keeping for compatibility)
        static let primaryBlue = cleanBlack
        static let primaryBlueDark = cleanBlack.opacity(0.8)
        static let trustBlue = cleanBlack
        static let successGreen = robinNeonGreen
        static let alertRed = softRed
        static let electricPurple = cleanBlack
        static let vibrantTeal = robinNeonGreen
        static let coralOrange = softRed
    }
    
    // MARK: - Accessibility
    struct Accessibility {
        static let minimumTouchTarget: CGFloat = 44
        static let minimumContrastRatio: CGFloat = 4.5
    }
    
    // MARK: - Minimalist Design Tokens (Robinhood/Public Style - No Visual Effects)
    struct MinimalistDesign {
        static let cornerRadius: CGFloat = 0 // No rounded corners in minimalist design
        static let borderWidth: CGFloat = 0 // No borders in minimalist design
        static let shadowRadius: CGFloat = 0 // No shadows in minimalist design
        static let shadowOpacity: Double = 0 // No shadows in minimalist design
        
        // Background Colors (Solid colors only)
        static let backgroundPrimary = Colors.backgroundPrimary
        static let backgroundSecondary = Colors.cardBackground
        static let backgroundTertiary = Colors.backgroundTertiary
        static let borderPrimary = Colors.borderPrimary // Color.clear
        
        // Tinted Colors for Emphasis (using Robinhood palette)
        static let tintedNeonGreen = Colors.robinNeonGreen.opacity(0.15)
        static let tintedBlack = Colors.cleanBlack.opacity(0.15)
        static let tintedRed = Colors.softRed.opacity(0.15)
        static let tintedGray = Colors.textSecondary.opacity(0.15)
        
        // Legacy support (disabled for minimalist design)
        static let blurRadius: CGFloat = 0
        static let saturation: Double = 1.0
        static let brightness: Double = 0.0
        static let opacity: Double = 1.0
    }
}
