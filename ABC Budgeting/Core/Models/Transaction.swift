import SwiftUI

struct Transaction: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let amount: Double
    let iconName: String
    let iconColorName: String
    let iconBackgroundName: String
    let category: TransactionCategory
    let isIncome: Bool
    let linkedGoalName: String?
    let date: Date

    var iconColor: Color { Color.fromName(iconColorName) }
    var iconBackground: Color { Color.fromName(iconBackgroundName) }

    static func makeMockData() -> [Transaction] {
        let now = Date()
        let calendar = Calendar.current
        return [
            Transaction(id: UUID(), title: "Adobe Illustrator", subtitle: "Subscription fee", amount: 32, iconName: "cart", iconColorName: "orange", iconBackgroundName: "orange.opacity15", category: .essentials, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -2, to: now)!),
            Transaction(id: UUID(), title: "Spotify", subtitle: "Music subscription", amount: 10, iconName: "music.note", iconColorName: "purple", iconBackgroundName: "purple.opacity15", category: .leisure, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -10, to: now)!),
            Transaction(id: UUID(), title: "Savings Deposit", subtitle: "Monthly savings", amount: 100, iconName: "banknote", iconColorName: "green", iconBackgroundName: "green.opacity15", category: .savings, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -15, to: now)!),
            Transaction(id: UUID(), title: "Salary", subtitle: "Monthly income", amount: 2000, iconName: "dollarsign.circle", iconColorName: "mint", iconBackgroundName: "mint.opacity15", category: .income, isIncome: true, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -20, to: now)!),
            Transaction(id: UUID(), title: "Electric Bill", subtitle: "Utilities", amount: 60, iconName: "doc.text", iconColorName: "red", iconBackgroundName: "red.opacity15", category: .bills, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -25, to: now)!),
            Transaction(id: UUID(), title: "Miscellaneous", subtitle: "Other expense", amount: 25, iconName: "ellipsis", iconColorName: "gray", iconBackgroundName: "gray.opacity15", category: .other, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -30, to: now)!)
        ]
    }
}

enum TransactionCategory: String, CaseIterable, Identifiable {
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
        case .savings: return .green
        case .income: return .mint
        case .bills: return .red
        case .other: return .gray
        }
    }
}

extension Color {
    static func fromName(_ name: String) -> Color {
        switch name {
        case "orange": return .orange
        case "purple": return .purple
        case "green": return .green
        case "mint": return .mint
        case "red": return .red
        case "gray": return .gray
        case "blue": return .blue
        case "orange.opacity15": return Color.orange.opacity(0.15)
        case "purple.opacity15": return Color.purple.opacity(0.15)
        case "green.opacity15": return Color.green.opacity(0.15)
        case "mint.opacity15": return Color.mint.opacity(0.15)
        case "red.opacity15": return Color.red.opacity(0.15)
        case "gray.opacity15": return Color.gray.opacity(0.15)
        case "blue.opacity15": return Color.blue.opacity(0.15)
        default: return .gray
        }
    }
}
