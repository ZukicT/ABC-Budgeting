//
//  InputValidationUtility.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Utility for validating and formatting user input, particularly currency
//  amounts. Provides input filtering, validation, and formatting functions
//  to ensure data integrity and consistent user experience.
//
//  Review Date: September 29, 2025
//

import Foundation

struct InputValidationUtility {
    
    static func validateCurrencyInput(_ input: String, currentValue: inout String) -> (String, Bool) {
        let filtered = input.filter { "0123456789.".contains($0) }
        
        if filtered != input {
            currentValue = filtered
        }
        
        let decimalCount = currentValue.filter { $0 == "." }.count
        if decimalCount > 1 {
            currentValue = String(currentValue.dropLast())
        }
        
        guard let amountValue = Double(currentValue) else {
            return (currentValue, false)
        }
        let isValid = amountValue >= 0
        
        return (currentValue, isValid)
    }
    
    static func isValidCurrencyAmount(_ input: String) -> Bool {
        guard let amount = Double(input) else { return false }
        return amount >= 0
    }
    
    static func formatCurrencyDisplay(_ amount: String, currencySymbol: String) -> String {
        return "\(currencySymbol)\(amount)"
    }
}
