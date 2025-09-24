import SwiftUI

/// Centralized text field style for edit forms to eliminate code duplication
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

/// Alternative text field style for different contexts
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
