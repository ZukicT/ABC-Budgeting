//
//  BudgetView.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Main budget management view providing comprehensive budget overview, creation,
//  and tracking capabilities. Features clean empty state for new users and full
//  functionality for existing budget management with progress tracking.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct BudgetView: View {
    @ObservedObject var viewModel: BudgetViewModel
    @ObservedObject var dataClearingService: DataClearingService
    @ObservedObject var loanViewModel: LoanViewModel
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showAddView = false
    @State private var selectedBudget: Budget?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
                contentSection
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .background(Constants.Colors.backgroundPrimary)
            .onAppear {
                // Only load if data hasn't been loaded yet to prevent loading on every tab switch
                if !viewModel.hasDataLoaded {
                    viewModel.loadBudgets()
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(dataClearingService: dataClearingService)
            }
            .sheet(isPresented: $showNotifications) {
                NotificationView()
            }
            .sheet(isPresented: $showAddView) {
                AddView(loanViewModel: loanViewModel, budgetViewModel: viewModel, transactionViewModel: transactionViewModel)
            }
            .sheet(item: $selectedBudget) { budget in
                BudgetDetailView(budgetId: budget.id, budgetViewModel: viewModel)
                    .presentationDetents([.height(450), .medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(20)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            HStack(alignment: .center) {
                Text(contentManager.localizedString("budget.title"))
                    .font(Constants.Typography.H1.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
            }
            .padding(.top, -Constants.UI.Spacing.medium)
            
            BudgetCategoryFilterView(selectedCategory: $viewModel.selectedCategory)
        }
        .padding(Constants.UI.Padding.screenMargin)
        .background(Constants.Colors.backgroundPrimary)
    }
    
    private var contentSection: some View {
        Group {
            if viewModel.isLoading {
                LoadingStateView(message: contentManager.localizedString("budget.loading"))
            } else if let errorMessage = viewModel.errorMessage {
                ErrorStateView(message: errorMessage) {
                    viewModel.loadBudgets()
                }
            } else if viewModel.budgets.isEmpty {
                BudgetEmptyState {
                    showAddView = true
                }
            } else {
                ScrollView {
                    VStack(spacing: Constants.UI.Spacing.large) {
                        BudgetSummaryCard(viewModel: viewModel)
                        budgetList
                    }
                    .padding(Constants.UI.Padding.screenMargin)
                }
            }
        }
    }
    
    private var budgetList: some View {
        VStack(spacing: 0) {
            BudgetTableHeader(budgetCount: viewModel.filteredBudgets.count)
            
            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.filteredBudgets.enumerated()), id: \.element.id) { index, budget in
                    Button(action: {
                        selectedBudget = budget
                    }) {
                        MobileBudgetRow(budget: budget, isEven: index % 2 == 0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .background(Constants.Colors.backgroundPrimary)
        .cornerRadius(Constants.UI.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .stroke(Constants.Colors.textPrimary.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showAddView = true
                }) {
                    Image(systemName: "plus")
                        .accessibilityLabel(contentManager.localizedString("budget.add_budget"))
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    showNotifications = true
                }) {
                    Image(systemName: "bell")
                        .accessibilityLabel("Notifications")
                }
                
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .accessibilityLabel("Settings")
                }
            }
        }
    }
}


private struct BudgetTableHeader: View {
    let budgetCount: Int
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        HStack {
            Text(contentManager.localizedString("budget.budgets"))
                .font(Constants.Typography.Caption.font)
                .foregroundColor(Constants.Colors.textSecondary)
            
            Spacer()
            
            Text("\(budgetCount) \(contentManager.localizedString("budget.total"))")
                .font(Constants.Typography.Caption.font)
                .foregroundColor(Constants.Colors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Constants.Colors.textPrimary.opacity(0.05))
    }
}

private struct MobileBudgetRow: View {
    let budget: Budget
    let isEven: Bool
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    private var budgetCategoryColor: Color {
        switch budget.category.lowercased() {
        case "food": return Constants.Colors.primaryOrange
        case "transport": return Constants.Colors.primaryBlue
        case "shopping": return Constants.Colors.primaryPink
        case "entertainment": return Constants.Colors.primaryLightBlue
        case "bills": return Constants.Colors.primaryOrange
        case "savings": return Constants.Colors.primaryBlue
        case "other": return Constants.Colors.textTertiary
        default: return Constants.Colors.primaryBlue
        }
    }
    
    private var budgetCategoryIcon: String {
        budget.category.categoryIcon
    }
    
    private var progressPercentage: Double {
        min(budget.spentAmount / budget.allocatedAmount, 1.0)
    }
    
    private var isOverBudget: Bool {
        budget.spentAmount > budget.allocatedAmount
    }
    
    private var progressColor: Color {
        let progressData = ProgressUtilities.budgetProgress(
            spentAmount: budget.spentAmount,
            allocatedAmount: budget.allocatedAmount
        )
        return progressData.color
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                        .fill(Constants.Colors.cleanBlack)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: budgetCategoryIcon)
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.category)
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    HStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.quaternary)
                                    .fill(Constants.Colors.textPrimary.opacity(0.1))
                                    .frame(height: 6)
                                
                                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.quaternary)
                                    .fill(progressColor)
                                    .frame(width: geometry.size.width * progressPercentage, height: 6)
                            }
                        }
                        .frame(height: 6)
                        
                    Text("\(Int(progressPercentage * 100))\(contentManager.localizedString("budget.used_percentage"))")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(progressColor)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(contentManager.localizedString("budget.allocated"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(budget.allocatedAmount, format: .currency(code: "USD"))
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(contentManager.localizedString("budget.spent"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(budget.spentAmount, format: .currency(code: "USD"))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.error)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(contentManager.localizedString("budget.remaining"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(budget.remainingAmount, format: .currency(code: "USD"))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(isOverBudget ? Constants.Colors.error : Constants.Colors.success)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            isEven ? Constants.Colors.backgroundPrimary : Constants.Colors.textPrimary.opacity(0.08)
        )
        .overlay(
            Rectangle()
                .fill(Constants.Colors.textPrimary.opacity(0.05))
                .frame(height: 0.5),
            alignment: .bottom
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(budget.category) budget: \(budget.spentAmount, format: .currency(code: "USD")) spent out of \(budget.allocatedAmount, format: .currency(code: "USD")) allocated, \(Int(progressPercentage * 100))% used")
    }
}

// MARK: - Budget Card
private struct BudgetCard: View {
    let budget: Budget
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    private var progressPercentage: Double {
        min(budget.spentAmount / budget.allocatedAmount, 1.0)
    }
    
    private var isOverBudget: Bool {
        budget.spentAmount > budget.allocatedAmount
    }
    
    private var progressColor: Color {
        let progressData = ProgressUtilities.budgetProgress(
            spentAmount: budget.spentAmount,
            allocatedAmount: budget.allocatedAmount
        )
        return progressData.color
    }
    
    private var budgetCategoryColor: Color {
        switch budget.category.lowercased() {
        case "food": return Constants.Colors.primaryOrange
        case "transport": return Constants.Colors.primaryBlue
        case "shopping": return Constants.Colors.primaryPink
        case "entertainment": return Constants.Colors.primaryLightBlue
        case "bills": return Constants.Colors.primaryOrange
        case "savings": return Constants.Colors.primaryBlue
        case "other": return Constants.Colors.textTertiary
        default: return Constants.Colors.primaryBlue
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.category)
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Text(contentManager.localizedString("budget.budget"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: Constants.UI.Spacing.small) {
                        Text(budget.allocatedAmount, format: .currency(code: "USD"))
                            .font(Constants.Typography.H2.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                        
                        .accessibilityLabel("Edit budget")
                    }
                    
                    Text(contentManager.localizedString("budget.allocated"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
            }
            
            VStack(spacing: Constants.UI.Spacing.small) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Constants.Colors.backgroundSecondary)
                            .frame(height: 8)
                            .cornerRadius(Constants.UI.CornerRadius.quaternary)
                        
                        Rectangle()
                            .fill(progressColor)
                            .frame(width: geometry.size.width * progressPercentage, height: 8)
                            .cornerRadius(Constants.UI.CornerRadius.quaternary)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text("\(contentManager.localizedString("budget.spent_colon")) \(budget.spentAmount, format: .currency(code: "USD"))")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(progressPercentage * 100))\(contentManager.localizedString("budget.used_percentage"))")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(progressColor)
                }
            }
            
            HStack {
                if isOverBudget {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.error)
                        
                        Text("\(contentManager.localizedString("budget.over_by_amount")) \((budget.spentAmount - budget.allocatedAmount), format: .currency(code: "USD"))")
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.error)
                    }
                } else {
                    Text("\(contentManager.localizedString("budget.remaining_colon")) \(budget.remainingAmount, format: .currency(code: "USD"))")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
                
                Text(isOverBudget ? contentManager.localizedString("budget.over_budget") : contentManager.localizedString("budget.on_track"))
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(progressColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(progressColor.opacity(0.1))
                    .cornerRadius(Constants.UI.CornerRadius.tertiary)
            }
        }
        .padding(Constants.UI.Padding.cardInternal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(budget.category) budget: \(budget.spentAmount, format: .currency(code: "USD")) spent out of \(budget.allocatedAmount, format: .currency(code: "USD")) allocated")
    }
}

// MARK: - Budget Summary Card
private struct BudgetSummaryCard: View {
    let viewModel: BudgetViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    private var totalAllocated: Double {
        viewModel.budgets.reduce(0) { $0 + $1.allocatedAmount }
    }
    
    private var totalSpent: Double {
        viewModel.budgets.reduce(0) { $0 + $1.spentAmount }
    }
    
    private var totalRemaining: Double {
        totalAllocated - totalSpent
    }
    
    private var formattedTotalAllocated: String {
        totalAllocated.formatted(.currency(code: "USD"))
    }
    
    private var formattedTotalSpent: String {
        totalSpent.formatted(.currency(code: "USD"))
    }
    
    private var formattedTotalRemaining: String {
        totalRemaining.formatted(.currency(code: "USD"))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text(contentManager.localizedString("budget.total_monthly_budget"))
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(formattedTotalAllocated)
                    .font(Constants.Typography.H1.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text(contentManager.localizedString("budget.total_spent"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text(formattedTotalSpent)
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.error)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                Rectangle()
                    .fill(Constants.Colors.textPrimary.opacity(0.2))
                    .frame(width: 1, height: 40)
                
                VStack(spacing: 6) {
                    Text(contentManager.localizedString("budget.remaining"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text(formattedTotalRemaining)
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(totalRemaining >= 0 ? Constants.Colors.success : Constants.Colors.error)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(Constants.UI.Spacing.large)
        .background(Constants.Colors.textPrimary.opacity(0.05))
        .cornerRadius(Constants.UI.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .stroke(Constants.Colors.textPrimary.opacity(0.1), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Total monthly budget: \(formattedTotalAllocated), Total spent: \(formattedTotalSpent), Remaining: \(formattedTotalRemaining)")
    }
}

#Preview {
    BudgetView(
        viewModel: BudgetViewModel(), 
        dataClearingService: DataClearingService(),
        loanViewModel: LoanViewModel(),
        transactionViewModel: TransactionViewModel()
    )
}
