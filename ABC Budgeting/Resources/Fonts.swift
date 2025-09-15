import SwiftUI

// MARK: - Professional Typography System
struct AppFonts {
    // MARK: - Display Fonts (Large Headers)
    static let displayLarge = Font.system(size: 48, weight: .bold, design: .default)
    static let displayMedium = Font.system(size: 40, weight: .bold, design: .default)
    static let displaySmall = Font.system(size: 32, weight: .bold, design: .default)
    
    // MARK: - Heading Fonts
    static let h1 = Font.system(size: 28, weight: .bold, design: .default)      // Main page titles
    static let h2 = Font.system(size: 24, weight: .bold, design: .default)      // Section headers
    static let h3 = Font.system(size: 20, weight: .semibold, design: .default)  // Subsection headers
    static let h4 = Font.system(size: 18, weight: .semibold, design: .default)  // Card titles
    static let h5 = Font.system(size: 16, weight: .semibold, design: .default)  // Small headers
    static let h6 = Font.system(size: 14, weight: .semibold, design: .default)  // Micro headers
    
    // MARK: - Body Text Fonts
    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)    // Large body text
    static let body = Font.system(size: 16, weight: .regular, design: .default)         // Standard body text
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)    // Small body text
    static let bodyTiny = Font.system(size: 12, weight: .regular, design: .default)     // Tiny body text
    
    // MARK: - Label Fonts
    static let labelLarge = Font.system(size: 16, weight: .medium, design: .default)    // Large labels
    static let label = Font.system(size: 14, weight: .medium, design: .default)         // Standard labels
    static let labelSmall = Font.system(size: 12, weight: .medium, design: .default)    // Small labels
    static let labelTiny = Font.system(size: 10, weight: .medium, design: .default)     // Tiny labels
    
    // MARK: - Button Fonts
    static let buttonLarge = Font.system(size: 18, weight: .semibold, design: .default) // Large buttons
    static let button = Font.system(size: 16, weight: .semibold, design: .default)      // Standard buttons
    static let buttonSmall = Font.system(size: 14, weight: .semibold, design: .default) // Small buttons
    static let buttonTiny = Font.system(size: 12, weight: .semibold, design: .default)  // Tiny buttons
    
    // MARK: - Caption Fonts
    static let caption = Font.system(size: 12, weight: .regular, design: .default)      // Standard captions
    static let captionSmall = Font.system(size: 10, weight: .regular, design: .default) // Small captions
    
    // MARK: - Special Fonts
    static let overline = Font.system(size: 10, weight: .semibold, design: .default)    // Overline text
    static let code = Font.system(size: 14, weight: .regular, design: .monospaced)      // Code text
    static let tab = Font.system(size: 12, weight: .medium, design: .default)           // Tab bar text
}

// MARK: - Text Style Modifiers
struct AppTextStyles {
    // MARK: - Display Styles
    static let displayLarge = AppFonts.displayLarge
    static let displayMedium = AppFonts.displayMedium
    static let displaySmall = AppFonts.displaySmall
    
    // MARK: - Heading Styles
    static let h1 = AppFonts.h1
    static let h2 = AppFonts.h2
    static let h3 = AppFonts.h3
    static let h4 = AppFonts.h4
    static let h5 = AppFonts.h5
    static let h6 = AppFonts.h6
    
    // MARK: - Body Styles
    static let bodyLarge = AppFonts.bodyLarge
    static let body = AppFonts.body
    static let bodySmall = AppFonts.bodySmall
    static let bodyTiny = AppFonts.bodyTiny
    
    // MARK: - Label Styles
    static let labelLarge = AppFonts.labelLarge
    static let label = AppFonts.label
    static let labelSmall = AppFonts.labelSmall
    static let labelTiny = AppFonts.labelTiny
    
    // MARK: - Button Styles
    static let buttonLarge = AppFonts.buttonLarge
    static let button = AppFonts.button
    static let buttonSmall = AppFonts.buttonSmall
    static let buttonTiny = AppFonts.buttonTiny
    
    // MARK: - Caption Styles
    static let caption = AppFonts.caption
    static let captionSmall = AppFonts.captionSmall
    
    // MARK: - Special Styles
    static let overline = AppFonts.overline
    static let code = AppFonts.code
    static let tab = AppFonts.tab
}

// MARK: - Typography Extensions
extension Font {
    // MARK: - Display Fonts
    static var displayLarge: Font { AppFonts.displayLarge }
    static var displayMedium: Font { AppFonts.displayMedium }
    static var displaySmall: Font { AppFonts.displaySmall }
    
    // MARK: - Heading Fonts
    static var h1: Font { AppFonts.h1 }
    static var h2: Font { AppFonts.h2 }
    static var h3: Font { AppFonts.h3 }
    static var h4: Font { AppFonts.h4 }
    static var h5: Font { AppFonts.h5 }
    static var h6: Font { AppFonts.h6 }
    
    // MARK: - Body Fonts
    static var bodyLarge: Font { AppFonts.bodyLarge }
    static var body: Font { AppFonts.body }
    static var bodySmall: Font { AppFonts.bodySmall }
    static var bodyTiny: Font { AppFonts.bodyTiny }
    
    // MARK: - Label Fonts
    static var labelLarge: Font { AppFonts.labelLarge }
    static var label: Font { AppFonts.label }
    static var labelSmall: Font { AppFonts.labelSmall }
    static var labelTiny: Font { AppFonts.labelTiny }
    
    // MARK: - Button Fonts
    static var buttonLarge: Font { AppFonts.buttonLarge }
    static var button: Font { AppFonts.button }
    static var buttonSmall: Font { AppFonts.buttonSmall }
    static var buttonTiny: Font { AppFonts.buttonTiny }
    
    // MARK: - Caption Fonts
    static var caption: Font { AppFonts.caption }
    static var captionSmall: Font { AppFonts.captionSmall }
    
    // MARK: - Special Fonts
    static var overline: Font { AppFonts.overline }
    static var code: Font { AppFonts.code }
    static var tab: Font { AppFonts.tab }
} 