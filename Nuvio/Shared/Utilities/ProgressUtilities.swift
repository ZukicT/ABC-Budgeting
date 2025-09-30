import SwiftUI

/// Centralized progress calculation utilities to eliminate code duplication
struct ProgressUtilities {
    
    // MARK: - Progress Color Calculation
    static func color(for percentage: Double, isOver: Bool = false) -> Color {
        if isOver {
            return Constants.Colors.error
        } else if percentage > 0.8 {
            return Constants.Colors.warning
        } else {
            return Constants.Colors.success
        }
    }
    
    // MARK: - Progress Percentage Calculation
    static func percentage(spent: Double, allocated: Double) -> Double {
        guard allocated > 0 else { return 0.0 }
        return min(spent / allocated, 1.0)
    }
    
    // MARK: - Budget Progress Calculation
    static func budgetProgress(spentAmount: Double, allocatedAmount: Double) -> (percentage: Double, isOverBudget: Bool, color: Color) {
        let percentage = percentage(spent: spentAmount, allocated: allocatedAmount)
        let isOverBudget = spentAmount > allocatedAmount
        let color = color(for: percentage, isOver: isOverBudget)
        
        return (percentage, isOverBudget, color)
    }
    
    // MARK: - Loan Progress Calculation
    static func loanProgress(remainingAmount: Double, principalAmount: Double) -> (percentage: Double, color: Color) {
        guard principalAmount > 0 else { return (0.0, Constants.Colors.textTertiary) }
        let paidAmount = principalAmount - remainingAmount
        let percentage = paidAmount / principalAmount
        let color = color(for: percentage)
        
        return (percentage, color)
    }
}

// MARK: - Progress Extensions
extension Double {
    var progressColor: Color {
        ProgressUtilities.color(for: self)
    }
    
    var progressColorOver: Color {
        ProgressUtilities.color(for: self, isOver: true)
    }
}
