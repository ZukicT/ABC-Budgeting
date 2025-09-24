import SwiftUI
import Foundation

/// View model for income projection calculations and data management
@MainActor
class IncomeProjectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var incomeProjections: [IncomeProjectionData] = []
    @Published var selectedTimeRange: TimeRange = .monthly
    @Published var workSchedule: WorkSchedule = .fullTime
    @Published var hourlyRate: Double = 25.0
    @Published var projectedHourlyRate: Double = 30.0
    @Published var monthlyExpenses: ExpenseBreakdown = ExpenseBreakdown(
        housing: 1200.0,
        food: 400.0,
        transportation: 300.0,
        loans: 500.0,
        other: 200.0
    )
    @Published var monthlyLoanPayments: Double = 500.0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    var currentProjection: IncomeProjectionData? {
        incomeProjections.first { $0.timeRange == selectedTimeRange }
    }
    
    var chartData: [IncomeProjectionChartData] {
        guard let projection = currentProjection else { return [] }
        return IncomeProjectionCalculator.generateChartData(projection)
    }
    
    var requiredHourlyRate: Double {
        IncomeProjectionCalculator.calculateRequiredHourlyRate(
            monthlyExpenses: monthlyExpenses,
            monthlyLoanPayments: monthlyLoanPayments,
            workSchedule: workSchedule
        )
    }
    
    // MARK: - Initialization
    init() {
        generateSampleData()
    }
    
    // MARK: - Public Methods
    func refreshData() {
        isLoading = true
        errorMessage = nil
        
        // Simulate data refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.calculateProjections()
            self.isLoading = false
        }
    }
    
    func updateHourlyRate(_ rate: Double) {
        hourlyRate = rate
        calculateProjections()
    }
    
    func updateProjectedHourlyRate(_ rate: Double) {
        projectedHourlyRate = rate
        calculateProjections()
    }
    
    func updateWorkSchedule(_ schedule: WorkSchedule) {
        workSchedule = schedule
        calculateProjections()
    }
    
    func updateMonthlyExpenses(_ expenses: ExpenseBreakdown) {
        monthlyExpenses = expenses
        calculateProjections()
    }
    
    func updateMonthlyLoanPayments(_ payments: Double) {
        monthlyLoanPayments = payments
        calculateProjections()
    }
    
    func selectTimeRange(_ timeRange: TimeRange) {
        selectedTimeRange = timeRange
    }
    
    // MARK: - Private Methods
    private func calculateProjections() {
        guard IncomeProjectionCalculator.validateInputs(
            hourlyRate: hourlyRate,
            workSchedule: workSchedule,
            monthlyExpenses: monthlyExpenses,
            monthlyLoanPayments: monthlyLoanPayments
        ) else {
            errorMessage = "Invalid input parameters"
            return
        }
        
        incomeProjections = IncomeProjectionCalculator.calculateIncomeProjections(
            hourlyRate: hourlyRate,
            projectedHourlyRate: projectedHourlyRate,
            workSchedule: workSchedule,
            monthlyExpenses: monthlyExpenses,
            monthlyLoanPayments: monthlyLoanPayments
        )
    }
    
    private func generateSampleData() {
        // Generate sample data for demonstration
        let sampleExpenses = ExpenseBreakdown(
            housing: 1200.0,
            food: 400.0,
            transportation: 300.0,
            loans: 500.0,
            other: 200.0
        )
        
        incomeProjections = IncomeProjectionCalculator.calculateIncomeProjections(
            hourlyRate: hourlyRate,
            projectedHourlyRate: projectedHourlyRate,
            workSchedule: workSchedule,
            monthlyExpenses: sampleExpenses,
            monthlyLoanPayments: monthlyLoanPayments
        )
    }
    
    // MARK: - Formatting Methods
    func formatValue(_ value: Double, timeRange: TimeRange) -> String {
        return TimeScaleConverter.formatValue(value, timeRange: timeRange)
    }
    
    func formatPercentage(_ value: Double) -> String {
        return String(format: "%.1f%%", value)
    }
    
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
    
    // MARK: - Validation Methods
    func validateHourlyRate(_ rate: Double) -> Bool {
        return rate > 0 && rate.isFinite
    }
    
    func validateExpenses(_ expenses: ExpenseBreakdown) -> Bool {
        return expenses.totalExpenses >= 0
    }
    
    func validateLoanPayments(_ payments: Double) -> Bool {
        return payments >= 0 && payments.isFinite
    }
}
