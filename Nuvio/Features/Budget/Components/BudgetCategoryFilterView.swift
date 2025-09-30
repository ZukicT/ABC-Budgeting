//
//  BudgetCategoryFilterView.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Category filter component for budget views providing horizontal scrolling
//  filter tags. Allows users to filter budgets by category with visual
//  selection states and accessibility support.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct BudgetCategoryFilterView: View {
    @Binding var selectedCategory: String?
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    let categories = CategoryUtilities.budgetCategories
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.UI.Spacing.small) {
                BudgetCategoryFilterTag(
                    category: nil,
                    displayName: contentManager.localizedString("budget.filter.all"),
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil,
                    action: {
                        selectedCategory = nil
                    }
                )
                
                ForEach(categories, id: \.self) { category in
                    BudgetCategoryFilterTag(
                        category: category,
                        displayName: category.localizedCategoryName,
                        icon: nil,
                        isSelected: selectedCategory == category,
                        action: {
                            selectedCategory = category
                        }
                    )
                }
            }
            .padding(.horizontal, Constants.UI.Padding.screenMargin)
        }
        .padding(.horizontal, -Constants.UI.Padding.screenMargin)
    }
}

struct BudgetCategoryFilterTag: View {
    let category: String?
    let displayName: String
    let icon: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.UI.Spacing.small) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(isSelected ? Constants.Colors.backgroundPrimary : Constants.Colors.textPrimary)
                }
                
                Text(displayName)
                    .font(Constants.Typography.BodySmall.font)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? Constants.Colors.backgroundPrimary : Constants.Colors.textPrimary)
            }
            .padding(.horizontal, Constants.UI.Spacing.medium)
            .padding(.vertical, Constants.UI.Spacing.small)
            .background(
                RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                    .fill(isSelected ? Constants.Colors.textPrimary : Constants.Colors.textPrimary.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Filter by \(displayName)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    BudgetCategoryFilterView(selectedCategory: .constant("Food"))
}
