import Foundation

class DataValidator {
    
    // MARK: - Transaction Validation
    
    func validateTransaction(amount: Double, title: String, category: String) -> ValidationResult {
        var errors: [String] = []
        
        // Validate amount
        if amount <= 0 {
            errors.append("Amount must be greater than 0")
        }
        
        if amount > 1_000_000 {
            errors.append("Amount seems too large. Please verify the amount.")
        }
        
        // Validate title
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Title is required")
        }
        
        if title.count > 100 {
            errors.append("Title is too long (maximum 100 characters)")
        }
        
        // Validate category
        if category.isEmpty {
            errors.append("Category is required")
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
    
    // MARK: - Goal Validation
    
    func validateGoal(name: String, targetAmount: Double, targetDate: Date) -> ValidationResult {
        var errors: [String] = []
        
        // Validate name
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Goal name is required")
        }
        
        if name.count > 100 {
            errors.append("Goal name is too long (maximum 100 characters)")
        }
        
        // Validate target amount
        if targetAmount <= 0 {
            errors.append("Target amount must be greater than 0")
        }
        
        if targetAmount > 10_000_000 {
            errors.append("Target amount seems too large. Please verify the amount.")
        }
        
        // Validate target date
        if targetDate <= Date() {
            errors.append("Target date must be in the future")
        }
        
        let calendar = Calendar.current
        let yearsFromNow = calendar.dateComponents([.year], from: Date(), to: targetDate).year ?? 0
        if yearsFromNow > 50 {
            errors.append("Target date is too far in the future")
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
    
    // MARK: - User Input Validation
    
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func validateCurrencyAmount(_ amount: String) -> Bool {
        let cleaned = amount.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        guard let value = Double(cleaned) else { return false }
        return value >= 0 && value <= 1_000_000
    }
    
    func sanitizeInput(_ input: String) -> String {
        return input.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct ValidationResult {
    let isValid: Bool
    let errors: [String]
    
    var errorMessage: String {
        return errors.joined(separator: "\n")
    }
}