//
//  LoanEmptyState.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Custom empty state component for the Loan view featuring branded illustration,
//  encouraging messaging, and prominent call-to-action button. Provides clean
//  onboarding experience for new users without loans.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct LoanEmptyState: View {
    let actionTitle: String
    let action: () -> Void
    let imageSize: CGFloat
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    init(
        actionTitle: String = "",
        imageSize: CGFloat = 200,
        action: @escaping () -> Void
    ) {
        let contentManager = MultilingualContentManager.shared
        self.actionTitle = actionTitle.isEmpty ? contentManager.localizedString("cta.add_loan") : actionTitle
        self.imageSize = imageSize
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            Image("Empty-State-Image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: imageSize, maxHeight: imageSize)
                .accessibilityHidden(true)
            
            VStack(spacing: Constants.UI.Spacing.medium) {
                Text(contentManager.localizedString("loan.empty_title"))
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text(contentManager.localizedString("loan.empty_description"))
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .lineLimit(3)
                    .accessibilityLabel(contentManager.localizedString("loan.empty_description"))
            }
            
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
            .accessibilityHint("Tap to add your first loan")
            .accessibilityAddTraits(.isButton)
        }
        .padding(Constants.UI.Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Constants.Colors.backgroundPrimary)
    }
}

#Preview {
    LoanEmptyState {
        // Preview action
    }
}
