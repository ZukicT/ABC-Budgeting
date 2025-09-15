//
//  AddTransactionView.swift
//  ABC Budgeting
//
//  Created by Development Team on 2025-01-09.
//  Copyright © 2025 ABC Budgeting. All rights reserved.
//

import SwiftUI
import Foundation

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var title: String = ""
    @State private var category: TransactionCategoryType = .essentials
    @State private var description: String = ""
    @State private var isIncome: Bool = false
    @State private var date: Date = Date()
    @State private var isRecurring: Bool = false
    @State private var recurringFrequency: RecurringFrequency = .monthly
    @State private var showSuggestions: Bool = false
    @State private var selectedSuggestion: String = ""
    @State private var isAnimating: Bool = false
    
    var onSave: (Double, String, String?, Bool) -> Void
    
    // Smart suggestions based on category
    private var smartSuggestions: [String] {
        switch category {
        case .essentials:
            return ["Groceries", "Rent", "Utilities", "Gas", "Insurance", "Food"]
        case .leisure:
            return ["Netflix", "Spotify", "Movies", "Games", "Dining Out", "Entertainment"]
        case .savings:
            return ["Emergency Fund", "Vacation", "Investment", "Retirement", "Goal", "Savings"]
        case .income:
            return ["Salary", "Freelance", "Investment", "Bonus", "Refund", "Cashback"]
        case .bills:
            return ["Electric Bill", "Water Bill", "Internet", "Phone", "Insurance", "Rent"]
        case .other:
            return ["Miscellaneous", "Transfer", "Refund", "Cash", "Other", "Unknown"]
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                RobinhoodColors.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Professional header section
                        headerSection
                        
                        // Transaction type selection with enhanced design
                        transactionTypeSection
                    
                        // Form fields with modern spacing
                        VStack(spacing: 24) {
                            // Amount input with enhanced styling
                            amountInputSection
                            
                            // Title input with smart suggestions
                            titleInputSection
                            
                            // Category selection with improved grid
                            categorySelectionSection
                            
                            // Recurring transaction toggle
                            recurringSection
                            
                            // Description with character count
                            descriptionSection
                            
                            // Date with smart defaults
                            dateSection
                        }
                        
                        // Enhanced save button with validation
                        saveButtonSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            dismiss()
                        }
                    }
                    .foregroundColor(RobinhoodColors.primary)
                    .font(RobinhoodTypography.callout)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("New Transaction")
                        .font(RobinhoodTypography.title3)
                        .foregroundColor(RobinhoodColors.textPrimary)
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                isAnimating = true
            }
        }
    }
    
    // MARK: - Professional Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Add Transaction")
                        .font(RobinhoodTypography.title1)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Text("Track your financial activity")
                        .font(RobinhoodTypography.subheadline)
                        .foregroundColor(RobinhoodColors.textSecondary)
                }
                
                Spacer()
                
                // Quick amount preview
                if !amount.isEmpty, let amountValue = Double(amount) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(amountValue.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                            .font(RobinhoodTypography.title2)
                            .foregroundColor(isIncome ? RobinhoodColors.success : RobinhoodColors.error)
                        
                        Text(isIncome ? "Income" : "Expense")
                            .font(RobinhoodTypography.caption)
                            .foregroundColor(RobinhoodColors.textSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isIncome ? RobinhoodColors.success.opacity(0.1) : RobinhoodColors.error.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isIncome ? RobinhoodColors.success.opacity(0.3) : RobinhoodColors.error.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : -20)
        .animation(.easeOut(duration: 0.6).delay(0.1), value: isAnimating)
    }
    
    // MARK: - Enhanced Transaction Type Selection
    private var transactionTypeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Transaction Type")
                .font(RobinhoodTypography.headline)
                .foregroundColor(RobinhoodColors.textPrimary)
            
            HStack(spacing: 16) {
                // Income button with enhanced styling
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isIncome = true
                    }
                }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(isIncome ? RobinhoodColors.success : RobinhoodColors.success.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(isIncome ? .white : RobinhoodColors.success)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Income")
                                .font(RobinhoodTypography.headline)
                                .foregroundColor(isIncome ? .white : RobinhoodColors.textPrimary)
                            
                            Text("Money in")
                                .font(RobinhoodTypography.caption)
                                .foregroundColor(isIncome ? .white.opacity(0.8) : RobinhoodColors.textSecondary)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isIncome ? RobinhoodColors.success : RobinhoodColors.cardBackground)
                            .shadow(color: isIncome ? RobinhoodColors.success.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isIncome ? RobinhoodColors.success : RobinhoodColors.border, lineWidth: isIncome ? 2 : 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add income transaction")
                .scaleEffect(isIncome ? 1.02 : 1.0)
                
                // Expense button with enhanced styling
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isIncome = false
                    }
                }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(!isIncome ? RobinhoodColors.error : RobinhoodColors.error.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(!isIncome ? .white : RobinhoodColors.error)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Expense")
                                .font(RobinhoodTypography.headline)
                                .foregroundColor(!isIncome ? .white : RobinhoodColors.textPrimary)
                            
                            Text("Money out")
                                .font(RobinhoodTypography.caption)
                                .foregroundColor(!isIncome ? .white.opacity(0.8) : RobinhoodColors.textSecondary)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(!isIncome ? RobinhoodColors.error : RobinhoodColors.cardBackground)
                            .shadow(color: !isIncome ? RobinhoodColors.error.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(!isIncome ? RobinhoodColors.error : RobinhoodColors.border, lineWidth: !isIncome ? 2 : 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add expense transaction")
                .scaleEffect(!isIncome ? 1.02 : 1.0)
            }
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)
    }
    
    // MARK: - Enhanced Amount Input
    private var amountInputSection: some View {
        let preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD (US Dollar)"
        let currencyCode = preferredCurrency.components(separatedBy: " ").first ?? "USD"
        
        // Get currency symbol from the currency code
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        let currencySymbol = formatter.currencySymbol ?? "$"
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Amount")
                    .font(RobinhoodTypography.headline)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                Spacer()
                
                // Quick amount suggestions
                if amount.isEmpty {
                    HStack(spacing: 8) {
                        ForEach([10, 25, 50, 100], id: \.self) { suggestion in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    amount = String(suggestion)
                                }
                            }) {
                                Text("\(currencySymbol)\(suggestion)")
                                    .font(RobinhoodTypography.caption)
                                    .foregroundColor(RobinhoodColors.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(RobinhoodColors.primary.opacity(0.1))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            HStack(spacing: 16) {
                // Currency symbol with enhanced styling
                ZStack {
                    Circle()
                        .fill(isIncome ? RobinhoodColors.success.opacity(0.1) : RobinhoodColors.error.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Text(currencySymbol)
                        .font(RobinhoodTypography.title1)
                        .foregroundColor(isIncome ? RobinhoodColors.success : RobinhoodColors.error)
                        .fontWeight(.bold)
                }
                
                // Amount input field
                VStack(alignment: .leading, spacing: 4) {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(RobinhoodTypography.largeTitle)
                        .foregroundColor(RobinhoodColors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .onChange(of: amount) { _, newValue in
                            // Format the amount as user types
                            let filtered = newValue.filter { "0123456789.".contains($0) }
                            if filtered != newValue {
                                amount = filtered
                            }
                        }
                    
                    if !amount.isEmpty, let amountValue = Double(amount) {
                        Text(amountValue.formatted(.currency(code: currencyCode).precision(.fractionLength(2))))
                            .font(RobinhoodTypography.caption)
                            .foregroundColor(RobinhoodColors.textSecondary)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(RobinhoodColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isIncome ? RobinhoodColors.success.opacity(0.3) : RobinhoodColors.error.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .animation(.easeOut(duration: 0.6).delay(0.3), value: isAnimating)
    }
    
    // MARK: - Enhanced Title Input with Smart Suggestions
    private var titleInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Title")
                    .font(RobinhoodTypography.headline)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                Spacer()
                
                if !title.isEmpty {
                    Text("\(title.count)/50")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                }
            }
            
            VStack(spacing: 12) {
                TextField("e.g. Coffee, Rent, Salary", text: $title)
                    .font(RobinhoodTypography.body)
                    .foregroundColor(RobinhoodColors.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(RobinhoodColors.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(RobinhoodColors.border, lineWidth: 1)
                            )
                    )
                    .onChange(of: title) { _, newValue in
                        if newValue.count > 50 {
                            title = String(newValue.prefix(50))
                        }
                    }
                
                // Smart suggestions
                if title.isEmpty || showSuggestions {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Suggestions")
                            .font(RobinhoodTypography.caption)
                            .foregroundColor(RobinhoodColors.textSecondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                            ForEach(smartSuggestions.prefix(6), id: \.self) { suggestion in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        title = suggestion
                                        showSuggestions = false
                                    }
                                }) {
                                    Text(suggestion)
                                        .font(RobinhoodTypography.caption)
                                        .foregroundColor(RobinhoodColors.primary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(RobinhoodColors.primary.opacity(0.1))
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .opacity(showSuggestions ? 1 : 0.7)
                    .animation(.easeInOut(duration: 0.3), value: showSuggestions)
                }
            }
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)
    }
    
    // MARK: - Enhanced Category Selection
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category")
                .font(RobinhoodTypography.headline)
                .foregroundColor(RobinhoodColors.textPrimary)
            
            categoryGrid
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .animation(.easeOut(duration: 0.6).delay(0.5), value: isAnimating)
    }
    
    // MARK: - Recurring Transaction Section
    private var recurringSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recurring Transaction")
                    .font(RobinhoodTypography.headline)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                Spacer()
                
                Toggle("", isOn: $isRecurring)
                    .toggleStyle(SwitchToggleStyle(tint: RobinhoodColors.primary))
            }
            
            if isRecurring {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Frequency")
                        .font(RobinhoodTypography.callout)
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    Picker("Frequency", selection: $recurringFrequency) {
                        ForEach(RecurringFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue.capitalized)
                                .tag(frequency)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(RobinhoodColors.cardBackground)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(RobinhoodColors.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(RobinhoodColors.border, lineWidth: 1)
                        )
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .animation(.easeOut(duration: 0.6).delay(0.6), value: isAnimating)
    }
    
    private var categoryGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            ForEach(TransactionCategoryType.allCases) { cat in
                categoryButton(for: cat)
            }
        }
    }
    
    private func categoryButton(for cat: TransactionCategoryType) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                category = cat
            }
        }) {
            categoryButtonContent(for: cat)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(cat.label)
        .accessibilityAddTraits(category == cat ? .isSelected : .isButton)
        .scaleEffect(category == cat ? 1.05 : 1.0)
    }
    
    private func categoryButtonContent(for cat: TransactionCategoryType) -> some View {
        VStack(spacing: 10) {
            categoryIcon(for: cat)
            categoryLabel(for: cat)
        }
        .frame(height: 90)
        .frame(maxWidth: .infinity)
        .background(categoryButtonBackground(for: cat))
    }
    
    private func categoryIcon(for cat: TransactionCategoryType) -> some View {
        ZStack {
            Circle()
                .fill(category == cat ? cat.color : cat.color.opacity(0.2))
                .frame(width: 44, height: 44)
                .shadow(color: category == cat ? cat.color.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
            
            Image(systemName: cat.symbol)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(category == cat ? .white : cat.color)
        }
    }
    
    private func categoryLabel(for cat: TransactionCategoryType) -> some View {
        Text(cat.label)
            .font(RobinhoodTypography.caption)
            .fontWeight(.medium)
            .foregroundColor(category == cat ? cat.color : RobinhoodColors.textPrimary)
            .lineLimit(1)
            .multilineTextAlignment(.center)
    }
    
    private func categoryButtonBackground(for cat: TransactionCategoryType) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(category == cat ? cat.color.opacity(0.15) : RobinhoodColors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(category == cat ? cat.color.opacity(0.5) : RobinhoodColors.border, lineWidth: category == cat ? 2 : 1)
            )
    }
    
    // MARK: - Enhanced Description
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Description (Optional)")
                    .font(RobinhoodTypography.headline)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                Spacer()
                
                if !description.isEmpty {
                    Text("\(description.count)/200")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                }
            }
            
            TextField("Add a description...", text: $description, axis: .vertical)
                .font(RobinhoodTypography.body)
                .foregroundColor(RobinhoodColors.textPrimary)
                .lineLimit(3...6)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(RobinhoodColors.cardBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(RobinhoodColors.border, lineWidth: 1)
                        )
                )
                .onChange(of: description) { _, newValue in
                    if newValue.count > 200 {
                        description = String(newValue.prefix(200))
                    }
                }
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .animation(.easeOut(duration: 0.6).delay(0.7), value: isAnimating)
    }
    
    // MARK: - Enhanced Date
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Date")
                .font(RobinhoodTypography.headline)
                .foregroundColor(RobinhoodColors.textPrimary)
            
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(RobinhoodColors.primary)
                
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .accentColor(RobinhoodColors.primary)
                
                Spacer()
                
                // Quick date buttons
                HStack(spacing: 8) {
                    Button("Today") {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            date = Date()
                        }
                    }
                    .font(RobinhoodTypography.caption)
                    .foregroundColor(RobinhoodColors.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(RobinhoodColors.primary.opacity(0.1))
                    )
                    .buttonStyle(.plain)
                    
                    Button("Yesterday") {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                        }
                    }
                    .font(RobinhoodTypography.caption)
                    .foregroundColor(RobinhoodColors.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(RobinhoodColors.primary.opacity(0.1))
                    )
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(RobinhoodColors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(RobinhoodColors.border, lineWidth: 1)
                    )
            )
        }
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .animation(.easeOut(duration: 0.6).delay(0.8), value: isAnimating)
    }
    
    // MARK: - Enhanced Save Button
    private var saveButtonSection: some View {
        VStack(spacing: 16) {
            Button(action: save) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(RobinhoodColors.primary)
                    }
                    
                    Text("Save Transaction")
                        .font(RobinhoodTypography.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    if !amount.isEmpty, let amountValue = Double(amount) {
                        Text(amountValue.formatted(.currency(code: "USD").precision(.fractionLength(0))))
                            .font(RobinhoodTypography.callout)
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isFormValid ? RobinhoodColors.primary : RobinhoodColors.textTertiary)
                        .shadow(color: isFormValid ? RobinhoodColors.primary.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                )
                .foregroundColor(.white)
            }
            .disabled(!isFormValid)
            .scaleEffect(isFormValid ? 1.0 : 0.98)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isFormValid)
            
            if !isFormValid {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(RobinhoodColors.warning)
                        
                        Text("Please complete the required fields")
                            .font(RobinhoodTypography.caption)
                            .foregroundColor(RobinhoodColors.warning)
                    }
                    
                    VStack(spacing: 4) {
                        if title.isEmpty {
                            Text("• Enter a title for the transaction")
                                .font(RobinhoodTypography.caption2)
                                .foregroundColor(RobinhoodColors.textSecondary)
                        }
                        if amount.isEmpty {
                            Text("• Enter an amount")
                                .font(RobinhoodTypography.caption2)
                                .foregroundColor(RobinhoodColors.textSecondary)
                        } else if Double(amount) == nil {
                            Text("• Enter a valid amount")
                                .font(RobinhoodTypography.caption2)
                                .foregroundColor(RobinhoodColors.textSecondary)
                        }
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(RobinhoodColors.warning.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(RobinhoodColors.warning.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .padding(.top, 8)
        .opacity(isAnimating ? 1 : 0)
        .offset(y: isAnimating ? 0 : 20)
        .animation(.easeOut(duration: 0.6).delay(0.9), value: isAnimating)
    }
    
    // MARK: - Form Validation
    private var isFormValid: Bool {
        !title.isEmpty && !amount.isEmpty && Double(amount) != nil
    }
    
    // MARK: - Helper Functions
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func save() {
        guard let amountValue = Double(amount) else { return }
        
        onSave(
            amountValue,
            category.rawValue,
            description.isEmpty ? nil : description,
            isIncome
        )
        dismiss()
    }
}

