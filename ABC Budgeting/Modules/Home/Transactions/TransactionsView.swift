import SwiftUI
import Foundation

struct TransactionsView: View {
    @State private var selectedCategory: TransactionCategory? = nil
    @Binding var transactions: [Transaction]
    @State private var showAddTransaction = false
    @Binding var goals: [GoalFormData]
    @State private var selectedTransaction: Transaction? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                        filterChipsSection
                        contentSection
                    }
                    .padding(.bottom, 80) // For FAB spacing
                }
                fabSection
            }
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionView(availableGoals: goals) { newTransaction in
                    // If the transaction is linked to a goal, update the goal's savedAmount
                    if let linkedGoalName = newTransaction.linkedGoalName,
                       let idx = goals.firstIndex(where: { $0.name == linkedGoalName }) {
                        let amount = newTransaction.amount
                        if amount > 0 {
                            goals[idx] = GoalFormData(
                                name: goals[idx].name,
                                subtitle: goals[idx].subtitle,
                                targetAmount: goals[idx].targetAmount,
                                savedAmount: goals[idx].savedAmount + amount,
                                targetDate: goals[idx].targetDate,
                                notes: goals[idx].notes,
                                iconName: goals[idx].iconName,
                                iconColorName: goals[idx].iconColorName
                            )
                        } else if amount < 0 {
                            goals[idx] = GoalFormData(
                                name: goals[idx].name,
                                subtitle: goals[idx].subtitle,
                                targetAmount: goals[idx].targetAmount,
                                savedAmount: goals[idx].savedAmount + amount,
                                targetDate: goals[idx].targetDate,
                                notes: goals[idx].notes,
                                iconName: goals[idx].iconName,
                                iconColorName: goals[idx].iconColorName
                            )
                        }
                    }
                    transactions.insert(newTransaction, at: 0)
                    showAddTransaction = false
                }
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionDetailView(transaction: transaction) { updatedTransaction in
                    if let idx = transactions.firstIndex(where: { $0.id == updatedTransaction.id }) {
                        transactions[idx] = updatedTransaction
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        Text("Transactions")
            .font(.title.bold())
            .foregroundColor(.primary)
            .padding(.top, 20)
            .padding(.horizontal)
    }

    private var filterChipsSection: some View {
        FilterChips(selected: $selectedCategory)
            .padding(.top, 12)
            .padding(.horizontal)
    }

    private var contentSection: some View {
        Group {
            if transactions.isEmpty {
                emptyStateSection
            } else {
                transactionListSection
            }
        }
    }

    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)
            Image("Transactions")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220, maxHeight: 220)
                .accessibilityLabel("No transactions yet")
            Text("No transactions yet")
                .font(.title3.weight(.semibold))
                .foregroundColor(.secondary)
            Text("Tap the + button to add your first transaction.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var transactionListSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Today")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
                    .padding(.horizontal)
                VStack(spacing: 16) {
                    ForEach(transactions.filter { selectedCategory == nil || $0.category == selectedCategory }) { transaction in
                        Button(action: { selectedTransaction = transaction }) {
                            TransactionRow(transaction: transaction)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal)
                .padding(.bottom, 80) // For FAB spacing
            }
        }
    }

    private var fabSection: some View {
        FloatingActionButton(action: {
            showAddTransaction = true
        })
        .padding(.trailing, AppPaddings.fabTrailing)
        .padding(.bottom, AppPaddings.fabBottom)
    }
}

// MARK: - Filter Chips
struct FilterChips: View {
    @Binding var selected: TransactionCategory?
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: { selected = nil }) {
                    Text("All")
                        .font(.subheadline.bold())
                        .foregroundColor(selected == nil ? .white : AppColors.tagUnselected)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selected == nil ? AppColors.black : AppColors.tagUnselectedBackground)
                        )
                }
                .accessibilityLabel("All")
                .accessibilityAddTraits(selected == nil ? .isSelected : .isButton)
                ForEach(TransactionCategory.allCases) { category in
                    Button(action: { selected = category }) {
                        HStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(category.color.opacity(0.18))
                                    .frame(width: 22, height: 22)
                                Image(systemName: category.symbol)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(selected == category ? .white : category.color)
                            }
                            Text(category.label)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(selected == category ? .white : AppColors.tagUnselected)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selected == category ? category.color : AppColors.tagUnselectedBackground)
                        )
                    }
                    .accessibilityLabel(category.label)
                    .accessibilityAddTraits(selected == category ? .isSelected : .isButton)
                }
            }
        }
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: Transaction
    @AppStorage("preferredCurrency") private var preferredCurrency: String = "USD"
    
    var body: some View {
        let currencyCode = preferredCurrency.components(separatedBy: " ").first ?? "USD"
        
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(transaction.iconBackground)
                    .frame(width: 48, height: 48)
                Image(systemName: transaction.iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(transaction.iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if !transaction.subtitle.isEmpty {
                    Text(transaction.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(transaction.date, format: .dateTime.month().day().hour().minute())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(transaction.amount, format: .currency(code: currencyCode).precision(.fractionLength(2)))
                    .font(.headline.weight(.bold))
                    .foregroundColor(transactionColor)
                
                Text(transaction.category.label)
                    .font(.caption.weight(.medium))
                    .foregroundColor(transaction.category.color)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 4)
        )
        .accessibilityElement(children: .combine)
    }
    
    // Helper to determine transaction color
    private var transactionColor: Color {
        transaction.isIncome ? Color(hex: "07e95e") : Color(hex: "dc2626")
    }
}





struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}



enum RecurringFrequency: String, CaseIterable, Identifiable {
    case daily, weekly, monthly, yearly
    var id: String { rawValue }
    var label: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}

// MARK: - Custom Segmented Control
struct BrandSegmentedPicker<T: Hashable & Identifiable & CustomStringConvertible>: View {
    @Binding var selection: T
    var options: [T]
    var accessibilityLabel: String?
    @Namespace private var animationNamespace
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.systemGray5))
            HStack(spacing: 0) {
                ForEach(options) { option in
                    Button(action: { withAnimation(.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0.25)) { selection = option } }) {
                        Text(option.description)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(selection == option ? .white : AppColors.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                ZStack {
                                    if selection == option {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(AppColors.black)
                                            .matchedGeometryEffect(id: "switcher", in: animationNamespace)
                                    }
                                }
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(option.description)
                    .accessibilityAddTraits(selection == option ? .isSelected : .isButton)
                }
            }
        }
        .frame(height: 44)
        .padding(.vertical, 2)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel ?? "")
    }
}

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var title: String = ""
    @State private var category: TransactionCategory = .essentials
    @State private var iconName: String = TransactionCategory.essentials.symbol
    @State private var iconColorName: String = TransactionCategory.essentials.color.toHex()
    @State private var iconBackgroundName: String = "orange.opacity15"
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var isRecurringBool: Bool = false
    @State private var recurringFrequency: RecurringFrequency = .monthly
    @State private var notifyMe: Bool = false
    @State private var incomeOrExpense: IncomeOrExpense = .expense
    @State private var selectedCategory: TransactionCategory = .essentials
    let availableGoals: [GoalFormData]
    @State private var selectedGoal: GoalFormData? = nil
    var onSave: (Transaction) -> Void

    // Bridge for BrandSegmentedPicker
    private var isRecurring: BoolOption {
        get { BoolOption(isRecurringBool) }
        set { isRecurringBool = newValue.value }
    }

    private var isRecurringBinding: Binding<BoolOption> {
        Binding<BoolOption>(
            get: { BoolOption(isRecurringBool) },
            set: { isRecurringBool = $0.value }
        )
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background matching Overview tab
                LinearGradient(
                    colors: [Color(hex: "f8fafc"), Color(hex: "e2e8f0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Title Section
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Add New Transaction")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(.primary)
                                
                                Text("Track your income and expenses")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    .background(AppColors.background.opacity(0.5))
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
                            // Transaction type selection
                            transactionTypeSection
                        
                        // Form fields
                        VStack(spacing: 20) {
                            // Amount input
                            amountInputSection
                            
                            // Title input
                            titleInputSection
                            
                            // Category selection
                            categorySelectionSection
                            
                            // Date and recurring
                            dateAndRecurringSection
                            
                            // Goal linking
                            goalLinkingSection
                            
                            // Notes
                            notesSection
                        }
                        
                            // Save button
                            saveButtonSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }

    
    // MARK: - Transaction Type Selection
    private var transactionTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transaction Type")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                // Income button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        incomeOrExpense = .income
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title3.weight(.semibold))
                        
                        Text("Income")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundColor(incomeOrExpense == .income ? Color(hex: "065f46") : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(incomeOrExpense == .income ? Color(hex: "07e95e") : Color.gray.opacity(0.2))
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add income transaction")
                
                // Expense button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        incomeOrExpense = .expense
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title3.weight(.semibold))
                        
                        Text("Expense")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundColor(incomeOrExpense == .expense ? Color(hex: "dc2626") : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(incomeOrExpense == .expense ? Color(hex: "fecaca") : Color.gray.opacity(0.2))
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add expense transaction")
            }
        }
    }
    
    // MARK: - Amount Input
    private var amountInputSection: some View {
        let preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD (US Dollar)"
        let currencyCode = preferredCurrency.components(separatedBy: " ").first ?? "USD"
        
        // Get currency symbol from the currency code
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        let currencySymbol = formatter.currencySymbol ?? "$"
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Amount")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Text(currencySymbol)
                    .font(.title.weight(.bold))
                    .foregroundColor(incomeOrExpense == .income ? Color(hex: "07e95e") : Color(hex: "dc2626"))
                    .frame(width: 30, alignment: .leading)
                
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.title.weight(.bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.card)
                    .shadow(color: AppColors.cardShadow, radius: 2, y: 1)
            )
        }
    }
    
    // MARK: - Title Input
    private var titleInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            TextField("e.g. Coffee, Rent, Salary", text: $title)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.card)
                        .shadow(color: AppColors.cardShadow, radius: 2, y: 1)
                )
        }
    }
    
    // MARK: - Category Selection
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            categoryGrid
        }
    }
    
    private var categoryGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
            ForEach(TransactionCategory.allCases) { cat in
                categoryButton(for: cat)
            }
        }
    }
    
    private func categoryButton(for cat: TransactionCategory) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = cat
                category = cat
                iconName = cat.symbol
                iconColorName = cat.color.toHex()
                iconBackgroundName = cat.color.toHex() + ".opacity15"
            }
        }) {
            categoryButtonContent(for: cat)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(cat.label)
        .accessibilityAddTraits(selectedCategory == cat ? .isSelected : .isButton)
    }
    
    private func categoryButtonContent(for cat: TransactionCategory) -> some View {
        VStack(spacing: 8) {
            categoryIcon(for: cat)
            categoryLabel(for: cat)
        }
        .frame(height: 70)
        .frame(maxWidth: .infinity)
        .background(categoryButtonBackground(for: cat))
    }
    
    private func categoryIcon(for cat: TransactionCategory) -> some View {
        ZStack {
            Circle()
                .fill(selectedCategory == cat ? cat.color : cat.color.opacity(0.15))
                .frame(width: 40, height: 40)
            
            Image(systemName: cat.symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(selectedCategory == cat ? .white : cat.color)
        }
    }
    
    private func categoryLabel(for cat: TransactionCategory) -> some View {
        Text(cat.label)
            .font(.caption.weight(.medium))
            .foregroundColor(selectedCategory == cat ? cat.color : .primary)
            .lineLimit(1)
            .multilineTextAlignment(.center)
    }
    
    private func categoryButtonBackground(for cat: TransactionCategory) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(selectedCategory == cat ? cat.color.opacity(0.2) : Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(selectedCategory == cat ? cat.color : Color.clear, lineWidth: 2)
            )
    }
    
    // MARK: - Date and Recurring Options
    private var dateAndRecurringSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Date")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Recurring")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Toggle(isOn: $isRecurringBool) {
                        EmptyView()
                    }
                    .tint(AppColors.primary)
                }
                
                if isRecurringBool {
                    HStack(spacing: 8) {
                        ForEach(RecurringFrequency.allCases) { frequency in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    recurringFrequency = frequency
                                }
                            }) {
                                Text(frequency.label)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(recurringFrequency == frequency ? .white : AppColors.primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(recurringFrequency == frequency ? AppColors.primary : AppColors.primary.opacity(0.1))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Goal Linking
    private var goalLinkingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Link to Goal")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            if availableGoals.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                    Text("No savings goals available")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.card)
                        .shadow(color: AppColors.cardShadow, radius: 2, y: 1)
                )
            } else {
                Menu {
                    Button("None") {
                        selectedGoal = nil
                    }
                    
                    ForEach(availableGoals, id: \.name) { goal in
                        Button(action: { selectedGoal = goal }) {
                            HStack {
                                Image(systemName: goal.iconName)
                                    .foregroundColor(goal.iconColor)
                                Text(goal.name)
                            }
                        }
                    }
                } label: {
                    HStack {
                        if let selectedGoal = selectedGoal {
                            HStack(spacing: 8) {
                                Image(systemName: selectedGoal.iconName)
                                    .foregroundColor(selectedGoal.iconColor)
                                Text(selectedGoal.name)
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.primary)
                            }
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "target")
                                    .foregroundColor(.secondary)
                                Text("Select a goal (optional)")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.card)
                            .shadow(color: AppColors.cardShadow, radius: 2, y: 1)
                    )
                }
            }
        }
    }
    
    // MARK: - Notes
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            TextField("Add a note...", text: $notes, axis: .vertical)
                .font(.body)
                .lineLimit(3...6)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.card)
                        .shadow(color: AppColors.cardShadow, radius: 2, y: 1)
                )
        }
    }
    
    // MARK: - Save Button
    private var saveButtonSection: some View {
        VStack(spacing: 12) {
            Button(action: save) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    Text("Save Transaction")
                        .font(.headline.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isFormValid ? AppColors.primary : Color(.systemGray4))
                        .shadow(color: isFormValid ? AppColors.primary.opacity(0.3) : Color.clear, radius: 4, y: 2)
                )
                .foregroundColor(.white)
            }
            .disabled(!isFormValid)
            .scaleEffect(isFormValid ? 1.0 : 0.98)
            .animation(.easeInOut(duration: 0.2), value: isFormValid)
            
            if !isFormValid {
                Text("Please fill in the title and amount to continue")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Form Validation
    private var isFormValid: Bool {
        !title.isEmpty && !amount.isEmpty && Double(amount) != nil
    }
    
    // MARK: - Gradient Helpers
    private var incomeGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "07e95e"), Color(hex: "059669")], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var incomeGradientDisabled: LinearGradient {
        LinearGradient(colors: [Color(hex: "07e95e").opacity(0.3), Color(hex: "059669").opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var expenseGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "dc2626"), Color(hex: "b91c1c")], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var expenseGradientDisabled: LinearGradient {
        LinearGradient(colors: [Color(hex: "dc2626").opacity(0.3), Color(hex: "b91c1c").opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var saveButtonGradient: LinearGradient {
        LinearGradient(colors: [AppColors.primary, Color(hex: "1e40af")], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    private var saveButtonGradientDisabled: LinearGradient {
        LinearGradient(colors: [Color(.systemGray4), Color(.systemGray4)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private func save() {
        let value = Double(amount.replacingOccurrences(of: "$", with: "")) ?? 0
        // Store the amount as positive, use isIncome to determine if it's income or expense
        
        let newTransaction = Transaction(
            id: UUID(),
            title: title,
            subtitle: notes,
            amount: value,
            iconName: iconName,
            iconColorName: iconColorName,
            iconBackgroundName: iconBackgroundName,
            category: category,
            isIncome: incomeOrExpense == .income,
            linkedGoalName: selectedGoal?.name,
            date: Date()
        )
        onSave(newTransaction)
        // If notifyMe is enabled, schedule notifications for 5 days before, 2 days before, and on the day of the transaction date.
        // Use the selected 'date' and 'recurringFrequency' to determine the next occurrence(s).
        // Notification scheduling logic should be implemented here (using UNUserNotificationCenter, etc.).
    }
}

// Helper for Bool option
struct BoolOption: Identifiable, Hashable, CustomStringConvertible {
    let value: Bool
    var id: Bool { value }
    var description: String { value ? "Recurring" : "One Time" }
    init(_ value: Bool) { self.value = value }
    static func == (lhs: BoolOption, rhs: BoolOption) -> Bool { lhs.value == rhs.value }
    func hash(into hasher: inout Hasher) { hasher.combine(value) }
}

// Conform RecurringFrequency to CustomStringConvertible
extension RecurringFrequency: CustomStringConvertible {
    var description: String { label }
}

// MARK: - IncomeOrExpense Enum
enum IncomeOrExpense: String, CaseIterable, Identifiable, CustomStringConvertible {
    case income = "Income"
    case expense = "Expense"
    var id: String { rawValue }
    var description: String { rawValue }
}

// MARK: - Add Transaction View With Preselection
struct AddTransactionViewWithPreselection: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var title: String = ""
    @State private var category: TransactionCategory = .essentials
    @State private var iconName: String = TransactionCategory.essentials.symbol
    @State private var iconColorName: String = TransactionCategory.essentials.color.toHex()
    @State private var iconBackgroundName: String = "orange.opacity15"
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var isRecurringBool: Bool = false
    @State private var recurringFrequency: RecurringFrequency = .monthly
    @State private var notifyMe: Bool = false
    @State private var incomeOrExpense: IncomeOrExpense
    @State private var selectedCategory: TransactionCategory = .essentials
    let availableGoals: [GoalFormData]
    @State private var selectedGoal: GoalFormData? = nil
    var onSave: (Transaction) -> Void
    
    init(availableGoals: [GoalFormData], preSelectedType: IncomeOrExpense, onSave: @escaping (Transaction) -> Void) {
        self.availableGoals = availableGoals
        self.onSave = onSave
        self._incomeOrExpense = State(initialValue: preSelectedType)
    }

    // Bridge for BrandSegmentedPicker
    private var isRecurring: BoolOption {
        get { BoolOption(isRecurringBool) }
        set { isRecurringBool = newValue.value }
    }

    private var isRecurringBinding: Binding<BoolOption> {
        Binding<BoolOption>(
            get: { BoolOption(isRecurringBool) },
            set: { isRecurringBool = $0.value }
        )
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Transaction type selection
                        transactionTypeSection
                    
                    // Form fields
                    VStack(spacing: 20) {
                        // Amount input
                        amountInputSection
                        
                        // Title input
                        titleInputSection
                        
                        // Category selection
                        categorySelectionSection
                        
                        // Date and recurring
                        dateAndRecurringSection
                        
                        // Goal linking
                        goalLinkingSection
                        
                        // Notes
                        notesSection
                    }
                    
                        // Save button
                        saveButtonSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    // MARK: - Transaction Type Selection
    private var transactionTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transaction Type")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                // Income button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        incomeOrExpense = .income
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title3.weight(.semibold))
                        
                        Text("Income")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundColor(incomeOrExpense == .income ? Color(hex: "065f46") : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(incomeOrExpense == .income ? Color(hex: "07e95e") : Color.gray.opacity(0.2))
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add income transaction")
                
                // Expense button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        incomeOrExpense = .expense
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title3.weight(.semibold))
                        
                        Text("Expense")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundColor(incomeOrExpense == .expense ? Color(hex: "dc2626") : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(incomeOrExpense == .expense ? Color(hex: "fecaca") : Color.gray.opacity(0.2))
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add expense transaction")
            }
        }
    }
    
    // MARK: - Amount Input Section
    private var amountInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amount")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            HStack {
                Text("$")
                    .font(.title.weight(.bold))
                    .foregroundColor(AppColors.primary)
                
                TextField("0.00", text: $amount)
                    .font(.title.weight(.bold))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                    .onChange(of: amount) { _, newValue in
                        // Format the amount as user types
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        if filtered != newValue {
                            amount = filtered
                        }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    // MARK: - Title Input Section
    private var titleInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Title")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            TextField("Enter transaction title", text: $title)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                )
        }
    }
    
    // MARK: - Category Selection Section
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(TransactionCategory.allCases, id: \.self) { category in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                            self.category = category
                            iconName = category.symbol
                            iconColorName = category.color.toHex()
                            iconBackgroundName = "\(category.color.toHex()).opacity15"
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: category.symbol)
                                .font(.title2.weight(.semibold))
                                .foregroundColor(selectedCategory == category ? .white : category.color)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(selectedCategory == category ? category.color : Color(.systemGray6))
                                )
                            
                            Text(category.label)
                                .font(.caption.weight(.medium))
                                .foregroundColor(selectedCategory == category ? .primary : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedCategory == category ? category.color.opacity(0.1) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Date and Recurring Section
    private var dateAndRecurringSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Date picker
            VStack(alignment: .leading, spacing: 12) {
                Text("Date")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            
            // Recurring toggle
            VStack(alignment: .leading, spacing: 12) {
                Text("Recurring")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                
                BrandSegmentedPicker(
                    selection: isRecurringBinding,
                    options: [BoolOption(false), BoolOption(true)]
                )
            }
            
            // Recurring frequency (only show if recurring is enabled)
            if isRecurringBool {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Frequency")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                    
                    BrandSegmentedPicker(
                        selection: Binding<BoolOption>(
                            get: { BoolOption(recurringFrequency == .monthly) },
                            set: { _ in recurringFrequency = .monthly }
                        ),
                        options: RecurringFrequency.allCases.map { BoolOption($0 == recurringFrequency) }
                    )
                }
            }
        }
    }
    
    // MARK: - Goal Linking Section
    private var goalLinkingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Link to Goal (Optional)")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            if availableGoals.isEmpty {
                Text("No goals available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                Menu {
                    Button("No Goal") {
                        selectedGoal = nil
                    }
                    
                    ForEach(availableGoals, id: \.name) { goal in
                        Button(goal.name) {
                            selectedGoal = goal
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedGoal?.name ?? "Select a goal")
                            .font(.body)
                            .foregroundColor(selectedGoal == nil ? .secondary : .primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray6))
                    )
                }
            }
        }
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes (Optional)")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            TextField("Add a note", text: $notes, axis: .vertical)
                .font(.body)
                .lineLimit(3...6)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                )
        }
    }
    
    // MARK: - Save Button Section
    private var saveButtonSection: some View {
        Button(action: save) {
            Text("Save Transaction")
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColors.primary)
                )
        }
        .buttonStyle(.plain)
        .disabled(amount.isEmpty || title.isEmpty)
        .opacity(amount.isEmpty || title.isEmpty ? 0.6 : 1.0)
    }
    
    private func save() {
        let value = Double(amount.replacingOccurrences(of: "$", with: "")) ?? 0
        // Store the amount as positive, use isIncome to determine if it's income or expense
        
        let newTransaction = Transaction(
            id: UUID(),
            title: title,
            subtitle: notes,
            amount: value,
            iconName: iconName,
            iconColorName: iconColorName,
            iconBackgroundName: iconBackgroundName,
            category: category,
            isIncome: incomeOrExpense == .income,
            linkedGoalName: selectedGoal?.name,
            date: Date()
        )
        onSave(newTransaction)
        // If notifyMe is enabled, schedule notifications for 5 days before, 2 days before, and on the day of the transaction date.
        // Use the selected 'date' and 'recurringFrequency' to determine the next occurrence(s).
        // Notification scheduling logic should be implemented here (using UNUserNotificationCenter, etc.).
    }
}

struct TransactionDetailView: View {
    let transaction: Transaction
    var onSave: (Transaction) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var note: String
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedAmount: String
    @State private var editedCategory: TransactionCategory
    @State private var editedIconName: String
    @State private var editedDate: Date
    @State private var editedLinkedGoalName: String?
    // For demo, we just update the local note. In a real app, this would persist to storage or view model.
    init(transaction: Transaction, onSave: @escaping (Transaction) -> Void) {
        self.transaction = transaction
        self.onSave = onSave
        _note = State(initialValue: transaction.subtitle)
        _editedTitle = State(initialValue: transaction.title)
        _editedAmount = State(initialValue: String(format: "%g", transaction.amount))
        _editedCategory = State(initialValue: transaction.category)
        _editedIconName = State(initialValue: transaction.iconName)
        _editedDate = State(initialValue: Date.now) // Replace with transaction.date if available
        _editedLinkedGoalName = State(initialValue: transaction.linkedGoalName)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { UIApplication.shared.endEditing() }
            Capsule()
                .fill(Color.secondary.opacity(0.25))
                .frame(width: 40, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .onTapGesture { dismiss() }

            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(editedCategory.color.opacity(0.18))
                        .frame(width: 56, height: 56)
                    Image(systemName: editedIconName)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(editedCategory.color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    if isEditing {
                        TextField("Title", text: $editedTitle)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        // Icon picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(editedCategory.icons, id: \.self) { icon in
                                    Button(action: { editedIconName = icon }) {
                                        ZStack {
                                            Circle()
                                                .fill(editedIconName == icon ? editedCategory.color : Color(.systemGray5))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: icon)
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(editedIconName == icon ? .white : editedCategory.color)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        Text(transaction.title)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        if !transaction.subtitle.isEmpty {
                            Text(transaction.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            Divider().padding(.vertical, 4)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Amount")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                    if isEditing {
                        let preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD (US Dollar)"
                        let currencyCode = preferredCurrency.components(separatedBy: " ").first ?? "USD"
                        let currencySymbol = Locale.availableIdentifiers.compactMap { Locale(identifier: $0) }
                            .first(where: { $0.currency?.identifier == currencyCode })?.currencySymbol ?? "$"
                        ZStack(alignment: .leading) {
                            Text(currencySymbol)
                                .font(.body.weight(.semibold))
                                .foregroundColor(.secondary)
                                .padding(.leading, 8)
                            TextField("0.00", text: $editedAmount)
                                .keyboardType(.decimalPad)
                                .font(.title3.weight(.semibold))
                                .foregroundColor((Double(editedAmount) ?? 0) >= 0 ? .green : .red)
                                .multilineTextAlignment(.trailing)
                                .padding(.leading, 32)
                                .frame(width: 100)
                        }
                    } else {
                        Text(transaction.amount, format: .currency(code: "USD"))
                            .font(.title3.weight(.semibold))
                            .foregroundColor(transaction.amount >= 0 ? .green : .red)
                    }
                }
                HStack {
                    Text("Category")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                    if isEditing {
                        Picker("Category", selection: $editedCategory) {
                            ForEach(TransactionCategory.allCases) { cat in
                                Text(cat.label).tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                    } else {
                        Label(transaction.category.label, systemImage: transaction.category.symbol)
                            .font(.body)
                            .foregroundColor(transaction.category.color)
                    }
                }
                if isEditing {
                    // Linked Goal Picker (if needed)
                }
                if let linkedGoalName = transaction.linkedGoalName {
                    HStack {
                        Text("Linked Goal")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                        if isEditing {
                            TextField("Linked Goal", text: Binding(
                                get: { editedLinkedGoalName ?? "" },
                                set: { editedLinkedGoalName = $0.isEmpty ? nil : $0 }
                            ))
                                .font(.body)
                                .foregroundColor(.primary)
                        } else {
                            Text(linkedGoalName)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                }
                HStack {
                    Text("Date & Time")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                    if isEditing {
                        DatePicker("", selection: $editedDate, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                    } else {
                        Text(editedDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Note")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    if isEditing {
                        TextField("Add a note...", text: $note, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                            .foregroundColor(.primary)
                    } else {
                        Text(note.isEmpty ? "No note" : note)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
            }
            HStack {
                if isEditing {
                    Button(action: { isEditing = false }) {
                        Text("Cancel")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                    Button(action: {
                        // Save logic: create new Transaction and call onSave
                        let updatedTransaction = Transaction(
                            id: transaction.id,
                            title: editedTitle,
                            subtitle: note,
                            amount: Double(editedAmount) ?? 0,
                            iconName: editedIconName,
                            iconColorName: editedCategory.color.toHex(),
                            iconBackgroundName: editedCategory.color.toHex() + ".opacity15",
                            category: editedCategory,
                            isIncome: editedCategory == .income,
                            linkedGoalName: editedLinkedGoalName,
                            date: editedDate
                        )
                        onSave(updatedTransaction)
                        isEditing = false
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                } else {
                    Button(action: { isEditing = true }) {
                        Text("Edit")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}


// Helper to dismiss keyboard
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
