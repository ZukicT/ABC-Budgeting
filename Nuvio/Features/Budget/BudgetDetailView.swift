//
//  BudgetDetailView.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Comprehensive detail view for displaying and managing individual budgets.
//  Features detailed budget information, progress tracking, edit/delete actions,
//  and proper error handling with accessibility compliance.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct BudgetDetailView: View {
    let budgetId: UUID
    @ObservedObject var budgetViewModel: BudgetViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    private var budget: Budget? {
        budgetViewModel.budgets.first { $0.id == budgetId }
    }
    
    private var progressPercentage: Double {
        guard let budget = budget else { return 0.0 }
        return min(budget.spentAmount / budget.allocatedAmount, 1.0)
    }
    
    private var isOverBudget: Bool {
        guard let budget = budget else { return false }
        return budget.spentAmount > budget.allocatedAmount
    }
    
    private var progressColor: Color {
        if isOverBudget {
            return Constants.Colors.error
        } else if progressPercentage > 0.8 {
            return Constants.Colors.warning
        } else {
            return Constants.Colors.success
        }
    }
    
    private var budgetBinding: Binding<Budget> {
        Binding(
            get: { budget ?? Budget(category: "Unknown", allocatedAmount: 0, spentAmount: 0, remainingAmount: 0) },
            set: { updatedBudget in
                budgetViewModel.updateBudget(updatedBudget)
            }
        )
    }
    
    var body: some View {
        Group {
            if let budget = budget {
                VStack(spacing: 0) {
                    // Header Section - Compact layout with icon repositioned
                    VStack(spacing: 16) {
                        // Top row with icon and amount
                        HStack(spacing: 16) {
                            // Category Icon - Visual category indicator (smaller size)
                            CategoryIcon(category: budget.category, size: 50)
                                .accessibilityLabel("Category: \(budget.category)")
                            
                            VStack(alignment: .leading, spacing: 4) {
                                // Allocated Amount - Primary focus (smaller font)
                    Text(budget.allocatedAmount.formatted(.currency(code: "USD")))
                        .font(Constants.Typography.Mono.H1.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                                    .accessibilityLabel("Allocated amount: \(budget.allocatedAmount.formatted(.currency(code: "USD")))")
                                    .accessibilityAddTraits(.isStaticText)
                                
                                // Category Name - Secondary
                                Text(budget.category)
                                    .font(Constants.Typography.H3.font)
                                    .foregroundColor(Constants.Colors.textPrimary)
                                    .accessibilityLabel("Budget category: \(budget.category)")
                                    .accessibilityAddTraits(.isStaticText)
                            }
                            
                            Spacer()
                        }
                        
                        // Progress Percentage - Tertiary
                        Text("\(Int(progressPercentage * 100))\(contentManager.localizedString("budget.used_percentage"))")
                            .font(Constants.Typography.Mono.Body.font)
                            .foregroundColor(progressColor)
                            .accessibilityLabel("Progress: \(Int(progressPercentage * 100)) percent used")
                            .accessibilityAddTraits(.isStaticText)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    // Progress Bar Section
                    VStack(spacing: 12) {
                        // Progress Bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                Rectangle()
                                    .fill(Constants.Colors.textTertiary.opacity(0.2))
                                    .frame(height: 8)
                                    .cornerRadius(Constants.UI.CornerRadius.quaternary)
                                
                                // Progress Fill
                                Rectangle()
                                    .fill(progressColor)
                                    .frame(width: geometry.size.width * progressPercentage, height: 8)
                                    .cornerRadius(Constants.UI.CornerRadius.quaternary)
                            }
                        }
                        .frame(height: 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                    
                    // Details Section - Essential information only
                    VStack(spacing: 16) {
                        // Spent Amount
                        HStack {
                    Text(contentManager.localizedString("budget.spent_caps"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textTertiary)
                                .tracking(1.0)
                            Spacer()
                            Text(budget.spentAmount.formatted(.currency(code: "USD")))
                                .font(Constants.Typography.Mono.Body.font)
                                .foregroundColor(Constants.Colors.error)
                        }
                        .padding(.horizontal, 24)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Spent amount: \(budget.spentAmount.formatted(.currency(code: "USD")))")
                        
                        Divider()
                            .background(Constants.Colors.textTertiary.opacity(0.3))
                            .padding(.horizontal, 24)
                        
                        // Remaining Amount
                        HStack {
                            Text(contentManager.localizedString("budget.remaining_caps"))
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(Constants.Colors.textTertiary)
                                .tracking(1.0)
                            Spacer()
                            Text(budget.remainingAmount.formatted(.currency(code: "USD")))
                                .font(Constants.Typography.Mono.Body.font)
                                .foregroundColor(isOverBudget ? Constants.Colors.error : Constants.Colors.success)
                        }
                        .padding(.horizontal, 24)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Remaining amount: \(budget.remainingAmount.formatted(.currency(code: "USD")))")
                        
                        // Over Budget Amount (if applicable)
                        if isOverBudget {
                            Divider()
                                .background(Constants.Colors.textTertiary.opacity(0.3))
                                .padding(.horizontal, 24)
                            
                            HStack {
                                Text(contentManager.localizedString("budget.over_by_caps"))
                                    .font(Constants.Typography.Caption.font)
                                    .foregroundColor(Constants.Colors.textTertiary)
                                    .tracking(1.0)
                                Spacer()
                                Text((budget.spentAmount - budget.allocatedAmount).formatted(.currency(code: "USD")))
                                    .font(Constants.Typography.Mono.Body.font)
                                    .foregroundColor(Constants.Colors.error)
                            }
                            .padding(.horizontal, 24)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("Over budget by: \((budget.spentAmount - budget.allocatedAmount).formatted(.currency(code: "USD")))")
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Action Buttons - Horizontal layout for compact design
                    HStack(spacing: 12) {
                        // Edit Button - Primary action
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "pencil")
                                    .font(Constants.Typography.Caption.font)
                                Text("budget.edit".localized)
                                    .font(Constants.Typography.Caption.font)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Constants.Colors.cleanBlack)
                            .cornerRadius(Constants.UI.CornerRadius.secondary)
                        }
                        .accessibilityLabel(contentManager.localizedString("accessibility.edit_budget"))
                        .accessibilityHint("Double tap to edit this budget")
                        
                        // Delete Button - Secondary action
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "trash")
                                    .font(Constants.Typography.Caption.font)
                                Text("budget.delete".localized)
                                    .font(Constants.Typography.Caption.font)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Constants.Colors.error)
                            .cornerRadius(Constants.UI.CornerRadius.secondary)
                        }
                        .accessibilityLabel(contentManager.localizedString("accessibility.delete_budget"))
                        .accessibilityHint("Double tap to delete this budget")
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .sheet(isPresented: $showingEditSheet) {
                    BudgetEditView(budget: budgetBinding)
                        .presentationDetents([.height(450), .medium])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(20)
                }
                .alert(contentManager.localizedString("alert.confirm_delete"), isPresented: $showingDeleteAlert) {
                    Button(contentManager.localizedString("button.cancel"), role: .cancel) { }
                    Button(contentManager.localizedString("button.delete"), role: .destructive) {
                        budgetViewModel.deleteBudget(budget)
                        dismiss()
                    }
                } message: {
                    Text(contentManager.localizedString("alert.delete_budget_message"))
                }
            } else {
                // Budget not found
                VStack(spacing: Constants.UI.Spacing.large) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(Constants.Typography.H1.font)
                        .foregroundColor(Constants.Colors.warning)
                    
                    Text("budget.not_found".localized)
                        .font(Constants.Typography.H2.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Text("budget.may_have_been_deleted".localized)
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Button(contentManager.localizedString("button.done")) {
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(.white)
                    .padding(.horizontal, Constants.UI.Spacing.large)
                    .padding(.vertical, Constants.UI.Spacing.medium)
                    .background(Constants.Colors.primaryBlue)
                    .cornerRadius(Constants.UI.cardCornerRadius)
                }
                .padding(Constants.UI.Padding.screenMargin)
            }
        }
    }
}

#Preview {
    let viewModel = BudgetViewModel()
    let sampleBudget = Budget(category: "Food", allocatedAmount: 500.0, spentAmount: 320.45, remainingAmount: 179.55)
    viewModel.addBudget(sampleBudget)
    
    return BudgetDetailView(
        budgetId: sampleBudget.id,
        budgetViewModel: viewModel
    )
}
