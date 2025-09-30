//
//  DataClearingService.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Service for clearing all financial data and managing data reset operations.
//  Handles complete data clearing, ViewModel reset, and user confirmation
//  for data management and privacy compliance.
//
//  Review Date: September 29, 2025
//

import Foundation
import SwiftUI

@MainActor
class DataClearingService: ObservableObject {
    @Published var isClearingData = false
    @Published var showStartingBalancePrompt = false
    
    var transactionViewModel: TransactionViewModel?
    var budgetViewModel: BudgetViewModel?
    var loanViewModel: LoanViewModel?
    
    func setViewModels(
        transactionViewModel: TransactionViewModel,
        budgetViewModel: BudgetViewModel,
        loanViewModel: LoanViewModel
    ) {
        self.transactionViewModel = transactionViewModel
        self.budgetViewModel = budgetViewModel
        self.loanViewModel = loanViewModel
    }
    
    func clearAllData() {
        isClearingData = true
        
        clearTransactionData()
        clearBudgetData()
        clearLoanData()
        clearUserDefaults()
        
        // Reset data loaded flags - safely handle nil ViewModels
        transactionViewModel?.hasDataLoaded = false
        budgetViewModel?.hasDataLoaded = false
        loanViewModel?.hasDataLoaded = false
        
        isClearingData = false
        
        // Show starting balance prompt
        showStartingBalancePrompt = true
    }
    
    /// Clears all transaction data
    private func clearTransactionData() {
        transactionViewModel?.transactions.removeAll()
        transactionViewModel?.isLoading = false
        transactionViewModel?.errorMessage = nil
    }
    
    /// Clears all budget data
    private func clearBudgetData() {
        budgetViewModel?.budgets.removeAll()
        budgetViewModel?.isLoading = false
        budgetViewModel?.errorMessage = nil
    }
    
    /// Clears all loan data
    private func clearLoanData() {
        loanViewModel?.loans.removeAll()
        loanViewModel?.isLoading = false
        loanViewModel?.errorMessage = nil
        loanViewModel?.selectedCategory = nil
    }
    
    /// Clears all UserDefaults data
    private func clearUserDefaults() {
        // Clear starting balance
        UserDefaults.standard.removeObject(forKey: "starting_balance")
        
        // Clear any other app-specific data
        UserDefaults.standard.removeObject(forKey: "selected_currency")
        UserDefaults.standard.removeObject(forKey: "onboarding_completed")
        
        // Clear any other financial data keys
        let keysToRemove = [
            "budget_period",
            "notifications_enabled",
            "biometric_enabled",
            "dark_mode_enabled"
        ]
        
        for key in keysToRemove {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Force UserDefaults to save
        UserDefaults.standard.synchronize()
    }
    
    /// Sets a new starting balance after data clearing
    func setNewStartingBalance(_ balance: Double) {
        CurrencyUtility.setStartingBalance(balance)
        showStartingBalancePrompt = false
    }
    
    /// Cancels the starting balance prompt (keeps balance at 0)
    func cancelStartingBalancePrompt() {
        CurrencyUtility.setStartingBalance(0.0)
        showStartingBalancePrompt = false
    }
}

// MARK: - Starting Balance Prompt View
struct StartingBalancePromptView: View {
    @ObservedObject var dataClearingService: DataClearingService
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var startingBalance: String = ""
    @State private var isValidInput: Bool = false
    @State private var showInvalidBalanceAlert: Bool = false
    
    private var currencySymbol: String {
        return CurrencyUtility.currentSymbol
    }
    
    var body: some View {
        ZStack {
            // Background
            Constants.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: Constants.UI.Spacing.large) {
                // Header
                VStack(spacing: Constants.UI.Spacing.medium) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(Constants.Typography.H1.font)
                        .fontWeight(.light)
                        .foregroundColor(Constants.Colors.primaryOrange)
                    
                    Text(contentManager.localizedString("data_cleared.title"))
                        .font(Constants.Typography.H1.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(contentManager.localizedString("data_cleared.message"))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Constants.UI.Padding.screenMargin)
                
                // Balance Input
                VStack(spacing: Constants.UI.Spacing.medium) {
                    Text(contentManager.localizedString("data_cleared.starting_balance"))
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text(currencySymbol)
                            .font(Constants.Typography.H2.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .frame(width: 40, alignment: .leading)
                        
                        TextField("0.00", text: $startingBalance)
                            .font(Constants.Typography.H2.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onChange(of: startingBalance) { _, newValue in
                                validateInput(newValue)
                            }
                    }
                    .padding(.horizontal, Constants.UI.Padding.cardInternal)
                    .padding(.vertical, Constants.UI.Padding.cardInternal)
                    .background(Constants.Colors.textPrimary.opacity(0.05))
                    .cornerRadius(Constants.UI.CornerRadius.secondary)
                }
                .padding(.horizontal, Constants.UI.Padding.screenMargin)
                
                // Action Buttons
                VStack(spacing: Constants.UI.Spacing.medium) {
                    Button(action: {
                        if let balance = Double(startingBalance), balance >= 0 {
                            dataClearingService.setNewStartingBalance(balance)
                        } else {
                            showInvalidBalanceAlert = true
                        }
                    }) {
                        Text(contentManager.localizedString("button.set_starting_balance"))
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Constants.Colors.primaryOrange)
                            .cornerRadius(Constants.UI.CornerRadius.secondary)
                    }
                    .disabled(!isValidInput)
                    
                    Button(action: {
                        dataClearingService.cancelStartingBalancePrompt()
                    }) {
                        Text(contentManager.localizedString("button.skip"))
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                }
                .padding(.horizontal, Constants.UI.Padding.screenMargin)
                
                Spacer()
            }
        }
        .onAppear {
            // Pre-fill with current starting balance if available
            let currentBalance = CurrencyUtility.startingBalance
            if currentBalance > 0 {
                startingBalance = String(format: "%.2f", currentBalance)
                isValidInput = true
            }
        }
        .alert(contentManager.localizedString("data_cleared.starting_balance"), isPresented: $showInvalidBalanceAlert) {
            Button(contentManager.localizedString("button.ok")) { }
        } message: {
            Text(contentManager.localizedString("data_cleared.validation_message"))
        }
    }
    
    private func validateInput(_ newValue: String) {
        // Simple validation - just check if it's a valid number >= 0
        if let value = Double(newValue) {
            isValidInput = value >= 0
        } else {
            isValidInput = false
        }
    }
}

#Preview {
    StartingBalancePromptView(dataClearingService: DataClearingService())
}
