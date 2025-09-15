import SwiftUI

// MARK: - Notification Category Models

enum NotificationCategory: String, CaseIterable {
    case alerts = "alerts"
    case transactions = "transactions"
    case goals = "goals"
    case upcoming = "upcoming"
    
    var title: String {
        switch self {
        case .alerts:
            return "Alerts"
        case .transactions:
            return "Transactions"
        case .goals:
            return "Goals & Milestones"
        case .upcoming:
            return "Upcoming"
        }
    }
    
    var iconName: String {
        switch self {
        case .alerts:
            return "exclamationmark.triangle.fill"
        case .transactions:
            return "arrow.left.arrow.right"
        case .goals:
            return "target"
        case .upcoming:
            return "clock.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .alerts:
            return RobinhoodColors.error
        case .transactions:
            return RobinhoodColors.success
        case .goals:
            return RobinhoodColors.primary
        case .upcoming:
            return RobinhoodColors.warning
        }
    }
    
    var priority: Int {
        switch self {
        case .alerts:
            return 1
        case .upcoming:
            return 2
        case .goals:
            return 3
        case .transactions:
            return 4
        }
    }
}

struct NotificationCategoryGroup {
    let category: NotificationCategory
    let notifications: [NotificationItem]
}

// MARK: - Notification Category Section

struct NotificationCategorySection: View {
    let category: NotificationCategory
    let notifications: [NotificationItem]
    let notificationService: NotificationService
    
    @State private var isExpanded: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Category Header
            categoryHeader
            
            if isExpanded {
                // Notifications List
                LazyVStack(spacing: 8) {
                    ForEach(notifications) { notification in
                        EnhancedNotificationCard(notification: notification) {
                            notificationService.markAsRead(notification)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button("Delete", role: .destructive) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    notificationService.removeNotification(notification)
                                }
                            }
                            .tint(RobinhoodColors.error)
                            
                            if !notification.isRead {
                                Button("Mark Read") {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        notificationService.markAsRead(notification)
                                    }
                                }
                                .tint(RobinhoodColors.success)
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            if !notification.isRead {
                                Button("Mark Read") {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        notificationService.markAsRead(notification)
                                    }
                                }
                                .tint(RobinhoodColors.success)
                            }
                        }
                    }
                }
                .padding(.top, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.bottom, 24)
    }
    
    private var categoryHeader: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        }) {
            HStack(spacing: 12) {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: category.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(category.color)
                }
                
                // Category Title and Count
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.title)
                        .font(RobinhoodTypography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Text("\(notifications.count) notification\(notifications.count == 1 ? "" : "s")")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                }
                
                Spacer()
                
                // Expand/Collapse Icon
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(RobinhoodColors.textTertiary)
                    .rotationEffect(.degrees(isExpanded ? 0 : 180))
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(RobinhoodColors.cardBackground)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - NotificationView

struct NotificationView: View {
    // MARK: - Properties
    @ObservedObject var notificationService: NotificationService
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if notificationService.notifications.isEmpty {
                    emptyStateView
                } else {
                    headerSection
                    notificationContent
                }
            }
            .background(RobinhoodColors.background)
            .navigationTitle("")
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(RobinhoodTypography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(RobinhoodColors.success)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !notificationService.notifications.isEmpty {
                        Menu {
                            Button("Mark All Read") {
                                notificationService.markAllAsRead()
                            }
                            
                            Button("Clear All", role: .destructive) {
                                notificationService.clearAllNotifications()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(RobinhoodColors.textSecondary)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    /// Robinhood-style header section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Title and stats
            VStack(alignment: .leading, spacing: 12) {
                Text("Notifications")
                    .font(RobinhoodTypography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                // Unread count and actions
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(RobinhoodColors.success)
                            .frame(width: 8, height: 8)
                        
                        Text("\(notificationService.unreadCount) unread")
                            .font(RobinhoodTypography.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(RobinhoodColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    if notificationService.unreadCount > 0 {
                        Button("Mark All Read") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                notificationService.markAllAsRead()
                            }
                        }
                        .font(RobinhoodTypography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(RobinhoodColors.success)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(RobinhoodColors.success.opacity(0.1))
                        )
                    }
                }
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .background(RobinhoodColors.background)
    }
    
    /// Robinhood-style notification list with enhanced hierarchy and categorization
    private var notificationContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(notificationCategories, id: \.category) { categoryGroup in
                    NotificationCategorySection(
                        category: categoryGroup.category,
                        notifications: categoryGroup.notifications,
                        notificationService: notificationService
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(RobinhoodColors.background)
        .refreshable {
            // Add refresh functionality if needed
            try? await Task.sleep(nanoseconds: 500_000_000) // Simulate refresh
        }
    }
    
    /// Group notifications by category for better hierarchy
    private var notificationCategories: [NotificationCategoryGroup] {
        let grouped = Dictionary(grouping: notificationService.notifications) { notification in
            notification.type.category
        }
        
        return NotificationCategory.allCases.compactMap { category in
            guard let notifications = grouped[category], !notifications.isEmpty else { return nil }
            return NotificationCategoryGroup(
                category: category,
                notifications: notifications.sorted { $0.date > $1.date }
            )
        }
    }
    
    /// Robinhood-style empty state view
    private var emptyStateView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 20) {
                // Notification icon with background
                ZStack {
                    Circle()
                        .fill(RobinhoodColors.textTertiary.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "bell.slash")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(RobinhoodColors.textTertiary)
                }
                
                VStack(spacing: 12) {
                    Text("No Notifications")
                        .font(RobinhoodTypography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Text("You're all caught up! New notifications will appear here.")
                        .font(RobinhoodTypography.body)
                        .foregroundColor(RobinhoodColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .background(RobinhoodColors.background)
    }
    
}

// MARK: - Enhanced Notification Card

struct EnhancedNotificationCard: View {
    let notification: NotificationItem
    let onTap: () -> Void
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: notification.date, relativeTo: Date())
    }
    
    private var priorityColor: Color {
        switch notification.type {
        case .budgetAlert:
            return RobinhoodColors.error
        case .upcomingTransaction, .upcomingIncome:
            return RobinhoodColors.warning
        case .goalMilestone:
            return RobinhoodColors.primary
        case .newTransaction:
            return RobinhoodColors.success
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Main Content
                HStack(alignment: .top, spacing: 16) {
                    // Priority Indicator and Icon
                    VStack(spacing: 8) {
                        // Priority indicator line
                        RoundedRectangle(cornerRadius: 2)
                            .fill(priorityColor)
                            .frame(width: 4, height: 32)
                        
                        // Notification type icon
                        ZStack {
                            Circle()
                                .fill(priorityColor.opacity(0.15))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: notification.type.iconName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(priorityColor)
                        }
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 8) {
                        // Title and status
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(notification.title)
                                    .font(RobinhoodTypography.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(RobinhoodColors.textPrimary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                
                                Text(notification.message)
                                    .font(RobinhoodTypography.body)
                                    .foregroundColor(RobinhoodColors.textSecondary)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Spacer()
                            
                            // Status indicators
                            VStack(alignment: .trailing, spacing: 8) {
                                if !notification.isRead {
                                    Circle()
                                        .fill(priorityColor)
                                        .frame(width: 8, height: 8)
                                }
                                
                                Text(timeAgo)
                                    .font(RobinhoodTypography.caption2)
                                    .foregroundColor(RobinhoodColors.textTertiary)
                            }
                        }
                        
                        // Action buttons (for high priority notifications)
                        if notification.type == .budgetAlert {
                            HStack(spacing: 12) {
                                Button("View Details") {
                                    onTap()
                                }
                                .font(RobinhoodTypography.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(priorityColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(priorityColor.opacity(0.1))
                                )
                                
                                Spacer()
                            }
                            .padding(.top, 4)
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(notification.isRead ? RobinhoodColors.cardBackground : priorityColor.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                    )
            )
        }
        .buttonStyle(EnhancedNotificationButtonStyle())
    }
}

// MARK: - Legacy RobinhoodNotificationCard (for backward compatibility)

struct RobinhoodNotificationCard: View {
    let notification: NotificationItem
    let onTap: () -> Void
    
    var body: some View {
        EnhancedNotificationCard(notification: notification, onTap: onTap)
    }
}

// MARK: - Custom Button Styles

struct NotificationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct EnhancedNotificationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.99 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#if DEBUG
struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        let service = NotificationService()
        service.addDemoNotifications()
        return NotificationView(notificationService: service)
    }
}
#endif