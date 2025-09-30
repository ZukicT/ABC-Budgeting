//
//  BudgetEditView.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Edit view for budget management providing comprehensive budget editing
//  functionality. Features form validation, category selection, and
//  real-time updates with proper error handling and accessibility.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct BudgetEditView: View {
    @Binding var budget: Budget
    @Environment(\.dismiss) var dismiss
    @State private var category: String
    @State private var allocatedAmount: String
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    private let categories = CategoryUtilities.budgetCategories
    
    private var budgetCategoryColor: Color {
        switch category.lowercased() {
        case "food": return .green
        case "transport": return .blue
        case "shopping": return .orange
        case "entertainment": return .purple
        case "bills": return .red
        case "savings": return .green
        case "other": return .gray
        default: return .blue
        }
    }
    
    init(budget: Binding<Budget>) {
        self._budget = budget
        self._category = State(initialValue: budget.wrappedValue.category)
        self._allocatedAmount = State(initialValue: String(budget.wrappedValue.allocatedAmount))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section - Compact layout
            VStack(spacing: 16) {
                // Top Row: Title + Close Button
                HStack {
                    Text(contentManager.localizedString("budget.edit_budget"))
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .accessibilityLabel("Edit Budget")
                        .accessibilityAddTraits(.isHeader)
                    
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
                    .accessibilityLabel("Close edit view")
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Form Section - Compact layout
            ScrollView {
                VStack(spacing: 20) {
                    // Category Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text(contentManager.localizedString("budget.category_caps"))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { categoryOption in
                                HStack {
                                    CategoryIcon(category: categoryOption, size: 20)
                                    Text(categoryOption.localizedCategoryName)
                                        .font(Constants.Typography.Mono.Body.font)
                                }
                                .tag(categoryOption)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Allocated Amount Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text(contentManager.localizedString("budget.allocated_amount_caps"))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        HStack {
                            Text("$")
                                .font(Constants.Typography.Mono.Body.font)
                                .foregroundColor(Constants.Colors.textSecondary)
                            
                            TextField("0.00", text: $allocatedAmount)
                                .font(Constants.Typography.Mono.Body.font)
                                .foregroundColor(Constants.Colors.textPrimary)
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Constants.Colors.textPrimary.opacity(0.05))
                        .cornerRadius(Constants.UI.CornerRadius.secondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.secondary)
                                .stroke(!isValidAmount ? Constants.Colors.error.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Allocated amount")
                        .accessibilityHint("Enter the dollar amount allocated for this budget")
                    }
                    
                    // Current Spending Info (Read-only)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(contentManager.localizedString("budget.current_spending_caps"))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text(contentManager.localizedString("budget.spent"))
                                    .font(Constants.Typography.Caption.font)
                                    .foregroundColor(Constants.Colors.textSecondary)
                                Spacer()
                                Text(budget.spentAmount.formatted(.currency(code: "USD")))
                                    .font(Constants.Typography.Mono.Body.font)
                                    .foregroundColor(Constants.Colors.error)
                            }
                            
                            HStack {
                                Text(contentManager.localizedString("budget.remaining"))
                                    .font(Constants.Typography.Caption.font)
                                    .foregroundColor(Constants.Colors.textSecondary)
                                Spacer()
                                Text(budget.remainingAmount.formatted(.currency(code: "USD")))
                                    .font(Constants.Typography.Mono.Body.font)
                                    .foregroundColor(Constants.Colors.success)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Constants.Colors.textPrimary.opacity(0.05))
                        .cornerRadius(Constants.UI.CornerRadius.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            
            // Action Buttons - Horizontal layout for compact design
            HStack(spacing: 12) {
                // Save Button - Primary action
                Button(action: {
                    // Haptic feedback
                    HapticFeedbackManager.medium()
                    
                    saveBudget()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(Constants.Typography.Caption.font)
                        Text(contentManager.localizedString("budget.save"))
                            .font(Constants.Typography.Caption.font)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Constants.Colors.cleanBlack)
                    .cornerRadius(Constants.UI.CornerRadius.secondary)
                }
                .disabled(!canSave)
                .accessibilityLabel("Save budget changes")
                .accessibilityHint("Double tap to save your changes to this budget")
                
                // Cancel Button - Secondary action
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                            .font(Constants.Typography.Caption.font)
                        Text("button.cancel".localized)
                            .font(Constants.Typography.Caption.font)
                    }
                    .foregroundColor(Constants.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Constants.Colors.textPrimary.opacity(0.05))
                    .cornerRadius(Constants.UI.CornerRadius.secondary)
                }
                .accessibilityLabel("Cancel editing")
                .accessibilityHint("Double tap to discard changes and return to budget details")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .alert(contentManager.localizedString("alert.validation_error"), isPresented: $showingErrorAlert) {
            Button(contentManager.localizedString("button.ok")) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Computed Properties
    private var isValidAmount: Bool {
        guard let amountValue = Double(allocatedAmount) else { return false }
        return amountValue > 0
    }
    
    private var canSave: Bool {
        !category.isEmpty && isValidAmount
    }
    
    private var progressColor: Color {
        let progressData = ProgressUtilities.budgetProgress(
            spentAmount: budget.spentAmount,
            allocatedAmount: budget.allocatedAmount
        )
        return progressData.color
    }
    
    private func saveBudget() {
        // Validate input
        guard !category.isEmpty else {
            errorMessage = contentManager.localizedString("budget.validation.select_category")
            showingErrorAlert = true
            return
        }
        
        guard let allocatedValue = Double(allocatedAmount), allocatedValue > 0 else {
            errorMessage = contentManager.localizedString("budget.validation.valid_amount")
            showingErrorAlert = true
            return
        }
        
        // Calculate new remaining amount
        let newRemainingAmount = allocatedValue - budget.spentAmount
        
        budget = Budget(
            id: budget.id, // Preserve the original ID
            category: category,
            allocatedAmount: allocatedValue,
            spentAmount: budget.spentAmount,
            remainingAmount: max(0, newRemainingAmount)
        )
        
        dismiss()
    }
    
    // MARK: - Helper Functions
    // Category utilities now handled by CategoryUtilities.swift
}

// MARK: - Edit Field Style
// EditFieldStyle now handled by Shared/Components/EditFieldStyle.swift

#Preview {
    BudgetEditView(budget: .constant(Budget(
        category: "Food",
        allocatedAmount: 500.0,
        spentAmount: 320.45,
        remainingAmount: 179.55
    )))
}
