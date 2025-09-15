//
//  TransactionRepository.swift
//  ABC Budgeting
//
//  Created by Development Team on 2025-01-09.
//  Copyright © 2025 ABC Budgeting. All rights reserved.
//

import Foundation
import CoreData
import os.log

/// Repository protocol for Transaction data operations
protocol TransactionRepositoryProtocol {
    func createTransaction(amount: Double, category: String, description: String?, isIncome: Bool) async throws -> Transaction
    func fetchTransactions() async throws -> [Transaction]
    func fetchTransaction(by id: UUID) async throws -> Transaction?
    func updateTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(_ transaction: Transaction) async throws
    func fetchTransactions(for category: String) async throws -> [Transaction]
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction]
    func fetchTransactions(by type: TransactionType) async throws -> [Transaction]
    func getTotalAmount(for category: String, from startDate: Date, to endDate: Date) async throws -> Double
    func getTotalAmount(by type: TransactionType, from startDate: Date, to endDate: Date) async throws -> Double
}

/// Transaction type enumeration
enum TransactionType: String, CaseIterable {
    case income = "income"
    case expense = "expense"
    
    var displayName: String {
        switch self {
        case .income:
            return "Income"
        case .expense:
            return "Expense"
        }
    }
}

/// Core Data implementation of TransactionRepository
final class CoreDataTransactionRepository: TransactionRepositoryProtocol {
    
    // MARK: - Properties
    private let coreDataStack: CoreDataStack
    private let logger = Logger(subsystem: "com.yourcompany.ABCBudgeting", category: "TransactionRepository")
    
    // MARK: - Initialization
    init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Create Operations
    func createTransaction(amount: Double, category: String, description: String?, isIncome: Bool) async throws -> Transaction {
        return try await coreDataStack.performBackgroundTask { context in
            // Validate input
            guard amount > 0 else {
                throw TransactionError.invalidAmount
            }
            
            guard !category.isEmpty else {
                throw TransactionError.invalidCategory
            }
            
            // Create transaction
            let transaction = Transaction(context: context)
            transaction.id = UUID()
            transaction.amount = amount
            transaction.category = category
            transaction.title = description ?? "Transaction"
            transaction.subtitle = category
            transaction.transactionDescription = description
            transaction.isIncome = isIncome
            transaction.createdDate = Date()
            transaction.date = Date()
            transaction.lastModified = Date()
            transaction.transactionType = isIncome ? "income" : "expense"
            
            // Set default icon properties based on category
            let categoryType = TransactionCategoryType(rawValue: category) ?? .other
            transaction.iconName = categoryType.symbol
            transaction.iconColorName = categoryType.color.toHex()
            transaction.iconBackgroundName = "\(categoryType.color.toHex()).opacity15"
            
            self.logger.info("Created transaction: \(transaction.id?.uuidString ?? "nil")")
            return transaction
        }
    }
    
    // MARK: - Read Operations
    func fetchTransactions() async throws -> [Transaction] {
        return try await coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.createdDate, ascending: false)]
            return try context.safeFetch(request)
        }
    }
    
    func fetchTransaction(by id: UUID) async throws -> Transaction? {
        return try await coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            return try context.safeFetch(request).first
        }
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        try await coreDataStack.performBackgroundTask { context in
            transaction.lastModified = Date()
            try context.save()
            self.logger.info("Updated transaction: \(transaction.id?.uuidString ?? "nil")")
        }
    }
    
    func deleteTransaction(_ transaction: Transaction) async throws {
        try await coreDataStack.performBackgroundTask { context in
            context.delete(transaction)
            try context.save()
            self.logger.info("Deleted transaction: \(transaction.id?.uuidString ?? "nil")")
        }
    }
    
    func fetchTransactions(for category: String) async throws -> [Transaction] {
        return try await coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "category == %@", category)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
            return try context.safeFetch(request)
        }
    }
    
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        return try await coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "createdDate >= %@ AND createdDate <= %@", startDate as CVarArg, endDate as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.createdDate, ascending: false)]
            return try context.safeFetch(request)
        }
    }
    
    func fetchTransactions(by type: TransactionType) async throws -> [Transaction] {
        return try await coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "transactionType == %@", type.rawValue)
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.createdDate, ascending: false)]
            return try context.safeFetch(request)
        }
    }
    
    func getTotalAmount(for category: String, from startDate: Date, to endDate: Date) async throws -> Double {
        return try await coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "category == %@ AND createdDate >= %@ AND createdDate <= %@", category, startDate as CVarArg, endDate as CVarArg)
            let transactions = try context.safeFetch(request)
            return transactions.reduce(0) { $0 + $1.amount }
        }
    }
    
    func getTotalAmount(by type: TransactionType, from startDate: Date, to endDate: Date) async throws -> Double {
        return try await coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
            request.predicate = NSPredicate(format: "transactionType == %@ AND createdDate >= %@ AND createdDate <= %@", type.rawValue, startDate as CVarArg, endDate as CVarArg)
            let transactions = try context.safeFetch(request)
            return transactions.reduce(0) { $0 + $1.amount }
        }
    }
}