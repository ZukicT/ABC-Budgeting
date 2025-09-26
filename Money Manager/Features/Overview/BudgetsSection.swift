import SwiftUI

struct BudgetsSection: View {
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            // Section Header
            HStack {
                Text("Budgets")
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                Button("View All") {
                    // TODO: Navigate to budgets tab
                }
                .font(Constants.Typography.BodySmall.font)
                .foregroundColor(Constants.Colors.success)
            }
            
            // Placeholder content
            VStack(spacing: Constants.UI.Spacing.small) {
                Text("Budget overview will appear here")
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text("This section will show budget progress and status")
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(Constants.UI.Padding.cardInternal)
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.UI.CornerRadius.secondary)
        }
    }
}

#Preview {
    BudgetsSection()
        .padding()
        .background(Constants.Colors.backgroundPrimary)
}
