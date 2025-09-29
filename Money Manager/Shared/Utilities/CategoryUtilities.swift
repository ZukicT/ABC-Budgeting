import SwiftUI

/// Centralized category management utilities to eliminate code duplication
struct CategoryUtilities {
    
    // MARK: - Category Icons
    static func icon(for category: String) -> String {
        switch category.lowercased() {
        case "food", "food & dining": return "fork.knife"
        case "transport", "transportation": return "car.fill"
        case "shopping": return "bag.fill"
        case "entertainment": return "tv.fill"
        case "bills", "utilities": return "doc.text.fill"
        case "savings": return "banknote.fill"
        case "income": return "arrow.down.circle.fill"
        case "housing": return "house.fill"
        case "healthcare", "health & fitness": return "cross.fill"
        case "education": return "graduationcap.fill"
        case "travel": return "airplane"
        case "other": return "questionmark.circle.fill"
        default: return "dollarsign.circle.fill"
        }
    }
    
    // MARK: - Category Colors
    static func color(for category: String) -> Color {
        switch category.lowercased() {
        case "food", "food & dining": return Constants.Colors.success
        case "transport", "transportation": return Constants.Colors.info
        case "shopping": return Constants.Colors.warning
        case "entertainment": return Constants.Colors.error
        case "bills", "utilities": return Constants.Colors.textSecondary
        case "savings": return Constants.Colors.success
        case "income": return Constants.Colors.success
        case "housing": return Constants.Colors.error
        case "healthcare", "health & fitness": return Constants.Colors.error
        case "education": return Constants.Colors.info
        case "travel": return Constants.Colors.warning
        case "other": return Constants.Colors.textTertiary
        default: return Constants.Colors.info
        }
    }
    
    // MARK: - Available Categories
    static let budgetCategories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Savings", "Other"]
    static let transactionCategories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Income", "Other"]
    static let allCategories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Savings", "Income", "Housing", "Healthcare", "Education", "Travel", "Other"]
}

// MARK: - Category Extension
extension String {
    var categoryIcon: String {
        CategoryUtilities.icon(for: self)
    }
    
    var categoryColor: Color {
        CategoryUtilities.color(for: self)
    }
}
