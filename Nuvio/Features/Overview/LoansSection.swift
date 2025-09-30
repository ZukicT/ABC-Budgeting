//
//  LoansSection.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Loans section component for overview display providing loan summary
//  information and navigation to full loan management functionality.
//  Features placeholder content and accessibility support.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct LoansSection: View {
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            HStack {
                Text(contentManager.localizedString("tab.loans"))
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                Button(contentManager.localizedString("button.view_all")) {
                }
                .font(Constants.Typography.BodySmall.font)
                .foregroundColor(Constants.Colors.success)
            }
            
            VStack(spacing: Constants.UI.Spacing.small) {
                Text(contentManager.localizedString("loans.overview_placeholder"))
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text(contentManager.localizedString("loans.overview_description"))
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(Constants.UI.Padding.cardInternal)
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.UI.cardCornerRadius)
        }
    }
}

#Preview {
    LoansSection()
        .padding()
        .background(Constants.Colors.backgroundPrimary)
}
