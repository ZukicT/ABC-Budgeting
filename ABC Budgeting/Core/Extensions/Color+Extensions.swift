import SwiftUI

extension Color {
    static func fromName(_ name: String) -> Color {
        switch name.lowercased() {
        case "blue": return .blue
        case "green": return RobinhoodColors.primary
        case "orange": return .orange
        case "red": return .red
        case "purple": return .purple
        case "mint": return .mint
        case "gray", "grey": return .gray
        case "yellow": return .yellow
        case "pink": return .pink
        case "cyan": return .cyan
        case "indigo": return .indigo
        case "teal": return .teal
        case "brown": return .brown
        case "black": return .black
        case "white": return .white
        // Handle opacity cases
        case "orange.opacity15": return Color.orange.opacity(0.15)
        case "purple.opacity15": return Color.purple.opacity(0.15)
        case "green.opacity15": return RobinhoodColors.primary.opacity(0.15)
        case "mint.opacity15": return Color.mint.opacity(0.15)
        case "red.opacity15": return Color.red.opacity(0.15)
        case "gray.opacity15", "grey.opacity15": return Color.gray.opacity(0.15)
        case "blue.opacity15": return Color.blue.opacity(0.15)
        case "yellow.opacity15": return Color.yellow.opacity(0.15)
        case "pink.opacity15": return Color.pink.opacity(0.15)
        case "cyan.opacity15": return Color.cyan.opacity(0.15)
        case "indigo.opacity15": return Color.indigo.opacity(0.15)
        case "teal.opacity15": return Color.teal.opacity(0.15)
        case "brown.opacity15": return Color.brown.opacity(0.15)
        default: return .gray
        }
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
}
