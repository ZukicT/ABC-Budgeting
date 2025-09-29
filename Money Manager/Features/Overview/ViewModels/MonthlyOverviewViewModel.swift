import Foundation
import SwiftUI

@MainActor
class MonthlyOverviewViewModel: ObservableObject {
    @Published var monthlyData: MonthlyOverviewData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Real transaction data from TransactionViewModel
    private var transactions: [Transaction] = []
    
    init() {
        // Start with empty data - will be populated from real data
        monthlyData = nil
    }
    
    func loadMonthlyData() {
        isLoading = true
        errorMessage = nil
        
        // Load real data from starting balance and transactions
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
        _ = CurrencyUtility.startingBalance
        
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
            ((currentIncome - previousIncome) / previousIncome) * 100 : 0
        
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

