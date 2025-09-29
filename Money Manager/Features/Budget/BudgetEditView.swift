import SwiftUI

struct BudgetEditView: View {
    @Binding var budget: Budget
    @Environment(\.dismiss) var dismiss
    @State private var category: String
    @State private var allocatedAmount: String
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
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
                    Text("Edit Budget")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Constants.Colors.textPrimary)
                        .accessibilityLabel("Edit Budget")
                        .accessibilityAddTraits(.isHeader)
                    
                    Spacer()
                    
                    // Close Button
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
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
                        Text("CATEGORY")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { categoryOption in
                                HStack {
                                    CategoryIcon(category: categoryOption, size: 20)
                                    Text(categoryOption)
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .tag(categoryOption)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Allocated Amount Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ALLOCATED AMOUNT")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        HStack {
                            Text("$")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Constants.Colors.textSecondary)
                            
                            TextField("0.00", text: $allocatedAmount)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Constants.Colors.textPrimary)
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Constants.Colors.textPrimary.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(!isValidAmount ? Constants.Colors.error.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Allocated amount")
                        .accessibilityHint("Enter the dollar amount allocated for this budget")
                    }
                    
                    // Current Spending Info (Read-only)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("CURRENT SPENDING")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("Spent")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Constants.Colors.textSecondary)
                                Spacer()
                                Text(budget.spentAmount.formatted(.currency(code: "USD")))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Constants.Colors.error)
                            }
                            
                            HStack {
                                Text("Remaining")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Constants.Colors.textSecondary)
                                Spacer()
                                Text(budget.remainingAmount.formatted(.currency(code: "USD")))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Constants.Colors.success)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Constants.Colors.textPrimary.opacity(0.05))
                        .cornerRadius(12)
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
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    saveBudget()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Save")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Constants.Colors.cleanBlack)
                    .cornerRadius(12)
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
                            .font(.system(size: 14, weight: .semibold))
                        Text("Cancel")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Constants.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Constants.Colors.textPrimary.opacity(0.05))
                    .cornerRadius(12)
                }
                .accessibilityLabel("Cancel editing")
                .accessibilityHint("Double tap to discard changes and return to budget details")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .alert("Validation Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
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
            errorMessage = "Please select a category."
            showingErrorAlert = true
            return
        }
        
        guard let allocatedValue = Double(allocatedAmount), allocatedValue > 0 else {
            errorMessage = "Please enter a valid allocated amount greater than 0."
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
