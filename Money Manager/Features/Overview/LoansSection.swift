import SwiftUI

struct LoansSection: View {
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            // Section Header
            HStack {
                Text(contentManager.localizedString("tab.loans"))
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                Button(contentManager.localizedString("button.view_all")) {
                    // TODO: Navigate to loans tab
                }
                .font(Constants.Typography.BodySmall.font)
                .foregroundColor(Constants.Colors.success)
            }
            
            // Placeholder content
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
