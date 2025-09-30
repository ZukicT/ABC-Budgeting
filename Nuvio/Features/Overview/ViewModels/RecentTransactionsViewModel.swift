//
//  RecentTransactionsViewModel.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  ViewModel for recent transactions data management providing transaction
//  preview, pagination, and summary statistics. Handles transaction data
//  processing and state management for overview displays.
//
//  Review Date: September 29, 2025
//

import SwiftUI
import Foundation

@MainActor
class RecentTransactionsViewModel: ObservableObject {
    @Published var recentTransactions: [RecentTransactionItem] = []
    @Published var hasMoreTransactions = false
    @Published var totalCount = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let maxRecentTransactions = 5
    
    init() {
        generateSampleData()
    }
    
    func refreshData() {
        isLoading = true
        errorMessage = nil
        
        // Simulate data refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.generateSampleData()
            self.isLoading = false
        }
    }
    
    private func generateSampleData() {
        // Sample transaction data
        let now = Date()
        
        let sampleTransactions = [
            Transaction(title: "Coffee Shop", amount: -4.50, date: now, category: "Food"),
            Transaction(title: "Gas Station", amount: -35.20, date: now.addingTimeInterval(-3600), category: "Transport"),
            Transaction(title: "Grocery Store", amount: -87.45, date: now.addingTimeInterval(-7200), category: "Food"),
            Transaction(title: "Salary", amount: 2500.00, date: now.addingTimeInterval(-10800), category: "Income"),
            Transaction(title: "Movie Theater", amount: -12.00, date: now.addingTimeInterval(-14400), category: "Entertainment"),
            Transaction(title: "Electric Bill", amount: -89.30, date: now.addingTimeInterval(-18000), category: "Bills"),
            Transaction(title: "Online Shopping", amount: -156.78, date: now.addingTimeInterval(-21600), category: "Shopping"),
            Transaction(title: "Restaurant", amount: -42.15, date: now.addingTimeInterval(-25200), category: "Food"),
            Transaction(title: "Uber Ride", amount: -15.75, date: now.addingTimeInterval(-28800), category: "Transport"),
            Transaction(title: "Netflix", amount: -15.99, date: now.addingTimeInterval(-32400), category: "Entertainment")
        ]
        
        // Sort by date (most recent first)
        let sortedTransactions = sampleTransactions.sorted { $0.date > $1.date }
        
        // Take only the most recent transactions
        let recentTransactions = Array(sortedTransactions.prefix(maxRecentTransactions))
        
        // Convert to RecentTransactionItem
        self.recentTransactions = recentTransactions.map { transaction in
            RecentTransactionItem(
                transaction: transaction,
                formattedAmount: formatAmount(transaction.amount),
                formattedDate: formatDate(transaction.date),
                categoryIcon: getCategoryIcon(transaction.category),
                isIncome: transaction.amount > 0,
                amountColor: transaction.amount > 0 ? Constants.Colors.success : Constants.Colors.error
            )
        }
        
        // Set metadata
        self.hasMoreTransactions = sortedTransactions.count > maxRecentTransactions
        self.totalCount = sortedTransactions.count
    }
    
    private func formatAmount(_ amount: Double) -> String {
        return CurrencyUtility.formatAmount(amount)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func getCategoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "food":
            return "fork.knife"
        case "transport":
            return "car.fill"
        case "shopping":
            return "bag.fill"
        case "entertainment":
            return "tv.fill"
        case "bills":
            return "doc.text.fill"
        case "income":
            return "dollarsign.circle.fill"
        case "other":
            return "questionmark.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
}

// MARK: - Data Models
struct RecentTransactionItem: Identifiable {
    let id = UUID()
    let transaction: Transaction
    let formattedAmount: String
    let formattedDate: String
    let categoryIcon: String
    let isIncome: Bool
    let amountColor: Color
}

struct RecentTransactionsData {
    let transactions: [RecentTransactionItem]
    let hasMoreTransactions: Bool
    let totalCount: Int
}
