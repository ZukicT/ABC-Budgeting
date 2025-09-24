import SwiftUI
import Foundation

// MARK: - Income Projection Data Models

/// Main data model for income projection calculations with expense breakdowns
struct IncomeProjectionData: Identifiable {
    let id = UUID()
    let timeRange: TimeRange
    let currentIncome: Double
    let projectedIncome: Double
    let expenseBreakdown: ExpenseBreakdown
    let loanPayments: Double
    let availableIncome: Double
    let projectedAvailableIncome: Double
    
    /// Calculates the income gap (projected income - projected expenses)
    var incomeGap: Double {
        projectedIncome - expenseBreakdown.totalExpenses
    }
    
    /// Calculates the current income gap
    var currentIncomeGap: Double {
        currentIncome - expenseBreakdown.totalExpenses
    }
}

/// Detailed breakdown of expenses by category
struct ExpenseBreakdown: Identifiable {
    let id = UUID()
    let housing: Double
    let food: Double
    let transportation: Double
    let loans: Double
    let other: Double
    
    /// Total of all expenses
    var totalExpenses: Double {
        housing + food + transportation + loans + other
    }
    
    /// Percentage breakdown for each category
    var housingPercentage: Double {
        totalExpenses > 0 ? (housing / totalExpenses) * 100 : 0
    }
    
    var foodPercentage: Double {
        totalExpenses > 0 ? (food / totalExpenses) * 100 : 0
    }
    
    var transportationPercentage: Double {
        totalExpenses > 0 ? (transportation / totalExpenses) * 100 : 0
    }
    
    var loansPercentage: Double {
        totalExpenses > 0 ? (loans / totalExpenses) * 100 : 0
    }
    
    var otherPercentage: Double {
        totalExpenses > 0 ? (other / totalExpenses) * 100 : 0
    }
}

// TimeRange enum is already defined in FinancialInsightsViewModel.swift

/// Work schedule types for income calculations
enum WorkSchedule: String, CaseIterable {
    case fullTime = "Full Time"
    case partTime = "Part Time"
    case freelance = "Freelance"
    case contract = "Contract"
    
    /// Hours per week for each schedule type
    var hoursPerWeek: Double {
        switch self {
        case .fullTime: return 40.0
        case .partTime: return 20.0
        case .freelance: return 30.0
        case .contract: return 35.0
        }
    }
}

/// Income projection calculation result
struct IncomeProjectionResult {
    let hourlyRate: Double
    let dailyIncome: Double
    let weeklyIncome: Double
    let monthlyIncome: Double
    let yearlyIncome: Double
    let expenseBreakdown: ExpenseBreakdown
    let loanPayments: Double
    let availableIncome: Double
    let projectedAvailableIncome: Double
}

// MARK: - Chart Data Models

/// Data model for bar chart visualization
struct IncomeProjectionChartData: Identifiable {
    let id = UUID()
    let category: ExpenseCategory
    let currentAmount: Double
    let projectedAmount: Double
    let color: Color
}

/// Expense categories for chart visualization
enum ExpenseCategory: String, CaseIterable {
    case housing = "Housing"
    case food = "Food"
    case transportation = "Transportation"
    case loans = "Loans"
    case other = "Other"
    case income = "Income"
    
    /// Color associated with each category
    var color: Color {
        switch self {
        case .housing: return Constants.Colors.error
        case .food: return Constants.Colors.warning
        case .transportation: return Constants.Colors.info
        case .loans: return Constants.Colors.textSecondary
        case .other: return Constants.Colors.textTertiary
        case .income: return Constants.Colors.success
        }
    }
    
    /// Icon for each category
    var icon: String {
        switch self {
        case .housing: return "house.fill"
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .loans: return "creditcard.fill"
        case .other: return "questionmark.circle.fill"
        case .income: return "dollarsign.circle.fill"
        }
    }
}
