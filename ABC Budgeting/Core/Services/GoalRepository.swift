//
//  GoalRepository.swift
//  ABC Budgeting
//
//  Created by Development Team on 2025-01-09.
//  Copyright © 2025 ABC Budgeting. All rights reserved.
//

import Foundation
import CoreData
import os.log

/// Repository protocol for Goal data operations
protocol GoalRepositoryProtocol {
    func createGoal(name: String, targetAmount: Double, targetDate: Date?, description: String?, priority: String, category: String?) async throws -> GoalFormData
    func fetchGoals() async throws -> [GoalFormData]
    func fetchGoal(by id: UUID) async throws -> GoalFormData?
    func updateGoal(_ goal: GoalFormData) async throws
    func deleteGoal(_ goal: GoalFormData) async throws
    func fetchActiveGoals() async throws -> [GoalFormData]
    func fetchCompletedGoals() async throws -> [GoalFormData]
    func updateGoalProgress(_ goal: GoalFormData, newAmount: Double) async throws
    func markGoalCompleted(_ goal: GoalFormData) async throws
}

/// Goal priority enumeration
enum GoalPriority: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        }
    }
}

/// Core Data implementation of GoalRepository
final class CoreDataGoalRepository: GoalRepositoryProtocol {
    
    // MARK: - Properties
    private let coreDataStack: CoreDataStack
    private let logger = Logger(subsystem: "com.yourcompany.ABCBudgeting", category: "GoalRepository")
    
    // MARK: - Initialization
    init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Create Operations
    func createGoal(name: String, targetAmount: Double, targetDate: Date?, description: String?, priority: String, category: String?) async throws -> GoalFormData {
        return try await coreDataStack.performBackgroundTask { context in
            // Validate input
            guard !name.isEmpty else {
                throw GoalError.invalidName
            }
            
            guard targetAmount > 0 else {
                throw GoalError.invalidTargetAmount
            }
            
            // Create goal
            let goal = GoalFormData(context: context)
            goal.id = UUID()
            goal.goalName = name
            goal.targetAmount = targetAmount
            goal.currentAmount = 0.0
            goal.targetDate = targetDate
            goal.goalDescription = description
            goal.isCompleted = false
            goal.createdDate = Date()
            goal.lastModified = Date()
            goal.priority = priority
            goal.category = category
            
            self.logger.info("Created goal: \(goal.id?.uuidString ?? "nil")")
            return goal
        }
    }
    
    // MARK: - Read Operations
    func fetchGoals() async throws -> [GoalFormData] {
        return try await coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<GoalFormData> = GoalFormData.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \GoalFormData.priority, ascending: false),
                NSSortDescriptor(keyPath: \GoalFormData.createdDate, ascending: false)
            ]
            
            let goals = try context.safeFetch(request)
            self.logger.info("Fetched \(goals.count) goals")
            return goals
        }
    }
    
    func fetchGoal(by id: UUID) async throws -> GoalFormData? {
        return try await coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<GoalFormData> = GoalFormData.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            
            let goals = try context.safeFetch(request)
            return goals.first
        }
    }
    
    func fetchActiveGoals() async throws -> [GoalFormData] {
        return try await coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<GoalFormData> = GoalFormData.fetchRequest()
            request.predicate = NSPredicate(format: "isCompleted == NO")
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \GoalFormData.priority, ascending: false),
                NSSortDescriptor(keyPath: \GoalFormData.createdDate, ascending: false)
            ]
            
            let goals = try context.safeFetch(request)
            self.logger.info("Fetched \(goals.count) active goals")
            return goals
        }
    }
    
    func fetchCompletedGoals() async throws -> [GoalFormData] {
        return try await coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<GoalFormData> = GoalFormData.fetchRequest()
            request.predicate = NSPredicate(format: "isCompleted == YES")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \GoalFormData.lastModified, ascending: false)]
            
            let goals = try context.safeFetch(request)
            self.logger.info("Fetched \(goals.count) completed goals")
            return goals
        }
    }
    
    // MARK: - Update Operations
    func updateGoal(_ goal: GoalFormData) async throws {
        try await coreDataStack.performBackgroundTask { context in
            // Validate goal
            guard !(goal.goalName?.isEmpty ?? true) else {
                throw GoalError.invalidName
            }
            
            guard goal.targetAmount > 0 else {
                throw GoalError.invalidTargetAmount
            }
            
            // Update last modified date
            goal.lastModified = Date()
            
            self.logger.info("Updated goal: \(goal.id?.uuidString ?? "nil")")
        }
    }
    
    func updateGoalProgress(_ goal: GoalFormData, newAmount: Double) async throws {
        try await coreDataStack.performBackgroundTask { context in
            guard newAmount >= 0 else {
                throw GoalError.invalidProgressAmount
            }
            
            goal.currentAmount = newAmount
            goal.lastModified = Date()
            
            // Check if goal is completed
            if newAmount >= goal.targetAmount {
                goal.isCompleted = true
                self.logger.info("Goal completed: \(goal.id?.uuidString ?? "nil")")
            }
            
            self.logger.info("Updated goal progress: \(goal.id?.uuidString ?? "nil") to \(newAmount)")
        }
    }
    
    func markGoalCompleted(_ goal: GoalFormData) async throws {
        try await coreDataStack.performBackgroundTask { context in
            goal.isCompleted = true
            goal.currentAmount = goal.targetAmount
            goal.lastModified = Date()
            
            self.logger.info("Marked goal as completed: \(goal.id?.uuidString ?? "nil")")
        }
    }
    
    // MARK: - Delete Operations
    func deleteGoal(_ goal: GoalFormData) async throws {
        try await coreDataStack.performBackgroundTask { context in
            context.delete(goal)
            self.logger.info("Deleted goal: \(goal.id?.uuidString ?? "nil")")
        }
    }
}

// MARK: - Goal Extensions
extension GoalFormData {
    
    // MARK: - Computed Properties
    var progressPercentage: Double {
        guard targetAmount > 0 else { return 0.0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    var isOverdue: Bool {
        guard let targetDate = targetDate else { return false }
        return !isCompleted && targetDate < Date()
    }
    
    var daysRemaining: Int? {
        guard let targetDate = targetDate else { return nil }
        let calendar = Calendar.current
        let today = Date()
        let components = calendar.dateComponents([.day], from: today, to: targetDate)
        return components.day
    }
    
    var formattedTargetAmount: String {
        return String(format: "%.2f", targetAmount)
    }
    
    var formattedCurrentAmount: String {
        return String(format: "%.2f", currentAmount)
    }
    
    var formattedProgress: String {
        return String(format: "%.1f%%", progressPercentage * 100)
    }
    
    // MARK: - Validation
    var isValid: Bool {
        return !(goalName?.isEmpty ?? true) && targetAmount > 0
    }
    
    // MARK: - Business Logic
    func addProgress(_ amount: Double) {
        guard amount > 0 else { return }
        currentAmount += amount
        
        // Check if goal is completed
        if currentAmount >= targetAmount {
            isCompleted = true
            currentAmount = targetAmount
        }
        
        lastModified = Date()
    }
    
    func resetProgress() {
        currentAmount = 0.0
        isCompleted = false
        lastModified = Date()
    }
    
    func updateTargetAmount(_ newAmount: Double) {
        guard newAmount > 0 else { return }
        targetAmount = newAmount
        
        // Check if goal is still completed
        if currentAmount >= targetAmount {
            isCompleted = true
        } else {
            isCompleted = false
        }
        
        lastModified = Date()
    }
}

