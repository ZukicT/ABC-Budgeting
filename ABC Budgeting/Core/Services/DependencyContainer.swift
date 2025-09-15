//
//  DependencyContainer.swift
//  ABC Budgeting
//
//  Created by Development Team on 2025-01-09.
//  Copyright © 2025 ABC Budgeting. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

/// Dependency injection container for managing app dependencies
final class DependencyContainer: ObservableObject {
    
    // MARK: - Singleton
    static let shared = DependencyContainer()
    
    // MARK: - Core Dependencies
    private var coreDataStack: CoreDataStack
    
    // MARK: - Repository Dependencies
    private var transactionRepository: TransactionRepositoryProtocol
    private var goalRepository: GoalRepositoryProtocol
    
    // MARK: - Service Dependencies
    private var dataValidator: DataValidator
    private var errorHandler: ErrorHandler
    
    // MARK: - Initialization
    private init() {
        // Initialize Core Data stack
        self.coreDataStack = CoreDataStack.shared
        
        // Initialize repositories
        self.transactionRepository = CoreDataTransactionRepository(coreDataStack: coreDataStack)
        self.goalRepository = CoreDataGoalRepository(coreDataStack: coreDataStack)
        
        // Initialize services
        self.dataValidator = DataValidator()
        self.errorHandler = ErrorHandler()
    }
    
    // MARK: - Public Accessors
    var transactionRepo: TransactionRepositoryProtocol {
        return transactionRepository
    }
    
    var goalRepo: GoalRepositoryProtocol {
        return goalRepository
    }
    
    var validator: DataValidator {
        return dataValidator
    }
    
    var errorService: ErrorHandler {
        return errorHandler
    }
    
    var coreData: CoreDataStack {
        return coreDataStack
    }
}

// MARK: - Dependency Injection Extensions
extension DependencyContainer {
    
    /// Create a new instance with custom dependencies (useful for testing)
    static func create(
        coreDataStack: CoreDataStack? = nil,
        transactionRepository: TransactionRepositoryProtocol? = nil,
        goalRepository: GoalRepositoryProtocol? = nil,
        dataValidator: DataValidator? = nil,
        errorHandler: ErrorHandler? = nil
    ) -> DependencyContainer {
        let container = DependencyContainer()
        
        // Override dependencies if provided
        if let coreDataStack = coreDataStack {
            container.coreDataStack = coreDataStack
        }
        
        if let transactionRepository = transactionRepository {
            container.transactionRepository = transactionRepository
        }
        
        if let goalRepository = goalRepository {
            container.goalRepository = goalRepository
        }
        
        if let dataValidator = dataValidator {
            container.dataValidator = dataValidator
        }
        
        if let errorHandler = errorHandler {
            container.errorHandler = errorHandler
        }
        
        return container
    }
}

// MARK: - Environment Key
struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer.shared
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

// MARK: - View Modifier
struct DependencyContainerModifier: ViewModifier {
    let container: DependencyContainer
    
    func body(content: Content) -> some View {
        content
            .environment(\.dependencies, container)
    }
}

extension View {
    func injectDependencies(_ container: DependencyContainer = DependencyContainer.shared) -> some View {
        self.modifier(DependencyContainerModifier(container: container))
    }
}
