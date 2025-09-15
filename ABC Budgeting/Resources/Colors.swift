import SwiftUI

// MARK: - Professional Flat Design Color System
struct AppColors {
    // MARK: - Primary Brand Colors
    static var primary: Color { Color(red: 0.0196, green: 0.8118, blue: 0.2980) } // New green primary color #05CF4C
    static var primaryDark: Color { Color(red: 0.01, green: 0.65, blue: 0.24) } // Darker version of new green #05CF4C
    static var secondary: Color { Color(red: 0.0196, green: 0.8118, blue: 0.2980) }     // New green primary color #05CF4C
    static var accent: Color { Color(hex: "7C3AED") }        // #7C3AED - Professional purple
    
    // MARK: - Background Colors
    static var background: Color { Color(hex: "FAFAFA") }    // #FAFAFA - Clean light background
    static var backgroundSecondary: Color { Color(hex: "F5F5F5") } // #F5F5F5 - Secondary background
    static var card: Color { Color(red: 0.1, green: 0.11, blue: 0.11) } // Dark card background
    static var cardSecondary: Color { Color(red: 0.1, green: 0.11, blue: 0.11) } // Dark card background
    
    // MARK: - Text Colors
    static var textPrimary: Color { Color(hex: "111827") }   // #111827 - Primary text (dark gray)
    static var textSecondary: Color { Color(hex: "6B7280") } // #6B7280 - Secondary text (medium gray)
    static var textTertiary: Color { Color(hex: "9CA3AF") }  // #9CA3AF - Tertiary text (light gray)
    static var textInverse: Color { Color(hex: "FFFFFF") }   // #FFFFFF - White text for dark backgrounds
    
    // MARK: - Semantic Colors
    static var success: Color { Color(red: 0.0196, green: 0.8118, blue: 0.2980) }       // New green primary color #05CF4C
    static var successLight: Color { Color(red: 0.0196, green: 0.8118, blue: 0.2980).opacity(0.1) }  // Light version of new green #05CF4C
    static var warning: Color { Color(hex: "D97706") }       // #D97706 - Warning orange
    static var warningLight: Color { Color(hex: "FEF3C7") }  // #FEF3C7 - Light warning background
    static var error: Color { Color(hex: "DC2626") }         // #DC2626 - Error red
    static var errorLight: Color { Color(hex: "FEE2E2") }    // #FEE2E2 - Light error background
    static var info: Color { Color(red: 0.0196, green: 0.8118, blue: 0.2980) }          // New green primary color #05CF4C
    static var infoLight: Color { Color(red: 0.0196, green: 0.8118, blue: 0.2980).opacity(0.1) }     // Light version of new green #05CF4C
    
    // MARK: - Transaction Colors
    static var income: Color { Color(red: 0.0196, green: 0.8118, blue: 0.2980) }        // New green primary color #05CF4C
    static var expense: Color { Color(hex: "DC2626") }       // #DC2626 - Red for expenses
    static var savings: Color { Color(hex: "7C3AED") }       // #7C3AED - Purple for savings
    static var earnings: Color { Color(red: 0.0196, green: 0.8118, blue: 0.2980) }      // New green primary color #05CF4C
    
    // MARK: - UI Element Colors
    static var border: Color { Color(hex: "E5E7EB") }        // #E5E7EB - Light border
    static var borderDark: Color { Color(hex: "D1D5DB") }    // #D1D5DB - Darker border
    static var divider: Color { Color(hex: "F3F4F6") }       // #F3F4F6 - Divider color
    static var shadow: Color { Color(hex: "000000").opacity(0.05) } // Subtle shadow
    
    // MARK: - Button Colors
    static var buttonPrimary: Color { Color(red: 0.0196, green: 0.8118, blue: 0.2980) } // New green primary color #05CF4C
    static var buttonPrimaryPressed: Color { Color(red: 0.01, green: 0.65, blue: 0.24) } // Darker version of new green #05CF4C
    static var buttonSecondary: Color { Color(hex: "F3F4F6") } // #F3F4F6 - Secondary button
    static var buttonSecondaryPressed: Color { Color(hex: "E5E7EB") } // #E5E7EB - Pressed secondary
    static var buttonDestructive: Color { Color(hex: "DC2626") } // #DC2626 - Destructive button
    static var buttonDestructivePressed: Color { Color(hex: "B91C1C") } // #B91C1C - Pressed destructive
    
    // MARK: - Chart Colors
    static var chartPrimary: Color { Color(red: 0.0196, green: 0.8118, blue: 0.2980) }  // New green primary color #05CF4C
    static var chartSecondary: Color { Color(red: 0.0196, green: 0.8118, blue: 0.2980) } // New green primary color #05CF4C
    static var chartTertiary: Color { Color(hex: "7C3AED") } // #7C3AED - Tertiary chart color
    static var chartQuaternary: Color { Color(hex: "D97706") } // #D97706 - Quaternary chart color
    static var chartAxis: Color { Color(hex: "E5E7EB") }     // #E5E7EB - Chart axis color
    static var chartGrid: Color { Color(hex: "F3F4F6") }     // #F3F4F6 - Chart grid color
    
    // MARK: - Status Colors
    static var statusActive: Color { Color(red: 0.0196, green: 0.8118, blue: 0.2980) }  // New green primary color #05CF4C
    static var statusInactive: Color { Color(hex: "6B7280") } // #6B7280 - Inactive status
    static var statusPending: Color { Color(hex: "D97706") } // #D97706 - Pending status
    static var statusError: Color { Color(hex: "DC2626") }   // #DC2626 - Error status
    
    // MARK: - Utility Colors
    static var white: Color { Color(hex: "FFFFFF") }
    static var black: Color { Color(hex: "000000") }
    static var transparent: Color { Color.clear }
    
    // MARK: - Category Colors (for transactions)
    static var categoryFood: Color { Color(hex: "F59E0B") }      // #F59E0B - Food category
    static var categoryLeisure: Color { Color(hex: "8B5CF6") }   // #8B5CF6 - Leisure category
    static var categoryBills: Color { Color(hex: "EF4444") }     // #EF4444 - Bills category
    static var categoryTransport: Color { Color(hex: "06B6D4") } // #06B6D4 - Transport category
    static var categoryHealth: Color { Color(hex: "EC4899") }    // #EC4899 - Health category
    static var categoryShopping: Color { Color(hex: "10B981") }  // #10B981 - Shopping category
    static var categoryOther: Color { Color(hex: "6B7280") }     // #6B7280 - Other category
}


