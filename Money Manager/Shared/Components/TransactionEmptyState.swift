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
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    init(
        actionTitle: String? = nil,
        action: @escaping () -> Void
    ) {
        self.actionTitle = actionTitle ?? "Add Transaction"
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
                Text(contentManager.localizedString("transactions.no_transactions"))
                    .font(Constants.Typography.H2.font)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text(contentManager.localizedString("transactions.add_first"))
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .accessibilityLabel(contentManager.localizedString("transactions.add_first"))
            }
            
            // Brand yellow call-to-action button
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
        #if DEBUG
        print("Add Transaction tapped")
        #endif
    }
}
