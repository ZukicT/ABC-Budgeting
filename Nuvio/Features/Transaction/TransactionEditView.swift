//
//  TransactionEditView.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Comprehensive edit view for modifying individual transactions with form
//  validation, real-time feedback, and performance optimizations. Features
//  haptic feedback, loading states, and accessibility compliance.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct TransactionEditView: View {
    @Binding var transaction: Transaction
    @Environment(\.dismiss) var dismiss
    @State private var title: String
    @State private var amount: String
    @State private var selectedDate: Date
    @State private var selectedCategory: String
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    private let categories = ["Food", "Transport", "Shopping", "Entertainment", "Bills", "Income", "Other"]
    
    // MARK: - Performance Optimized Properties
    private var isIncome: Bool {
        transaction.amount >= 0
    }
    
    private var isValidTitle: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isValidAmount: Bool {
        guard let amountValue = Double(amount) else { return false }
        return amountValue > 0
    }
    
    private var canSave: Bool {
        isValidTitle && isValidAmount
    }
    
    init(transaction: Binding<Transaction>) {
        self._transaction = transaction
        self._title = State(initialValue: transaction.wrappedValue.title)
        self._amount = State(initialValue: String(abs(transaction.wrappedValue.amount)))
        self._selectedDate = State(initialValue: transaction.wrappedValue.date)
        self._selectedCategory = State(initialValue: transaction.wrappedValue.category)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section - Compact layout
            VStack(spacing: 16) {
                // Top Row: Title + Close Button
                HStack {
                    Text(contentManager.localizedString("transaction.edit_title"))
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .accessibilityLabel(contentManager.localizedString("transaction.edit_title"))
                        .accessibilityAddTraits(.isHeader)
                    
                    Spacer()
                    
                    // Close Button
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(Constants.Typography.Caption.font)
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
                    // Title Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text(contentManager.localizedString("form.title_label"))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        TextField("Enter transaction title", text: $title)
                            .font(Constants.Typography.Mono.Body.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Constants.Colors.textPrimary.opacity(0.05))
                            .cornerRadius(Constants.UI.CornerRadius.secondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.secondary)
                                    .stroke(!isValidTitle ? 
                                           Constants.Colors.error.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                            .accessibilityLabel("Transaction title")
                            .accessibilityHint("Enter the name or description of this transaction")
                    }
                    
                    // Amount Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text(contentManager.localizedString("form.amount_label"))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        HStack {
                            Text("$")
                                .font(Constants.Typography.Mono.Body.font)
                                .foregroundColor(Constants.Colors.textSecondary)
                            
                            TextField("0.00", text: $amount)
                                .font(Constants.Typography.Mono.Body.font)
                                .foregroundColor(Constants.Colors.textPrimary)
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Constants.Colors.textPrimary.opacity(0.05))
                        .cornerRadius(Constants.UI.CornerRadius.secondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.secondary)
                                .stroke(!isValidAmount ? 
                                       Constants.Colors.error.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Transaction amount")
                        .accessibilityHint("Enter the dollar amount for this transaction")
                    }
                    
                    // Transaction Type Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text(contentManager.localizedString("form.type_label"))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                // Haptic feedback
                                HapticFeedbackManager.light()
                                
                                // Set as income (positive) - update transaction amount
                                if let currentAmount = Double(amount) {
                                    amount = String(currentAmount)
                                    // Update the transaction to be positive
                                    transaction = Transaction(
                                        id: transaction.id,
                                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                        amount: currentAmount,
                                        date: selectedDate,
                                        category: selectedCategory
                                    )
                                }
                            }) {
                                Text(contentManager.localizedString("form.income_type"))
                                    .font(Constants.Typography.Caption.font)
                                    .foregroundColor(isIncome ? .white : Constants.Colors.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isIncome ? Constants.Colors.success : Constants.Colors.textPrimary.opacity(0.05))
                                    .cornerRadius(Constants.UI.CornerRadius.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityLabel("Income")
                            .accessibilityHint("Mark this transaction as income")
                            .accessibilityAddTraits(isIncome ? .isSelected : [])
                            
                            Button(action: {
                                // Haptic feedback
                                HapticFeedbackManager.light()
                                
                                // Set as expense (negative) - update transaction amount
                                if let currentAmount = Double(amount) {
                                    amount = String(currentAmount)
                                    // Update the transaction to be negative
                                    transaction = Transaction(
                                        id: transaction.id,
                                        title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                        amount: -currentAmount,
                                        date: selectedDate,
                                        category: selectedCategory
                                    )
                                }
                            }) {
                                Text(contentManager.localizedString("form.expense_type"))
                                    .font(Constants.Typography.Caption.font)
                                    .foregroundColor(!isIncome ? .white : Constants.Colors.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(!isIncome ? Constants.Colors.error : Constants.Colors.textPrimary.opacity(0.05))
                                    .cornerRadius(Constants.UI.CornerRadius.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityLabel("Expense")
                            .accessibilityHint("Mark this transaction as an expense")
                            .accessibilityAddTraits(!isIncome ? .isSelected : [])
                        }
                    }
                    
                    // Date Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text(contentManager.localizedString("form.date_label"))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Category Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text(contentManager.localizedString("form.category_label"))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(categories, id: \.self) { category in
                                HStack {
                                    CategoryIcon(category: category, size: 20)
                                    Text(category)
                                        .font(Constants.Typography.Mono.Body.font)
                                }
                                .tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                    HapticFeedbackManager.medium()
                    
                    saveTransaction()
                }) {
                    HStack(spacing: 8) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "checkmark")
                                .font(Constants.Typography.Caption.font)
                        }
                        Text(isSaving ? "Saving..." : "Save")
                            .font(Constants.Typography.Caption.font)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Constants.Colors.cleanBlack)
                    .cornerRadius(Constants.UI.CornerRadius.secondary)
                }
                .disabled(isSaving || !canSave)
                .accessibilityLabel(isSaving ? "Saving transaction changes" : "Save transaction changes")
                .accessibilityHint("Double tap to save your changes to this transaction")
                
                // Cancel Button - Secondary action
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                            .font(Constants.Typography.Caption.font)
                        Text(contentManager.localizedString("button.cancel"))
                            .font(Constants.Typography.Caption.font)
                    }
                    .foregroundColor(Constants.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Constants.Colors.textPrimary.opacity(0.05))
                    .cornerRadius(Constants.UI.CornerRadius.secondary)
                }
                .accessibilityLabel("Cancel editing")
                .accessibilityHint("Double tap to discard changes and return to transaction details")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .alert(contentManager.localizedString("alert.validation_error"), isPresented: $showingErrorAlert) {
            Button(contentManager.localizedString("button.ok")) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveTransaction() {
        // Set loading state
        isSaving = true
        
        // Validate input
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a transaction title."
            showingErrorAlert = true
            isSaving = false
            return
        }
        
        guard let amountValue = Double(amount), amountValue > 0 else {
            errorMessage = "Please enter a valid amount greater than 0."
            showingErrorAlert = true
            isSaving = false
            return
        }
        
        guard !selectedCategory.isEmpty else {
            errorMessage = "Please select a category."
            showingErrorAlert = true
            isSaving = false
            return
        }
        
        // Determine if it's income or expense based on current transaction
        let finalAmount = transaction.amount >= 0 ? amountValue : -amountValue
        
        // Simulate save delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            transaction = Transaction(
                id: transaction.id,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                amount: finalAmount,
                date: selectedDate,
                category: selectedCategory
            )
            
            isSaving = false
            dismiss()
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