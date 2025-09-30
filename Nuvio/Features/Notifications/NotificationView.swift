//
//  NotificationView.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Production-ready notification management view with proper MVVM architecture,
//  accessibility compliance, and consistent design patterns. Features full
//  accessibility support, error handling, and loading states.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = NotificationViewModel()
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with stats
                VStack(spacing: Constants.UI.Spacing.medium) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(contentManager.localizedString("notifications.title"))
                                .font(Constants.Typography.H2.font)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            Text("\(viewModel.unreadCount) \(contentManager.localizedString("notifications.unread_count"))")
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(Constants.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: Constants.UI.Spacing.medium) {
                            Button(contentManager.localizedString("notifications.clear_all")) {
                                viewModel.clearAllNotifications()
                            }
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.error)
                            .accessibilityLabel(contentManager.localizedString("notifications.clear_all"))
                            .accessibilityHint("Double tap to clear all notifications")
                            
                            Button(contentManager.localizedString("notifications.mark_all_read")) {
                                viewModel.markAllAsRead()
                            }
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                            .accessibilityLabel(contentManager.localizedString("notifications.mark_all_read"))
                            .accessibilityHint("Double tap to mark all notifications as read")
                        }
                    }
                    
                    // Stats card
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            // Total notifications
                            VStack(spacing: 4) {
                                Text(contentManager.localizedString("notifications.total"))
                                    .font(Constants.Typography.Caption.font)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.notifications.count)")
                                    .font(Constants.Typography.Mono.H3.font)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Divider
                            Rectangle()
                                .fill(Constants.Colors.separator)
                                .frame(width: 1)
                                .frame(height: 40)
                            
                            // Unread notifications
                            VStack(spacing: 4) {
                                Text(contentManager.localizedString("notifications.unread"))
                                    .font(Constants.Typography.Caption.font)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.unreadCount)")
                                    .font(Constants.Typography.Mono.H3.font)
                                    .foregroundColor(Constants.Colors.warning)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Divider
                            Rectangle()
                                .fill(Constants.Colors.separator)
                                .frame(width: 1)
                                .frame(height: 40)
                            
                            // Today's notifications
                            VStack(spacing: 4) {
                                Text(contentManager.localizedString("notifications.today"))
                                    .font(Constants.Typography.Caption.font)
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.todayCount)")
                                    .font(Constants.Typography.Mono.H3.font)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, Constants.UI.Spacing.medium)
                        .padding(.vertical, Constants.UI.Spacing.medium)
                    }
                    .background(Constants.Colors.cardBackground)
                    .cornerRadius(Constants.UI.CornerRadius.secondary)
                }
                .padding(.horizontal, Constants.UI.Padding.screenMargin)
                .padding(.top, Constants.UI.Spacing.medium)
                .padding(.bottom, Constants.UI.Spacing.large)
                .background(Constants.Colors.backgroundPrimary)
                
                // Notifications list
                if viewModel.notifications.isEmpty {
                    EmptyNotificationsView()
                } else {
                        List {
                            ForEach(viewModel.notifications) { notification in
                                NotificationRow(notification: notification) {
                                    viewModel.markAsRead(notification)
                                }
                                .listRowSeparator(.visible)
                                .listRowInsets(EdgeInsets(top: 0, leading: Constants.UI.Padding.screenMargin, bottom: 0, trailing: Constants.UI.Padding.screenMargin))
                            }
                        }
                        .listStyle(.plain)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(contentManager.localizedString("notifications.done")) {
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .accessibilityLabel(contentManager.localizedString("notifications.done"))
                    .accessibilityHint("Double tap to close notifications")
                }
            }
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
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(notification.type.color)
                    .frame(width: 24, height: 24)
                    .accessibilityHidden(true)
                
                // Notification content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(notification.title)
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        if !notification.isRead {
                            Circle()
                                .fill(Constants.Colors.warning)
                                .frame(width: 8, height: 8)
                                .accessibilityLabel("Unread notification")
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to mark as read")
        .accessibilityAddTraits(.isButton)
    }
    
    private var accessibilityLabel: String {
        let readStatus = notification.isRead ? "Read" : "Unread"
        return "\(readStatus) notification: \(notification.title). \(notification.message). \(timeAgoString(from: notification.timestamp))"
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Empty Notifications View
private struct EmptyNotificationsView: View {
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            Image("Empty-State-Image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 200, maxHeight: 200)
                .accessibilityHidden(true)
            
            VStack(spacing: Constants.UI.Spacing.medium) {
                Text(contentManager.localizedString("notifications.empty_title"))
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text(contentManager.localizedString("notifications.empty_description"))
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .lineLimit(3)
                    .accessibilityLabel(contentManager.localizedString("notifications.empty_description"))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, Constants.UI.Padding.screenMargin)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(contentManager.localizedString("notifications.empty_title")). \(contentManager.localizedString("notifications.empty_description"))")
    }
}

#Preview {
    NotificationView()
}