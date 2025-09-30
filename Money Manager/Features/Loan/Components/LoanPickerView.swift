//
//  LoanPickerView.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Loan picker component for selecting existing loans to mark as paid.
//  Features search functionality, loan filtering, and accessibility
//  support for loan management operations.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct LoanPickerView: View {
    let loans: [Loan]
    @Binding var selectedLoan: Loan?
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var searchText = ""
    
    private var filteredLoans: [Loan] {
        if searchText.isEmpty {
            return loans.filter { $0.calculatedStatus != .paid }
        } else {
            return loans.filter { 
                $0.calculatedStatus != .paid && 
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Constants.Colors.textSecondary)
                
                TextField(contentManager.localizedString("loan.search_placeholder"), text: $searchText)
                    .font(Constants.Typography.Body.font)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(Constants.UI.Spacing.medium)
            .background(Constants.Colors.backgroundSecondary)
            .cornerRadius(Constants.UI.cardCornerRadius)
            
            // Loan List
            if filteredLoans.isEmpty {
                VStack(spacing: Constants.UI.Spacing.medium) {
                    Image(systemName: "creditcard")
                        .font(Constants.Typography.H1.font)
                        .foregroundColor(Constants.Colors.textTertiary)
                    
                    Text(searchText.isEmpty ? contentManager.localizedString("loan.no_unpaid") : contentManager.localizedString("loan.no_found"))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    if !searchText.isEmpty {
                        Text(contentManager.localizedString("loan.try_different"))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textTertiary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(Constants.UI.Spacing.large)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(filteredLoans.enumerated()), id: \.element.id) { index, loan in
                            VStack(spacing: 0) {
                                Button(action: {
                                    selectedLoan = loan
                                }) {
                                    LoanPickerRow(loan: loan, isSelected: selectedLoan?.id == loan.id)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Separation line (except for last item)
                                if index < filteredLoans.count - 1 {
                                    Rectangle()
                                        .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                                        .frame(height: 1)
                                        .padding(.horizontal, Constants.UI.Padding.screenMargin)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Loan Picker Row
private struct LoanPickerRow: View {
    let loan: Loan
    let isSelected: Bool
    
    private var currentStatus: LoanPaymentStatus {
        loan.calculatedStatus
    }
    
    var body: some View {
        HStack(spacing: Constants.UI.Spacing.medium) {
            // Selection Indicator
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(Constants.Typography.H3.font)
                .foregroundColor(isSelected ? Constants.Colors.success : Constants.Colors.textTertiary)
            
            // Loan Info
            VStack(alignment: .leading, spacing: 4) {
                Text(loan.name)
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .lineLimit(1)
                
                Text("\\(loan.remainingAmount, format: .currency(code: \"USD\")) \\(contentManager.localizedString(\"loan.remaining\"))")
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            
            Spacer()
            
            // Status Tag
            StatusTag(status: currentStatus)
        }
        .padding(Constants.UI.Padding.cardInternal)
        .background(isSelected ? Constants.Colors.success.opacity(0.1) : Color.clear)
        .cornerRadius(Constants.UI.cardCornerRadius)
    }
}

#Preview {
    let sampleLoans = [
        Loan(name: "Auto Loan", principalAmount: 25000.0, remainingAmount: 18500.0, interestRate: 4.5, monthlyPayment: 450.0, dueDate: Date().addingTimeInterval(86400 * 15), paymentStatus: .current, lastPaymentDate: Date().addingTimeInterval(-86400 * 30), nextPaymentDueDate: Date().addingTimeInterval(86400 * 15), category: .auto),
        Loan(name: "Student Loan", principalAmount: 15000.0, remainingAmount: 12000.0, interestRate: 3.2, monthlyPayment: 280.0, dueDate: Date().addingTimeInterval(86400 * 5), paymentStatus: .overdue, lastPaymentDate: Date().addingTimeInterval(-86400 * 30), nextPaymentDueDate: Date().addingTimeInterval(86400 * -2), category: .student),
        Loan(name: "Credit Card", principalAmount: 5000.0, remainingAmount: 3200.0, interestRate: 18.9, monthlyPayment: 150.0, dueDate: Date().addingTimeInterval(86400 * 3), paymentStatus: .missed, lastPaymentDate: Date().addingTimeInterval(-86400 * 60), nextPaymentDueDate: Date().addingTimeInterval(86400 * -5), category: .creditCard)
    ]
    
    LoanPickerView(loans: sampleLoans, selectedLoan: .constant(nil))
        .padding()
}
