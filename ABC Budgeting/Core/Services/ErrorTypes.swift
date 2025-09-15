import Foundation

// MARK: - Transaction Errors
enum TransactionError: LocalizedError {
    case invalidAmount
    case invalidCategory
    case invalidDescription
    case transactionNotFound
    case saveFailed
    case fetchFailed
    case deleteFailed
    case updateFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Transaction amount must be greater than zero"
        case .invalidCategory:
            return "Transaction category cannot be empty"
        case .invalidDescription:
            return "Transaction description is invalid"
        case .transactionNotFound:
            return "Transaction not found"
        case .saveFailed:
            return "Failed to save transaction"
        case .fetchFailed:
            return "Failed to fetch transactions"
        case .deleteFailed:
            return "Failed to delete transaction"
        case .updateFailed:
            return "Failed to update transaction"
        }
    }
}

// MARK: - Goal Errors
enum GoalError: LocalizedError {
    case invalidName
    case invalidTargetAmount
    case invalidTargetDate
    case goalNotFound
    case saveFailed
    case fetchFailed
    case deleteFailed
    case updateFailed
    case invalidProgressAmount
    
    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Goal name cannot be empty"
        case .invalidTargetAmount:
            return "Target amount must be greater than zero"
        case .invalidTargetDate:
            return "Target date is invalid"
        case .goalNotFound:
            return "Goal not found"
        case .saveFailed:
            return "Failed to save goal"
        case .fetchFailed:
            return "Failed to fetch goals"
        case .deleteFailed:
            return "Failed to delete goal"
        case .updateFailed:
            return "Failed to update goal"
        case .invalidProgressAmount:
            return "Progress amount cannot be negative"
        }
    }
}

// MARK: - Core Data Errors
enum CoreDataError: LocalizedError {
    case contextNotFound
    case saveFailed
    case fetchFailed
    case deleteFailed
    case invalidEntity
    case relationshipNotFound
    
    var errorDescription: String? {
        switch self {
        case .contextNotFound:
            return "Core Data context not found"
        case .saveFailed:
            return "Failed to save to Core Data"
        case .fetchFailed:
            return "Failed to fetch from Core Data"
        case .deleteFailed:
            return "Failed to delete from Core Data"
        case .invalidEntity:
            return "Invalid Core Data entity"
        case .relationshipNotFound:
            return "Core Data relationship not found"
        }
    }
}
