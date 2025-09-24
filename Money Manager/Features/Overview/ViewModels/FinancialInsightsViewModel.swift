import SwiftUI
import Charts

class FinancialInsightsViewModel: ObservableObject {
    @Published var incomeExpenseData: [IncomeExpenseData] = []
    @Published var categorySpendingData: [CategorySpendingData] = []
    @Published var incomeNeededData: [IncomeNeededData] = []
    @Published var selectedTimeRange: TimeRange = .monthly
    @Published var isLoading = false
    @Published var errorMessage: String?
    
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
        // Generate Income vs Expense data
        incomeExpenseData = [
            IncomeExpenseData(month: "Jan", income: 5000, expenses: 3200),
            IncomeExpenseData(month: "Feb", income: 5200, expenses: 3100),
            IncomeExpenseData(month: "Mar", income: 4800, expenses: 3400),
            IncomeExpenseData(month: "Apr", income: 5500, expenses: 3300),
            IncomeExpenseData(month: "May", income: 5100, expenses: 3600),
            IncomeExpenseData(month: "Jun", income: 5300, expenses: 3500)
        ]
        
        // Generate Category Spending data
        categorySpendingData = [
            CategorySpendingData(category: "Housing", amount: 1200, percentage: 35.3, color: Constants.Colors.error),
            CategorySpendingData(category: "Food", amount: 800, percentage: 23.5, color: Constants.Colors.warning),
            CategorySpendingData(category: "Transportation", amount: 600, percentage: 17.6, color: Constants.Colors.info),
            CategorySpendingData(category: "Entertainment", amount: 400, percentage: 11.8, color: Constants.Colors.success),
            CategorySpendingData(category: "Other", amount: 400, percentage: 11.8, color: Constants.Colors.textTertiary)
        ]
        
        // Generate Income Needed data
        incomeNeededData = [
            IncomeNeededData(timeRange: .hourly, currentIncome: 25.0, projectedIncome: 28.0, currentExpenses: 20.0, projectedExpenses: 22.0),
            IncomeNeededData(timeRange: .daily, currentIncome: 200.0, projectedIncome: 220.0, currentExpenses: 160.0, projectedExpenses: 170.0),
            IncomeNeededData(timeRange: .weekly, currentIncome: 1400.0, projectedIncome: 1500.0, currentExpenses: 1100.0, projectedExpenses: 1200.0),
            IncomeNeededData(timeRange: .monthly, currentIncome: 6000.0, projectedIncome: 6500.0, currentExpenses: 4800.0, projectedExpenses: 5000.0),
            IncomeNeededData(timeRange: .yearly, currentIncome: 72000.0, projectedIncome: 78000.0, currentExpenses: 57600.0, projectedExpenses: 60000.0)
        ]
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

struct IncomeNeededData: Identifiable {
    let id = UUID()
    let timeRange: TimeRange
    let currentIncome: Double
    let projectedIncome: Double
    let currentExpenses: Double
    let projectedExpenses: Double
    
    var incomeGap: Double {
        projectedIncome - projectedExpenses
    }
}

enum TimeRange: String, CaseIterable {
    case hourly = "Hourly"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    /// Conversion factors relative to hourly
    var conversionFactor: Double {
        switch self {
        case .hourly: return 1.0
        case .daily: return 8.0  // 8 hours per day
        case .weekly: return 40.0  // 40 hours per week
        case .monthly: return 173.33  // 173.33 hours per month (2080/12)
        case .yearly: return 2080.0  // 2080 hours per year
        }
    }
    
    /// Display format for values
    var displayFormat: String {
        switch self {
        case .hourly: return "$%.2f/hr"
        case .daily: return "$%.0f/day"
        case .weekly: return "$%.0f/week"
        case .monthly: return "$%.0f/month"
        case .yearly: return "$%.0f/year"
        }
    }
}
