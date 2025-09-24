import SwiftUI

struct LoanBlankStateView: View {
    let onAddLoan: () -> Void
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            Spacer()
            
            // Main Content
            VStack(spacing: Constants.UI.Spacing.medium) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Constants.Colors.textPrimary.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "creditcard")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                .accessibilityHidden(true)
                
                // Title
                Text("No Loans Yet")
                    .font(Constants.Typography.H2.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                // Description
                Text("Start tracking your loans to manage your debt effectively and stay on top of payments.")
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                // Guidance Text
                VStack(spacing: Constants.UI.Spacing.small) {
                    Text("Tap the + button above to add your first loan")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                    
                    // Visual Arrow pointing up
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textTertiary)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, Constants.UI.Spacing.large)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Constants.Colors.backgroundPrimary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No loans yet. Tap the plus button above to add your first loan.")
    }
}

#Preview {
    LoanBlankStateView {
        print("Add loan tapped")
    }
}
