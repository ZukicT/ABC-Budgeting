import SwiftUI

struct TrapFontUtility {
    
    // MARK: - Font Family Name
    static let fontFamilyName = "Trap"
    
    // MARK: - Font Weights
    enum TrapWeight: String, CaseIterable {
        case light = "Light"
        case regular = "Regular"
        case medium = "Medium"
        case semiBold = "SemiBold"
        case bold = "Bold"
        case extraBold = "ExtraBold"
        case black = "Black"
        
        var fontName: String {
            return "\(TrapFontUtility.fontFamilyName)-\(rawValue)"
        }
        
        var swiftUIWeight: Font.Weight {
            switch self {
            case .light: return .light
            case .regular: return .regular
            case .medium: return .medium
            case .semiBold: return .semibold
            case .bold: return .bold
            case .extraBold: return .heavy
            case .black: return .black
            }
        }
    }
    
    // MARK: - Font Creation
    static func trapFont(size: CGFloat, weight: TrapWeight) -> Font {
        return Font.custom(weight.fontName, size: size)
    }
    
    // MARK: - Typography Scale
    struct Typography {
        // MARK: - H1 - Screen Titles
        struct H1 {
            static let size: CGFloat = 32
            static let weight: TrapWeight = .bold
            static let lineHeight: CGFloat = 38
            static let font = trapFont(size: size, weight: weight)
            static let usage = "Main screen headers, account balance"
        }
        
        // MARK: - H2 - Section Headers
        struct H2 {
            static let size: CGFloat = 24
            static let weight: TrapWeight = .semiBold
            static let lineHeight: CGFloat = 30
            static let font = trapFont(size: size, weight: weight)
            static let usage = "Category titles, card headers"
        }
        
        // MARK: - H3 - Subsection Headers
        struct H3 {
            static let size: CGFloat = 18
            static let weight: TrapWeight = .semiBold
            static let lineHeight: CGFloat = 24
            static let font = trapFont(size: size, weight: weight)
            static let usage = "Transaction categories, settings sections"
        }
        
        // MARK: - Body - Primary Text
        struct Body {
            static let size: CGFloat = 16
            static let weight: TrapWeight = .regular
            static let lineHeight: CGFloat = 22
            static let font = trapFont(size: size, weight: weight)
            static let usage = "Transaction descriptions, main content"
        }
        
        // MARK: - Body Small - Secondary Text
        struct BodySmall {
            static let size: CGFloat = 14
            static let weight: TrapWeight = .regular
            static let lineHeight: CGFloat = 20
            static let font = trapFont(size: size, weight: weight)
            static let usage = "Dates, helper text, descriptions"
        }
        
        // MARK: - Caption - Meta Information
        struct Caption {
            static let size: CGFloat = 12
            static let weight: TrapWeight = .regular
            static let lineHeight: CGFloat = 16
            static let font = trapFont(size: size, weight: weight)
            static let usage = "Timestamps, fine print, labels"
        }
        
        // MARK: - Button Text
        struct Button {
            static let size: CGFloat = 16
            static let weight: TrapWeight = .semiBold
            static let lineHeight: CGFloat = 20
            static let font = trapFont(size: size, weight: weight)
            static let usage = "All button labels"
        }
        
        // MARK: - Large Display Text
        struct Display {
            static let size: CGFloat = 48
            static let weight: TrapWeight = .black
            static let lineHeight: CGFloat = 56
            static let font = trapFont(size: size, weight: weight)
            static let usage = "Large numbers, hero text"
        }
        
        // MARK: - Small Display Text
        struct DisplaySmall {
            static let size: CGFloat = 36
            static let weight: TrapWeight = .extraBold
            static let lineHeight: CGFloat = 42
            static let font = trapFont(size: size, weight: weight)
            static let usage = "Medium numbers, important values"
        }
    }
    
    // MARK: - Font Loading Verification
    static func verifyFontsLoaded() -> Bool {
        let weights: [TrapWeight] = [.light, .regular, .medium, .semiBold, .bold, .extraBold, .black]
        var allLoaded = true
        
        print("🔍 Checking Trap font availability...")
        
        for weight in weights {
            let font = UIFont(name: weight.fontName, size: 16)
            if font == nil {
                print("⚠️ Trap font not loaded: \(weight.fontName)")
                allLoaded = false
            } else {
                print("✅ Trap font loaded: \(weight.fontName)")
            }
        }
        
        if allLoaded {
            print("🎉 All Trap fonts loaded successfully!")
        } else {
            print("❌ Some Trap fonts failed to load. Using system font fallbacks.")
        }
        
        return allLoaded
    }
    
    // MARK: - List All Available Fonts (for debugging)
    static func listAllAvailableFonts() {
        print("📋 All available fonts in the app:")
        for family in UIFont.familyNames.sorted() {
            print("Family: \(family)")
            for font in UIFont.fontNames(forFamilyName: family) {
                print("  - \(font)")
            }
        }
    }
    
    // MARK: - Fallback Font System
    static func fallbackFont(size: CGFloat, weight: TrapWeight) -> Font {
        return Font.system(size: size, weight: weight.swiftUIWeight)
    }
    
    // MARK: - Safe Font Creation (with fallback)
    static func safeTrapFont(size: CGFloat, weight: TrapWeight) -> Font {
        // Check if Trap font is available
        if UIFont(name: weight.fontName, size: size) != nil {
            return trapFont(size: size, weight: weight)
        } else {
            print("⚠️ Using fallback font for \(weight.fontName)")
            return fallbackFont(size: size, weight: weight)
        }
    }
}
