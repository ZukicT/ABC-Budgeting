//
//  DataExportService.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Service for exporting financial data to CSV format. Handles data export
//  for transactions, budgets, and loans with proper CSV formatting and
//  file management for user data portability.
//
//  Review Date: September 29, 2025
//

import Foundation
import SwiftUI

@MainActor
class DataExportService: ObservableObject {
    @Published var isExporting = false
    @Published var exportError: String?
    
    private var transactionViewModel: TransactionViewModel?
    private var budgetViewModel: BudgetViewModel?
    private var loanViewModel: LoanViewModel?
    
    func setViewModels(
        transactionViewModel: TransactionViewModel,
        budgetViewModel: BudgetViewModel,
        loanViewModel: LoanViewModel
    ) {
        self.transactionViewModel = transactionViewModel
        self.budgetViewModel = budgetViewModel
        self.loanViewModel = loanViewModel
    }
    
    func exportData(type: ExportDataType) async -> URL? {
        isExporting = true
        exportError = nil
        
        do {
            let csvContent = try generateCSVContent(for: type)
            let fileName = generateFileName(for: type)
            let url = try saveCSVToFile(content: csvContent, fileName: fileName)
            
            isExporting = false
            return url
        } catch {
            exportError = error.localizedDescription
            isExporting = false
            return nil
        }
    }
    
    func createShareableFile(type: ExportDataType) async -> URL? {
        isExporting = true
        exportError = nil
        
        do {
            let csvContent = try generateCSVContent(for: type)
            let fileName = generateFileName(for: type)
            let url = try createShareableFile(content: csvContent, fileName: fileName)
            
            isExporting = false
            return url
        } catch {
            exportError = error.localizedDescription
            isExporting = false
            return nil
        }
    }
    
    /// Generate CSV content for the specified data type
    private func generateCSVContent(for type: ExportDataType) throws -> String {
        switch type {
        case .transactions:
            return try generateTransactionsCSV()
        case .budgets:
            return try generateBudgetsCSV()
        case .loans:
            return try generateLoansCSV()
        case .all:
            return try generateAllDataCSV()
        }
    }
    
    /// Generate CSV content for transactions
    private func generateTransactionsCSV() throws -> String {
        guard let transactions = transactionViewModel?.transactions else {
            throw ExportError.noDataAvailable
        }
        
        var csvContent = "Date,Title,Amount,Category\n"
        
        for transaction in transactions {
            let dateString = DateFormatter.csvDateFormatter.string(from: transaction.date)
            let amountString = String(format: "%.2f", transaction.amount)
            let escapedTitle = escapeCSVField(transaction.title)
            let escapedCategory = escapeCSVField(transaction.category)
            
            csvContent += "\(dateString),\(escapedTitle),\(amountString),\(escapedCategory)\n"
        }
        
        return csvContent
    }
    
    /// Generate CSV content for budgets
    private func generateBudgetsCSV() throws -> String {
        guard let budgets = budgetViewModel?.budgets else {
            throw ExportError.noDataAvailable
        }
        
        var csvContent = "Category,Allocated Amount,Spent Amount,Remaining Amount\n"
        
        for budget in budgets {
            let allocatedString = String(format: "%.2f", budget.allocatedAmount)
            let spentString = String(format: "%.2f", budget.spentAmount)
            let remainingString = String(format: "%.2f", budget.remainingAmount)
            let escapedCategory = escapeCSVField(budget.category)
            
            csvContent += "\(escapedCategory),\(allocatedString),\(spentString),\(remainingString)\n"
        }
        
        return csvContent
    }
    
    /// Generate CSV content for loans
    private func generateLoansCSV() throws -> String {
        guard let loans = loanViewModel?.loans else {
            throw ExportError.noDataAvailable
        }
        
        var csvContent = "Name,Principal Amount,Remaining Amount,Interest Rate,Monthly Payment,Due Date,Payment Status,Last Payment Date,Next Payment Due,Category\n"
        
        for loan in loans {
            let principalString = String(format: "%.2f", loan.principalAmount)
            let remainingString = String(format: "%.2f", loan.remainingAmount)
            let interestString = String(format: "%.2f", loan.interestRate)
            let paymentString = String(format: "%.2f", loan.monthlyPayment)
            let dueDateString = DateFormatter.csvDateFormatter.string(from: loan.dueDate)
            let lastPaymentString = loan.lastPaymentDate != nil ? DateFormatter.csvDateFormatter.string(from: loan.lastPaymentDate!) : ""
            let nextPaymentString = loan.nextPaymentDueDate != nil ? DateFormatter.csvDateFormatter.string(from: loan.nextPaymentDueDate!) : ""
            
            let escapedName = escapeCSVField(loan.name)
            let escapedStatus = escapeCSVField(loan.paymentStatus.displayName)
            let escapedCategory = escapeCSVField(loan.category.displayName)
            
            csvContent += "\(escapedName),\(principalString),\(remainingString),\(interestString),\(paymentString),\(dueDateString),\(escapedStatus),\(lastPaymentString),\(nextPaymentString),\(escapedCategory)\n"
        }
        
        return csvContent
    }
    
    /// Generate CSV content for all data types
    private func generateAllDataCSV() throws -> String {
        var csvContent = ""
        
        // Add transactions section
        csvContent += "=== TRANSACTIONS ===\n"
        csvContent += try generateTransactionsCSV()
        csvContent += "\n"
        
        // Add budgets section
        csvContent += "=== BUDGETS ===\n"
        csvContent += try generateBudgetsCSV()
        csvContent += "\n"
        
        // Add loans section
        csvContent += "=== LOANS ===\n"
        csvContent += try generateLoansCSV()
        
        return csvContent
    }
    
    /// Escape CSV field to handle commas, quotes, and newlines
    private func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escapedField = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escapedField)\""
        }
        return field
    }
    
    /// Generate appropriate filename for export
    private func generateFileName(for type: ExportDataType) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        switch type {
        case .transactions:
            return "Nuvio_Transactions_\(dateString).csv"
        case .budgets:
            return "Nuvio_Budgets_\(dateString).csv"
        case .loans:
            return "Nuvio_Loans_\(dateString).csv"
        case .all:
            return "Nuvio_AllData_\(dateString).csv"
        }
    }
    
    /// Save CSV content to a file in Documents directory
    private func saveCSVToFile(content: String, fileName: String) throws -> URL {
        // Use Documents directory instead of temporary directory for better iOS compatibility
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Remove existing file if it exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        // Ensure file is accessible for sharing
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        var mutableFileURL = fileURL
        try mutableFileURL.setResourceValues(resourceValues)
        
        return fileURL
    }
    
    /// Create a shareable file with proper iOS permissions
    private func createShareableFile(content: String, fileName: String) throws -> URL {
        // Create a temporary file with proper permissions
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        // Remove existing file if it exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        
        // Write content to file
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        
        // Set proper file attributes for sharing
        var attributes: [FileAttributeKey: Any] = [:]
        attributes[.posixPermissions] = 0o644
        try FileManager.default.setAttributes(attributes, ofItemAtPath: fileURL.path)
        
        return fileURL
    }
}

// MARK: - Export Data Types
enum ExportDataType: String, CaseIterable {
    case transactions = "transactions"
    case budgets = "budgets"
    case loans = "loans"
    case all = "all"
    
    var displayName: String {
        switch self {
        case .transactions:
            return "Transactions"
        case .budgets:
            return "Budgets"
        case .loans:
            return "Loans"
        case .all:
            return "All Data"
        }
    }
    
    var description: String {
        switch self {
        case .transactions:
            return "Export all transaction records"
        case .budgets:
            return "Export all budget information"
        case .loans:
            return "Export all loan details"
        case .all:
            return "Export all financial data"
        }
    }
}

// MARK: - Export Errors
enum ExportError: LocalizedError {
    case noDataAvailable
    case fileCreationFailed
    case dataProcessingFailed
    
    var errorDescription: String? {
        switch self {
        case .noDataAvailable:
            return "No data available to export"
        case .fileCreationFailed:
            return "Failed to create export file"
        case .dataProcessingFailed:
            return "Failed to process data for export"
        }
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let csvDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
