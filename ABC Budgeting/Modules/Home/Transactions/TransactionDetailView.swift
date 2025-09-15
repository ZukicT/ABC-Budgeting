//
//  TransactionDetailView.swift
//  ABC Budgeting
//
//  Created by Development Team on 2025-01-09.
//  Copyright © 2025 ABC Budgeting. All rights reserved.
//

import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    var onSave: (Transaction) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedAmount: String
    @State private var editedCategory: TransactionCategoryType
    @State private var editedDescription: String
    @State private var editedDate: Date
    @State private var editedIsIncome: Bool
    
    init(transaction: Transaction, onSave: @escaping (Transaction) -> Void) {
        self.transaction = transaction
        self.onSave = onSave
        _editedTitle = State(initialValue: transaction.transactionDescription ?? "Transaction")
        _editedAmount = State(initialValue: String(format: "%g", transaction.amount))
        _editedCategory = State(initialValue: TransactionCategoryType.from(string: transaction.category ?? "other"))
        _editedDescription = State(initialValue: transaction.transactionDescription ?? "")
        _editedDate = State(initialValue: transaction.createdDate ?? Date())
        _editedIsIncome = State(initialValue: transaction.isIncome)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Modern drag indicator
            Capsule()
                .fill(AppColors.border)
                .frame(width: 40, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .onTapGesture { dismiss() }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Modern header section
                    headerSection
                    
                    // Transaction details
                    detailsSection
                    
                    // Action buttons
                    actionButtonsSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(AppColors.background)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(16)
        .presentationCompactAdaptation(.sheet)
    }
    
    // MARK: - Modern Header Section
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(editedCategory.color.opacity(0.15))
                    .frame(width: 64, height: 64)
                Image(systemName: editedCategory.symbol)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(editedCategory.color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                if isEditing {
                    TextField("Title", text: $editedTitle)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                } else {
                    Text(editedTitle)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    if !editedDescription.isEmpty {
                        Text(editedDescription)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Modern Details Section
    private var detailsSection: some View {
        VStack(spacing: 20) {
            // Amount row
            detailRow(
                title: "Amount",
                content: { amountContent }
            )
            
            // Category row
            detailRow(
                title: "Category",
                content: { categoryContent }
            )
            
            // Type row
            detailRow(
                title: "Type",
                content: { typeContent }
            )
            
            // Date row
            detailRow(
                title: "Date & Time",
                content: { dateContent }
            )
            
            // Description row
            VStack(alignment: .leading, spacing: 12) {
                Text("Description")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                if isEditing {
                    TextField("Add a description...", text: $editedDescription, axis: .vertical)
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppColors.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.border, lineWidth: 1)
                                )
                        )
                } else {
                    Text(editedDescription.isEmpty ? "No description" : editedDescription)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(editedDescription.isEmpty ? AppColors.textTertiary : AppColors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppColors.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.border, lineWidth: 1)
                                )
                        )
                }
            }
        }
    }
    
    // MARK: - Detail Row Helper
    private func detailRow<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.border, lineWidth: 1)
                )
        )
    }
    
    // MARK: - Content Views
    @ViewBuilder
    private var amountContent: some View {
        if isEditing {
            let preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD (US Dollar)"
            let currencyCode = preferredCurrency.components(separatedBy: " ").first ?? "USD"
            let currencySymbol = Locale.availableIdentifiers.compactMap { Locale(identifier: $0) }
                .first(where: { $0.currency?.identifier == currencyCode })?.currencySymbol ?? "$"
            
            HStack(spacing: 4) {
                Text(currencySymbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                TextField("0.00", text: $editedAmount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor((Double(editedAmount) ?? 0) >= 0 ? AppColors.success : AppColors.error)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
        } else {
            Text(transaction.amount, format: .currency(code: "USD"))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(transaction.amount >= 0 ? AppColors.success : AppColors.error)
        }
    }
    
    @ViewBuilder
    private var categoryContent: some View {
        if isEditing {
            Picker("Category", selection: $editedCategory) {
                ForEach(TransactionCategoryType.allCases) { cat in
                    Text(cat.label).tag(cat)
                }
            }
            .pickerStyle(.menu)
        } else {
            HStack(spacing: 8) {
                Image(systemName: editedCategory.symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(editedCategory.color)
                
                Text(editedCategory.label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(editedCategory.color)
            }
        }
    }
    
    @ViewBuilder
    private var typeContent: some View {
        if isEditing {
            Picker("Type", selection: $editedIsIncome) {
                Text("Income").tag(true)
                Text("Expense").tag(false)
            }
            .pickerStyle(.segmented)
            .frame(width: 150)
        } else {
            Text(editedIsIncome ? "Income" : "Expense")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(editedIsIncome ? AppColors.success : AppColors.error)
        }
    }
    
    @ViewBuilder
    private var dateContent: some View {
        if isEditing {
            DatePicker("", selection: $editedDate, displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
        } else {
            Text(editedDate.formatted(date: .abbreviated, time: .shortened))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
        }
    }
    
    // MARK: - Modern Action Buttons
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            if isEditing {
                Button(action: { isEditing = false }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.border, lineWidth: 1)
                                )
                        )
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Button(action: save) {
                    Text("Save")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.primary)
                        )
                        .foregroundColor(AppColors.textInverse)
                }
            } else {
                Button(action: { isEditing = true }) {
                    Text("Edit")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppColors.primary)
                        )
                        .foregroundColor(AppColors.textInverse)
                }
            }
        }
    }
    
    private func save() {
        // Update the transaction properties
        transaction.transactionDescription = editedTitle
        transaction.amount = Double(editedAmount) ?? 0
        transaction.category = editedCategory.rawValue
        transaction.transactionDescription = editedDescription
        transaction.createdDate = editedDate
        transaction.isIncome = editedIsIncome
        transaction.lastModified = Date()
        
        onSave(transaction)
        isEditing = false
        dismiss()
    }
}

