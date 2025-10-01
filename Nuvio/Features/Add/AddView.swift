//
//  AddView.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Comprehensive form view for adding new transactions, budgets, and loans.
//  Features tabbed interface with type-specific forms, validation, success
//  feedback, and real-time error prevention with accessibility compliance.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedType: AddType = .transaction
    @State private var showingSuccess = false
    @ObservedObject var loanViewModel: LoanViewModel
    @ObservedObject var budgetViewModel: BudgetViewModel
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var budgetTransactionService: BudgetTransactionService
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
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
            case .budget: return Constants.Colors.accentColor
            case .loan: return Constants.Colors.softRed
            }
        }
        
        func localizedDisplayName(_ contentManager: MultilingualContentManager) -> String {
            switch self {
            case .transaction: return contentManager.localizedString("transactions.title")
            case .budget: return contentManager.localizedString("budget.title")
            case .loan: return contentManager.localizedString("tab.loans")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.UI.Spacing.large) {
                    // Type Selector
                    VStack(spacing: Constants.UI.Spacing.medium) {
                        Text(contentManager.localizedString("add.title"))
                            .font(Constants.Typography.H3.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Picker("Type", selection: $selectedType) {
                            ForEach(AddType.allCases, id: \.self) { type in
                                Text(type.localizedDisplayName(contentManager))
                                    .font(Constants.Typography.Body.font)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .background(
                            RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                                .fill(Constants.Colors.textPrimary.opacity(0.05))
                        )
                    }
                    .padding(.horizontal, Constants.UI.Padding.screenMargin)
                    .padding(.top, Constants.UI.Spacing.medium)
                    
                    // Form Content
                    VStack(spacing: Constants.UI.Spacing.large) {
                        switch selectedType {
                        case .transaction:
                            TransactionForm(transactionViewModel: transactionViewModel)
                        case .budget:
                            BudgetForm(budgetViewModel: budgetViewModel, budgetTransactionService: budgetTransactionService)
                        case .loan:
                            LoanForm(loanViewModel: loanViewModel)
                        }
                    }
                    .padding(.horizontal, Constants.UI.Padding.screenMargin)
                    .padding(.bottom, Constants.UI.Spacing.section)
                }
            }
            .navigationTitle(contentManager.localizedString("nav.add_new"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(contentManager.localizedString("button.done")) {
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                }
            }
        }
    }
}


// MARK: - Transaction Form
private struct TransactionForm: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var title = ""
    @State private var amount = ""
    @State private var category = "Food"
    @State private var date = Date()
    @State private var isExpense = true
    @State private var showingSuccess = false
    @State private var isSubmitting = false
    @State private var isRecurring = false
    @State private var recurringFrequency = "Monthly"
    @State private var weeklyDay = "Monday"
    @State private var monthlyDay = "Same Day"
    @State private var yearlyMonth = "January"
    @State private var yearlyDay = 1
    
    private var categories: [String] {
        [
            contentManager.localizedString("add.category.food"),
            contentManager.localizedString("add.category.transport"),
            contentManager.localizedString("add.category.shopping"),
            contentManager.localizedString("add.category.entertainment"),
            contentManager.localizedString("add.category.bills"),
            contentManager.localizedString("add.category.income"),
            contentManager.localizedString("add.category.other")
        ]
    }
    private var weekDays: [String] {
        [
            contentManager.localizedString("add.day.monday"),
            contentManager.localizedString("add.day.tuesday"),
            contentManager.localizedString("add.day.wednesday"),
            contentManager.localizedString("add.day.thursday"),
            contentManager.localizedString("add.day.friday"),
            contentManager.localizedString("add.day.saturday"),
            contentManager.localizedString("add.day.sunday")
        ]
    }
    private let monthlyOptions = ["Same Day", "1st", "15th", "Last Day"]
    private var months: [String] {
        [
            contentManager.localizedString("add.month.january"),
            contentManager.localizedString("add.month.february"),
            contentManager.localizedString("add.month.march"),
            contentManager.localizedString("add.month.april"),
            contentManager.localizedString("add.month.may"),
            contentManager.localizedString("add.month.june"),
            contentManager.localizedString("add.month.july"),
            contentManager.localizedString("add.month.august"),
            contentManager.localizedString("add.month.september"),
            contentManager.localizedString("add.month.october"),
            contentManager.localizedString("add.month.november"),
            contentManager.localizedString("add.month.december")
        ]
    }
    
    private var maxDayForSelectedMonth: Int {
        let monthIndex = months.firstIndex(of: yearlyMonth) ?? 0
        let daysInMonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        return daysInMonth[monthIndex]
    }
    
    private var validDays: [Int] {
        Array(1...maxDayForSelectedMonth)
    }
    
    private var isValid: Bool {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !amount.isEmpty,
              let amountValue = Double(amount),
              amountValue > 0 else {
            return false
        }
        return true
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Transaction Type Picker
            Picker("Transaction Type", selection: $isExpense) {
                Text(contentManager.localizedString("transaction.expense"))
                    .tag(true)
                Text(contentManager.localizedString("transaction.income"))
                    .tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(
                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                    .fill(Constants.Colors.textPrimary.opacity(0.05))
            )
            
            // Form Fields
            VStack(spacing: Constants.UI.Spacing.medium) {
                // Title
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    Text(contentManager.localizedString("form.title"))
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    TextField(contentManager.localizedString("add.placeholder.transaction_title"), text: $title)
                        .font(Constants.Typography.Body.font)
                        .padding(Constants.UI.Spacing.medium)
                        .background(Constants.Colors.textPrimary.opacity(0.05))
                        .cornerRadius(Constants.UI.CornerRadius.tertiary)
                }
                
                // Amount
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    Text(contentManager.localizedString("form.amount"))
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    HStack {
                        Text("$")
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                        
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(Constants.Typography.Body.font)
                    }
                    .padding(Constants.UI.Spacing.medium)
                    .background(Constants.Colors.textPrimary.opacity(0.05))
                    .cornerRadius(Constants.UI.CornerRadius.tertiary)
                }
                
                // Category
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    Text(contentManager.localizedString("form.category"))
                        .font(Constants.Typography.H3.font)
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
                                            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                                                .fill(category == cat ? Constants.Colors.cleanBlack : Constants.Colors.textPrimary.opacity(0.05))
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
                    Text(contentManager.localizedString("form.date"))
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    DatePicker("", selection: $date, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .accentColor(Constants.Colors.primaryBlue)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Recurring Toggle
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    HStack {
                        Text(contentManager.localizedString("transaction.recurring"))
                            .font(Constants.Typography.H3.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Spacer()
                        
                        Toggle("", isOn: $isRecurring)
                            .toggleStyle(SwitchToggleStyle(tint: Constants.Colors.primaryBlue))
                    }
                    
                    if isRecurring {
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
                            // Frequency Selection
                            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                                Text(contentManager.localizedString("transaction.frequency"))
                                    .font(Constants.Typography.Body.font)
                                    .foregroundColor(Constants.Colors.textSecondary)
                                
                                Picker("Frequency", selection: $recurringFrequency) {
                                    Text(contentManager.localizedString("frequency.daily")).tag("Daily")
                                    Text(contentManager.localizedString("frequency.weekly")).tag("Weekly")
                                    Text(contentManager.localizedString("frequency.monthly")).tag("Monthly")
                                    Text(contentManager.localizedString("frequency.yearly")).tag("Yearly")
                                }
                                .pickerStyle(.segmented)
                                .accentColor(Constants.Colors.primaryBlue)
                            }
                            
                            // Detailed Options based on Frequency
                            if recurringFrequency == "Weekly" {
                                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                                    Text(contentManager.localizedString("frequency.day_of_week"))
                                        .font(Constants.Typography.Body.font)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                    
                                    Picker(contentManager.localizedString("frequency.day_of_week"), selection: $weeklyDay) {
                                        ForEach(weekDays, id: \.self) { day in
                                            Text(day).tag(day)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .accentColor(Constants.Colors.primaryBlue)
                                }
                            } else if recurringFrequency == "Monthly" {
                                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                                    Text(contentManager.localizedString("frequency.day_of_month"))
                                        .font(Constants.Typography.Body.font)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                    
                                    Picker("Day of Month", selection: $monthlyDay) {
                                        ForEach(monthlyOptions, id: \.self) { option in
                                            Text(option).tag(option)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .accentColor(Constants.Colors.primaryBlue)
                                }
                            } else if recurringFrequency == "Yearly" {
                                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                                    Text(contentManager.localizedString("frequency.month"))
                                        .font(Constants.Typography.Body.font)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                    
                                    Picker("Month", selection: $yearlyMonth) {
                                        ForEach(months, id: \.self) { month in
                                            Text(month).tag(month)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .accentColor(Constants.Colors.primaryBlue)
                                    
                                    Text(contentManager.localizedString("frequency.day"))
                                        .font(Constants.Typography.Body.font)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                        .padding(.top, Constants.UI.Spacing.small)
                                    
                                    Picker("Day", selection: $yearlyDay) {
                                        ForEach(validDays, id: \.self) { day in
                                            Text("\(day)").tag(day)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .accentColor(Constants.Colors.primaryBlue)
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
                HStack {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text(showingSuccess ? contentManager.localizedString("add.success.transaction_added") : contentManager.localizedString("add.cta.add_transaction"))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background((isValid && !isSubmitting) ? Constants.Colors.cleanBlack : Constants.Colors.textTertiary)
                .cornerRadius(Constants.UI.cardCornerRadius)
            }
            .disabled(!isValid || isSubmitting)
            .animation(.easeInOut(duration: 0.2), value: isValid)
            .animation(.easeInOut(duration: 0.3), value: showingSuccess)
            
            if showingSuccess {
                Text(contentManager.localizedString("add.success.transaction_added"))
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.accentColor)
                    .transition(.opacity)
            }
        }
    }
    
    private func submitTransaction() {
        guard isValid && !isSubmitting else { return }
        
        isSubmitting = true
        
        HapticFeedbackManager.medium()
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingSuccess = false
                isSubmitting = false
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
    @ObservedObject var budgetTransactionService: BudgetTransactionService
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var category = "Food"
    @State private var amount = ""
    @State private var period = "Monthly"
    @State private var showingSuccess = false
    @State private var isSubmitting = false
    
    private var categories: [String] {
        [
            contentManager.localizedString("add.category.food"),
            contentManager.localizedString("add.category.transport"),
            contentManager.localizedString("add.category.shopping"),
            contentManager.localizedString("add.category.entertainment"),
            contentManager.localizedString("add.category.bills"),
            contentManager.localizedString("add.category.savings"),
            contentManager.localizedString("add.category.other")
        ]
    }
    private var periods: [String] {
        [
            contentManager.localizedString("add.period.weekly"),
            contentManager.localizedString("add.period.monthly"),
            contentManager.localizedString("add.period.yearly")
        ]
    }
    
    private var isValid: Bool {
        guard !amount.isEmpty,
              let amountValue = Double(amount),
              amountValue > 0 else {
            return false
        }
        return true
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Form Fields
            VStack(spacing: Constants.UI.Spacing.medium) {
                // Category
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    Text(contentManager.localizedString("form.category"))
                        .font(Constants.Typography.H3.font)
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
                                            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                                                .fill(category == cat ? Constants.Colors.cleanBlack : Constants.Colors.textPrimary.opacity(0.05))
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
                    Text(contentManager.localizedString("form.budget_amount"))
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    HStack {
                        Text("$")
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                        
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(Constants.Typography.Body.font)
                    }
                    .padding(Constants.UI.Spacing.medium)
                    .background(Constants.Colors.textPrimary.opacity(0.05))
                    .cornerRadius(Constants.UI.CornerRadius.tertiary)
                }
                
                // Period
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    Text(contentManager.localizedString("form.period"))
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Picker("Period", selection: $period) {
                        ForEach(periods, id: \.self) { period in
                            Text(period).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accentColor(Constants.Colors.primaryBlue)
                }
            }
            
            // Submit Button
            Button(action: submitBudget) {
                HStack {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text(showingSuccess ? contentManager.localizedString("add.success.budget_created") : contentManager.localizedString("add.cta.create_budget"))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background((isValid && !isSubmitting) ? Constants.Colors.cleanBlack : Constants.Colors.textTertiary)
                .cornerRadius(Constants.UI.cardCornerRadius)
            }
            .disabled(!isValid || isSubmitting)
            .animation(.easeInOut(duration: 0.2), value: isValid)
            .animation(.easeInOut(duration: 0.3), value: showingSuccess)
            
            if showingSuccess {
                Text(contentManager.localizedString("add.success.budget_created"))
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.accentColor)
                    .transition(.opacity)
            }
        }
    }
    
    private func submitBudget() {
        guard isValid && !isSubmitting else { return }
        
        isSubmitting = true
        
        HapticFeedbackManager.medium()
        
        // Map period string to BudgetPeriodType
        let periodType: BudgetPeriodType = {
            switch period {
            case contentManager.localizedString("add.period.weekly"): return .weekly
            case contentManager.localizedString("add.period.yearly"): return .yearly
            default: return .monthly
            }
        }()
        
        // Create budget with historical transaction calculation
        let allocatedAmount = Double(amount) ?? 0.0
        let newBudget = budgetTransactionService.createBudgetWithHistoricalData(
            category: category,
            allocatedAmount: allocatedAmount,
            periodType: periodType
        )
        
        budgetViewModel.addBudget(newBudget)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showingSuccess = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingSuccess = false
                isSubmitting = false
                amount = ""
                // Dismiss the view
                dismiss()
            }
        }
        
        // Budget successfully added to view model
    }
}

// MARK: - Loan Form
private struct LoanForm: View {
    @ObservedObject var loanViewModel: LoanViewModel
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var loanAction: LoanAction = .addNew
    @State private var name = ""
    @State private var principal = ""
    @State private var interestRate = ""
    @State private var monthlyPayment = ""
    @State private var loanTerm = "30" // Default to 30 years
    @State private var dueDate = 1
    @State private var category = LoanCategory.personal
    @State private var paymentStatus = LoanPaymentStatus.current
    @State private var lastPaymentDate = Date()
    @State private var nextPaymentDueDate = Date()
    @State private var showingSuccess = false
    @State private var isSubmitting = false
    @State private var selectedLoan: Loan?
    @State private var availableLoans: [Loan] = []
    
    private let categories = LoanCategory.allCases
    
    enum LoanAction: String, CaseIterable {
        case addNew = "add_new_loan"
        case markPaid = "mark_loan_paid"
        
        func localizedDisplayName(_ contentManager: MultilingualContentManager) -> String {
            switch self {
            case .addNew: return contentManager.localizedString("add.action.add_new_loan")
            case .markPaid: return contentManager.localizedString("add.action.mark_loan_paid")
            }
        }
        
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
    
    private var calculatedMonthlyPayment: String {
        guard let principalAmount = Double(principal),
              let interestRateValue = Double(interestRate),
              let termYears = Int(loanTerm),
              principalAmount > 0,
              interestRateValue >= 0,
              termYears > 0 else {
            return "0.00"
        }
        
        let monthlyRate = interestRateValue / 100 / 12
        let numberOfPayments = termYears * 12
        
        if monthlyRate == 0 {
            // No interest case
            return String(format: "%.2f", principalAmount / Double(numberOfPayments))
        } else {
            // Standard loan calculation
            let monthlyPayment = principalAmount * (monthlyRate * pow(1 + monthlyRate, Double(numberOfPayments))) / (pow(1 + monthlyRate, Double(numberOfPayments)) - 1)
            return String(format: "%.2f", monthlyPayment)
        }
    }
    
    private var isValid: Bool {
        switch loanAction {
        case .addNew:
            guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !principal.isEmpty,
                  !interestRate.isEmpty,
                  !loanTerm.isEmpty,
                  let principalValue = Double(principal),
                  let interestRateValue = Double(interestRate),
                  let termYears = Int(loanTerm),
                  principalValue > 0,
                  interestRateValue >= 0,
                  termYears > 0 else {
                return false
            }
            return true
        case .markPaid:
            return selectedLoan != nil
        }
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Action Selector
            Picker("Loan Action", selection: $loanAction) {
                ForEach(LoanAction.allCases, id: \.self) { action in
                    Text(action.localizedDisplayName(contentManager))
                        .font(Constants.Typography.Body.font)
                        .tag(action)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .background(
                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                    .fill(Constants.Colors.textPrimary.opacity(0.05))
            )
            .onChange(of: loanAction) {
                selectedLoan = nil // Reset selection when switching actions
            }
            
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
    
    // MARK: - Helper Functions
    private func calculateMonthlyPayment() {
        // This function is called by onChange modifiers
        // The calculatedMonthlyPayment computed property handles the actual calculation
    }
    
    private func calculateNextPaymentDate() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        // Get the current month and year
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        // Create a date for the due day in the current month
        var nextPaymentDate = calendar.date(from: DateComponents(year: currentYear, month: currentMonth, day: dueDate)) ?? now
        
        // If the due date has already passed this month, move to next month
        if nextPaymentDate <= now {
            nextPaymentDate = calendar.date(byAdding: .month, value: 1, to: nextPaymentDate) ?? now
        }
        
        return nextPaymentDate
    }
    
    // MARK: - Add New Loan Form
    private var addNewLoanForm: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            // Loan Name
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text(contentManager.localizedString("form.loan_name"))
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                TextField(contentManager.localizedString("add.placeholder.loan_name"), text: $name)
                    .font(Constants.Typography.Body.font)
                    .padding(Constants.UI.Spacing.medium)
                    .background(Constants.Colors.textPrimary.opacity(0.05))
                    .cornerRadius(Constants.UI.CornerRadius.tertiary)
            }
            
            // Category
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text(contentManager.localizedString("form.category"))
                    .font(Constants.Typography.H3.font)
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
                                        RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                                            .fill(category == cat ? Constants.Colors.cleanBlack : Constants.Colors.textPrimary.opacity(0.05))
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
                Text(contentManager.localizedString("form.principal_amount"))
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                HStack {
                    Text("$")
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    TextField("0.00", text: $principal)
                        .keyboardType(.decimalPad)
                        .font(Constants.Typography.Body.font)
                        .onChange(of: principal) { _, _ in
                            calculateMonthlyPayment()
                        }
                }
                .padding(Constants.UI.Spacing.medium)
                .background(Constants.Colors.textPrimary.opacity(0.05))
                .cornerRadius(Constants.UI.CornerRadius.tertiary)
            }
            
            // Interest Rate
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text(contentManager.localizedString("form.interest_rate"))
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                HStack {
                    TextField("0.0", text: $interestRate)
                        .keyboardType(.decimalPad)
                        .font(Constants.Typography.Body.font)
                        .onChange(of: interestRate) { _, _ in
                            calculateMonthlyPayment()
                        }
                    
                    Text("%")
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                .padding(Constants.UI.Spacing.medium)
                .background(Constants.Colors.textPrimary.opacity(0.05))
                .cornerRadius(Constants.UI.CornerRadius.tertiary)
            }
            
            // Loan Term (Years)
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text(contentManager.localizedString("form.loan_term"))
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                HStack {
                    TextField("30", text: $loanTerm)
                        .keyboardType(.numberPad)
                        .font(Constants.Typography.Body.font)
                        .onChange(of: loanTerm) { _, _ in
                            calculateMonthlyPayment()
                        }
                    
                    Text(contentManager.localizedString("frequency.years"))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                .padding(Constants.UI.Spacing.medium)
                .background(Constants.Colors.textPrimary.opacity(0.05))
                .cornerRadius(Constants.UI.CornerRadius.tertiary)
            }
            
            // Calculated Monthly Payment (Read-only)
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text(contentManager.localizedString("form.monthly_payment"))
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                HStack {
                    Text("$")
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(calculatedMonthlyPayment)
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(Constants.UI.Spacing.medium)
                .background(Constants.Colors.textPrimary.opacity(0.05))
                .cornerRadius(Constants.UI.CornerRadius.tertiary)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                        .stroke(Constants.Colors.primaryOrange, lineWidth: 1)
                )
            }
            
            // Due Date
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                Text(contentManager.localizedString("form.payment_due_day"))
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Text(contentManager.localizedString("loan.payment_due_description"))
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
            
            // Submit Button
            Button(action: submitLoan) {
                HStack {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    
                    Text(showingSuccess ? (loanAction == .addNew ? contentManager.localizedString("add.success.loan_added") : contentManager.localizedString("add.success.payment_marked")) : (loanAction == .addNew ? contentManager.localizedString("add.cta.add_loan") : contentManager.localizedString("add.cta.mark_as_paid")))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background((isValid && !isSubmitting) ? Constants.Colors.cleanBlack : Constants.Colors.textTertiary)
                .cornerRadius(Constants.UI.cardCornerRadius)
            }
            .disabled(!isValid || isSubmitting)
            .animation(.easeInOut(duration: 0.2), value: isValid)
            .animation(.easeInOut(duration: 0.3), value: showingSuccess)
            
            if showingSuccess {
                Text(loanAction == .addNew ? contentManager.localizedString("add.success.loan_added") : contentManager.localizedString("add.success.payment_marked"))
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.accentColor)
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
                        .font(Constants.Typography.H1.font)
                        .foregroundColor(Constants.Colors.success)
                    
                    Text(contentManager.localizedString("loan.all_paid"))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(contentManager.localizedString("loan.no_unpaid"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(Constants.UI.Spacing.large)
            } else {
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    Text(contentManager.localizedString("loan.select_to_pay"))
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Text(contentManager.localizedString("loan.choose_to_pay"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                LoanPickerView(loans: availableLoans, selectedLoan: $selectedLoan)
                    .frame(maxHeight: 300)
                
                // Submit Button for Mark Paid
                Button(action: submitLoan) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        
                        Text(showingSuccess ? contentManager.localizedString("add.success.payment_marked") : contentManager.localizedString("add.cta.mark_as_paid"))
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Constants.UI.Spacing.medium)
                    .background((isValid && !isSubmitting) ? Constants.Colors.cleanBlack : Constants.Colors.textTertiary)
                    .cornerRadius(Constants.UI.CornerRadius.tertiary)
                }
                .disabled(!isValid || isSubmitting)
                .animation(.easeInOut(duration: 0.2), value: isValid)
                .animation(.easeInOut(duration: 0.3), value: showingSuccess)
                
                if showingSuccess {
                    Text(contentManager.localizedString("success.payment_marked"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.accentColor)
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
        guard isValid && !isSubmitting else { return }
        
        isSubmitting = true
        
        HapticFeedbackManager.medium()
        
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
                monthlyPayment: Double(calculatedMonthlyPayment) ?? 0.0,
                dueDay: dueDate,
                category: category,
                paymentStatus: .current, // New loans start as current
                lastPaymentDate: Date(), // Set to current date for new loans
                nextPaymentDueDate: calculateNextPaymentDate()
            )
            // Loan successfully added to view model
        case .markPaid:
            if let loan = selectedLoan {
                // Mark the loan as paid in the view model
                loanViewModel.markLoanAsPaid(loan)
                // Loan successfully marked as paid
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingSuccess = false
                isSubmitting = false
                if loanAction == .addNew {
                    name = ""
                    principal = ""
                    interestRate = ""
                    loanTerm = "30"
                    dueDate = 1
                    category = .personal
                } else {
                    selectedLoan = nil
                }
                // Dismiss the view
                dismiss()
            }
        }
    }
}

#Preview {
    AddView(loanViewModel: LoanViewModel(), budgetViewModel: BudgetViewModel(), transactionViewModel: TransactionViewModel(), budgetTransactionService: BudgetTransactionService())
}