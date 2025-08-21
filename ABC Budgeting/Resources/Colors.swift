import SwiftUI

// MARK: - App Color Palette
struct AppColors {
    private static func safeColor(_ color: @autoclosure () -> Color, fallback: Color = .black, name: String) -> Color {
        return color()
    }
    static var brandBlack: Color { return safeColor(Color(red: 36.0/255.0, green: 36.0/255.0, blue: 36.0/255.0), name: "brandBlack") }
    static var brandBlue: Color { return safeColor(Color(red: 55.0/255.0, green: 124.0/255.0, blue: 200.0/255.0), name: "brandBlue") }
    static var brandYellow: Color { return safeColor(Color(red: 255.0/255.0, green: 203.0/255.0, blue: 86.0/255.0), name: "brandYellow") }
    static var brandGreen: Color { return safeColor(Color(red: 70.0/255.0, green: 155.0/255.0, blue: 136.0/255.0), name: "brandGreen") }
    static var brandPurple: Color { return safeColor(Color(red: 157.0/255.0, green: 167.0/255.0, blue: 208.0/255.0), name: "brandPurple") }
    static var brandPink: Color { return safeColor(Color(red: 231.0/255.0, green: 140.0/255.0, blue: 157.0/255.0), name: "brandPink") }
    static var brandRed: Color { return safeColor(Color(red: 224.0/255.0, green: 83.0/255.0, blue: 61.0/255.0), name: "brandRed") }
    static var brandWhite: Color { return safeColor(Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0), name: "brandWhite") }
    static var white: Color { return safeColor(Color(red: 1, green: 1, blue: 1), name: "white") } // #FFFFFF
    static var background: Color { return safeColor(Color(red: 243.0/255.0, green: 243.0/255.0, blue: 243.0/255.0), name: "background") } // #F3F3F3
    
    // Backgrounds
    static var card: Color { return safeColor(Color.white, name: "card") }
    static var cardShadow: Color { return safeColor(Color.black.opacity(0.05), name: "cardShadow") }

    // Semantic
    static var income: Color { return brandGreen }
    static var expense: Color { return brandRed }
    static var accent: Color { return brandBlue }
    static var savings: Color { return brandYellow }
    static var earnings: Color { return brandPink }
    static var chartBar: Color { return brandGreen }
    static var chartAxis: Color { return safeColor(Color.gray.opacity(0.5), name: "chartAxis") }
    static var tagUnselected: Color { return safeColor(Color(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0), name: "tagUnselected") } // #8C8F98
    static var tagUnselectedBackground: Color { return safeColor(Color(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0), name: "tagUnselectedBackground") } // #F0F0F0
}

