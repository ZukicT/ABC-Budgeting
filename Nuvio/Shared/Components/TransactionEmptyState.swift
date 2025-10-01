//
//  TransactionEmptyState.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Custom empty state component for the Transaction view featuring branded
//  illustration, encouraging messaging, and prominent call-to-action button.
//  Provides clean onboarding experience for new users without transactions.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct TransactionEmptyState: View {
    let actionTitle: String
    let action: () -> Void
    let imageSize: CGFloat
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    init(
        actionTitle: String? = nil,
        imageSize: CGFloat = 200,
        action: @escaping () -> Void
    ) {
        let contentManager = MultilingualContentManager.shared
        self.actionTitle = actionTitle ?? contentManager.localizedString("cta.add_transaction")
        self.imageSize = imageSize
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Custom illustration
            Image("Empty-State-Image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: imageSize, maxHeight: imageSize)
                .accessibilityHidden(true)
            
            // Content section
            VStack(spacing: Constants.UI.Spacing.medium) {
                Text(contentManager.localizedString("transactions.no_transactions"))
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text(contentManager.localizedString("transactions.add_first"))
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .lineLimit(2)
                    .accessibilityLabel(contentManager.localizedString("transactions.add_first"))
            }
            
            // Brand yellow call-to-action button
            Button(action: action) {
                Text(actionTitle)
                    .font(Constants.Typography.Button.font)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Constants.Colors.textPrimary)
                    .cornerRadius(Constants.UI.CornerRadius.primary)
            }
            .accessibilityLabel(actionTitle)
            .accessibilityHint("Tap to add your first transaction")
            .accessibilityAddTraits(.isButton)
        }
        .padding(Constants.UI.Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Constants.Colors.backgroundPrimary)
    }
}

#Preview {
    TransactionEmptyState {
        // Preview action
    }
}
