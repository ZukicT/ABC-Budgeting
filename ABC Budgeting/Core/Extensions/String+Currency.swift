import Foundation

extension String {
    func currencyInputFormatting(currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        let cleaned = self.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        let doubleValue = Double(cleaned) ?? 0
        return formatter.string(from: NSNumber(value: doubleValue)) ?? self
    }
} 