//
//  MonthlyOverviewViewModel.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  ViewModel for monthly overview data management providing financial
//  metrics calculation, trend analysis, and data processing for
//  monthly financial summaries with proper state management.
//
//  Review Date: September 29, 2025
//

import Foundation
import SwiftUI

@MainActor
class MonthlyOverviewViewModel: ObservableObject {
    @Published var monthlyData: MonthlyOverviewData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var transactions: [Transaction] = []
    
    init() {
        monthlyData = nil
    }
    
    func loadMonthlyData() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.calculateMonthlyData()
            self.isLoading = false
        }
    }
    
    func refreshData(transactions: [Transaction] = []) {
        self.transactions = transactions
        loadMonthlyData()
    }
    
    private func calculateMonthlyData() {
        let calendar = Calendar.current
        let now = Date()
        
        // Get current month data
        let currentMonthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let currentMonthEnd = calendar.dateInterval(of: .month, for: now)?.end ?? now
        
        // Get previous month data
        let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart) ?? now
        let previousMonthEnd = calendar.date(byAdding: .month, value: -1, to: currentMonthEnd) ?? now
        
        // Get starting balance from onboarding
        let startingBalance = CurrencyUtility.startingBalance
        
        // Filter transactions by month
        let currentMonthTransactions = transactions.filter { transaction in
            transaction.date >= currentMonthStart && transaction.date < currentMonthEnd
        }
        
        let previousMonthTransactions = transactions.filter { transaction in
            transaction.date >= previousMonthStart && transaction.date < previousMonthEnd
        }
        
        // Calculate current month totals
        // Positive amounts are income, negative amounts are expenses
        let currentIncome = currentMonthTransactions
            .filter { $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
        
        let currentExpenses = currentMonthTransactions
            .filter { $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
        
        // Calculate previous month totals
        let previousIncome = previousMonthTransactions
            .filter { $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
        
        let previousExpenses = previousMonthTransactions
            .filter { $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
        
        
        // If no transactions, show empty state
        if currentIncome == 0 && currentExpenses == 0 && previousIncome == 0 && previousExpenses == 0 {
            self.monthlyData = nil
            return
        }
        
        // Calculate percentages against starting balance
        let currentIncomePercentage = startingBalance > 0 ? (currentIncome / startingBalance) * 100 : 0
        let currentExpensePercentage = startingBalance > 0 ? (currentExpenses / startingBalance) * 100 : 0
        let previousIncomePercentage = startingBalance > 0 ? (previousIncome / startingBalance) * 100 : 0
        let previousExpensePercentage = startingBalance > 0 ? (previousExpenses / startingBalance) * 100 : 0
        
        // Create month data objects
        let currentMonthData = MonthData(
            income: currentIncome,
            expenses: currentExpenses,
            date: currentMonthStart,
            incomePercentage: currentIncomePercentage,
            expensePercentage: currentExpensePercentage
        )
        
        let previousMonthData = MonthData(
            income: previousIncome,
            expenses: previousExpenses,
            date: previousMonthStart,
            incomePercentage: previousIncomePercentage,
            expensePercentage: previousExpensePercentage
        )
        
        // Calculate month-over-month change (percentage) based on income
        let monthOverMonthChange = previousIncome != 0 ? 
            ((currentIncome - previousIncome) / previousIncome) * 100 : 0
        
        // Create monthly overview data
        self.monthlyData = MonthlyOverviewData(
            currentMonth: currentMonthData,
            previousMonth: previousMonthData,
            monthOverMonthChange: monthOverMonthChange,
            startingBalance: startingBalance
        )
    }
}

// MARK: - Data Models
struct MonthlyOverviewData {
    let currentMonth: MonthData
    let previousMonth: MonthData
    let monthOverMonthChange: Double
    let startingBalance: Double
}

struct MonthData {
    let income: Double
    let expenses: Double
    let date: Date
    let incomePercentage: Double
    let expensePercentage: Double
}

