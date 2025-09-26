import SwiftUI

struct BudgetEditView: View {
    @Binding var budget: Budget
    @Environment(\.dismiss) var dismiss
    @State private var category: String
    @State private var allocatedAmount: String
    @State private var showingCategoryPicker = false
    
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
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.UI.Spacing.large) {
                    // Header Section
                    VStack(spacing: Constants.UI.Spacing.medium) {
                        // Category Icon
                        ZStack {
                            Circle()
                                .fill(budgetCategoryColor)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: category.categoryIcon)
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .accessibilityHidden(true)
                        
                        Text("Edit Budget")
                            .font(Constants.Typography.H1.font)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Constants.UI.Spacing.large)
                    
                    // Form Section
                    VStack(spacing: Constants.UI.Spacing.medium) {
                        // Category Field
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                            Text("Category")
                                .font(Constants.Typography.Body.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            Button(action: {
                                showingCategoryPicker = true
                            }) {
                                HStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                                            .fill(budgetCategoryColor.opacity(0.1))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: category.categoryIcon)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(budgetCategoryColor)
                                    }
                                    
                                    Text(category)
                                        .font(Constants.Typography.Body.font)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Constants.Colors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                }
                                .padding(.horizontal, Constants.UI.Spacing.medium)
                                .padding(.vertical, Constants.UI.Spacing.small)
                                .background(Constants.Colors.backgroundSecondary)
                                .cornerRadius(Constants.UI.cardCornerRadius)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Allocated Amount Field
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                            Text("Allocated Amount")
                                .font(Constants.Typography.Body.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            HStack {
                                Text("$")
                                    .font(Constants.Typography.H3.font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Constants.Colors.textSecondary)
                                
                                TextField("0.00", text: $allocatedAmount)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(EditFieldStyle())
                            }
                        }
                        
                        // Current Spending Info (Read-only)
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                            Text("Current Spending")
                                .font(Constants.Typography.Body.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            VStack(spacing: Constants.UI.Spacing.small) {
                                HStack {
                                    Text("Spent Amount")
                                        .font(Constants.Typography.Caption.font)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                    
                                    Spacer()
                                    
                                    Text(budget.spentAmount, format: .currency(code: "USD"))
                                        .font(Constants.Typography.Body.font)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Constants.Colors.error)
                                }
                                
                                HStack {
                                    Text("Remaining Amount")
                                        .font(Constants.Typography.Caption.font)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                    
                                    Spacer()
                                    
                                    Text(budget.remainingAmount, format: .currency(code: "USD"))
                                        .font(Constants.Typography.Body.font)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Constants.Colors.success)
                                }
                            }
                            .padding(.horizontal, Constants.UI.Spacing.medium)
                            .padding(.vertical, Constants.UI.Spacing.small)
                            .background(Constants.Colors.backgroundSecondary)
                            .cornerRadius(Constants.UI.cardCornerRadius)
                        }
                        
                        // Progress Section
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                            Text("Current Progress")
                                .font(Constants.Typography.Body.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            VStack(spacing: Constants.UI.Spacing.small) {
                                HStack {
                                    Text("Progress")
                                        .font(Constants.Typography.Caption.font)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                    
                                    Spacer()
                                    
                                    Text("\(Int((budget.spentAmount / budget.allocatedAmount) * 100))%")
                                        .font(Constants.Typography.Caption.font)
                                        .fontWeight(.bold)
                                        .foregroundColor(progressColor)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        // Background
                                        Rectangle()
                                            .fill(Constants.Colors.backgroundSecondary)
                                            .frame(height: 8)
                                            .cornerRadius(Constants.UI.CornerRadius.quaternary)
                                        
                                        // Progress Fill
                                        Rectangle()
                                            .fill(progressColor)
                                            .frame(width: geometry.size.width * min(budget.spentAmount / budget.allocatedAmount, 1.0), height: 8)
                                            .cornerRadius(Constants.UI.CornerRadius.quaternary)
                                    }
                                }
                                .frame(height: 8)
                            }
                            .padding(.horizontal, Constants.UI.Spacing.medium)
                            .padding(.vertical, Constants.UI.Spacing.small)
                            .background(Constants.Colors.backgroundSecondary)
                            .cornerRadius(Constants.UI.cardCornerRadius)
                        }
                    }
                    .padding(.horizontal, Constants.UI.Padding.screenMargin)
                    
                    Spacer(minLength: Constants.UI.Spacing.section)
                }
            }
            .navigationTitle("Edit Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBudget()
                    }
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(selectedCategory: $category, categories: categories)
            }
        }
    }
    
    private var progressColor: Color {
        let progressData = ProgressUtilities.budgetProgress(
            spentAmount: budget.spentAmount,
            allocatedAmount: budget.allocatedAmount
        )
        return progressData.color
    }
    
    private func saveBudget() {
        guard let allocatedValue = Double(allocatedAmount), allocatedValue > 0 else { return }
        
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

// MARK: - Category Picker View
private struct CategoryPickerView: View {
    @Binding var selectedCategory: String
    let categories: [String]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        dismiss()
                    }) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                                    .fill(category.categoryColor.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: category.categoryIcon)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(category.categoryColor)
                            }
                            
                            Text(category)
                                .font(Constants.Typography.Body.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            Spacer()
                            
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Constants.Colors.primaryBlue)
                            }
                        }
                        .padding(.vertical, Constants.UI.Spacing.small)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Category utilities now handled by CategoryUtilities.swift
}

#Preview {
    BudgetEditView(budget: .constant(Budget(
        category: "Food",
        allocatedAmount: 500.0,
        spentAmount: 320.45,
        remainingAmount: 179.55
    )))
}
