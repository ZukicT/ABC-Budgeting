import Foundation

struct CurrencyList {
    static let all = [
        "USD (US Dollar)",
        "EUR (Euro)",
        "GBP (British Pound)",
        "JPY (Japanese Yen)",
        "CAD (Canadian Dollar)",
        "AUD (Australian Dollar)",
        "CHF (Swiss Franc)",
        "CNY (Chinese Yuan)",
        "SEK (Swedish Krona)",
        "NZD (New Zealand Dollar)",
        "MXN (Mexican Peso)",
        "SGD (Singapore Dollar)",
        "HKD (Hong Kong Dollar)",
        "NOK (Norwegian Krone)",
        "TRY (Turkish Lira)",
        "RUB (Russian Ruble)",
        "INR (Indian Rupee)",
        "BRL (Brazilian Real)",
        "ZAR (South African Rand)",
        "KRW (South Korean Won)"
    ]
    
    static func getCurrencyCode(from fullName: String) -> String {
        let components = fullName.components(separatedBy: " ")
        return components.first ?? "USD"
    }
    
    static func getCurrencySymbol(for code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        return formatter.currencySymbol ?? "$"
    }
}