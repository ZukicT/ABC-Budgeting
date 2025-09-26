import SwiftUI

struct RecentTransactionsSection: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @State private var selectedTransaction: Transaction?
    
    let onTabSwitch: (Int) -> Void
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Section Header
            HStack {
                Text("Recent Transactions")
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                // See All Button
                Button(action: {
                    onTabSwitch(1) // Switch to Transactions tab
                }) {
                    Text("See All")
                        .font(Constants.Typography.BodySmall.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                .accessibilityLabel("View all transactions")
            }
            
            if transactionViewModel.transactions.isEmpty {
                EmptyStateView(
                    icon: "list.bullet",
                    title: "No Transactions",
                    message: "Your recent transactions will appear here.",
                    actionTitle: "Add Transaction",
                    action: {
                        // TODO: Navigate to add transaction
                    }
                )
            } else {
                // Recent Transactions Content
                VStack(spacing: Constants.UI.Spacing.small) {
                    // Transaction List - Show last 5 transactions
                    LazyVStack(spacing: 0) {
                        ForEach(Array(transactionViewModel.transactions.prefix(5).enumerated()), id: \.element.id) { index, transaction in
                            VStack(spacing: 0) {
                                Button(action: {
                                    selectedTransaction = transaction
                                }) {
                                    TransactionCard(transaction: transaction)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Separation line (except for last transaction)
                                if index < min(transactionViewModel.transactions.count, 5) - 1 {
                                    Rectangle()
                                        .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                                        .frame(height: 1)
                                        .padding(.horizontal, Constants.UI.Padding.screenMargin)
                                }
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailView(transactionId: transaction.id, transactionViewModel: transactionViewModel)
        }
    }
}


#Preview {
    RecentTransactionsSection(
        transactionViewModel: TransactionViewModel(),
        onTabSwitch: { _ in }
    )
}