import SwiftUI

struct BudgetView: View {
    @StateObject private var viewModel = BudgetViewModel()
    @StateObject private var loanViewModel = LoanViewModel()
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showAddView = false
    @State private var selectedBudget: Budget?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Static Header Section
                VStack(spacing: Constants.UI.Spacing.medium) {
                    // Header with title and total counter
                    HStack(alignment: .center) {
                        // Title only
                        Text("Budget")
                            .font(Constants.Typography.H1.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                        
                        Spacer()
                    }
                    .padding(.top, -Constants.UI.Spacing.medium)
                    
                    // Category Filter
                    BudgetCategoryFilterView(selectedCategory: $viewModel.selectedCategory)
                }
                .padding(Constants.UI.Padding.screenMargin)
                .background(Constants.Colors.backgroundPrimary)
                
                // Scrollable Content Section
                ScrollView {
                    VStack(spacing: Constants.UI.Spacing.large) {
                        // Total Monthly Budget Card
                        BudgetSummaryCard(viewModel: viewModel)
                        
                        if viewModel.isLoading {
                            LoadingStateView(message: "Loading budget...")
                        } else if let errorMessage = viewModel.errorMessage {
                            ErrorStateView(message: errorMessage) {
                                viewModel.loadBudgets()
                            }
                        } else if viewModel.budgets.isEmpty {
                            EmptyStateView(
                                icon: "dollarsign.circle",
                                title: "No Budgets",
                                message: "Create your first budget to start managing your finances effectively.",
                                actionTitle: "Create Budget",
                                action: {
                                    // TODO: Implement create budget
                                }
                            )
                        } else {
                            // Mobile-Optimized Budget List
                            VStack(spacing: 0) {
                                // Table Header
                                BudgetTableHeader(budgetCount: viewModel.filteredBudgets.count)
                                
                                // Mobile-Optimized Rows
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
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Constants.Colors.textPrimary.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                    .padding(Constants.UI.Padding.screenMargin)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Plus Button - Left Side
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showAddView = true
                    }) {
                        Image(systemName: "plus")
                            .accessibilityLabel("Create Budget")
                    }
                }
                
                // Notifications and Settings - Right Side
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Notifications Button
                    Button(action: {
                        showNotifications = true
                    }) {
                        Image(systemName: "bell")
                            .accessibilityLabel("Notifications")
                    }
                    
                    // Settings Button
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .accessibilityLabel("Settings")
                    }
                }
            }
            .background(Constants.Colors.backgroundPrimary)
            .onAppear {
                viewModel.loadBudgets()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showNotifications) {
                NotificationView()
            }
            .sheet(isPresented: $showAddView) {
                AddView(loanViewModel: loanViewModel, budgetViewModel: viewModel)
            }
            .sheet(item: $selectedBudget) { budget in
                BudgetDetailView(budgetId: budget.id, budgetViewModel: viewModel)
            }
        }
    }
}


// MARK: - Enhanced Table Components

private struct BudgetTableHeader: View {
    let budgetCount: Int
    
    var body: some View {
        HStack {
            Text("BUDGETS")
                .font(Constants.Typography.Caption.font)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colors.textSecondary)
            
            Spacer()
            
            Text("\(budgetCount) total")
                .font(Constants.Typography.Caption.font)
                .fontWeight(.medium)
                .foregroundColor(Constants.Colors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Constants.Colors.textPrimary.opacity(0.08))
    }
}

private struct MobileBudgetRow: View {
    let budget: Budget
    let isEven: Bool
    
    private var budgetCategoryColor: Color {
        switch budget.category.lowercased() {
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
            // Top Row: Icon, Category, and Allocated Amount
            HStack(spacing: 12) {
                // Budget Category Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(budgetCategoryColor)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: budgetCategoryIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Budget Category and Progress
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.category)
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    // Progress Bar
                    HStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Constants.Colors.textPrimary.opacity(0.1))
                                    .frame(height: 6)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(progressColor)
                                    .frame(width: geometry.size.width * progressPercentage, height: 6)
                            }
                        }
                        .frame(height: 6)
                        
                        Text("\(Int(progressPercentage * 100))%")
                            .font(Constants.Typography.Caption.font)
                            .fontWeight(.medium)
                            .foregroundColor(progressColor)
                    }
                }
                
                Spacer()
                
                // Allocated Amount (Most Important)
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Allocated")
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(budget.allocatedAmount, format: .currency(code: "USD"))
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            
            // Bottom Row: Spent and Remaining
            HStack {
                // Spent Amount
                VStack(alignment: .leading, spacing: 2) {
                    Text("Spent")
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(budget.spentAmount, format: .currency(code: "USD"))
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.error)
                }
                
                Spacer()
                
                // Remaining Amount
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Remaining")
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(budget.remainingAmount, format: .currency(code: "USD"))
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.semibold)
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
                .fill(Constants.Colors.textPrimary.opacity(0.08))
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
            // Header with category and amount
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.category)
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Text("Budget")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: Constants.UI.Spacing.small) {
                        Text(budget.allocatedAmount, format: .currency(code: "USD"))
                            .font(Constants.Typography.H2.font)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.textPrimary)
                        
                        .accessibilityLabel("Edit budget")
                    }
                    
                    Text("Allocated")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
            }
            
            // Progress Section
            VStack(spacing: Constants.UI.Spacing.small) {
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Rectangle()
                            .fill(Constants.Colors.backgroundSecondary)
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        // Progress Fill
                        Rectangle()
                            .fill(progressColor)
                            .frame(width: geometry.size.width * progressPercentage, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                // Progress Details
                HStack {
                    Text("Spent: \(budget.spentAmount, format: .currency(code: "USD"))")
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(progressPercentage * 100))%")
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                }
            }
            
            // Remaining/Over Budget
            HStack {
                if isOverBudget {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundColor(Constants.Colors.error)
                        
                        Text("Over by \((budget.spentAmount - budget.allocatedAmount), format: .currency(code: "USD"))")
                            .font(Constants.Typography.Caption.font)
                            .fontWeight(.medium)
                            .foregroundColor(Constants.Colors.error)
                    }
                } else {
                    Text("Remaining: \(budget.remainingAmount, format: .currency(code: "USD"))")
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
                
                // Status Indicator
                Text(isOverBudget ? "Over Budget" : "On Track")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(progressColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(progressColor.opacity(0.1))
                    .cornerRadius(8)
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
            // Primary Focus: Total Monthly Budget
            VStack(spacing: 8) {
                Text("Total Monthly Budget")
                    .font(Constants.Typography.Caption.font)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(formattedTotalAllocated)
                    .font(Constants.Typography.H1.font)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            
            // Secondary Information Row
            HStack(spacing: 24) {
                // Total Spent
                VStack(spacing: 6) {
                    Text("Total Spent")
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text(formattedTotalSpent)
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.error)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(Constants.Colors.textPrimary.opacity(0.2))
                    .frame(width: 1, height: 40)
                
                // Total Remaining
                VStack(spacing: 6) {
                    Text("Remaining")
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text(formattedTotalRemaining)
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.semibold)
                        .foregroundColor(totalRemaining >= 0 ? Constants.Colors.success : Constants.Colors.error)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(Constants.UI.Spacing.large)
        .background(Constants.Colors.textPrimary.opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Constants.Colors.textPrimary.opacity(0.1), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Total monthly budget: \(formattedTotalAllocated), Total spent: \(formattedTotalSpent), Remaining: \(formattedTotalRemaining)")
    }
}


#Preview {
    BudgetView()
}
