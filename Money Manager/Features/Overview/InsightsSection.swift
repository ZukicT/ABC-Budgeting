import SwiftUI

struct InsightsSection: View {
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            // Section Header
            HStack {
                Text(contentManager.localizedString("insights.title"))
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                Button(contentManager.localizedString("button.view_all")) {
                    // TODO: Navigate to insights or analytics
                }
                .font(Constants.Typography.BodySmall.font)
                .foregroundColor(Constants.Colors.success)
            }
            
            // Placeholder content
            VStack(spacing: Constants.UI.Spacing.small) {
                Text(contentManager.localizedString("insights.coming_soon"))
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text(contentManager.localizedString("insights.description"))
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
    InsightsSection()
        .padding()
        .background(Constants.Colors.backgroundPrimary)
}
