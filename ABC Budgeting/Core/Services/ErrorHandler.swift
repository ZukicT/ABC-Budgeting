import Foundation

class ErrorHandler {
    
    enum AppError: LocalizedError {
        case coreDataError(String)
        case networkError(String)
        case validationError(String)
        case fileSystemError(String)
        case unknownError(String)
        
        var errorDescription: String? {
            switch self {
            case .coreDataError(let message):
                return "Data Error: \(message)"
            case .networkError(let message):
                return "Network Error: \(message)"
            case .validationError(let message):
                return "Validation Error: \(message)"
            case .fileSystemError(let message):
                return "File System Error: \(message)"
            case .unknownError(let message):
                return "Unknown Error: \(message)"
            }
        }
    }
    
    func handle(_ error: Error, context: String = "") {
        print("Error in \(context): \(error.localizedDescription)")
    }
    
    func getUserFriendlyMessage(for error: Error) -> String {
        if let appError = error as? AppError {
            switch appError {
            case .coreDataError:
                return "There was a problem saving your data. Please try again."
            case .networkError:
                return "Please check your internet connection and try again."
            case .validationError(let message):
                return message
            case .fileSystemError:
                return "There was a problem accessing your files. Please try again."
            case .unknownError:
                return "Something went wrong. Please try again."
            }
        }
        return "An unexpected error occurred. Please try again."
    }
}