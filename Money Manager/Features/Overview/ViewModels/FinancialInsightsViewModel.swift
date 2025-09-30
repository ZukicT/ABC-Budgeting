//
//  FinancialInsightsViewModel.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  ViewModel for financial insights data management providing income vs expense
//  analysis and category spending breakdowns. Handles data processing for
//  financial charts and analytics with proper state management.
//
//  Review Date: September 29, 2025
//

import SwiftUI
import Charts

class FinancialInsightsViewModel: ObservableObject {
    @Published var incomeExpenseData: [IncomeExpenseData] = []
    @Published var categorySpendingData: [CategorySpendingData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        incomeExpenseData = []
        categorySpendingData = []
        loadData()
    }
    
    private func loadData() {
        isLoading = true
        errorMessage = nil
        
        // Note: Load real data from Core Data or transaction service
        // For now, we'll keep empty data to show empty states
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            // Keep data empty to demonstrate empty states
            // In a real implementation, this would load from Core Data
        }
    }
    
    // MARK: - Data Update Methods (for automatic updates)
    func updateData() {
        // This method will be called automatically when transaction data changes
        loadData()
    }
    
    // MARK: - Data Loading Methods (to be implemented with real data)
    func loadIncomeExpenseData(from transactions: [Transaction]) {
        // Note: Implement real data loading from transactions
        // Group transactions by month and calculate income vs expenses
    }
    
    func loadCategorySpendingData(from transactions: [Transaction]) {
        // Note: Implement real data loading from transactions
        // Group transactions by category and calculate spending amounts and percentages
    }
    
    func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Housing": return Constants.Colors.error
        case "Food": return Constants.Colors.warning
        case "Transportation": return Constants.Colors.info
        case "Entertainment": return Constants.Colors.success
        default: return Constants.Colors.textTertiary
        }
    }
}

// MARK: - Data Models
struct IncomeExpenseData: Identifiable {
    let id = UUID()
    let month: String
    let income: Double
    let expenses: Double
    
    var netIncome: Double {
        income - expenses
    }
}

struct CategorySpendingData: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    let percentage: Double
    let color: Color
}

