import SwiftUI

struct TransactionEditView: View {
    @Binding var transaction: Transaction
    @Environment(\.dismiss) var dismiss
    @State private var title: String
    @State private var amount: String
    @State private var selectedDate: Date
    @State private var selectedCategory: String
    @State private var showingCategoryPicker = false
    
    private let categories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Income", "Other"]
    
    init(transaction: Binding<Transaction>) {
        self._transaction = transaction
        self._title = State(initialValue: transaction.wrappedValue.title)
        self._amount = State(initialValue: String(abs(transaction.wrappedValue.amount)))
        self._selectedDate = State(initialValue: transaction.wrappedValue.date)
        self._selectedCategory = State(initialValue: transaction.wrappedValue.category)
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
                                .fill(categoryColor(for: selectedCategory))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: categoryIcon(for: selectedCategory))
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .accessibilityHidden(true)
                        
                        Text("Edit Transaction")
                            .font(Constants.Typography.H1.font)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, Constants.UI.Spacing.large)
                    
                    // Form Section
                    VStack(spacing: Constants.UI.Spacing.medium) {
                        // Title Field
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                            Text("Title")
                                .font(Constants.Typography.Body.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            TextField("Enter transaction title", text: $title)
                                .textFieldStyle(EditFieldStyle())
                        }
                        
                        // Amount Field
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                            Text("Amount")
                                .font(Constants.Typography.Body.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            HStack {
                                Text("$")
                                    .font(Constants.Typography.H3.font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Constants.Colors.textSecondary)
                                
                                TextField("0.00", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(EditFieldStyle())
                            }
                            
                            // Transaction Type Toggle
                            HStack(spacing: Constants.UI.Spacing.medium) {
                                Button(action: {
                                    // Set as income (positive)
                                    if let currentAmount = Double(amount) {
                                        amount = String(currentAmount)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.down.circle.fill")
                                        Text("Income")
                                    }
                                    .font(Constants.Typography.Body.font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, Constants.UI.Spacing.medium)
                                    .padding(.vertical, Constants.UI.Spacing.small)
                                    .background(Constants.Colors.success)
                                    .cornerRadius(Constants.UI.cardCornerRadius)
                                }
                                
                                Button(action: {
                                    // Set as expense (negative)
                                    if let currentAmount = Double(amount) {
                                        amount = String(currentAmount)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.up.circle.fill")
                                        Text("Expense")
                                    }
                                    .font(Constants.Typography.Body.font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, Constants.UI.Spacing.medium)
                                    .padding(.vertical, Constants.UI.Spacing.small)
                                    .background(Constants.Colors.error)
                                    .cornerRadius(Constants.UI.cardCornerRadius)
                                }
                                
                                Spacer()
                            }
                        }
                        
                        // Date Field
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                            Text("Date")
                                .font(Constants.Typography.Body.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            HStack {
                                DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                                Spacer(minLength: 0)
                            }
                        }
                        
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
                                            .fill(categoryColor(for: selectedCategory).opacity(0.1))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: categoryIcon(for: selectedCategory))
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(categoryColor(for: selectedCategory))
                                    }
                                    
                                    Text(selectedCategory)
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
                    }
                    .padding(.horizontal, Constants.UI.Padding.screenMargin)
                    
                    Spacer(minLength: Constants.UI.Spacing.section)
                }
            }
            .navigationTitle("Edit Transaction")
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
                        saveTransaction()
                    }
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
            .sheet(isPresented: $showingCategoryPicker) {
                CategoryPickerView(selectedCategory: $selectedCategory, categories: categories)
            }
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        // Determine if it's income or expense based on current transaction
        let finalAmount = transaction.amount >= 0 ? amountValue : -amountValue
        
        transaction = Transaction(
            id: transaction.id,
            title: title,
            amount: finalAmount,
            date: selectedDate,
            category: selectedCategory
        )
        
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
    
    private func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "food": return Constants.Colors.success
        case "transport": return Constants.Colors.info
        case "shopping": return Constants.Colors.warning
        case "entertainment": return Constants.Colors.error
        case "bills": return Constants.Colors.textSecondary
        case "income": return Constants.Colors.success
        default: return Constants.Colors.info
        }
    }
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
                                    .fill(categoryColor(for: category).opacity(0.1))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: categoryIcon(for: category))
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(categoryColor(for: category))
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
    
    private func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "food": return Constants.Colors.success
        case "transport": return Constants.Colors.info
        case "shopping": return Constants.Colors.warning
        case "entertainment": return Constants.Colors.error
        case "bills": return Constants.Colors.textSecondary
        case "income": return Constants.Colors.success
        default: return Constants.Colors.info
        }
    }
}

#Preview {
    TransactionEditView(transaction: .constant(Transaction(
        title: "Coffee Shop",
        amount: -4.50,
        date: Date(),
        category: "Food"
    )))
}
