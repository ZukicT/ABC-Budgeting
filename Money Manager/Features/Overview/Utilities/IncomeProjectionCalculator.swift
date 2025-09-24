import Foundation

/// Calculator class for income projection calculations
class IncomeProjectionCalculator {
    
    /// Calculate comprehensive income projection for all time scales
    /// - Parameters:
    ///   - hourlyRate: Current hourly rate
    ///   - projectedHourlyRate: Projected hourly rate
    ///   - workSchedule: Work schedule type
    ///   - monthlyExpenses: Monthly expense breakdown
    ///   - monthlyLoanPayments: Monthly loan payments
    /// - Returns: Array of income projection data for all time scales
    static func calculateIncomeProjections(
        hourlyRate: Double,
        projectedHourlyRate: Double,
        workSchedule: WorkSchedule,
        monthlyExpenses: ExpenseBreakdown,
        monthlyLoanPayments: Double
    ) -> [IncomeProjectionData] {
        
        var projections: [IncomeProjectionData] = []
        
        for timeRange in TimeRange.allCases {
            let currentIncome = TimeScaleConverter.calculateIncome(
                hourlyRate: hourlyRate,
                workSchedule: workSchedule,
                timeRange: timeRange
            )
            
            let projectedIncome = TimeScaleConverter.calculateIncome(
                hourlyRate: projectedHourlyRate,
                workSchedule: workSchedule,
                timeRange: timeRange
            )
            
            let expenseBreakdown = TimeScaleConverter.calculateExpenses(
                monthlyExpenses,
                timeRange: timeRange
            )
            
            let loanPayments = TimeScaleConverter.calculateLoanPayments(
                monthlyLoanPayments,
                timeRange: timeRange
            )
            
            let availableIncome = currentIncome - expenseBreakdown.totalExpenses - loanPayments
            let projectedAvailableIncome = projectedIncome - expenseBreakdown.totalExpenses - loanPayments
            
            let projection = IncomeProjectionData(
                timeRange: timeRange,
                currentIncome: currentIncome,
                projectedIncome: projectedIncome,
                expenseBreakdown: expenseBreakdown,
                loanPayments: loanPayments,
                availableIncome: availableIncome,
                projectedAvailableIncome: projectedAvailableIncome
            )
            
            projections.append(projection)
        }
        
        return projections
    }
    
    /// Calculate income projection for a specific time range
    /// - Parameters:
    ///   - hourlyRate: Hourly rate
    ///   - workSchedule: Work schedule type
    ///   - timeRange: Target time range
    ///   - monthlyExpenses: Monthly expense breakdown
    ///   - monthlyLoanPayments: Monthly loan payments
    /// - Returns: Income projection result
    static func calculateIncomeProjection(
        hourlyRate: Double,
        workSchedule: WorkSchedule,
        timeRange: TimeRange,
        monthlyExpenses: ExpenseBreakdown,
        monthlyLoanPayments: Double
    ) -> IncomeProjectionResult {
        
        let income = TimeScaleConverter.calculateIncome(
            hourlyRate: hourlyRate,
            workSchedule: workSchedule,
            timeRange: timeRange
        )
        
        let expenseBreakdown = TimeScaleConverter.calculateExpenses(
            monthlyExpenses,
            timeRange: timeRange
        )
        
        let loanPayments = TimeScaleConverter.calculateLoanPayments(
            monthlyLoanPayments,
            timeRange: timeRange
        )
        
        let availableIncome = income - expenseBreakdown.totalExpenses - loanPayments
        
        return IncomeProjectionResult(
            hourlyRate: hourlyRate,
            dailyIncome: TimeScaleConverter.calculateIncome(hourlyRate: hourlyRate, workSchedule: workSchedule, timeRange: .daily),
            weeklyIncome: TimeScaleConverter.calculateIncome(hourlyRate: hourlyRate, workSchedule: workSchedule, timeRange: .weekly),
            monthlyIncome: TimeScaleConverter.calculateIncome(hourlyRate: hourlyRate, workSchedule: workSchedule, timeRange: .monthly),
            yearlyIncome: TimeScaleConverter.calculateIncome(hourlyRate: hourlyRate, workSchedule: workSchedule, timeRange: .yearly),
            expenseBreakdown: expenseBreakdown,
            loanPayments: loanPayments,
            availableIncome: availableIncome,
            projectedAvailableIncome: availableIncome
        )
    }
    
    /// Calculate required hourly rate to meet expenses
    /// - Parameters:
    ///   - monthlyExpenses: Monthly expense breakdown
    ///   - monthlyLoanPayments: Monthly loan payments
    ///   - workSchedule: Work schedule type
    ///   - targetSavings: Target monthly savings amount
    /// - Returns: Required hourly rate
    static func calculateRequiredHourlyRate(
        monthlyExpenses: ExpenseBreakdown,
        monthlyLoanPayments: Double,
        workSchedule: WorkSchedule,
        targetSavings: Double = 0
    ) -> Double {
        let totalMonthlyNeeds = monthlyExpenses.totalExpenses + monthlyLoanPayments + targetSavings
        let hoursPerMonth = workSchedule.hoursPerWeek * 4.33
        return totalMonthlyNeeds / hoursPerMonth
    }
    
    /// Calculate expense breakdown percentages
    /// - Parameter expenseBreakdown: Expense breakdown data
    /// - Returns: Dictionary of category percentages
    static func calculateExpensePercentages(_ expenseBreakdown: ExpenseBreakdown) -> [ExpenseCategory: Double] {
        let total = expenseBreakdown.totalExpenses
        
        return [
            .housing: total > 0 ? (expenseBreakdown.housing / total) * 100 : 0,
            .food: total > 0 ? (expenseBreakdown.food / total) * 100 : 0,
            .transportation: total > 0 ? (expenseBreakdown.transportation / total) * 100 : 0,
            .loans: total > 0 ? (expenseBreakdown.loans / total) * 100 : 0,
            .other: total > 0 ? (expenseBreakdown.other / total) * 100 : 0
        ]
    }
    
    /// Generate chart data for visualization
    /// - Parameter projection: Income projection data
    /// - Returns: Array of chart data
    static func generateChartData(_ projection: IncomeProjectionData) -> [IncomeProjectionChartData] {
        var chartData: [IncomeProjectionChartData] = []
        
        // Add income data
        chartData.append(IncomeProjectionChartData(
            category: .income,
            currentAmount: projection.currentIncome,
            projectedAmount: projection.projectedIncome,
            color: .green
        ))
        
        // Add expense categories
        chartData.append(IncomeProjectionChartData(
            category: .housing,
            currentAmount: projection.expenseBreakdown.housing,
            projectedAmount: projection.expenseBreakdown.housing,
            color: .red
        ))
        
        chartData.append(IncomeProjectionChartData(
            category: .food,
            currentAmount: projection.expenseBreakdown.food,
            projectedAmount: projection.expenseBreakdown.food,
            color: .orange
        ))
        
        chartData.append(IncomeProjectionChartData(
            category: .transportation,
            currentAmount: projection.expenseBreakdown.transportation,
            projectedAmount: projection.expenseBreakdown.transportation,
            color: .blue
        ))
        
        chartData.append(IncomeProjectionChartData(
            category: .loans,
            currentAmount: projection.loanPayments,
            projectedAmount: projection.loanPayments,
            color: .purple
        ))
        
        chartData.append(IncomeProjectionChartData(
            category: .other,
            currentAmount: projection.expenseBreakdown.other,
            projectedAmount: projection.expenseBreakdown.other,
            color: .gray
        ))
        
        return chartData
    }
    
    /// Validate input parameters
    /// - Parameters:
    ///   - hourlyRate: Hourly rate to validate
    ///   - workSchedule: Work schedule to validate
    ///   - monthlyExpenses: Monthly expenses to validate
    ///   - monthlyLoanPayments: Monthly loan payments to validate
    /// - Returns: True if all parameters are valid
    static func validateInputs(
        hourlyRate: Double,
        workSchedule: WorkSchedule,
        monthlyExpenses: ExpenseBreakdown,
        monthlyLoanPayments: Double
    ) -> Bool {
        guard hourlyRate > 0 && hourlyRate.isFinite else { return false }
        guard monthlyExpenses.totalExpenses >= 0 else { return false }
        guard monthlyLoanPayments >= 0 && monthlyLoanPayments.isFinite else { return false }
        
        return true
    }
}
