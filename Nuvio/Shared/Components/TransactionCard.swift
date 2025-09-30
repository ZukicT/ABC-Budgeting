//
//  TransactionCard.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Reusable transaction card component providing consistent transaction display
//  with category icons, formatting, and accessibility support. Used across
//  the app for uniform transaction presentation.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct TransactionCard: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: Constants.UI.Spacing.medium) {
            // Category Icon - Fixed Size
            ZStack {
                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                    .fill(Constants.Colors.cleanBlack)
                    .frame(width: 40, height: 40)
                
                Image(systemName: categoryIcon(for: transaction.category))
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(.white)
            }
            .accessibilityHidden(true)
            
            // Transaction Details - Fixed Layout
            VStack(alignment: .leading, spacing: 4) {
                // Transaction Title - Primary Information
                Text(transaction.title)
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                // Category and Date - Secondary Information
                HStack(spacing: 6) {
                    Text(transaction.category.localizedCategoryName)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text("•")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textTertiary)
                    
                    Text(transaction.date, format: .dateTime.month(.abbreviated).day().year(.twoDigits))
                        .font(Constants.Typography.Mono.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Amount Section - Fixed Width
            VStack(alignment: .trailing, spacing: 2) {
                // Amount - Most Prominent
        Text(transaction.amount, format: .currency(code: "USD"))
            .font(Constants.Typography.Mono.H3.font)
            .foregroundColor(transaction.amount >= 0 ? Constants.Colors.success : Constants.Colors.error)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // Transaction Type Label
                Text(transaction.amount >= 0 ? "Income" : "Expense")
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(transaction.amount >= 0 ? Constants.Colors.success : Constants.Colors.error)
            }
            .frame(width: 80, alignment: .trailing)
        }
        .padding(Constants.UI.Padding.cardInternal)
        .background(Constants.Colors.cardBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(transaction.title), \(transaction.amount, format: .currency(code: "USD")), \(transaction.category)")
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "food": return "fork.knife"
        case "transport": return "car.fill"
        case "shopping": return "bag.fill"
        case "entertainment": return "tv.fill"
        case "bills": return "doc.text.fill"
        case "income": return "arrow.down.circle.fill"
        default: return "creditcard.fill"
        }
    }
    
}

#Preview {
    VStack(spacing: 16) {
        TransactionCard(transaction: Transaction(
            title: "Coffee Shop",
            amount: -4.50,
            date: Date(),
            category: "Food"
        ))
        
        TransactionCard(transaction: Transaction(
            title: "Salary",
            amount: 2500.00,
            date: Date(),
            category: "Income"
        ))
    }
    .padding()
}
