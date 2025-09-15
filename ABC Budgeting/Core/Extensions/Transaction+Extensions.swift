import Foundation
import CoreData

// MARK: - Transaction Extensions for UI Integration
extension Transaction {
    
    /// Convert Core Data Transaction to TransactionItem for UI display
    func toTransactionItem() -> TransactionItem {
        return TransactionItem(
            id: id ?? UUID(),
            title: title ?? transactionDescription ?? "Transaction",
            subtitle: subtitle ?? category ?? "Transaction",
            amount: amount,
            iconName: iconName ?? getIconName(for: category ?? "other"),
            iconColorName: iconColorName ?? getIconColorName(for: category ?? "other"),
            iconBackgroundName: iconBackgroundName ?? getIconBackgroundName(for: category ?? "other"),
            category: TransactionCategoryType(rawValue: category ?? "other") ?? .other,
            isIncome: isIncome,
            linkedGoalName: linkedGoalName,
            date: date ?? createdDate ?? Date()
        )
    }
    
    /// Get appropriate icon name based on category
    private func getIconName(for category: String) -> String {
        let categoryType = TransactionCategoryType(rawValue: category) ?? .other
        return categoryType.symbol
    }
    
    /// Get appropriate icon color name based on category
    private func getIconColorName(for category: String) -> String {
        let categoryType = TransactionCategoryType(rawValue: category) ?? .other
        return categoryType.color.toHex()
    }
    
    /// Get appropriate icon background name based on category
    private func getIconBackgroundName(for category: String) -> String {
        let categoryType = TransactionCategoryType(rawValue: category) ?? .other
        return "\(categoryType.color.toHex()).opacity15"
    }
}

// MARK: - TransactionItem Extensions for Core Data Integration
extension TransactionItem {
    
    /// Convert TransactionItem to Core Data Transaction
    func toTransaction(context: NSManagedObjectContext) -> Transaction {
        let transaction = Transaction(context: context)
        transaction.id = id
        transaction.amount = amount
        transaction.category = category.rawValue
        transaction.title = title
        transaction.subtitle = subtitle
        transaction.transactionDescription = title
        transaction.isIncome = isIncome
        transaction.createdDate = date
        transaction.date = date
        transaction.lastModified = Date()
        transaction.transactionType = isIncome ? "income" : "expense"
        transaction.iconName = iconName
        transaction.iconColorName = iconColorName
        transaction.iconBackgroundName = iconBackgroundName
        transaction.linkedGoalName = linkedGoalName
        return transaction
    }
}
