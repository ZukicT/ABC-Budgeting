import Foundation
import SwiftUI

@MainActor
class BudgetViewModel: ObservableObject {
    @Published var budgets: [Budget] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: String? = nil
    
    private var hasDataLoaded = false
    
    // Counter for tab display (Goals equivalent)
    var budgetCount: Int {
        budgets.count
    }
    
    // Filtered budgets based on selected category
    var filteredBudgets: [Budget] {
        if let selectedCategory = selectedCategory {
            return budgets.filter { $0.category.lowercased() == selectedCategory.lowercased() }
        } else {
            return budgets
        }
    }
    
    init() {
        // Initialize budget data
    }
    
    func loadBudgets() {
        // Only load if data hasn't been loaded yet
        guard !hasDataLoaded else { return }
        
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement budget loading logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Start with empty budgets for new users
            self.budgets = []
            self.isLoading = false
            self.hasDataLoaded = true
        }
    }
    
    func updateBudget(_ updatedBudget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == updatedBudget.id }) {
            budgets[index] = updatedBudget
        }
    }
    
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
    }
    
    func editBudget(_ budget: Budget) {
        // This method can be used for any pre-edit logic if needed
        // Currently just a placeholder for future functionality
    }
    
    func refreshBudgets() {
        hasDataLoaded = false
        loadBudgets()
    }
}

struct Budget: Identifiable {
    let id: UUID
    let category: String
    let allocatedAmount: Double
    let spentAmount: Double
    let remainingAmount: Double
    
    init(category: String, allocatedAmount: Double, spentAmount: Double, remainingAmount: Double) {
        self.id = UUID()
        self.category = category
        self.allocatedAmount = allocatedAmount
        self.spentAmount = spentAmount
        self.remainingAmount = remainingAmount
    }
    
    init(id: UUID, category: String, allocatedAmount: Double, spentAmount: Double, remainingAmount: Double) {
        self.id = id
        self.category = category
        self.allocatedAmount = allocatedAmount
        self.spentAmount = spentAmount
        self.remainingAmount = remainingAmount
    }
}
