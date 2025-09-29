import SwiftUI
import Foundation

@MainActor
class BudgetsOverviewViewModel: ObservableObject {
    @Published var budgetOverviewItems: [BudgetOverviewItem] = []
    @Published var totalBudgeted: Double = 0.0
    @Published var totalSpent: Double = 0.0
    @Published var overallProgress: Double = 0.0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        // Start with empty data - no sample data
        budgetOverviewItems = []
        totalBudgeted = 0.0
        totalSpent = 0.0
        overallProgress = 0.0
    }
    
    func refreshData() {
        isLoading = true
        errorMessage = nil
        
        // Simulate data refresh - no sample data generated
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Keep empty data to show empty states
            self.isLoading = false
        }
    }
    
    private func generateSampleData() {
        // Sample budget data
        let sampleBudgets = [
            Budget(category: "Food", allocatedAmount: 500.0, spentAmount: 320.45, remainingAmount: 179.55),
            Budget(category: "Transport", allocatedAmount: 200.0, spentAmount: 156.80, remainingAmount: 43.20),
            Budget(category: "Entertainment", allocatedAmount: 150.0, spentAmount: 89.30, remainingAmount: 60.70),
            Budget(category: "Bills", allocatedAmount: 800.0, spentAmount: 800.0, remainingAmount: 0.0),
            Budget(category: "Shopping", allocatedAmount: 300.0, spentAmount: 156.78, remainingAmount: 143.22),
            Budget(category: "Savings", allocatedAmount: 1000.0, spentAmount: 450.0, remainingAmount: 550.0)
        ]
        
        // Calculate overview items
        budgetOverviewItems = sampleBudgets.map { budget in
            let progressPercentage = min(budget.spentAmount / budget.allocatedAmount, 1.0)
            let isOverBudget = budget.spentAmount > budget.allocatedAmount
            
            let statusColor: Color
            if isOverBudget {
                statusColor = Constants.Colors.error
            } else if progressPercentage > 0.8 {
                statusColor = Constants.Colors.warning
            } else {
                statusColor = Constants.Colors.success
            }
            
            return BudgetOverviewItem(
                budget: budget,
                spentAmount: budget.spentAmount,
                remainingAmount: budget.remainingAmount,
                progressPercentage: progressPercentage,
                isOverBudget: isOverBudget,
                statusColor: statusColor
            )
        }
        
        // Calculate totals
        totalBudgeted = sampleBudgets.reduce(0) { $0 + $1.allocatedAmount }
        totalSpent = sampleBudgets.reduce(0) { $0 + $1.spentAmount }
        overallProgress = totalBudgeted > 0 ? totalSpent / totalBudgeted : 0.0
    }
}

// MARK: - Data Models
struct BudgetOverviewItem: Identifiable {
    let id = UUID()
    let budget: Budget
    let spentAmount: Double
    let remainingAmount: Double
    let progressPercentage: Double
    let isOverBudget: Bool
    let statusColor: Color
}

struct BudgetsOverviewData {
    let budgets: [BudgetOverviewItem]
    let totalBudgeted: Double
    let totalSpent: Double
    let overallProgress: Double
}
