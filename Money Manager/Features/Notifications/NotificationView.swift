import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var notifications: [NotificationItem] = [
        NotificationItem(
            id: "1",
            title: "Budget Alert",
            message: "You've spent 80% of your Food budget",
            timestamp: Date().addingTimeInterval(-3600),
            type: .warning,
            isRead: false
        ),
        NotificationItem(
            id: "2",
            title: "Payment Reminder",
            message: "Auto Loan payment due in 3 days",
            timestamp: Date().addingTimeInterval(-7200),
            type: .info,
            isRead: false
        ),
        NotificationItem(
            id: "3",
            title: "Transaction Added",
            message: "New transaction: Coffee Shop - $4.50",
            timestamp: Date().addingTimeInterval(-14400),
            type: .success,
            isRead: true
        ),
        NotificationItem(
            id: "4",
            title: "Budget Created",
            message: "New budget category 'Entertainment' added",
            timestamp: Date().addingTimeInterval(-28800),
            type: .success,
            isRead: true
        ),
        NotificationItem(
            id: "5",
            title: "Weekly Summary",
            message: "Your spending this week: $245.30",
            timestamp: Date().addingTimeInterval(-86400),
            type: .info,
            isRead: true
        )
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with stats
                VStack(spacing: Constants.UI.Spacing.medium) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notifications")
                                .font(Constants.Typography.H2.font)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            Text("\(unreadCount) unread")
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(Constants.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button("Mark All Read") {
                            markAllAsRead()
                        }
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    }
                    
                    // Quick stats
                    HStack(spacing: Constants.UI.Spacing.large) {
                        NotificationStatCard(
                            title: "Total",
                            value: "\(notifications.count)",
                            color: Constants.Colors.textPrimary
                        )
                        
                        NotificationStatCard(
                            title: "Unread",
                            value: "\(unreadCount)",
                            color: Constants.Colors.warning
                        )
                        
                        NotificationStatCard(
                            title: "Today",
                            value: "\(todayCount)",
                            color: Constants.Colors.info
                        )
                    }
                }
                .padding(.horizontal, Constants.UI.Padding.screenMargin)
                .padding(.top, Constants.UI.Spacing.medium)
                .padding(.bottom, Constants.UI.Spacing.large)
                .background(Constants.Colors.backgroundPrimary)
                
                // Notifications list
                if notifications.isEmpty {
                    EmptyNotificationsView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(notifications) { notification in
                                NotificationRow(notification: notification) {
                                    markAsRead(notification)
                                }
                                
                                if notification.id != notifications.last?.id {
                                    Rectangle()
                                        .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                                        .frame(height: 1)
                                        .padding(.leading, 60) // Align with notification content
                                }
                            }
                        }
                        .padding(.horizontal, Constants.UI.Padding.screenMargin)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    private var todayCount: Int {
        let calendar = Calendar.current
        let today = Date()
        return notifications.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }.count
    }
    
    // MARK: - Actions
    private func markAsRead(_ notification: NotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }
    
    private func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
}

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

// MARK: - Notification Stat Card
private struct NotificationStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Constants.Typography.H3.font)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(Constants.Typography.Caption.font)
                .foregroundColor(Constants.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Notification Row
private struct NotificationRow: View {
    let notification: NotificationItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: Constants.UI.Spacing.medium) {
                // Notification icon
                Image(systemName: notification.type.icon)
                    .font(.title3)
                    .foregroundColor(notification.type.color)
                    .frame(width: 24, height: 24)
                
                // Notification content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notification.title)
                            .font(Constants.Typography.Body.font)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(Constants.Colors.warning)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text(notification.message)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text(timeAgoString(from: notification.timestamp))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textTertiary)
                }
                
                Spacer()
            }
            .padding(.vertical, Constants.UI.Spacing.medium)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(notification.isRead ? 0.7 : 1.0)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Empty Notifications View
private struct EmptyNotificationsView: View {
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(Constants.Colors.textTertiary)
            
            VStack(spacing: Constants.UI.Spacing.small) {
                Text("No Notifications")
                    .font(Constants.Typography.H3.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Text("You're all caught up! We'll notify you when there's something important.")
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, Constants.UI.Padding.screenMargin)
    }
}

#Preview {
    NotificationView()
}
