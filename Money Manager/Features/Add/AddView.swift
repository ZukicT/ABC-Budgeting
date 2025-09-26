import SwiftUI

/**
 * AddView
 *
 * Comprehensive form view for adding new transactions, budgets, and loans to the Money Manager app.
 * Features a tabbed interface with type-specific forms, validation, and success feedback.
 *
 * Features:
 * - Multi-type form support (Transaction, Budget, Loan)
 * - Real-time validation and error prevention
 * - Success animations and haptic feedback
 * - Comprehensive form fields with proper validation
 * - Accessibility compliance
 * - Professional UI with consistent design system
 *
 * Architecture:
 * - MVVM pattern with proper view model integration
 * - Modular form components for maintainability
 * - State management with @State and @ObservedObject
 * - Proper dependency injection for all view models
 *
 * Last Review: 2025-01-26
 * Status: Production Ready
 */

struct AddView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedType: AddType = .transaction
    @State private var showingSuccess = false
    @ObservedObject var loanViewModel: LoanViewModel
    @ObservedObject var budgetViewModel: BudgetViewModel
    @ObservedObject var transactionViewModel: TransactionViewModel
    
    enum AddType: String, CaseIterable {
        case transaction = "Transaction"
        case budget = "Budget"
        case loan = "Loan"
        
        var icon: String {
            switch self {
            case .transaction: return "plus.circle.fill"
            case .budget: return "chart.bar.fill"
            case .loan: return "creditcard.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .transaction: return Constants.Colors.cleanBlack
            case .budget: return Constants.Colors.robinNeonGreen
            case .loan: return Constants.Colors.softRed
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.UI.Spacing.large) {
                    // Type Selector
                    HStack(spacing: Constants.UI.Spacing.small) {
                        ForEach(AddType.allCases, id: \.self) { type in
                            TypeButton(
                                type: type,
                                isSelected: selectedType == type,
                                action: { selectedType = type }
                            )
                        }
                    }
                    .padding(.horizontal, Constants.UI.Padding.screenMargin)
                    .padding(.top, Constants.UI.Spacing.medium)
                    
                    // Form Content
                    VStack(spacing: Constants.UI.Spacing.large) {
                        switch selectedType {
                        case .transaction:
                            TransactionForm(transactionViewModel: transactionViewModel)
                        case .budget:
                            BudgetForm(budgetViewModel: budgetViewModel)
                        case .loan:
                            LoanForm(loanViewModel: loanViewModel)
                        }
                    }
                    .padding(.horizontal, Constants.UI.Padding.screenMargin)
                    .padding(.bottom, Constants.UI.Spacing.section)
                }
            }
            .navigationTitle("Add New")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                }
            }
        }
    }
}

// MARK: - Type Button
private struct TypeButton: View {
    let type: AddView.AddType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Constants.UI.Spacing.small) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : type.color)
                
                Text(type.rawValue)
                    .font(Constants.Typography.Caption.font)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? .white : Constants.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Constants.UI.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                    .fill(isSelected ? type.color : Constants.Colors.backgroundSecondary)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Add \(type.rawValue)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Transaction Form
private struct TransactionForm: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var amount = ""
    @State private var category = "Food"
    @State private var date = Date()
    @State private var isExpense = true
    @State private var showingSuccess = false
    @State private var isRecurring = false
    @State private var recurringFrequency = "Monthly"
    @State private var weeklyDay = "Monday"
    @State private var monthlyDay = "Same Day"
    @State private var yearlyMonth = "January"
    @State private var yearlyDay = 1
    
    private let categories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Income", "Other"]
    private let weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    private let monthlyOptions = ["Same Day", "1st", "15th", "Last Day"]
    private let months = ["January", "February", "March", "April", "May", "June", 
                         "July", "August", "September", "October", "November", "December"]
    
    private var maxDayForSelectedMonth: Int {
        let monthIndex = months.firstIndex(of: yearlyMonth) ?? 0
        let daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        return daysInMonth[monthIndex]
    }
    
    private var validDays: [Int] {
        Array(1...maxDayForSelectedMonth)
    }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !amount.isEmpty &&
        Double(amount) != nil &&
        Double(amount)! > 0
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Transaction Type Toggle
            HStack(spacing: 0) {
                Button(action: { isExpense = true }) {
                    Text("Expense")
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.medium)
                        .foregroundColor(isExpense ? .white : Constants.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Constants.UI.Spacing.medium)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                                .fill(isExpense ? Constants.Colors.softRed : Constants.Colors.backgroundSecondary)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { isExpense = false }) {
                    Text("Income")
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.medium)
                        .foregroundColor(!isExpense ? .white : Constants.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Constants.UI.Spacing.medium)
                        .background(
                            RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                                .fill(!isExpense ? Constants.Colors.robinNeonGreen : Constants.Colors.backgroundSecondary)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(
                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                    .fill(Constants.Colors.backgroundSecondary)
            )
            
            // Form Fields
            VStack(spacing: Constants.UI.Spacing.medium) {
                // Title
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    Text("Title")
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    TextField("Enter transaction title", text: $title)
                        .font(Constants.Typography.Body.font)
                        .padding(Constants.UI.Spacing.medium)
                        .background(Constants.Colors.backgroundSecondary)
                        .cornerRadius(Constants.UI.cardCornerRadius)
                }
                
                // Amount
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    Text("Amount")
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    HStack {
                        Text("$")
                            .font(Constants.Typography.Body.font)
                            .fontWeight(.medium)
                            .foregroundColor(Constants.Colors.textSecondary)
                        
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(Constants.Typography.Body.font)
                    }
                    .padding(Constants.UI.Spacing.medium)
                    .background(Constants.Colors.backgroundSecondary)
                    .cornerRadius(Constants.UI.cardCornerRadius)
                }
                
                // Category
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    Text("Category")
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Constants.UI.Spacing.small) {
                            ForEach(categories, id: \.self) { cat in
                                Button(action: { category = cat }) {
                                    Text(cat)
                                        .font(Constants.Typography.Caption.font)
                                        .fontWeight(category == cat ? .semibold : .medium)
                                        .foregroundColor(category == cat ? .white : Constants.Colors.textPrimary)
                                        .padding(.horizontal, Constants.UI.Spacing.medium)
                                        .padding(.vertical, Constants.UI.Spacing.small)
                                        .background(
                                            RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.secondary)
                                                .fill(category == cat ? Constants.Colors.cleanBlack : Constants.Colors.backgroundSecondary)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, Constants.UI.Spacing.small)
                    }
                }
                
                // Date
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    Text("Date")
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    DatePicker("", selection: $date, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .accentColor(Constants.Colors.cleanBlack)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Recurring Toggle
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    HStack {
                        Text("Recurring Transaction")
                            .font(Constants.Typography.H3.font)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Spacer()
                        
                        Toggle("", isOn: $isRecurring)
                            .toggleStyle(SwitchToggleStyle(tint: Constants.Colors.cleanBlack))
                    }
                    
                    if isRecurring {
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
                            // Frequency Selection
                            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                                Text("Frequency")
                                    .font(Constants.Typography.Body.font)
                                    .fontWeight(.medium)
                                    .foregroundColor(Constants.Colors.textSecondary)
                                
                                Picker("Frequency", selection: $recurringFrequency) {
                                    Text("Daily").tag("Daily")
                                    Text("Weekly").tag("Weekly")
                                    Text("Monthly").tag("Monthly")
                                    Text("Yearly").tag("Yearly")
                                }
                                .pickerStyle(.segmented)
                                .accentColor(Constants.Colors.cleanBlack)
                            }
                            
                            // Detailed Options based on Frequency
                            if recurringFrequency == "Weekly" {
                                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                                    Text("Day of Week")
                                        .font(Constants.Typography.Body.font)
                                        .fontWeight(.medium)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                    
                                    Picker("Day of Week", selection: $weeklyDay) {
                                        ForEach(weekDays, id: \.self) { day in
                                            Text(day).tag(day)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .accentColor(Constants.Colors.cleanBlack)
                                }
                            } else if recurringFrequency == "Monthly" {
                                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                                    Text("Day of Month")
                                        .font(Constants.Typography.Body.font)
                                        .fontWeight(.medium)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                    
                                    Picker("Day of Month", selection: $monthlyDay) {
                                        ForEach(monthlyOptions, id: \.self) { option in
                                            Text(option).tag(option)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .accentColor(Constants.Colors.cleanBlack)
                                }
                            } else if recurringFrequency == "Yearly" {
                                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                                    Text("Month")
                                        .font(Constants.Typography.Body.font)
                                        .fontWeight(.medium)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                    
                                    Picker("Month", selection: $yearlyMonth) {
                                        ForEach(months, id: \.self) { month in
                                            Text(month).tag(month)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .accentColor(Constants.Colors.cleanBlack)
                                    
                                    Text("Day")
                                        .font(Constants.Typography.Body.font)
                                        .fontWeight(.medium)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                        .padding(.top, Constants.UI.Spacing.small)
                                    
                                    Picker("Day", selection: $yearlyDay) {
                                        ForEach(validDays, id: \.self) { day in
                                            Text("\(day)").tag(day)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .accentColor(Constants.Colors.cleanBlack)
                                    .onChange(of: yearlyMonth) {
                                        // Reset day if it becomes invalid for the selected month
                                        if yearlyDay > maxDayForSelectedMonth {
                                            yearlyDay = maxDayForSelectedMonth
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.top, Constants.UI.Spacing.small)
                    }
                }
            }
            
            // Submit Button
            Button(action: submitTransaction) {
                Text(showingSuccess ? "Transaction Added!" : "Add Transaction")
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Constants.UI.Spacing.medium)
                    .background(isValid ? Constants.Colors.cleanBlack : Constants.Colors.textTertiary)
                    .cornerRadius(Constants.UI.cardCornerRadius)
            }
            .disabled(!isValid)
            .animation(.easeInOut(duration: 0.2), value: isValid)
            .animation(.easeInOut(duration: 0.3), value: showingSuccess)
            
            if showingSuccess {
                Text("Transaction added successfully!")
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.robinNeonGreen)
                    .transition(.opacity)
            }
        }
    }
    
    private func submitTransaction() {
        guard isValid else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Create the transaction
        let transactionAmount = isExpense ? -(Double(amount) ?? 0) : (Double(amount) ?? 0)
        let newTransaction = Transaction(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: transactionAmount,
            date: date,
            category: category
        )
        
        // Add transaction to the view model
        transactionViewModel.addTransaction(newTransaction)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showingSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingSuccess = false
                // Reset form
                title = ""
                amount = ""
                date = Date()
                isRecurring = false
                recurringFrequency = "Monthly"
                weeklyDay = "Monday"
                monthlyDay = "Same Day"
                yearlyMonth = "January"
                yearlyDay = 1
                // Dismiss the view
                dismiss()
            }
        }
        
        // Transaction successfully added to view model
    }
}

// MARK: - Budget Form
private struct BudgetForm: View {
    @ObservedObject var budgetViewModel: BudgetViewModel
    @State private var category = "Food"
    @State private var amount = ""
    @State private var period = "Monthly"
    @State private var showingSuccess = false
    
    private let categories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Savings", "Other"]
    private let periods = ["Weekly", "Monthly", "Yearly"]
    
    private var isValid: Bool {
        !amount.isEmpty &&
        Double(amount) != nil &&
        Double(amount)! > 0
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Form Fields
            VStack(spacing: Constants.UI.Spacing.medium) {
                // Category
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    Text("Category")
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Constants.UI.Spacing.small) {
                            ForEach(categories, id: \.self) { cat in
                                Button(action: { category = cat }) {
                                    Text(cat)
                                        .font(Constants.Typography.Caption.font)
                                        .fontWeight(category == cat ? .semibold : .medium)
                                        .foregroundColor(category == cat ? .white : Constants.Colors.textPrimary)
                                        .padding(.horizontal, Constants.UI.Spacing.medium)
                                        .padding(.vertical, Constants.UI.Spacing.small)
                                        .background(
                                            RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.secondary)
                                                .fill(category == cat ? Constants.Colors.cleanBlack : Constants.Colors.backgroundSecondary)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, Constants.UI.Spacing.small)
                    }
                }
                
                // Amount
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    Text("Budget Amount")
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    HStack {
                        Text("$")
                            .font(Constants.Typography.Body.font)
                            .fontWeight(.medium)
                            .foregroundColor(Constants.Colors.textSecondary)
                        
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(Constants.Typography.Body.font)
                    }
                    .padding(Constants.UI.Spacing.medium)
                    .background(Constants.Colors.backgroundSecondary)
                    .cornerRadius(Constants.UI.cardCornerRadius)
                }
                
                // Period
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    Text("Period")
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Picker("Period", selection: $period) {
                        ForEach(periods, id: \.self) { period in
                            Text(period).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accentColor(Constants.Colors.cleanBlack)
                }
            }
            
            // Submit Button
            Button(action: submitBudget) {
                Text(showingSuccess ? "Budget Created!" : "Create Budget")
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Constants.UI.Spacing.medium)
                    .background(isValid ? Constants.Colors.robinNeonGreen : Constants.Colors.textTertiary)
                    .cornerRadius(Constants.UI.cardCornerRadius)
            }
            .disabled(!isValid)
            .animation(.easeInOut(duration: 0.2), value: isValid)
            .animation(.easeInOut(duration: 0.3), value: showingSuccess)
            
            if showingSuccess {
                Text("Budget created successfully!")
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.robinNeonGreen)
                    .transition(.opacity)
            }
        }
    }
    
    private func submitBudget() {
        guard isValid else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Add the budget to the view model
        let allocatedAmount = Double(amount) ?? 0.0
        let newBudget = Budget(
            category: category,
            allocatedAmount: allocatedAmount,
            spentAmount: 0.0, // New budgets start with 0 spent
            remainingAmount: allocatedAmount // Remaining = allocated - spent
        )
        
        budgetViewModel.addBudget(newBudget)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showingSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingSuccess = false
                amount = ""
            }
        }
        
        // Budget successfully added to view model
    }
}

// MARK: - Loan Form
private struct LoanForm: View {
    @ObservedObject var loanViewModel: LoanViewModel
    @State private var loanAction: LoanAction = .addNew
    @State private var name = ""
    @State private var principal = ""
    @State private var interestRate = ""
    @State private var monthlyPayment = ""
    @State private var dueDate = 1
    @State private var category = LoanCategory.personal
    @State private var paymentStatus = LoanPaymentStatus.current
    @State private var lastPaymentDate = Date()
    @State private var nextPaymentDueDate = Date()
    @State private var showingSuccess = false
    @State private var selectedLoan: Loan?
    @State private var availableLoans: [Loan] = []
    
    private let categories = LoanCategory.allCases
    
    enum LoanAction: String, CaseIterable {
        case addNew = "Add New Loan"
        case markPaid = "Mark Loan as Paid"
        
        var icon: String {
            switch self {
            case .addNew: return "plus.circle.fill"
            case .markPaid: return "checkmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .addNew: return Constants.Colors.softRed
            case .markPaid: return Constants.Colors.success
            }
        }
    }
    
    private var isValid: Bool {
        switch loanAction {
        case .addNew:
            return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   !principal.isEmpty &&
                   !interestRate.isEmpty &&
                   !monthlyPayment.isEmpty &&
                   Double(principal) != nil &&
                   Double(interestRate) != nil &&
                   Double(monthlyPayment) != nil &&
                   Double(principal)! > 0 &&
                   Double(interestRate)! >= 0 &&
                   Double(monthlyPayment)! > 0
        case .markPaid:
            return selectedLoan != nil
        }
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Action Selector
            HStack(spacing: 0) {
                ForEach(LoanAction.allCases, id: \.self) { action in
                    Button(action: { 
                        loanAction = action
                        selectedLoan = nil // Reset selection when switching actions
                    }) {
                        Text(action.rawValue)
                            .font(Constants.Typography.Body.font)
                            .fontWeight(.medium)
                            .foregroundColor(loanAction == action ? .white : Constants.Colors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Constants.UI.Spacing.medium)
                            .background(
                                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                                    .fill(loanAction == action ? action.color : Constants.Colors.backgroundSecondary)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("\(action.rawValue) action")
                    .accessibilityAddTraits(loanAction == action ? .isSelected : [])
                }
            }
            .background(
                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                    .fill(Constants.Colors.backgroundSecondary)
            )
            
            // Conditional Content
            switch loanAction {
            case .addNew:
                addNewLoanForm
            case .markPaid:
                markPaidForm
            }
        }
        .onAppear {
            loadAvailableLoans()
        }
    }
    
    // MARK: - Add New Loan Form
    private var addNewLoanForm: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            // Loan Name
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text("Loan Name")
                    .font(Constants.Typography.H3.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                TextField("Enter loan name", text: $name)
                    .font(Constants.Typography.Body.font)
                    .padding(Constants.UI.Spacing.medium)
                    .background(Constants.Colors.backgroundSecondary)
                    .cornerRadius(Constants.UI.cardCornerRadius)
            }
            
            // Category
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text("Category")
                    .font(Constants.Typography.H3.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Constants.UI.Spacing.small) {
                        ForEach(categories, id: \.self) { cat in
                            Button(action: { category = cat }) {
                                Text(cat.displayName)
                                    .font(Constants.Typography.Caption.font)
                                    .fontWeight(category == cat ? .semibold : .medium)
                                    .foregroundColor(category == cat ? .white : Constants.Colors.textPrimary)
                                    .padding(.horizontal, Constants.UI.Spacing.medium)
                                    .padding(.vertical, Constants.UI.Spacing.small)
                                    .background(
                                        RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.secondary)
                                            .fill(category == cat ? Constants.Colors.cleanBlack : Constants.Colors.backgroundSecondary)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, Constants.UI.Spacing.small)
                }
            }
            
            // Principal Amount
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text("Principal Amount")
                    .font(Constants.Typography.H3.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                HStack {
                    Text("$")
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    TextField("0.00", text: $principal)
                        .keyboardType(.decimalPad)
                        .font(Constants.Typography.Body.font)
                }
                .padding(Constants.UI.Spacing.medium)
                .background(Constants.Colors.backgroundSecondary)
                .cornerRadius(Constants.UI.cardCornerRadius)
            }
            
            // Interest Rate
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text("Interest Rate")
                    .font(Constants.Typography.H3.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                HStack {
                    TextField("0.0", text: $interestRate)
                        .keyboardType(.decimalPad)
                        .font(Constants.Typography.Body.font)
                    
                    Text("%")
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                .padding(Constants.UI.Spacing.medium)
                .background(Constants.Colors.backgroundSecondary)
                .cornerRadius(Constants.UI.cardCornerRadius)
            }
            
            // Monthly Payment
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text("Monthly Payment")
                    .font(Constants.Typography.H3.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                HStack {
                    Text("$")
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    TextField("0.00", text: $monthlyPayment)
                        .keyboardType(.decimalPad)
                        .font(Constants.Typography.Body.font)
                }
                .padding(Constants.UI.Spacing.medium)
                .background(Constants.Colors.backgroundSecondary)
                .cornerRadius(Constants.UI.cardCornerRadius)
            }
            
            // Due Date
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text("Payment Due Day")
                    .font(Constants.Typography.H3.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Text("Select the day of the month your payment is due (e.g., 1st, 15th, 30th)")
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .padding(.bottom, Constants.UI.Spacing.small)
                
                Picker("Day of Month", selection: $dueDate) {
                    ForEach(1...31, id: \.self) { day in
                        Text("\(day)\(day == 1 ? "st" : day == 2 ? "nd" : day == 3 ? "rd" : "th")").tag(day)
                    }
                }
                .pickerStyle(.menu)
                .accentColor(Constants.Colors.cleanBlack)
            }
            
            // Payment Status
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text("Payment Status")
                    .font(Constants.Typography.H3.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Picker("Payment Status", selection: $paymentStatus) {
                    ForEach(LoanPaymentStatus.allCases, id: \.self) { status in
                        Text(status.displayName).tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .accentColor(Constants.Colors.cleanBlack)
            }
            
            // Last Payment Date
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text("Last Payment Date")
                    .font(Constants.Typography.H3.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                DatePicker("", selection: $lastPaymentDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .accentColor(Constants.Colors.cleanBlack)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Next Payment Due Date
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text("Next Payment Due Date")
                    .font(Constants.Typography.H3.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                DatePicker("", selection: $nextPaymentDueDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .accentColor(Constants.Colors.cleanBlack)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Submit Button
            Button(action: submitLoan) {
                Text(showingSuccess ? (loanAction == .addNew ? "Loan Added!" : "Payment Marked!") : (loanAction == .addNew ? "Add Loan" : "Mark as Paid"))
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Constants.UI.Spacing.medium)
                    .background(isValid ? (loanAction == .addNew ? Constants.Colors.softRed : Constants.Colors.success) : Constants.Colors.textTertiary)
                    .cornerRadius(Constants.UI.cardCornerRadius)
            }
            .disabled(!isValid)
            .animation(.easeInOut(duration: 0.2), value: isValid)
            .animation(.easeInOut(duration: 0.3), value: showingSuccess)
            
            if showingSuccess {
                Text(loanAction == .addNew ? "Loan added successfully!" : "Payment marked successfully!")
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.robinNeonGreen)
                    .transition(.opacity)
            }
        }
    }
    
    // MARK: - Mark Paid Form
    private var markPaidForm: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            if availableLoans.isEmpty {
                VStack(spacing: Constants.UI.Spacing.medium) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 48))
                        .foregroundColor(Constants.Colors.success)
                    
                    Text("All loans are already paid!")
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text("No unpaid loans available to mark as paid")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(Constants.UI.Spacing.large)
            } else {
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    Text("Select Loan to Mark as Paid")
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Text("Choose the loan you want to mark as paid")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                LoanPickerView(loans: availableLoans, selectedLoan: $selectedLoan)
                    .frame(maxHeight: 300)
                
                // Submit Button for Mark Paid
                Button(action: submitLoan) {
                    Text(showingSuccess ? "Payment Marked!" : "Mark as Paid")
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Constants.UI.Spacing.medium)
                        .background(isValid ? Constants.Colors.success : Constants.Colors.textTertiary)
                        .cornerRadius(Constants.UI.cardCornerRadius)
                }
                .disabled(!isValid)
                .animation(.easeInOut(duration: 0.2), value: isValid)
                .animation(.easeInOut(duration: 0.3), value: showingSuccess)
                
                if showingSuccess {
                    Text("Payment marked successfully!")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.robinNeonGreen)
                        .transition(.opacity)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func loadAvailableLoans() {
        // Load unpaid loans from the view model
        availableLoans = loanViewModel.getUnpaidLoans()
    }
    
    private func submitLoan() {
        guard isValid else { return }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showingSuccess = true
        }
        
        switch loanAction {
        case .addNew:
            // Add the new loan to the view model
            loanViewModel.addLoan(
                name: name,
                principalAmount: Double(principal) ?? 0.0,
                interestRate: Double(interestRate) ?? 0.0,
                monthlyPayment: Double(monthlyPayment) ?? 0.0,
                dueDay: dueDate,
                category: category,
                paymentStatus: paymentStatus,
                lastPaymentDate: lastPaymentDate,
                nextPaymentDueDate: nextPaymentDueDate
            )
            // Loan successfully added to view model
        case .markPaid:
            if let loan = selectedLoan {
                // Mark the loan as paid in the view model
                loanViewModel.markLoanAsPaid(loan)
                // Loan successfully marked as paid
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingSuccess = false
                if loanAction == .addNew {
                    name = ""
                    principal = ""
                    interestRate = ""
                    monthlyPayment = ""
                    dueDate = 1
                    paymentStatus = .current
                    lastPaymentDate = Date()
                    nextPaymentDueDate = Date()
                } else {
                    selectedLoan = nil
                }
            }
        }
    }
}

#Preview {
    AddView(loanViewModel: LoanViewModel(), budgetViewModel: BudgetViewModel(), transactionViewModel: TransactionViewModel())
}