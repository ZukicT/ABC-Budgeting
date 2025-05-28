import SwiftUI

// MARK: - App Color Palette
struct AppColors {
    private static func safeColor(_ color: @autoclosure () -> Color, fallback: Color = .black, name: String) -> Color {
        do {
            let c = color()
            return c
        } catch {
            print("[AppColors] Failed to create color for \(name): \(error). Using fallback color.")
            return fallback
        }
    }
    static var brandBlack: Color { print("AppColors.brandBlack"); return safeColor(Color(red: 36.0/255.0, green: 36.0/255.0, blue: 36.0/255.0), name: "brandBlack") }
    static var brandBlue: Color { print("AppColors.brandBlue"); return safeColor(Color(red: 55.0/255.0, green: 124.0/255.0, blue: 200.0/255.0), name: "brandBlue") }
    static var brandYellow: Color { print("AppColors.brandYellow"); return safeColor(Color(red: 255.0/255.0, green: 203.0/255.0, blue: 86.0/255.0), name: "brandYellow") }
    static var brandGreen: Color { print("AppColors.brandGreen"); return safeColor(Color(red: 70.0/255.0, green: 155.0/255.0, blue: 136.0/255.0), name: "brandGreen") }
    static var brandPurple: Color { print("AppColors.brandPurple"); return safeColor(Color(red: 157.0/255.0, green: 167.0/255.0, blue: 208.0/255.0), name: "brandPurple") }
    static var brandPink: Color { print("AppColors.brandPink"); return safeColor(Color(red: 231.0/255.0, green: 140.0/255.0, blue: 157.0/255.0), name: "brandPink") }
    static var brandRed: Color { print("AppColors.brandRed"); return safeColor(Color(red: 224.0/255.0, green: 83.0/255.0, blue: 61.0/255.0), name: "brandRed") }
    static var brandWhite: Color { print("AppColors.brandWhite"); return safeColor(Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0), name: "brandWhite") }
    static var white: Color { print("AppColors.white"); return safeColor(Color(red: 1, green: 1, blue: 1), name: "white") } // #FFFFFF
    static var background: Color { print("AppColors.background"); return safeColor(Color(red: 243.0/255.0, green: 243.0/255.0, blue: 243.0/255.0), name: "background") } // #F3F3F3
    
    // Backgrounds
    static var card: Color { print("AppColors.card"); return safeColor(Color.white, name: "card") }
    static var cardShadow: Color { print("AppColors.cardShadow"); return safeColor(Color.black.opacity(0.05), name: "cardShadow") }

    // Semantic
    static var income: Color { print("AppColors.income"); return brandGreen }
    static var outcome: Color { print("AppColors.outcome"); return brandRed }
    static var accent: Color { print("AppColors.accent"); return brandBlue }
    static var savings: Color { print("AppColors.savings"); return brandYellow }
    static var earnings: Color { print("AppColors.earnings"); return brandPink }
    static var chartBar: Color { print("AppColors.chartBar"); return brandGreen }
    static var chartAxis: Color { print("AppColors.chartAxis"); return safeColor(Color.gray.opacity(0.5), name: "chartAxis") }
    static var tagUnselected: Color { print("AppColors.tagUnselected"); return safeColor(Color(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0), name: "tagUnselected") } // #8C8F98
    static var tagUnselectedBackground: Color { print("AppColors.tagUnselectedBackground"); return safeColor(Color(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0), name: "tagUnselectedBackground") } // #F0F0F0
}

