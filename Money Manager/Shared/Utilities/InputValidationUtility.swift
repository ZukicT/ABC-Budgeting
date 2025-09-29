import Foundation

struct InputValidationUtility {
    
    /// Validates and filters numeric input for currency amounts
    /// - Parameters:
    ///   - input: The input string to validate
    ///   - currentValue: The current value to update
    /// - Returns: Tuple containing (filteredInput, isValid)
    static func validateCurrencyInput(_ input: String, currentValue: inout String) -> (String, Bool) {
        // Filter to only allow digits and decimal point
        let filtered = input.filter { "0123456789.".contains($0) }
        
        // Update current value if filtering changed the input
        if filtered != input {
            currentValue = filtered
        }
        
        // Ensure only one decimal point
        let decimalCount = currentValue.filter { $0 == "." }.count
        if decimalCount > 1 {
            currentValue = String(currentValue.dropLast())
        }
        
        // Check if the result is a valid positive number
        guard let amountValue = Double(currentValue) else {
            return (currentValue, false)
        }
        let isValid = amountValue >= 0
        
        return (currentValue, isValid)
    }
    
    /// Validates if a string represents a valid currency amount
    /// - Parameter input: The input string to validate
    /// - Returns: True if valid currency amount, false otherwise
    static func isValidCurrencyAmount(_ input: String) -> Bool {
        guard let amount = Double(input) else { return false }
        return amount >= 0
    }
    
    /// Formats a currency amount string for display
    /// - Parameters:
    ///   - amount: The amount as a string
    ///   - currencySymbol: The currency symbol to prepend
    /// - Returns: Formatted currency string
    static func formatCurrencyDisplay(_ amount: String, currencySymbol: String) -> String {
        return "\(currencySymbol)\(amount)"
    }
}
