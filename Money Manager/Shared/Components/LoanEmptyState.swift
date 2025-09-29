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
    
    init(
        actionTitle: String = "Add A Loan",
        action: @escaping () -> Void
    ) {
        self.actionTitle = actionTitle
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
                Text("No Loans Yet")
                    .font(Constants.Typography.H2.font)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Add your first loan to start tracking your debt.")
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .lineLimit(3)
                    .accessibilityLabel("Add your first loan to start tracking your debt.")
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
