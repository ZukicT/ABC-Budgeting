//
//  Constants.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Centralized constants and design system definitions including colors,
//  spacing, typography, and UI configuration. Provides consistent design
//  tokens and utility functions for the entire application.
//
//  Review Date: September 29, 2025
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct Constants {
    // MARK: - App Configuration
    static let appName = "Money Manager"
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
        
        // MARK: - Corner Radius System (Global Consistency)
        /**
         * Global Corner Radius System
         * 
         * Provides consistent corner radius values across the entire application
         * to maintain visual harmony and design system compliance.
         * 
         * Usage Guidelines:
         * - primary (24pt): Main CTA buttons, large cards, primary UI elements
         * - secondary (24pt): Standard cards, input fields, secondary buttons
         * - tertiary (24pt): Small indicators, tags, micro elements
         * - quaternary (24pt): Progress bars, minimal visual elements
         * 
         * Design Philosophy:
         * - Creates consistent rounded appearance across all UI elements
         * - Maintains visual harmony with uniform corner radius
         * - Follows iOS Human Interface Guidelines
         * - Supports accessibility and touch targets
         * 
         * Last Review: 2025-01-26
         * Status: Production Ready
         */
        struct CornerRadius {
            // Primary corner radius - Buttons, CTAs, large cards
            static let primary: CGFloat = 24
            
            // Secondary corner radius - Cards, sections, input fields
            static let secondary: CGFloat = 12
            
            // Tertiary corner radius - Small elements, badges, chips
            static let tertiary: CGFloat = 8
            
            // Quaternary corner radius - Micro elements, indicators
            static let quaternary: CGFloat = 4
            
            // Legacy support - map old values to new system
            static let cardCornerRadius = secondary
            static let buttonCornerRadius = primary
            static let inputCornerRadius = secondary
            static let indicatorCornerRadius = quaternary
        }
        
        // MARK: - Legacy Corner Radius (Deprecated - Use CornerRadius instead)
        static let cornerRadius: CGFloat = CornerRadius.secondary
        static let cardCornerRadius: CGFloat = CornerRadius.secondary
        
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
    
    // MARK: - Typography Hierarchy & Weights (iOS System Fonts)
    struct Typography {
        // MARK: - H1 - Screen Titles
        struct H1 {
            static let size: CGFloat = 32        // 2rem
            static let weight: Font.Weight = .bold // 700
            static let lineHeight: CGFloat = 38
            static let font = Font.system(size: size, weight: weight, design: .default)
            static let usage = "Main screen headers, account balance"
        }
        
        // MARK: - H2 - Section Headers
        struct H2 {
            static let size: CGFloat = 24        // 1.5rem
            static let weight: Font.Weight = .bold // 700
            static let lineHeight: CGFloat = 30
            static let font = Font.system(size: size, weight: weight, design: .default)
            static let usage = "Category titles, card headers"
        }
        
        // MARK: - H3 - Subsection Headers
        struct H3 {
            static let size: CGFloat = 18        // 1.125rem
            static let weight: Font.Weight = .bold // 700
            static let lineHeight: CGFloat = 24
            static let font = Font.system(size: size, weight: weight, design: .default)
            static let usage = "Transaction categories, settings sections"
        }
        
        // MARK: - Body - Primary Text
        struct Body {
            static let size: CGFloat = 16        // 1rem
            static let weight: Font.Weight = .regular // 400
            static let lineHeight: CGFloat = 22
            static let font = Font.system(size: size, weight: weight, design: .default)
            static let usage = "Transaction descriptions, main content"
        }
        
        // MARK: - Body Small - Secondary Text
        struct BodySmall {
            static let size: CGFloat = 14        // 0.875rem
            static let weight: Font.Weight = .regular // 400
            static let lineHeight: CGFloat = 20
            static let font = Font.system(size: size, weight: weight, design: .default)
            static let usage = "Dates, helper text, descriptions"
        }
        
        // MARK: - Caption - Meta Information
        struct Caption {
            static let size: CGFloat = 12        // 0.75rem
            static let weight: Font.Weight = .regular // 400
            static let lineHeight: CGFloat = 16
            static let font = Font.system(size: size, weight: weight, design: .default)
            static let usage = "Timestamps, fine print, labels"
        }
        
        // MARK: - Button Text
        struct Button {
            static let size: CGFloat = 16        // 1rem
            static let weight: Font.Weight = .bold // 700
            static let lineHeight: CGFloat = 20
            static let font = Font.system(size: size, weight: weight, design: .default)
            static let usage = "All button labels"
        }
        
        // MARK: - Display Text (Large Numbers)
        struct Display {
            static let size: CGFloat = 48        // 3rem
            static let weight: Font.Weight = .bold // 700
            static let lineHeight: CGFloat = 56
            static let font = Font.system(size: size, weight: weight, design: .default)
            static let usage = "Large numbers, hero text, account balances"
        }
        
        // MARK: - Display Small (Medium Numbers)
        struct DisplaySmall {
            static let size: CGFloat = 36        // 2.25rem
            static let weight: Font.Weight = .bold // 700
            static let lineHeight: CGFloat = 42
            static let font = Font.system(size: size, weight: weight, design: .default)
            static let usage = "Medium numbers, important values"
        }
        
        // MARK: - Mono Fonts for Subtext Components (using same font as regular text)
        struct Mono {
            // MARK: - Mono Caption - Small Labels & Values
            struct Caption {
                static let size: CGFloat = 12        // 0.75rem
                static let weight: Font.Weight = .regular // 400
                static let lineHeight: CGFloat = 16
                static let font = Font.system(size: size, weight: weight, design: .default)
                static let usage = "Amounts, percentages, timestamps, small values"
            }
            
            // MARK: - Mono Body Small - Medium Labels & Values
            struct BodySmall {
                static let size: CGFloat = 14        // 0.875rem
                static let weight: Font.Weight = .regular // 400
                static let lineHeight: CGFloat = 20
                static let font = Font.system(size: size, weight: weight, design: .default)
                static let usage = "Currency amounts, financial values, data labels"
            }
            
            // MARK: - Mono Body - Primary Values
            struct Body {
                static let size: CGFloat = 16        // 1rem
                static let weight: Font.Weight = .medium // 500
                static let lineHeight: CGFloat = 22
                static let font = Font.system(size: size, weight: weight, design: .default)
                static let usage = "Important financial values, large amounts"
            }
            
            // MARK: - Mono H3 - Prominent Values
            struct H3 {
                static let size: CGFloat = 18        // 1.125rem
                static let weight: Font.Weight = .semibold // 600
                static let lineHeight: CGFloat = 24
                static let font = Font.system(size: size, weight: weight, design: .default)
                static let usage = "Large financial values, key metrics"
            }
            
            // MARK: - Mono H1 - Large Display Values
            struct H1 {
                static let size: CGFloat = 32        // 2rem
                static let weight: Font.Weight = .bold // 700
                static let lineHeight: CGFloat = 38
                static let font = Font.system(size: size, weight: weight, design: .default)
                static let usage = "Very large financial values, main display numbers"
            }
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
    
    // MARK: - Colors (Vibrant Modern Palette)
    struct Colors {
        // Primary Brand Colors (From your color palette)
        static let primaryBlue = Color(red: 0.341, green: 0.455, blue: 0.804) // #5774CD - Blue-Purple
        static let primaryOrange = Color(red: 0.996, green: 0.643, blue: 0.098) // #FEA419 - Orange
        static let primaryPink = Color(red: 1.0, green: 0.396, blue: 0.518) // #FF6584 - Light Pink
        static let primaryLightBlue = Color(red: 0.886, green: 0.914, blue: 1.0) // #E2E9FF - Very Light Blue-Purple
        static let primaryRed = Color(red: 0.996, green: 0.227, blue: 0.004) // #FE3A01 - Vibrant Red
        
        // Background & Neutral Colors
        static let backgroundPrimary = Color(red: 1.0, green: 1.0, blue: 1.0) // #FFFFFF - White
        static let cardBackground = Color(red: 1.0, green: 1.0, blue: 1.0) // #FFFFFF - White cards
        static let backgroundSecondary = Color(red: 0.886, green: 0.914, blue: 1.0) // #E2E9FF - Very Light Blue-Purple
        static let backgroundTertiary = Color(red: 0.95, green: 0.95, blue: 0.95) // Light gray for subtle separation
        
        // Text Colors
        static let textPrimary = Color(red: 0.247, green: 0.239, blue: 0.337) // #3F3D56 - Dark Gray
        static let textSecondary = Color(red: 0.341, green: 0.455, blue: 0.804) // #5774CD - Blue-Purple for secondary text
        static let textTertiary = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray for subtle text
        static let textQuaternary = Color(red: 0.7, green: 0.7, blue: 0.7) // Light gray for disabled states
        
        // Semantic Colors (Using your palette)
        static let success = primaryBlue // #5774CD - Blue-Purple for success
        static let warning = primaryPink // #FFB6C8 - Pink for warnings
        static let error = primaryPink // #FFB6C8 - Pink for errors
        static let info = primaryBlue // #5774CD - Blue-Purple for info
        
        // Additional variants using your palette
        static let successLight = primaryLightBlue // #E2E9FF - Light blue background for success states
        static let warningLight = primaryPink // #FFB6C8 - Light pink background for warning states
        static let errorLight = primaryPink // #FFB6C8 - Light pink background for error states
        static let infoLight = primaryLightBlue // #E2E9FF - Light blue background for info states
        
        // Border & Separator Colors (Minimalist - No borders)
        static let borderPrimary = Color.clear // No borders in minimalist design
        static let borderSecondary = Color.clear // No borders in minimalist design
        static let separator = Color.clear // No separators in minimalist design
        
        // Legacy support (keeping for compatibility)
        static let accentColor = primaryBlue // Map old name to new primary color
        static let cleanBlack = textPrimary
        static let softRed = primaryPink
        static let primaryBlueDark = primaryBlue.opacity(0.8)
        static let trustBlue = primaryBlue
        static let successGreen = primaryBlue
        static let alertRed = primaryPink
        static let electricPurple = primaryBlue
        static let vibrantTeal = primaryBlue
        static let coralOrange = primaryPink
    }
    
    // MARK: - Accessibility
    struct Accessibility {
        static let minimumTouchTarget: CGFloat = 44
        static let minimumContrastRatio: CGFloat = 4.5
    }
    
    // MARK: - Onboarding Layout Constants
    struct Onboarding {
        // Layout proportions (as percentages)
        static let illustrationHeightRatio: CGFloat = 0.50  // 50% of screen height
        static let textHeightRatio: CGFloat = 0.35          // 35% of screen height
        static let actionHeightRatio: CGFloat = 0.20        // 20% of screen height
        
        // Spacing constants
        static let headlineBodySpacing: CGFloat = 16        // Space between headline and body text
        static let buttonIndicatorSpacing: CGFloat = 24     // Space between button and page indicators
        static let indicatorBottomSpacing: CGFloat = 16     // Space below page indicators
        static let horizontalMargin: CGFloat = 20           // Horizontal margins throughout
        
        // Animation constants
        static let fadeInDuration: Double = 0.8
        static let scaleAnimationDuration: Double = 0.8
        static let scaleAnimationDelay: Double = 0.2
        static let scaleFromValue: CGFloat = 0.9
        static let scaleToValue: CGFloat = 1.0
        
        // Button constants
        static let buttonHeight: CGFloat = 56
        static let buttonCornerRadius: CGFloat = 12
        static let buttonIconSize: CGFloat = 16
        static let buttonTextSpacing: CGFloat = 12
        
        // Page indicator constants
        static let activeIndicatorWidth: CGFloat = 20
        static let activeIndicatorHeight: CGFloat = 4
        static let inactiveIndicatorSize: CGFloat = 6
        static let indicatorSpacing: CGFloat = 8
        
        // Typography constants
        static let headlineFontSize: CGFloat = 32
        static let bodyTextOpacity: CGFloat = 0.7
        
        // Color constants
        static let primaryBlueHex = Color(red: 0.341, green: 0.455, blue: 0.804)  // #5774CD
        static let lightPurpleHex = Color(red: 0.886, green: 0.914, blue: 1.0)    // #E2E9FF
        static let pinkHex = Color(red: 1.0, green: 0.396, blue: 0.518)           // #FF6584
        static let yellowHex = Color(red: 0.996, green: 0.643, blue: 0.098)       // #FEA419 (Brand Yellow)
        }
        
        // MARK: - Currency Screen Constants
        struct Currency {
            static let listHeight: CGFloat = 450
            static let backButtonHeight: CGFloat = 40
            static let backButtonCornerRadius: CGFloat = 24
            static let backButtonHorizontalPadding: CGFloat = 16
            static let backButtonTopPadding: CGFloat = 10
            static let headerSpacing: CGFloat = 16
            static let headerTopPadding: CGFloat = 20
            static let headerBottomPadding: CGFloat = 20
            static let headerHorizontalPadding: CGFloat = 20
            static let currencyItemSpacing: CGFloat = 16
            static let currencyItemHorizontalPadding: CGFloat = 16
            static let currencyItemVerticalPadding: CGFloat = 12
            static let currencySymbolSize: CGFloat = 18
            static let currencySymbolFrameSize: CGFloat = 40
            static let currencySymbolCornerRadius: CGFloat = 8
            static let currencyNameFontSize: CGFloat = 16
            static let currencyCodeFontSize: CGFloat = 14
            static let checkmarkSize: CGFloat = 24
            static let sectionHeaderFontSize: CGFloat = 16
            static let sectionHeaderPadding: CGFloat = 12
            static let sectionHeaderHorizontalPadding: CGFloat = 16
            static let sectionCornerRadius: CGFloat = 12
            static let sectionBorderWidth: CGFloat = 1
            static let sectionBottomPadding: CGFloat = 16
            static let listHorizontalPadding: CGFloat = 20
            static let listTopPadding: CGFloat = 20
        }
        
        // MARK: - Starting Balance Screen Constants
        struct StartingBalance {
            static let backButtonHeight: CGFloat = 40
            static let backButtonCornerRadius: CGFloat = 24
            static let backButtonHorizontalPadding: CGFloat = 16
            static let backButtonTopPadding: CGFloat = 10
            static let headerSpacing: CGFloat = 16
            static let headerTopPadding: CGFloat = 20
            static let headerBottomPadding: CGFloat = 0
            static let headerHorizontalPadding: CGFloat = 20
            static let headlineFontSize: CGFloat = 32
            static let bodyTextFontSize: CGFloat = 14
            static let inputSectionHeight: CGFloat = 450
            static let inputSectionSpacing: CGFloat = 20
            static let inputFieldSpacing: CGFloat = 12
            static let inputFieldHorizontalPadding: CGFloat = 16
            static let inputFieldVerticalPadding: CGFloat = 16
            static let inputFieldCornerRadius: CGFloat = 12
            static let inputFieldBorderWidth: CGFloat = 1
            static let currencySymbolWidth: CGFloat = 40
            static let inputFontSize: CGFloat = 20
            static let labelFontSize: CGFloat = 16
            static let errorFontSize: CGFloat = 14
            static let quickAmountsSpacing: CGFloat = 12
            static let quickAmountButtonSpacing: CGFloat = 12
            static let quickAmountButtonVerticalPadding: CGFloat = 12
            static let quickAmountButtonCornerRadius: CGFloat = 8
            static let quickAmountFontSize: CGFloat = 14
            static let quickAmountValues: [Int] = [100, 500, 1000, 5000]
            static let sectionHorizontalPadding: CGFloat = 20
            static let sectionTopPadding: CGFloat = 20
            static let sectionCornerRadius: CGFloat = 12
        }
    
    // MARK: - Minimalist Design Tokens (Professional Flat Design Style - No Visual Effects)
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
        
        // Tinted Colors for Emphasis (using pink brand palette)
        static let tintedBlue = Colors.primaryBlue.opacity(0.15)
        static let tintedOrange = Colors.primaryPink.opacity(0.15)
        static let tintedPink = Colors.primaryPink.opacity(0.15)
        static let tintedLightBlue = Colors.primaryLightBlue.opacity(0.15)
        
        // Legacy support (disabled for minimalist design)
        static let blurRadius: CGFloat = 0
        static let saturation: Double = 1.0
        static let brightness: Double = 0.0
        static let opacity: Double = 1.0
    }
}
