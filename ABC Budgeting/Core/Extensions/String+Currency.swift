import Foundation

extension String {
    func toCurrency() -> String {
        // Remove any non-numeric characters except decimal point
        let cleaned = self.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        
        // Convert to Double and format as currency
        if let amount = Double(cleaned) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
        }
        
        return "$0.00"
    }
    
    func fromCurrency() -> Double {
        // Remove currency symbols and convert to Double
        let cleaned = self.replacingOccurrences(of: "[^0-9.-]", with: "", options: .regularExpression)
        return Double(cleaned) ?? 0.0
    }
    
    func isValidCurrency() -> Bool {
        let cleaned = self.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        return Double(cleaned) != nil
    }
}