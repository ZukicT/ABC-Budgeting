//
//  BudgetViewModel.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  ViewModel for managing budget data, goal tracking, and spending analysis.
//  Handles budget CRUD operations, category filtering, and progress calculations
//  for financial goal management.
//
//  Review Date: September 29, 2025
//

import Foundation
import SwiftUI

@MainActor
class BudgetViewModel: ObservableObject {
    @Published var budgets: [Budget] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: String? = nil
    
    var hasDataLoaded = false
    
    var budgetCount: Int {
        budgets.count
    }
    
    var filteredBudgets: [Budget] {
        if let selectedCategory = selectedCategory {
            return budgets.filter { $0.category.lowercased() == selectedCategory.lowercased() }
        } else {
            return budgets
        }
    }
    
    init() {}
    
    func loadBudgets() {
        guard !hasDataLoaded else { return }
        
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
    
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
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
