import SwiftUI

struct LoansSection: View {
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            // Section Header
            HStack {
                Text("Loans")
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                Button("View All") {
                    // TODO: Navigate to loans tab
                }
                .font(Constants.Typography.BodySmall.font)
                .foregroundColor(Constants.Colors.success)
            }
            
            // Placeholder content
            VStack(spacing: Constants.UI.Spacing.small) {
                Text("Loan overview will appear here")
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                Text("This section will show active loans and payment status")
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            .padding(Constants.UI.Padding.cardInternal)
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.UI.cornerRadius)
        }
    }
}

#Preview {
    LoansSection()
        .padding()
        .background(Constants.Colors.backgroundPrimary)
}
