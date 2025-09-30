//
//  BaseView.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Base view protocol and common UI components providing consistent styling
//  and behavior across the app. Includes loading states, error states, and
//  common view patterns with accessibility support.
//
//  Review Date: September 29, 2025
//

import SwiftUI

protocol BaseView: View {
    associatedtype Content: View
    var content: Content { get }
}

extension BaseView {
    var body: some View {
        content
            .background(Constants.Colors.backgroundPrimary)
            .preferredColorScheme(.none)
    }
}

struct LoadingStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            ProgressView()
                .scaleEffect(1.2)
                .accessibilityHidden(true)
            
            Text(message)
                .font(Constants.Typography.Body.font)
                .foregroundColor(Constants.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Constants.Colors.backgroundPrimary)
        .accessibilityLabel("Loading: \(message)")
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            Image(systemName: icon)
                .font(Constants.Typography.H1.font)
                .foregroundColor(Constants.Colors.textTertiary)
                .accessibilityHidden(true)
            
            VStack(spacing: Constants.UI.Spacing.small) {
                Text(title)
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle) {
                    action()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityLabel(actionTitle)
            }
        }
        .padding(Constants.UI.Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Constants.Colors.backgroundPrimary)
    }
}

// MARK: - Error State View
struct ErrorStateView: View {
    let message: String
    let retryAction: (() -> Void)?
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(Constants.Typography.H1.font)
                .foregroundColor(Constants.Colors.error)
                .accessibilityHidden(true)
            
            VStack(spacing: Constants.UI.Spacing.small) {
                Text(contentManager.localizedString("error.something_wrong"))
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let retryAction = retryAction {
                Button(contentManager.localizedString("error.try_again")) {
                    retryAction()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityLabel(contentManager.localizedString("error.try_again"))
            }
        }
        .padding(Constants.UI.Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Constants.Colors.backgroundPrimary)
    }
}
