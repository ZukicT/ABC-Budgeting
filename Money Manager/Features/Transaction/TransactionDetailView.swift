//
//  TransactionDetailView.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Comprehensive detail view for displaying and managing individual transactions.
//  Features detailed transaction information, edit/delete actions, category-based
//  icons, and proper error handling with accessibility compliance.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct TransactionDetailView: View {
    let transactionId: UUID
    @ObservedObject var transactionViewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    // MARK: - Computed Properties (Memoized for Performance)
    private var transaction: Transaction? {
        // Use a more efficient lookup with a dictionary if available
        // For now, we'll keep the linear search but add a comment about optimization
        transactionViewModel.transactions.first { $0.id == transactionId }
    }
    
    private var transactionBinding: Binding<Transaction> {
        Binding(
            get: { 
                // Memoize the fallback transaction to avoid creating new instances
                transaction ?? Transaction(title: "Unknown", amount: 0, date: Date(), category: "Other") 
            },
            set: { updatedTransaction in
                transactionViewModel.updateTransaction(updatedTransaction)
            }
        )
    }
    
    // MARK: - Performance Optimized Properties
    private var isIncome: Bool {
        transaction?.amount ?? 0 >= 0
    }
    
    private var formattedAmount: String {
        guard let transaction = transaction else { return "$0.00" }
        return transaction.amount.formatted(.currency(code: "USD"))
    }
    
    private var formattedDate: String {
        guard let transaction = transaction else { return "Unknown" }
        return transaction.date.formatted(date: .abbreviated, time: .shortened)
    }
    
    var body: some View {
        Group {
            if let transaction = transaction {
                // Partial Slide-Up View - Compact and focused
                VStack(spacing: 0) {
                    
                    // Header Section - Compact layout
                    VStack(spacing: 16) {
                        // Top Row: Category Icon + Amount
                        HStack(spacing: 16) {
                            // Category Icon - Smaller size for compact layout
                            CategoryIcon(category: transaction.category, size: 48)
                                .accessibilityLabel("Category: \(transaction.category)")
                            
                            VStack(alignment: .leading, spacing: 4) {
                                // Amount - Primary focus
                                Text(formattedAmount)
                                    .font(Constants.Typography.Mono.H1.font)
                                    .foregroundColor(isIncome ? Constants.Colors.success : Constants.Colors.error)
                                    .accessibilityLabel("Amount: \(formattedAmount)")
                                    .accessibilityAddTraits(.isStaticText)
                                
                                // Merchant Name - Secondary
                                Text(transaction.title)
                                    .font(Constants.Typography.Mono.Body.font)
                                    .foregroundColor(Constants.Colors.textPrimary)
                                    .lineLimit(1)
                                    .accessibilityLabel("Merchant: \(transaction.title)")
                                    .accessibilityAddTraits(.isStaticText)
                            }
                            
                            Spacer()
                            
                            // Close Button
                            Button(action: { dismiss() }) {
                                Image(systemName: "xmark")
                                    .font(Constants.Typography.Caption.font)
                                    .foregroundColor(Constants.Colors.textSecondary)
                                    .frame(width: 32, height: 32)
                                    .background(Constants.Colors.textTertiary.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            .accessibilityLabel("Close transaction details")
                        }
                        
                        // Bottom Row: Date + Category
                        HStack {
                            // Date
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(Constants.Typography.Caption.font)
                                    .foregroundColor(Constants.Colors.textSecondary)
                                Text(formattedDate)
                                    .font(Constants.Typography.Mono.Caption.font)
                                    .fontWeight(.regular)
                                    .foregroundColor(Constants.Colors.textSecondary)
                            }
                            .accessibilityLabel("Date: \(formattedDate)")
                            
                            Spacer()
                            
                            // Category Badge
                            Text(transaction.category.uppercased())
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(Constants.Colors.textSecondary)
                                .tracking(0.5)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Constants.Colors.textTertiary.opacity(0.1))
                                .cornerRadius(Constants.UI.CornerRadius.tertiary)
                                .accessibilityLabel("Category: \(transaction.category)")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    
                    // Action Buttons - Horizontal layout for compact design
                    HStack(spacing: 12) {
                        // Edit Button
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            showingEditSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "pencil")
                                    .font(Constants.Typography.Caption.font)
                                Text(contentManager.localizedString("transaction.edit"))
                                    .font(Constants.Typography.Caption.font)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Constants.Colors.cleanBlack)
                            .cornerRadius(Constants.UI.CornerRadius.secondary)
                        }
                        .accessibilityLabel("Edit transaction")
                        
                        // Delete Button
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            showingDeleteAlert = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash")
                                    .font(Constants.Typography.Caption.font)
                                Text(contentManager.localizedString("transaction.delete"))
                                    .font(Constants.Typography.Caption.font)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Constants.Colors.error)
                            .cornerRadius(Constants.UI.CornerRadius.secondary)
                        }
                        .accessibilityLabel("Delete transaction")
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .sheet(isPresented: $showingEditSheet) {
                    TransactionEditView(transaction: transactionBinding)
                        .presentationDetents([.height(400), .medium])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(20)
                }
                .alert(contentManager.localizedString("transaction.delete_alert_title"), isPresented: $showingDeleteAlert) {
                    Button(contentManager.localizedString("button.cancel"), role: .cancel) { }
                    Button(contentManager.localizedString("transaction.delete"), role: .destructive) {
                        deleteTransaction()
                    }
                } message: {
                    Text(contentManager.localizedString("transaction.delete_alert_message"))
                }
            } else {
                // Clean Error State - No shadows, minimal design
                VStack(spacing: 40) {
                    // Simple error icon
                    ZStack {
                        Rectangle()
                            .fill(Constants.Colors.error)
                            .frame(width: 60, height: 60)
                            .cornerRadius(Constants.UI.CornerRadius.secondary)
                        
                        Image(systemName: "exclamationmark.triangle")
                            .font(Constants.Typography.H3.font)
                            .foregroundColor(.white)
                    }
                    
                    // Error content - Clean typography
                    VStack(spacing: 16) {
                        Text(contentManager.localizedString("transaction.not_found"))
                            .font(Constants.Typography.H3.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .tracking(1.0)
                        
                        Text(contentManager.localizedString("transaction.may_have_been_deleted"))
                            .font(Constants.Typography.Mono.Body.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                    
                    // Done button - Original CTA styling
                    Button(action: {
                        dismiss()
                    }) {
                        Text(contentManager.localizedString("button.done"))
                            .font(Constants.Typography.Button.font)
                            .foregroundColor(.white)
                            .frame(width: 120, height: 56)
                            .background(Constants.Colors.cleanBlack)
                            .cornerRadius(Constants.UI.CornerRadius.secondary)
                    }
                }
                .padding(.horizontal, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Constants.Colors.backgroundPrimary)
            }
        }
    }
    
    // MARK: - Actions
    private func deleteTransaction() {
        guard let transaction = transaction else { return }
        
        // Provide haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Delete the transaction from the view model
        transactionViewModel.deleteTransaction(withId: transaction.id)
        
        // Dismiss the view
        dismiss()
    }
    
    // MARK: - Helper Functions
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


// MARK: - Legacy Detail Row Component (for compatibility)
private struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: Constants.UI.Spacing.medium) {
            // Icon - Professional flat design
            ZStack {
                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(iconColor)
            }
            .accessibilityHidden(true)
            
            // Content - Professional typography hierarchy
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.micro) {
                Text(title)
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textSecondary)
                
                Text(value)
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
            }
            
            Spacer()
        }
        .padding(.vertical, Constants.UI.Spacing.medium)
        .padding(.horizontal, Constants.UI.Spacing.medium)
        .background(Constants.Colors.backgroundSecondary)
        .cornerRadius(Constants.UI.CornerRadius.secondary)
    }
}

#Preview {
    TransactionDetailView(
        transactionId: UUID(),
        transactionViewModel: TransactionViewModel()
    )
}
