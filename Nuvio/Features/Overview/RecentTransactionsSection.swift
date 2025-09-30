//
//  RecentTransactionsSection.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Recent transactions section displaying latest transaction activity with
//  quick navigation to full transaction management. Features transaction
//  preview cards and accessibility support for overview dashboard.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct RecentTransactionsSection: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @State private var selectedTransaction: Transaction?
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    let onTabSwitch: (Int) -> Void
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            HStack {
                Text(contentManager.localizedString("overview.recent_transactions_title"))
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                Button(action: {
                    onTabSwitch(1)
                }) {
                    Text(contentManager.localizedString("button.view_all"))
                        .font(Constants.Typography.BodySmall.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                .accessibilityLabel("View all transactions")
            }
            
            if transactionViewModel.transactions.isEmpty {
                TransactionEmptyState(
                    actionTitle: contentManager.localizedString("cta.add_transaction"),
                    imageSize: 80,
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