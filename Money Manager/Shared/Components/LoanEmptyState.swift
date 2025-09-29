import SwiftUI

/**
 * LoanEmptyState
 * 
 * Custom empty state component for the Loan view featuring branded illustration,
 * encouraging messaging, and prominent call-to-action button. Provides clean
 * onboarding experience for new users without loans.
 * 
 * Features:
 * - Branded illustration with consistent sizing
 * - Brand yellow call-to-action button with proper accessibility
 * - Professional messaging encouraging loan tracking
 * - Responsive layout with proper spacing
 * - Full accessibility compliance
 * 
 * Last Review: 2025-01-26
 * Status: Production Ready
 */

struct LoanEmptyState: View {
    let actionTitle: String
    let action: () -> Void
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    init(
        actionTitle: String = "",
        action: @escaping () -> Void
    ) {
        let contentManager = MultilingualContentManager.shared
        self.actionTitle = actionTitle.isEmpty ? contentManager.localizedString("cta.add_loan") : actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            Image("Budget-Empty")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 200, maxHeight: 200)
                .accessibilityHidden(true)
            
            VStack(spacing: Constants.UI.Spacing.medium) {
                Text(contentManager.localizedString("loan.empty_title"))
                    .font(Constants.Typography.H2.font)
                    .fontWeight(.bold)
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
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.black)
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
        #if DEBUG
        print("Add Loan tapped")
        #endif
    }
}
