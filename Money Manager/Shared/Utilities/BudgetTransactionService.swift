import Foundation
import SwiftUI

/**
 * BudgetTransactionService
 *
 * Service responsible for automatically updating budget spending based on transaction categories.
 * When a transaction is added, updated, or deleted, this service calculates the impact on
 * corresponding budgets and updates the budget's spent amount accordingly.
 *
 * Features:
 * - Automatic budget updates based on transaction categories
 * - Handles transaction additions, updates, and deletions
 * - Calculates spent amounts for each budget category
 * - Updates remaining amounts automatically
 * - Maintains data consistency between transactions and budgets
 *
 * Architecture:
 * - Pure service class with no UI dependencies
 * - Uses dependency injection for ViewModels
 * - Thread-safe operations
 * - Performance optimized with efficient calculations
 *
 * Last Review: 2025-01-26
 * Status: Production Ready
 */

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
        
        // Calculate spent amounts for each budget category
        let spentAmounts = calculateSpentAmountsByCategory(from: transactionViewModel.transactions)
        
        // Update each budget with its corresponding spent amount
        for budget in budgetViewModel.budgets {
            let spentAmount = spentAmounts[budget.category.lowercased()] ?? 0.0
            let remainingAmount = budget.allocatedAmount - spentAmount
            
            let updatedBudget = Budget(
                id: budget.id,
                category: budget.category,
                allocatedAmount: budget.allocatedAmount,
                spentAmount: spentAmount,
                remainingAmount: max(0, remainingAmount)
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
        
        // Find the budget for this category
        guard let budgetIndex = budgetViewModel.budgets.firstIndex(where: { 
            $0.category.lowercased() == category 
        }) else { return }
        
        let currentBudget = budgetViewModel.budgets[budgetIndex]
        let newSpentAmount: Double
        
        switch operation {
        case .add:
            newSpentAmount = currentBudget.spentAmount + transactionAmount
        case .remove:
            newSpentAmount = max(0, currentBudget.spentAmount - transactionAmount)
        }
        
        let newRemainingAmount = currentBudget.allocatedAmount - newSpentAmount
        
        let updatedBudget = Budget(
            id: currentBudget.id,
            category: currentBudget.category,
            allocatedAmount: currentBudget.allocatedAmount,
            spentAmount: newSpentAmount,
            remainingAmount: max(0, newRemainingAmount)
        )
        
        budgetViewModel.updateBudget(updatedBudget)
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
    
    // MARK: - Utility Methods
    
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
