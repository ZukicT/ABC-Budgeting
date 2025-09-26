import SwiftUI

struct BudgetsOverviewSection: View {
    @StateObject private var viewModel = BudgetsOverviewViewModel()
    @State private var selectedBudget: Budget?
    @ObservedObject var budgetViewModel: BudgetViewModel
    
    let onTabSwitch: (Int) -> Void
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Section Header
            HStack {
                Text("Budgets Overview")
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                // See All Button
                Button(action: {
                    onTabSwitch(2) // Switch to Budget tab
                }) {
                    Text("See All")
                        .font(Constants.Typography.BodySmall.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                .accessibilityLabel("View all budgets")
            }
            
            if viewModel.isLoading {
                LoadingStateView(message: "Loading budgets...")
            } else if let errorMessage = viewModel.errorMessage {
                ErrorStateView(message: errorMessage) {
                    viewModel.refreshData()
                }
            } else if viewModel.budgetOverviewItems.isEmpty {
                EmptyStateView(
                    icon: "dollarsign.circle",
                    title: "No Budgets",
                    message: "Create your first budget to start tracking your spending.",
                    actionTitle: "Create Budget",
                    action: {
                        // TODO: Navigate to create budget
                    }
                )
            } else {
                // Budget Overview Content
                VStack(spacing: Constants.UI.Spacing.medium) {
                    // Main Summary Card
                    BudgetSummaryCard(
                        totalBudgeted: viewModel.totalBudgeted,
                        totalSpent: viewModel.totalSpent,
                        overallProgress: viewModel.overallProgress
                    )
                    
                    // Compact Budget List
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.budgetOverviewItems.enumerated()), id: \.element.id) { index, item in
                            VStack(spacing: 0) {
                                Button(action: {
                                    selectedBudget = item.budget
                                }) {
                                    CompactBudgetItem(item: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Separation line (except for last item)
                                if index < viewModel.budgetOverviewItems.count - 1 {
                                    Rectangle()
                                        .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                                        .frame(height: 1)
                                        .padding(.horizontal, Constants.UI.Padding.screenMargin)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
        .sheet(item: $selectedBudget) { budget in
            BudgetDetailView(budgetId: budget.id, budgetViewModel: budgetViewModel)
        }
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
                Text("Total Budget")
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                Text("\(Int(overallProgress * 100))%")
                    .font(Constants.Typography.H3.font)
                    .fontWeight(.bold)
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
                    Text("Budgeted")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(totalBudgeted, format: .currency(code: "USD"))
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Spent")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(totalSpent, format: .currency(code: "USD"))
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                }
            }
        }
        .padding(Constants.UI.Spacing.medium)
        .background(Constants.Colors.textPrimary.opacity(0.05)) // WCAG AA compliant background
        .cornerRadius(Constants.UI.CornerRadius.secondary)
    }
}

// MARK: - Compact Budget Item
private struct CompactBudgetItem: View {
    let item: BudgetOverviewItem
    
    var body: some View {
        HStack(spacing: Constants.UI.Spacing.medium) {
            // Category Name
            VStack(alignment: .leading, spacing: 2) {
                Text(item.budget.category)
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Text("\(Int(item.progressPercentage * 100))% used")
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            
            // Progress Line
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Constants.Colors.backgroundSecondary)
                        .frame(height: 4)
                        .cornerRadius(Constants.UI.CornerRadius.quaternary)
                    
                    // Progress Fill
                    Rectangle()
                        .fill(item.statusColor)
                        .frame(width: geometry.size.width * min(item.progressPercentage, 1.0), height: 4)
                        .cornerRadius(Constants.UI.CornerRadius.quaternary)
                }
            }
            .frame(height: 4)
            
            // Amount and Status
            VStack(alignment: .trailing, spacing: 2) {
                Text(item.spentAmount, format: .currency(code: "USD"))
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.bold)
                    .foregroundColor(item.statusColor)
                
                if item.isOverBudget {
                    Text("Over")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.error)
                } else {
                    Text("On Track")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.success)
                }
            }
        }
        .padding(Constants.UI.Spacing.small)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.budget.category) budget: \(item.spentAmount, format: .currency(code: "USD")) spent out of \(item.budget.allocatedAmount, format: .currency(code: "USD")) allocated")
    }
}

#Preview {
    BudgetsOverviewSection(budgetViewModel: BudgetViewModel(), onTabSwitch: { _ in })
}
