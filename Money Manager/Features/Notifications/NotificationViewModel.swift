import SwiftUI
import Foundation

// MARK: - Notification Item Model
struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let message: String
    let timestamp: Date
    let type: NotificationType
    var isRead: Bool
}

enum NotificationType {
    case info
    case warning
    case success
    case error
    
    var icon: String {
        switch self {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .info: return Constants.Colors.info
        case .warning: return Constants.Colors.warning
        case .success: return Constants.Colors.success
        case .error: return Constants.Colors.error
        }
    }
}

/**
 * NotificationViewModel
 * 
 * Manages local notification data and state for the NotificationView.
 * All data is stored locally on device - no database or API calls.
 * 
 * Features:
 * - Local data management with @Published properties
 * - Notification management (mark as read, mark all read)
 * - Computed properties for stats
 * - Production-ready local data handling
 * 
 * Last Review: 2025-01-26
 * Status: Production Ready
 */

@MainActor
class NotificationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var notifications: [NotificationItem] = []
    @Published var hasDataLoaded = false
    
    // MARK: - Computed Properties
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    var todayCount: Int {
        let calendar = Calendar.current
        let today = Date()
        return notifications.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }.count
    }
    
    // MARK: - Initialization
    init() {
        // Initialize with empty notifications
        notifications = []
        hasDataLoaded = true // No loading needed for local data
    }
    
    // MARK: - Notification Management
    func markAsRead(_ notification: NotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }
    
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
    
    func clearAllNotifications() {
        notifications.removeAll()
    }
}
