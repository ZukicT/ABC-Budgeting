//
//  EditFieldStyle.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Centralized text field styles for edit forms providing consistent styling
//  and behavior across the app. Includes standard and compact variants with
//  proper typography, colors, and spacing.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct EditFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(Constants.Typography.Body.font)
            .foregroundColor(Constants.Colors.textPrimary)
            .padding(.horizontal, Constants.UI.Spacing.medium)
            .padding(.vertical, Constants.UI.Spacing.small)
            .background(Constants.Colors.backgroundSecondary)
            .cornerRadius(Constants.UI.cardCornerRadius)
    }
}

struct CompactEditFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(Constants.Typography.BodySmall.font)
            .foregroundColor(Constants.Colors.textPrimary)
            .padding(.horizontal, Constants.UI.Spacing.small)
            .padding(.vertical, Constants.UI.Spacing.small)
            .background(Constants.Colors.backgroundSecondary)
            .cornerRadius(Constants.UI.cardCornerRadius)
    }
}
