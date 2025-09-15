import SwiftUI

struct TransactionItem: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let amount: Double
    let iconName: String
    let iconColorName: String
    let iconBackgroundName: String
    let category: TransactionCategoryType
    let isIncome: Bool
    let linkedGoalName: String?
    let date: Date

    var iconColor: Color { Color.fromName(iconColorName) }
    var iconBackground: Color { Color.fromName(iconBackgroundName) }

    static func makeMockData() -> [TransactionItem] {
        let now = Date()
        let calendar = Calendar.current
        return [
            TransactionItem(id: UUID(), title: "Adobe Illustrator", subtitle: "Subscription fee", amount: 32, iconName: "cart", iconColorName: "orange", iconBackgroundName: "orange.opacity15", category: .essentials, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -2, to: now)!),
            TransactionItem(id: UUID(), title: "Spotify", subtitle: "Music subscription", amount: 10, iconName: "music.note", iconColorName: "purple", iconBackgroundName: "purple.opacity15", category: .leisure, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -10, to: now)!),
            TransactionItem(id: UUID(), title: "Savings Deposit", subtitle: "Monthly savings", amount: 100, iconName: "banknote", iconColorName: "green", iconBackgroundName: "green.opacity15", category: .savings, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -15, to: now)!),
            TransactionItem(id: UUID(), title: "Salary", subtitle: "Monthly income", amount: 2000, iconName: "dollarsign.circle", iconColorName: "mint", iconBackgroundName: "mint.opacity15", category: .income, isIncome: true, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -20, to: now)!),
            TransactionItem(id: UUID(), title: "Electric Bill", subtitle: "Utilities", amount: 60, iconName: "doc.text", iconColorName: "red", iconBackgroundName: "red.opacity15", category: .bills, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -25, to: now)!),
            TransactionItem(id: UUID(), title: "Miscellaneous", subtitle: "Other expense", amount: 25, iconName: "ellipsis", iconColorName: "gray", iconBackgroundName: "gray.opacity15", category: .other, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -30, to: now)!)
        ]
    }
}

enum TransactionCategoryType: String, CaseIterable, Identifiable {
    case essentials, leisure, savings, income, bills, other

    var id: String { rawValue }
    var label: String {
        switch self {
        case .essentials: return "Essentials"
        case .leisure: return "Leisure"
        case .savings: return "Savings"
        case .income: return "Income"
        case .bills: return "Bills"
        case .other: return "Other"
        }
    }
    var symbol: String { icons.first ?? "questionmark" }
    var icons: [String] {
        switch self {
        case .essentials: return [
            "cart", "fork.knife", "bag", "cup.and.saucer", "takeoutbag.and.cup.and.straw", "cart.badge.plus", "cart.badge.minus", "basket"
        ]
        case .leisure: return [
            "gamecontroller", "music.note", "music.mic", "film", "sportscourt", "theatermasks", "paintpalette", "headphones"
        ]
        case .savings: return [
            "banknote", "dollarsign.circle", "laptopcomputer", "car", "house", "gift", "creditcard", "cart", "bag", "airplane"
        ]
        case .income: return [
            "dollarsign.circle", "creditcard", "arrow.down.circle", "arrow.up.circle", "wallet.pass"
        ]
        case .bills: return [
            "doc.text", "calendar", "creditcard", "envelope", "tray.full"
        ]
        case .other: return [
            "ellipsis", "questionmark.circle", "star", "circle", "square", "app"
        ]
        }
    }
    var color: Color {
        switch self {
        case .essentials: return .orange
        case .leisure: return .purple
        case .savings: return RobinhoodColors.primary
        case .income: return .mint
        case .bills: return .red
        case .other: return .gray
        }
    }
}

// MARK: - Supporting Types
enum RecurringFrequency: String, CaseIterable, Identifiable, CustomStringConvertible {
    case daily, weekly, monthly, yearly
    var id: String { rawValue }
    var label: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    var description: String { label }
}

enum IncomeOrExpense: String, CaseIterable, Identifiable, CustomStringConvertible {
    case income = "Income"
    case expense = "Expense"
    var id: String { rawValue }
    var description: String { rawValue }
}

struct BoolOption: Hashable, Identifiable, CustomStringConvertible {
    let value: Bool
    var id: Bool { value }
    var description: String { value ? "Recurring" : "One Time" }
    init(_ value: Bool) { self.value = value }
    static func == (lhs: BoolOption, rhs: BoolOption) -> Bool { lhs.value == rhs.value }
    func hash(into hasher: inout Hasher) { hasher.combine(value) }
}

