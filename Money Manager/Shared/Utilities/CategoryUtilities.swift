//
//  CategoryUtilities.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Centralized category management utilities providing localized names, icons,
//  and colors for transaction categories. Eliminates code duplication and
//  ensures consistent category handling across the app.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct CategoryUtilities {
    
    static func localizedName(for category: String) -> String {
        let contentManager = MultilingualContentManager.shared
        switch category.lowercased() {
        case "food": return contentManager.localizedString("category.food")
        case "transport": return contentManager.localizedString("category.transport")
        case "shopping": return contentManager.localizedString("category.shopping")
        case "entertainment": return contentManager.localizedString("category.entertainment")
        case "bills": return contentManager.localizedString("category.bills")
        case "savings": return contentManager.localizedString("category.savings")
        case "income": return contentManager.localizedString("category.income")
        case "housing": return contentManager.localizedString("category.housing")
        case "healthcare", "health & fitness": return contentManager.localizedString("category.healthcare")
        case "education": return contentManager.localizedString("category.education")
        case "travel": return contentManager.localizedString("category.travel")
        case "other": return contentManager.localizedString("category.other")
        default: return contentManager.localizedString("category.other")
        }
    }
    
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
    
    // MARK: - Available Categories (English keys for internal use)
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
    
    var localizedCategoryName: String {
        CategoryUtilities.localizedName(for: self)
    }
}
