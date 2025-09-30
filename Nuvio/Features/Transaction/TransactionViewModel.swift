//
//  TransactionViewModel.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  ViewModel for managing transaction data, CRUD operations, and budget integration.
//  Handles transaction loading, filtering, validation, and synchronization with
//  budget tracking system.
//
//  Review Date: September 29, 2025
//

import Foundation
import SwiftUI

@MainActor
class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var hasDataLoaded = false
    
    private var budgetTransactionService: BudgetTransactionService?
    
    var transactionCount: Int {
        transactions.count
    }
    
    init() {}
    
    // MARK: - Budget Integration
    
    func setBudgetTransactionService(_ service: BudgetTransactionService) {
        self.budgetTransactionService = service
    }
    
    func loadTransactions() {
        guard !hasDataLoaded else { return }
        
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.transactions = []
            self.isLoading = false
            self.hasDataLoaded = true
            self.budgetTransactionService?.updateAllBudgetsFromTransactions()
        }
    }
    
    func refreshTransactions() {
        hasDataLoaded = false
        loadTransactions()
    }
    
    func updateTransaction(_ updatedTransaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == updatedTransaction.id }) {
            let oldTransaction = transactions[index]
            transactions[index] = updatedTransaction
            
            // Update budgets based on transaction change
            budgetTransactionService?.handleTransactionUpdated(oldTransaction, updatedTransaction)
        }
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        // Sort transactions by date (newest first)
        transactions.sort { $0.date > $1.date }
        
        // Update budgets based on new transaction
        budgetTransactionService?.handleTransactionAdded(transaction)
    }
    
    func deleteTransaction(withId id: UUID) {
        if let transaction = transactions.first(where: { $0.id == id }) {
            transactions.removeAll { $0.id == id }
            
            // Update budgets based on deleted transaction
            budgetTransactionService?.handleTransactionDeleted(transaction)
        }
    }
}

struct Transaction: Identifiable {
    let id: UUID
    let title: String
    let amount: Double
    let date: Date
    let category: String
    
    init(title: String, amount: Double, date: Date, category: String) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
    }
    
    init(id: UUID, title: String, amount: Double, date: Date, category: String) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
    }
}
