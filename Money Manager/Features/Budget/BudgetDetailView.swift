import SwiftUI

struct BudgetDetailView: View {
    let budgetId: UUID
    @ObservedObject var budgetViewModel: BudgetViewModel
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
                NavigationStack {
            ScrollView {
                VStack(spacing: Constants.UI.Spacing.large) {
                    // Header Section
                    VStack(spacing: Constants.UI.Spacing.medium) {
                        // Category Icon
                        ZStack {
                            Circle()
                                .fill(categoryColor(for: budget.category))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: categoryIcon(for: budget.category))
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .accessibilityHidden(true)
                        
                        // Budget Category
                        Text(budget.category)
                            .font(Constants.Typography.H1.font)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        // Allocated Amount
                        Text(budget.allocatedAmount, format: .currency(code: "USD"))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(Constants.Colors.textPrimary)
                            .accessibilityLabel("Allocated amount: \(budget.allocatedAmount, format: .currency(code: "USD"))")
                    }
                    .padding(.top, Constants.UI.Spacing.large)
                    
                    // Progress Section
                    VStack(spacing: Constants.UI.Spacing.medium) {
                        // Progress Bar
                        VStack(spacing: Constants.UI.Spacing.small) {
                            HStack {
                                Text("Progress")
                                    .font(Constants.Typography.H3.font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Constants.Colors.textPrimary)
                                
                                Spacer()
                                
                                Text("\(Int(progressPercentage * 100))%")
                                    .font(Constants.Typography.H3.font)
                                    .fontWeight(.bold)
                                    .foregroundColor(progressColor)
                            }
                            
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
                                        .frame(width: geometry.size.width * progressPercentage, height: 12)
                                        .cornerRadius(Constants.UI.CornerRadius.tertiary)
                                }
                            }
                            .frame(height: 12)
                        }
                        .padding(.horizontal, Constants.UI.Spacing.medium)
                        .padding(.vertical, Constants.UI.Spacing.medium)
                        .background(Constants.Colors.backgroundSecondary)
                        .cornerRadius(Constants.UI.cardCornerRadius)
                    }
                    
                    // Details Section
                    VStack(spacing: Constants.UI.Spacing.medium) {
                        // Spent Amount
                        DetailRow(
                            title: "Spent Amount",
                            value: budget.spentAmount.formatted(.currency(code: "USD")),
                            icon: "dollarsign.circle.fill",
                            iconColor: Constants.Colors.error
                        )
                        
                        // Remaining Amount
                        DetailRow(
                            title: "Remaining Amount",
                            value: budget.remainingAmount.formatted(.currency(code: "USD")),
                            icon: "minus.circle.fill",
                            iconColor: isOverBudget ? Constants.Colors.error : Constants.Colors.success
                        )
                        
                        // Budget Status
                        DetailRow(
                            title: "Status",
                            value: isOverBudget ? "Over Budget" : "On Track",
                            icon: isOverBudget ? "exclamationmark.triangle.fill" : "checkmark.circle.fill",
                            iconColor: progressColor
                        )
                        
                        // Over Budget Amount (if applicable)
                        if isOverBudget {
                            DetailRow(
                                title: "Over by",
                                value: (budget.spentAmount - budget.allocatedAmount).formatted(.currency(code: "USD")),
                                icon: "exclamationmark.triangle.fill",
                                iconColor: Constants.Colors.error
                            )
                        }
                        
                        // Category
                        DetailRow(
                            title: "Category",
                            value: budget.category,
                            icon: "tag.fill",
                            iconColor: categoryColor(for: budget.category)
                        )
                    }
                    .padding(.horizontal, Constants.UI.Padding.screenMargin)
                    
                    // Action Buttons
                    VStack(spacing: Constants.UI.Spacing.medium) {
                        // Edit Button
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Budget")
                            }
                            .font(Constants.Typography.Body.font)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Constants.UI.Spacing.medium)
                            .background(Constants.Colors.cleanBlack)
                            .cornerRadius(Constants.UI.cardCornerRadius)
                        }
                        .accessibilityLabel("Edit budget")
                        
                        // Delete Button
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Budget")
                            }
                            .font(Constants.Typography.Body.font)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Constants.UI.Spacing.medium)
                            .background(Constants.Colors.error)
                            .cornerRadius(Constants.UI.cardCornerRadius)
                        }
                        .accessibilityLabel("Delete budget")
                    }
                    .padding(.horizontal, Constants.UI.Padding.screenMargin)
                    .padding(.bottom, Constants.UI.Spacing.section)
                }
            }
            .navigationTitle("Budget Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                BudgetEditView(budget: budgetBinding)
            }
            .alert("Delete Budget", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    // TODO: Implement delete functionality
                    dismiss()
                }
            }             message: {
                Text("Are you sure you want to delete this budget? This action cannot be undone.")
            }
                }
            } else {
                // Budget not found
                VStack(spacing: Constants.UI.Spacing.large) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(Constants.Colors.warning)
                    
                    Text("Budget Not Found")
                        .font(Constants.Typography.H2.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Text("This budget may have been deleted.")
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Done") {
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.semibold)
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
    
    // MARK: - Helper Functions
    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "food": return "fork.knife"
        case "transport": return "car.fill"
        case "shopping": return "bag.fill"
        case "entertainment": return "tv.fill"
        case "bills": return "doc.text.fill"
        case "savings": return "banknote.fill"
        default: return "dollarsign.circle.fill"
        }
    }
    
    private func categoryColor(for category: String) -> Color {
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
}

// MARK: - Detail Row Component
private struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: Constants.UI.Spacing.medium) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(iconColor)
            }
            .accessibilityHidden(true)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Constants.Typography.Caption.font)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textSecondary)
                
                Text(value)
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
            }
            
            Spacer()
        }
        .padding(.vertical, Constants.UI.Spacing.small)
        .padding(.horizontal, Constants.UI.Spacing.medium)
        .background(Constants.Colors.backgroundSecondary)
        .cornerRadius(Constants.UI.cardCornerRadius)
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
