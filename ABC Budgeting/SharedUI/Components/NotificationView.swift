import SwiftUI

struct NotificationView: View {
    @ObservedObject var notificationService: NotificationService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter: NotificationFilter = .all
    
    enum NotificationFilter: String, CaseIterable {
        case all = "All"
        case unread = "Unread"
        case newTransactions = "New Transactions"
        case upcoming = "Upcoming"
        case goals = "Goals"
        
        var iconName: String {
            switch self {
            case .all: return "bell"
            case .unread: return "circle.fill"
            case .newTransactions: return "plus.circle"
            case .upcoming: return "clock"
            case .goals: return "target"
            }
        }
    }
    
    private var filteredNotifications: [NotificationItem] {
        let notifications = notificationService.notifications
        
        switch selectedFilter {
        case .all:
            return notifications
        case .unread:
            return notifications.filter { !$0.isRead }
        case .newTransactions:
            return notifications.filter { $0.type == .newTransaction }
        case .upcoming:
            return notifications.filter { $0.type == .upcomingTransaction || $0.type == .upcomingIncome }
        case .goals:
            return notifications.filter { $0.type == .goalMilestone }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background matching Overview tab
                LinearGradient(
                    colors: [Color(hex: "f8fafc"), Color(hex: "e2e8f0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                // Filter Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(NotificationFilter.allCases, id: \.self) { filter in
                            FilterChip(
                                title: filter.rawValue,
                                iconName: filter.iconName,
                                isSelected: selectedFilter == filter,
                                count: getCount(for: filter)
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
                .background(AppColors.background.opacity(0.5))
                
                // Notifications List
                if filteredNotifications.isEmpty {
                    EmptyNotificationsView(filter: selectedFilter)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredNotifications) { notification in
                                NotificationRow(
                                    notification: notification,
                                    onTap: {
                                        notificationService.markAsRead(notification)
                                    },
                                    onDelete: {
                                        notificationService.removeNotification(notification)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
                
                Spacer()
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        notificationService.clearAllNotifications()
                    }
                    .disabled(notificationService.notifications.isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Mark All Read") {
                        notificationService.markAllAsRead()
                    }
                    .disabled(notificationService.unreadCount == 0)
                }
            }
        }
    }
    
    private func getCount(for filter: NotificationFilter) -> Int {
        let notifications = notificationService.notifications
        
        switch filter {
        case .all:
            return notifications.count
        case .unread:
            return notifications.filter { !$0.isRead }.count
        case .newTransactions:
            return notifications.filter { $0.type == .newTransaction }.count
        case .upcoming:
            return notifications.filter { $0.type == .upcomingTransaction || $0.type == .upcomingIncome }.count
        case .goals:
            return notifications.filter { $0.type == .goalMilestone }.count
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.caption.weight(.medium))
                
                Text(title)
                    .font(.caption.weight(.medium))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? .white : .primary)
                        )
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? AppColors.primary : AppColors.background.opacity(0.3))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Notification Row
struct NotificationRow: View {
    let notification: NotificationItem
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteConfirmation = false
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: notification.date, relativeTo: Date())
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(notification.type.color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: notification.type.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(notification.type.color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notification.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(AppColors.primary)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text(notification.message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(timeAgo)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Delete button
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(notification.isRead ? AppColors.background.opacity(0.3) : AppColors.card)
                    .shadow(color: AppColors.cardShadow, radius: 2, y: 1)
            )
        }
        .buttonStyle(.plain)
        .confirmationDialog("Delete Notification", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this notification?")
        }
    }
}

// MARK: - Empty State
struct EmptyNotificationsView: View {
    let filter: NotificationView.NotificationFilter
    
    private var emptyStateContent: (title: String, message: String, iconName: String) {
        switch filter {
        case .all:
            return (
                title: "No notifications yet",
                message: "You'll see notifications about new transactions, upcoming payments, and goal milestones here.",
                iconName: "bell"
            )
        case .unread:
            return (
                title: "All caught up!",
                message: "You have no unread notifications.",
                iconName: "checkmark.circle"
            )
        case .newTransactions:
            return (
                title: "No new transactions",
                message: "New transaction notifications will appear here when you add expenses or income.",
                iconName: "plus.circle"
            )
        case .upcoming:
            return (
                title: "No upcoming transactions",
                message: "Upcoming payment and income notifications will appear here.",
                iconName: "clock"
            )
        case .goals:
            return (
                title: "No goal notifications",
                message: "Goal milestone notifications will appear here when you reach savings targets.",
                iconName: "target"
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: emptyStateContent.iconName)
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.secondary.opacity(0.6))
            
            VStack(spacing: 8) {
                Text(emptyStateContent.title)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.secondary)
                
                Text(emptyStateContent.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
}

#Preview {
    NotificationView(notificationService: NotificationService())
}
