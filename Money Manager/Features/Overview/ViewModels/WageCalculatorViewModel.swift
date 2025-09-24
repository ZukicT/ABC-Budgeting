import SwiftUI
import Foundation

/// View model for wage calculator calculations and data management
@MainActor
class WageCalculatorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var targetYearlySalary: Double = 75000.0
    @Published var workSchedule: WorkSchedule = .fullTime
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    var wageData: WageData? {
        calculateWageData()
    }
    
    // MARK: - Initialization
    init() {
        // Initialize with default values
    }
    
    // MARK: - Public Methods
    func updateTargetYearlySalary(_ salary: Double) {
        targetYearlySalary = max(0, salary)
        isLoading = true
        
        // Simulate calculation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
    
    func updateWorkSchedule(_ schedule: WorkSchedule) {
        workSchedule = schedule
    }
    
    func refreshData() {
        isLoading = true
        errorMessage = nil
        
        // Simulate data refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
        }
    }
    
    // MARK: - Private Methods
    private func calculateWageData() -> WageData? {
        guard targetYearlySalary > 0 else { return nil }
        
        let hourlyWage = calculateHourlyWage()
        let dailyWage = hourlyWage * 8.0  // 8 hours per day
        let weeklyWage = hourlyWage * workSchedule.hoursPerWeek
        let monthlyWage = targetYearlySalary / 12.0
        
        return WageData(
            targetYearlySalary: targetYearlySalary,
            hourlyWage: hourlyWage,
            dailyWage: dailyWage,
            weeklyWage: weeklyWage,
            monthlyWage: monthlyWage,
            yearlySalary: targetYearlySalary,
            workSchedule: workSchedule
        )
    }
    
    private func calculateHourlyWage() -> Double {
        // Calculate hourly wage needed to reach target yearly salary
        // Based on work schedule hours per week
        let weeksPerYear = 52.0
        let totalHoursPerYear = workSchedule.hoursPerWeek * weeksPerYear
        return targetYearlySalary / totalHoursPerYear
    }
    
    // MARK: - Validation Methods
    func validateYearlySalary(_ salary: Double) -> Bool {
        return salary > 0 && salary.isFinite
    }
}

// MARK: - Data Models

/// Wage calculation data model
struct WageData: Identifiable {
    let id = UUID()
    let targetYearlySalary: Double
    let hourlyWage: Double
    let dailyWage: Double
    let weeklyWage: Double
    let monthlyWage: Double
    let yearlySalary: Double
    let workSchedule: WorkSchedule
    
    /// Calculates the difference between target and calculated yearly salary
    var salaryDifference: Double {
        yearlySalary - targetYearlySalary
    }
    
    /// Calculates the percentage of target salary achieved
    var targetPercentage: Double {
        guard targetYearlySalary > 0 else { return 0 }
        return (yearlySalary / targetYearlySalary) * 100
    }
}
