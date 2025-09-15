import SwiftUI

struct NotificationItem: Identifiable, Hashable {
    let id: UUID
    let type: NotificationType
    let title: String
    let message: String
    let date: Date
    let isRead: Bool
    let relatedTransactionId: UUID?
    let relatedGoalId: UUID?
    
    init(
        type: NotificationType,
        title: String,
        message: String,
        date: Date = Date(),
        isRead: Bool = false,
        relatedTransactionId: UUID? = nil,
        relatedGoalId: UUID? = nil
    ) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.message = message
        self.date = date
        self.isRead = isRead
        self.relatedTransactionId = relatedTransactionId
        self.relatedGoalId = relatedGoalId
    }
}

enum NotificationType: String, CaseIterable {
    case newTransaction = "new_transaction"
    case upcomingTransaction = "upcoming_transaction"
    case upcomingIncome = "upcoming_income"
    case goalMilestone = "goal_milestone"
    case budgetAlert = "budget_alert"
    
    var iconName: String {
        switch self {
        case .newTransaction:
            return "plus.circle.fill"
        case .upcomingTransaction:
            return "clock.fill"
        case .upcomingIncome:
            return "arrow.down.circle.fill"
        case .goalMilestone:
            return "target"
        case .budgetAlert:
            return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .newTransaction:
            return AppColors.primary
        case .upcomingTransaction:
            return AppColors.secondary
        case .upcomingIncome:
            return AppColors.secondary
        case .goalMilestone:
            return AppColors.primary
        case .budgetAlert:
            return AppColors.primary
        }
    }
    
    var priority: Int {
        switch self {
        case .budgetAlert:
            return 1
        case .upcomingTransaction, .upcomingIncome:
            return 2
        case .goalMilestone:
            return 3
        case .newTransaction:
            return 4
        }
    }
    
    var category: NotificationCategory {
        switch self {
        case .budgetAlert:
            return .alerts
        case .newTransaction:
            return .transactions
        case .goalMilestone:
            return .goals
        case .upcomingTransaction, .upcomingIncome:
            return .upcoming
        }
    }
}

// MARK: - Notification Service
@MainActor
class NotificationService: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    @Published var unreadCount: Int = 0
    
    private let maxNotifications = 50
    
    init() {
        loadNotifications()
    }
    
    // MARK: - Public Methods
    
    func addNotification(_ notification: NotificationItem) {
        notifications.insert(notification, at: 0)
        
        // Keep only the most recent notifications
        if notifications.count > maxNotifications {
            notifications = Array(notifications.prefix(maxNotifications))
        }
        
        updateUnreadCount()
        saveNotifications()
    }
    
    func markAsRead(_ notification: NotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index] = NotificationItem(
                type: notification.type,
                title: notification.title,
                message: notification.message,
                date: notification.date,
                isRead: true,
                relatedTransactionId: notification.relatedTransactionId,
                relatedGoalId: notification.relatedGoalId
            )
            updateUnreadCount()
            saveNotifications()
        }
    }
    
    func markAllAsRead() {
        notifications = notifications.map { notification in
            NotificationItem(
                type: notification.type,
                title: notification.title,
                message: notification.message,
                date: notification.date,
                isRead: true,
                relatedTransactionId: notification.relatedTransactionId,
                relatedGoalId: notification.relatedGoalId
            )
        }
        updateUnreadCount()
        saveNotifications()
    }
    
    func clearAllNotifications() {
        notifications.removeAll()
        updateUnreadCount()
        saveNotifications()
    }
    
    func removeNotification(_ notification: NotificationItem) {
        notifications.removeAll { $0.id == notification.id }
        updateUnreadCount()
        saveNotifications()
    }
    
    // MARK: - Transaction Notifications
    
    func addNewTransactionNotification(for transaction: TransactionItem) {
        let type: NotificationType = transaction.isIncome ? .upcomingIncome : .newTransaction
        let title = transaction.isIncome ? "New Income Added" : "New Expense Added"
        let message = "\(transaction.title) - \(transaction.amount.formatted(.currency(code: "USD")))"
        
        let notification = NotificationItem(
            type: type,
            title: title,
            message: message,
            relatedTransactionId: transaction.id
        )
        
        addNotification(notification)
    }
    
    func addUpcomingTransactionNotification(for transaction: TransactionItem) {
        let title = transaction.isIncome ? "Upcoming Income" : "Upcoming Expense"
        let message = "\(transaction.title) due soon - \(transaction.amount.formatted(.currency(code: "USD")))"
        
        let notification = NotificationItem(
            type: transaction.isIncome ? .upcomingIncome : .upcomingTransaction,
            title: title,
            message: message,
            relatedTransactionId: transaction.id
        )
        
        addNotification(notification)
    }
    
    // MARK: - Goal Notifications
    
    func addGoalMilestoneNotification(for goal: GoalFormItem, milestone: String) {
        let notification = NotificationItem(
            type: .goalMilestone,
            title: "Goal Milestone Reached!",
            message: "\(goal.name): \(milestone)",
            relatedGoalId: UUID(uuidString: goal.id) ?? UUID()
        )
        
        addNotification(notification)
    }
    
    func addBudgetAlertNotification(message: String) {
        let notification = NotificationItem(
            type: .budgetAlert,
            title: "Budget Alert",
            message: message
        )
        
        addNotification(notification)
    }
    
    // MARK: - Private Methods
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
    
    private func saveNotifications() {
        // In a real app, this would save to Core Data or UserDefaults
        // For now, we'll just keep them in memory
    }
    
    private func loadNotifications() {
        // In a real app, this would load from Core Data or UserDefaults
        // For now, we'll start with an empty array
        notifications = []
        updateUnreadCount()
    }
    
    // MARK: - Demo Data
    
    func addDemoNotifications() {
        let now = Date()
        let calendar = Calendar.current
        
        // Add some demo notifications
        addNotification(NotificationItem(
            type: .newTransaction,
            title: "New Expense Added",
            message: "Groceries - $120.00",
            date: calendar.date(byAdding: .minute, value: -5, to: now) ?? now
        ))
        
        addNotification(NotificationItem(
            type: .upcomingTransaction,
            title: "Upcoming Expense",
            message: "Netflix Subscription - $15.00",
            date: calendar.date(byAdding: .hour, value: -2, to: now) ?? now
        ))
        
        addNotification(NotificationItem(
            type: .upcomingIncome,
            title: "Upcoming Income",
            message: "Salary - $3,000.00",
            date: calendar.date(byAdding: .day, value: -1, to: now) ?? now
        ))
        
        addNotification(NotificationItem(
            type: .goalMilestone,
            title: "Goal Milestone Reached!",
            message: "Vacation Fund: 40% Complete",
            date: calendar.date(byAdding: .day, value: -2, to: now) ?? now
        ))
    }
}
