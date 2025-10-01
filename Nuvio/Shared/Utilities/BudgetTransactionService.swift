//
//  BudgetTransactionService.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Service for automatically updating budget spending based on transaction categories.
//  Handles transaction-budget synchronization, spent amount calculations,
//  and maintains data consistency between transactions and budgets.
//
//  Review Date: September 29, 2025
//

import Foundation
import SwiftUI

@MainActor
class BudgetTransactionService: ObservableObject {
    
    // MARK: - Dependencies
    private var transactionViewModel: TransactionViewModel?
    private var budgetViewModel: BudgetViewModel?
    
    // MARK: - Initialization
    init() {}
    
    // MARK: - Setup
    func setViewModels(
        transactionViewModel: TransactionViewModel,
        budgetViewModel: BudgetViewModel
    ) {
        self.transactionViewModel = transactionViewModel
        self.budgetViewModel = budgetViewModel
    }
    
    // MARK: - Public Methods
    
    /// Updates all budgets based on current transactions
    func updateAllBudgetsFromTransactions() {
        guard let transactionViewModel = transactionViewModel,
              let budgetViewModel = budgetViewModel else { return }
        
        // Update each budget with its corresponding spent amount considering time period
        for budget in budgetViewModel.budgets {
            let spentAmount = calculateSpentAmountsForBudget(budget, from: transactionViewModel.transactions)
            let remainingAmount = budget.allocatedAmount - spentAmount
            
            let updatedBudget = Budget(
                id: budget.id,
                category: budget.category,
                allocatedAmount: budget.allocatedAmount,
                spentAmount: spentAmount,
                remainingAmount: max(0, remainingAmount),
                startDate: budget.startDate,
                endDate: budget.endDate,
                periodType: budget.periodType
            )
            
            budgetViewModel.updateBudget(updatedBudget)
        }
    }
    
    /// Updates budgets when a transaction is added
    func handleTransactionAdded(_ transaction: Transaction) {
        updateBudgetsForTransaction(transaction, operation: .add)
    }
    
    /// Updates budgets when a transaction is updated
    func handleTransactionUpdated(_ oldTransaction: Transaction, _ newTransaction: Transaction) {
        // First, remove the old transaction's impact
        updateBudgetsForTransaction(oldTransaction, operation: .remove)
        
        // Then, add the new transaction's impact
        updateBudgetsForTransaction(newTransaction, operation: .add)
    }
    
    /// Updates budgets when a transaction is deleted
    func handleTransactionDeleted(_ transaction: Transaction) {
        updateBudgetsForTransaction(transaction, operation: .remove)
    }
    
    // MARK: - Private Methods
    
    private enum Operation {
        case add
        case remove
    }
    
    private func updateBudgetsForTransaction(_ transaction: Transaction, operation: Operation) {
        guard let budgetViewModel = budgetViewModel else { return }
        
        // Only process expense transactions (negative amounts)
        guard transaction.amount < 0 else { return }
        
        let transactionAmount = abs(transaction.amount)
        let category = transaction.category.lowercased()
        
        // Find budgets for this category that include the transaction date
        let relevantBudgets = budgetViewModel.budgets.filter { budget in
            budget.category.lowercased() == category &&
            transaction.date >= budget.startDate &&
            transaction.date <= budget.endDate
        }
        
        // Update each relevant budget
        for budget in relevantBudgets {
            let newSpentAmount: Double
            
            switch operation {
            case .add:
                newSpentAmount = budget.spentAmount + transactionAmount
            case .remove:
                newSpentAmount = max(0, budget.spentAmount - transactionAmount)
            }
            
            let newRemainingAmount = budget.allocatedAmount - newSpentAmount
            
            let updatedBudget = Budget(
                id: budget.id,
                category: budget.category,
                allocatedAmount: budget.allocatedAmount,
                spentAmount: newSpentAmount,
                remainingAmount: max(0, newRemainingAmount),
                startDate: budget.startDate,
                endDate: budget.endDate,
                periodType: budget.periodType
            )
            
            budgetViewModel.updateBudget(updatedBudget)
        }
    }
    
    private func calculateSpentAmountsByCategory(from transactions: [Transaction]) -> [String: Double] {
        var spentAmounts: [String: Double] = [:]
        
        for transaction in transactions {
            // Only count expense transactions (negative amounts)
            guard transaction.amount < 0 else { continue }
            
            let category = transaction.category.lowercased()
            let amount = abs(transaction.amount)
            
            spentAmounts[category, default: 0.0] += amount
        }
        
        return spentAmounts
    }
    
    /// Calculates spent amounts for a specific budget considering its time period
    private func calculateSpentAmountsForBudget(_ budget: Budget, from transactions: [Transaction]) -> Double {
        let filteredTransactions = transactions.filter { transaction in
            // Only count expense transactions (negative amounts)
            guard transaction.amount < 0 else { return false }
            
            // Check if transaction category matches budget category
            guard transaction.category.lowercased() == budget.category.lowercased() else { return false }
            
            // Check if transaction date falls within budget period
            return transaction.date >= budget.startDate && transaction.date <= budget.endDate
        }
        
        return filteredTransactions.reduce(0) { total, transaction in
            total + abs(transaction.amount)
        }
    }
    
    // MARK: - Utility Methods
    
    /// Creates a new budget with historical transaction calculation
    func createBudgetWithHistoricalData(
        category: String,
        allocatedAmount: Double,
        periodType: BudgetPeriodType,
        startDate: Date? = nil
    ) -> Budget {
        // Calculate start and end dates based on period type
        let (budgetStartDate, budgetEndDate) = calculateBudgetPeriod(
            periodType: periodType,
            startDate: startDate ?? Date()
        )
        
        // Calculate historical spent amount for this budget period
        let historicalSpentAmount = calculateHistoricalSpentAmount(
            category: category,
            startDate: budgetStartDate,
            endDate: budgetEndDate
        )
        
        let remainingAmount = allocatedAmount - historicalSpentAmount
        
        return Budget(
            category: category,
            allocatedAmount: allocatedAmount,
            spentAmount: historicalSpentAmount,
            remainingAmount: max(0, remainingAmount),
            startDate: budgetStartDate,
            endDate: budgetEndDate,
            periodType: periodType
        )
    }
    
    /// Calculates budget period dates based on type
    private func calculateBudgetPeriod(periodType: BudgetPeriodType, startDate: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        
        switch periodType {
        case .weekly:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startDate)?.start ?? startDate
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? startDate
            return (startOfWeek, endOfWeek)
            
        case .monthly:
            let startOfMonth = calendar.dateInterval(of: .month, for: startDate)?.start ?? startDate
            let endOfMonth = calendar.dateInterval(of: .month, for: startDate)?.end ?? startDate
            return (startOfMonth, endOfMonth)
            
        case .yearly:
            let startOfYear = calendar.dateInterval(of: .year, for: startDate)?.start ?? startDate
            let endOfYear = calendar.dateInterval(of: .year, for: startDate)?.end ?? startDate
            return (startOfYear, endOfYear)
        }
    }
    
    /// Calculates historical spent amount for a specific category and time period
    private func calculateHistoricalSpentAmount(category: String, startDate: Date, endDate: Date) -> Double {
        guard let transactionViewModel = transactionViewModel else { return 0.0 }
        
        return transactionViewModel.transactions
            .filter { transaction in
                transaction.category.lowercased() == category.lowercased() &&
                transaction.amount < 0 &&
                transaction.date >= startDate &&
                transaction.date <= endDate
            }
            .reduce(0) { total, transaction in
                total + abs(transaction.amount)
            }
    }
    
    /// Gets the total spent amount for a specific category
    func getSpentAmountForCategory(_ category: String) -> Double {
        guard let transactionViewModel = transactionViewModel else { return 0.0 }
        
        return transactionViewModel.transactions
            .filter { $0.category.lowercased() == category.lowercased() && $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
    }
    
    /// Gets the remaining budget amount for a specific category
    func getRemainingBudgetForCategory(_ category: String) -> Double {
        guard let budgetViewModel = budgetViewModel else { return 0.0 }
        
        let budget = budgetViewModel.budgets.first { 
            $0.category.lowercased() == category.lowercased() 
        }
        
        return budget?.remainingAmount ?? 0.0
    }
    
    /// Checks if a category is over budget
    func isOverBudgetForCategory(_ category: String) -> Bool {
        guard let budgetViewModel = budgetViewModel else { return false }
        
        let budget = budgetViewModel.budgets.first { 
            $0.category.lowercased() == category.lowercased() 
        }
        
        return budget?.spentAmount ?? 0.0 > budget?.allocatedAmount ?? 0.0
    }
}
