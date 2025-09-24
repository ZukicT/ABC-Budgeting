import Foundation
import SwiftUI

@MainActor
class MonthlyOverviewViewModel: ObservableObject {
    @Published var monthlyData: MonthlyOverviewData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Sample data for now - will be replaced with real data integration
    private let sampleTransactions: [TransactionData] = [
        TransactionData(id: UUID(), amount: 5000, category: "Salary", type: .income, date: Date(), description: "Monthly Salary"),
        TransactionData(id: UUID(), amount: 1200, category: "Rent", type: .expense, date: Date(), description: "Monthly Rent"),
        TransactionData(id: UUID(), amount: 300, category: "Groceries", type: .expense, date: Date(), description: "Weekly Groceries"),
        TransactionData(id: UUID(), amount: 150, category: "Utilities", type: .expense, date: Date(), description: "Electric Bill"),
        TransactionData(id: UUID(), amount: 200, category: "Transportation", type: .expense, date: Date(), description: "Gas & Public Transport"),
        TransactionData(id: UUID(), amount: 100, category: "Entertainment", type: .expense, date: Date(), description: "Movies & Dining"),
        TransactionData(id: UUID(), amount: 4000, category: "Salary", type: .income, date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(), description: "Previous Month Salary"),
        TransactionData(id: UUID(), amount: 1100, category: "Rent", type: .expense, date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(), description: "Previous Month Rent"),
        TransactionData(id: UUID(), amount: 280, category: "Groceries", type: .expense, date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(), description: "Previous Month Groceries"),
        TransactionData(id: UUID(), amount: 140, category: "Utilities", type: .expense, date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(), description: "Previous Month Electric"),
        TransactionData(id: UUID(), amount: 180, category: "Transportation", type: .expense, date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(), description: "Previous Month Transport"),
        TransactionData(id: UUID(), amount: 120, category: "Entertainment", type: .expense, date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(), description: "Previous Month Entertainment")
    ]
    
    init() {
        loadMonthlyData()
    }
    
    func loadMonthlyData() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.calculateMonthlyData()
            self.isLoading = false
        }
    }
    
    func refreshData() {
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
        
        // Filter transactions for current month
        let currentMonthTransactions = sampleTransactions.filter { transaction in
            transaction.date >= currentMonthStart && transaction.date < currentMonthEnd
        }
        
        // Filter transactions for previous month
        let previousMonthTransactions = sampleTransactions.filter { transaction in
            transaction.date >= previousMonthStart && transaction.date < previousMonthEnd
        }
        
        // Calculate current month totals
        let currentIncome = currentMonthTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
        
        let currentExpenses = currentMonthTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
        
        // Calculate previous month totals
        let previousIncome = previousMonthTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
        
        let previousExpenses = previousMonthTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
        
        // Create month data objects
        let currentMonthData = MonthData(
            income: currentIncome,
            expenses: currentExpenses,
            date: currentMonthStart
        )
        
        let previousMonthData = MonthData(
            income: previousIncome,
            expenses: previousExpenses,
            date: previousMonthStart
        )
        
        // Calculate month-over-month change (percentage) based on income
        let monthOverMonthChange = previousIncome != 0 ? 
            ((currentIncome - previousIncome) / abs(previousIncome)) * 100 : 0
        
        // Create monthly overview data
        self.monthlyData = MonthlyOverviewData(
            currentMonth: currentMonthData,
            previousMonth: previousMonthData,
            monthOverMonthChange: monthOverMonthChange
        )
    }
}

// MARK: - Data Models
struct MonthlyOverviewData {
    let currentMonth: MonthData
    let previousMonth: MonthData
    let monthOverMonthChange: Double
}

struct MonthData {
    let income: Double
    let expenses: Double
    let date: Date
}

struct TransactionData {
    let id: UUID
    let amount: Double
    let category: String
    let type: TransactionType
    let date: Date
    let description: String
}

enum TransactionType {
    case income
    case expense
}
