//
//  TransactionsViewModel.swift
//  ABC Budgeting
//
//  Created by Development Team on 2025-01-09.
//  Copyright © 2025 ABC Budgeting. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

/// ViewModel for managing transaction data and operations
@MainActor
final class TransactionsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var transactions: [Transaction] = []
    @Published var filteredTransactions: [Transaction] = []
    @Published var selectedCategory: TransactionCategoryType? = nil
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // MARK: - Dependencies
    private let transactionRepository: TransactionRepositoryProtocol
    private let goalRepository: GoalRepositoryProtocol
    
    // MARK: - Initialization
    init(
        transactionRepository: TransactionRepositoryProtocol,
        goalRepository: GoalRepositoryProtocol
    ) {
        self.transactionRepository = transactionRepository
        self.goalRepository = goalRepository
    }
    
    // MARK: - Public Methods
    func loadTransactions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedTransactions = try await transactionRepository.fetchTransactions()
            transactions = fetchedTransactions
            applyFilter()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    func createTransaction(
        amount: Double,
        category: String,
        description: String?,
        isIncome: Bool
    ) async {
        do {
            let newTransaction = try await transactionRepository.createTransaction(
                amount: amount,
                category: category,
                description: description,
                isIncome: isIncome
            )
            
            // Add to local array
            transactions.insert(newTransaction, at: 0)
            applyFilter()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func updateTransaction(_ transaction: Transaction) async {
        do {
            try await transactionRepository.updateTransaction(transaction)
            
            // Update local array
            if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
                transactions[index] = transaction
                applyFilter()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) async {
        do {
            try await transactionRepository.deleteTransaction(transaction)
            
            // Remove from local array
            transactions.removeAll { $0.id == transaction.id }
            applyFilter()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    func setSelectedCategory(_ category: TransactionCategoryType?) {
        selectedCategory = category
        applyFilter()
    }
    
    // MARK: - Private Methods
    private func applyFilter() {
        if let selectedCategory = selectedCategory {
            filteredTransactions = transactions.filter { transaction in
                transaction.category == selectedCategory.rawValue
            }
        } else {
            filteredTransactions = transactions
        }
    }
    
    // MARK: - Computed Properties
    var totalIncome: Double {
        transactions
            .filter { $0.isIncome }
            .reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Double {
        transactions
            .filter { !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
    }
    
    var netAmount: Double {
        totalIncome - totalExpenses
    }
    
    var transactionsByCategory: [String: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { $0.category ?? "Uncategorized" }
    }
    
    var transactionsByDate: [Date: [Transaction]] {
        let calendar = Calendar.current
        return Dictionary(grouping: filteredTransactions) { transaction in
            calendar.startOfDay(for: transaction.createdDate ?? Date())
        }
    }
}


// MARK: - TransactionCategoryType Extensions
extension TransactionCategoryType {

    /// Convert string to TransactionCategoryType
    static func from(string: String) -> TransactionCategoryType {
        return TransactionCategoryType(rawValue: string) ?? .other
    }
}

