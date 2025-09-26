import Foundation

/// Utility class for converting income and expense values across different time scales
class TimeScaleConverter {
    
    /// Convert a value from one time scale to another
    /// - Parameters:
    ///   - value: The value to convert
    ///   - from: Source time scale
    ///   - to: Target time scale
    /// - Returns: Converted value
    static func convert(_ value: Double, from: TimeRange, to: TimeRange) -> Double {
        // Convert to hourly first, then to target scale
        let hourlyValue = value / from.conversionFactor
        return hourlyValue * to.conversionFactor
    }
    
    /// Convert hourly rate to any time scale
    /// - Parameters:
    ///   - hourlyRate: Hourly rate in dollars
    ///   - to: Target time scale
    /// - Returns: Converted value
    static func fromHourly(_ hourlyRate: Double, to: TimeRange) -> Double {
        return hourlyRate * to.conversionFactor
    }
    
    /// Convert any time scale to hourly rate
    /// - Parameters:
    ///   - value: Value in source time scale
    ///   - from: Source time scale
    /// - Returns: Hourly rate
    static func toHourly(_ value: Double, from: TimeRange) -> Double {
        return value / from.conversionFactor
    }
    
    /// Calculate income for a specific work schedule
    /// - Parameters:
    ///   - hourlyRate: Hourly rate in dollars
    ///   - workSchedule: Work schedule type
    ///   - timeRange: Target time range
    /// - Returns: Calculated income
    static func calculateIncome(hourlyRate: Double, workSchedule: WorkSchedule, timeRange: TimeRange) -> Double {
        let hoursPerWeek = workSchedule.hoursPerWeek
        let weeklyIncome = hourlyRate * hoursPerWeek
        
        switch timeRange {
        case .hourly:
            return hourlyRate
        case .daily:
            return weeklyIncome / 7.0
        case .weekly:
            return weeklyIncome
        case .monthly:
            return weeklyIncome * 4.33  // Average weeks per month
        case .yearly:
            return weeklyIncome * 52.0
        }
    }
    
    /// Calculate expenses for a specific time range
    /// - Parameters:
    ///   - monthlyExpenses: Monthly expense breakdown
    ///   - timeRange: Target time range
    /// - Returns: Converted expense breakdown
    static func calculateExpenses(_ monthlyExpenses: ExpenseBreakdown, timeRange: TimeRange) -> ExpenseBreakdown {
        let conversionFactor = timeRange.conversionFactor / TimeRange.monthly.conversionFactor
        
        return ExpenseBreakdown(
            housing: monthlyExpenses.housing * conversionFactor,
            food: monthlyExpenses.food * conversionFactor,
            transportation: monthlyExpenses.transportation * conversionFactor,
            loans: monthlyExpenses.loans * conversionFactor,
            other: monthlyExpenses.other * conversionFactor
        )
    }
    
    /// Calculate loan payments for a specific time range
    /// - Parameters:
    ///   - monthlyLoanPayments: Monthly loan payments
    ///   - timeRange: Target time range
    /// - Returns: Converted loan payments
    static func calculateLoanPayments(_ monthlyLoanPayments: Double, timeRange: TimeRange) -> Double {
        let conversionFactor = timeRange.conversionFactor / TimeRange.monthly.conversionFactor
        return monthlyLoanPayments * conversionFactor
    }
    
    /// Format value for display based on time range
    /// - Parameters:
    ///   - value: Value to format
    ///   - timeRange: Time range for formatting
    /// - Returns: Formatted string
    static func formatValue(_ value: Double, timeRange: TimeRange) -> String {
        let fractionDigits = timeRange == .hourly ? 2 : 0
        return CurrencyUtility.formatAmount(value, fractionDigits: fractionDigits)
    }
    
    /// Get all time ranges as chart data
    /// - Returns: Array of time ranges for chart display
    static func getAllTimeRanges() -> [TimeRange] {
        return TimeRange.allCases
    }
    
    /// Validate time scale conversion
    /// - Parameters:
    ///   - value: Value to validate
    ///   - timeRange: Time range
    /// - Returns: True if valid, false otherwise
    static func isValidValue(_ value: Double, timeRange: TimeRange) -> Bool {
        return value >= 0 && value.isFinite
    }
}
