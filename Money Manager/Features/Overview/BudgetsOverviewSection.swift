//
//  BudgetsOverviewSection.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Overview section displaying budget summary with progress tracking and
//  quick navigation. Features budget statistics, progress indicators,
//  and navigation to full budget management with accessibility support.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct BudgetsOverviewSection: View {
    @ObservedObject var budgetViewModel: BudgetViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var totalBudgeted: Double = 0.0
    @State private var totalSpent: Double = 0.0
    @State private var overallProgress: Double = 0.0
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let onTabSwitch: (Int) -> Void
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            HStack {
                Text(contentManager.localizedString("budgets_overview.title"))
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                Button(action: {
                    onTabSwitch(2)
                }) {
                    Text(contentManager.localizedString("button.view_all"))
                        .font(Constants.Typography.BodySmall.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                .accessibilityLabel("View all budgets")
            }
            
            if isLoading {
                LoadingStateView(message: "Loading budgets...")
            } else if let errorMessage = errorMessage {
                ErrorStateView(message: errorMessage) {
                    refreshData()
                }
            } else if budgetViewModel.budgets.isEmpty {
                BudgetEmptyState(
                    actionTitle: contentManager.localizedString("cta.create_budget"),
                    imageSize: 80,
                    action: {
                        // TODO: Navigate to create budget
                    }
                )
            } else {
                // Budget Overview Content
                VStack(spacing: Constants.UI.Spacing.medium) {
                    // Main Summary Card
                    BudgetSummaryCard(
                        totalBudgeted: totalBudgeted,
                        totalSpent: totalSpent,
                        overallProgress: overallProgress
                    )
                }
            }
        }
        .onAppear {
            refreshData()
        }
        .onChange(of: budgetViewModel.budgets.count) { _, _ in
            refreshData()
        }
    }
    
    // MARK: - Data Processing
    private func refreshData() {
        isLoading = true
        errorMessage = nil
        
        // Calculate budget data from actual budgetViewModel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.calculateBudgetData()
            self.isLoading = false
        }
    }
    
    private func calculateBudgetData() {
        guard !budgetViewModel.budgets.isEmpty else {
            totalBudgeted = 0.0
            totalSpent = 0.0
            overallProgress = 0.0
            return
        }
        
        // Calculate total budgeted amount
        totalBudgeted = budgetViewModel.budgets.reduce(0) { $0 + $1.allocatedAmount }
        
        // Calculate total spent
        totalSpent = budgetViewModel.budgets.reduce(0) { $0 + $1.spentAmount }
        
        // Calculate overall progress
        overallProgress = totalBudgeted > 0 ? totalSpent / totalBudgeted : 0.0
    }
}

// MARK: - Budget Summary Card
private struct BudgetSummaryCard: View {
    let totalBudgeted: Double
    let totalSpent: Double
    let overallProgress: Double
    
    private var isOverBudget: Bool {
        totalSpent > totalBudgeted
    }
    
    private var progressColor: Color {
        if isOverBudget {
            return Constants.Colors.error
        } else if overallProgress > 0.8 {
            return Constants.Colors.warning
        } else {
            return Constants.Colors.success
        }
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            // Header
            HStack {
                Text("budgets_overview.total_budget".localized)
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                Text("\(Int(overallProgress * 100))%")
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(progressColor)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Constants.Colors.backgroundSecondary)
                        .frame(height: 12)
                        .cornerRadius(Constants.UI.CornerRadius.tertiary)
                    
                    // Progress Fill
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * min(overallProgress, 1.0), height: 12)
                        .cornerRadius(Constants.UI.CornerRadius.tertiary)
                }
            }
            .frame(height: 12)
            
            // Amount Details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("budgets_overview.budgeted".localized)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
            Text(totalBudgeted, format: .currency(code: "USD"))
                .font(Constants.Typography.Mono.H3.font)
                .foregroundColor(Constants.Colors.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("budgets_overview.spent".localized)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
            Text(totalSpent, format: .currency(code: "USD"))
                .font(Constants.Typography.Mono.H3.font)
                .foregroundColor(progressColor)
                }
            }
        }
        .padding(Constants.UI.Spacing.medium)
        .background(Constants.Colors.textPrimary.opacity(0.05)) // WCAG AA compliant background
        .cornerRadius(Constants.UI.cardCornerRadius)
    }
}

#Preview {
    BudgetsOverviewSection(budgetViewModel: BudgetViewModel(), onTabSwitch: { _ in })
}
