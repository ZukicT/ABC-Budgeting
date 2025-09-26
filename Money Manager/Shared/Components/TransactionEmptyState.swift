import SwiftUI

/**
 * TransactionEmptyState
 * 
 * Custom empty state component for the Transaction view featuring a branded
 * illustration, encouraging messaging, and prominent call-to-action button.
 * 
 * Features:
 * - Custom branded illustration (Transaction-Empty.png)
 * - Brand yellow call-to-action button
 * - Professional messaging and typography
 * - Accessibility compliance
 * - Responsive layout
 * 
 * Last Review: 2025-01-26
 * Status: Production Ready
 */

struct TransactionEmptyState: View {
    let actionTitle: String
    let action: () -> Void
    
    init(
        actionTitle: String = "Add Transaction",
        action: @escaping () -> Void
    ) {
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Custom illustration
            Image("Transaction-Empty")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 200, maxHeight: 200)
                .accessibilityHidden(true)
            
            // Content section
            VStack(spacing: Constants.UI.Spacing.medium) {
                Text("No Transactions Yet")
                    .font(Constants.Typography.H2.font)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Add your first transaction to start tracking your spending.")
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .accessibilityLabel("Add your first transaction to start tracking your spending.")
            }
            
            // Brand yellow call-to-action button
            Button(action: action) {
                HStack(spacing: Constants.UI.Spacing.small) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(actionTitle)
                        .font(Constants.Typography.Button.font)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Constants.Onboarding.yellowHex)
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
        print("Add Transaction tapped")
    }
}
