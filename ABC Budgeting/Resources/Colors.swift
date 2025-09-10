import SwiftUI

// MARK: - App Color Palette
struct AppColors {
    // Primary Colors
    static var primary: Color { Color(hex: "0a38c3") }      // #0a38c3 - Main brand color
    static var secondary: Color { Color(hex: "07e95e") }    // #07e95e - Accent color
    static var background: Color { Color(hex: "daeaf3") }   // #daeaf3 - Background color
    
    // Semantic Colors
    static var brandBlue: Color { primary }
    static var brandGreen: Color { secondary }
    static var brandBlack: Color { Color.black }
    static var brandWhite: Color { Color.white }
    
    // Backgrounds
    static var card: Color { Color.white }
    static var cardShadow: Color { Color.black.opacity(0.05) }
    
    // Semantic
    static var income: Color { secondary }
    static var expense: Color { primary }
    static var accent: Color { primary }
    static var savings: Color { secondary }
    static var earnings: Color { secondary }
    static var chartBar: Color { secondary }
    static var chartAxis: Color { Color.gray.opacity(0.5) }
    static var tagUnselected: Color { Color.gray }
    static var tagUnselectedBackground: Color { Color.gray.opacity(0.1) }
    
    // Utility Colors
    static var white: Color { Color.white }
    static var black: Color { Color.black }
    static var gray: Color { Color.gray }
    static var red: Color { primary }      // Use primary for error/expense
    static var yellow: Color { secondary } // Use secondary for warnings
    static var purple: Color { primary }   // Use primary for special elements
    static var pink: Color { secondary }   // Use secondary for highlights
    static var orange: Color { secondary } // Use secondary for alerts
    static var teal: Color { primary }     // Use primary for info
    static var indigo: Color { primary }   // Use primary for navigation
    static var cyan: Color { secondary }   // Use secondary for success
}

// MARK: - Color Extension for Hex Support
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb = Int(red * 255) << 16 | Int(green * 255) << 8 | Int(blue * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
}

