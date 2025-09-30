//
//  OverviewView.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Main overview screen displaying financial dashboard with balance summary,
//  recent transactions, budget progress, and loan information. Provides
//  quick access to add transactions and navigate to other app sections.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct OverviewView: View {
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showAddView = false
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    let onTabSwitch: (Int) -> Void
    @ObservedObject var loanViewModel: LoanViewModel
    @ObservedObject var budgetViewModel: BudgetViewModel
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var dataClearingService: DataClearingService
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: Constants.UI.Spacing.medium) {
                    HStack(alignment: .center) {
                        Text(contentManager.localizedString("overview.title"))
                            .font(Constants.Typography.H1.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                        
                        Spacer()
                    }
                    .padding(.top, -Constants.UI.Spacing.medium)
                }
                .padding(Constants.UI.Padding.screenMargin)
                .background(Constants.Colors.backgroundPrimary)
                
                ScrollView {
                    OverviewContent(
                        onTabSwitch: onTabSwitch, 
                        loanViewModel: loanViewModel, 
                        budgetViewModel: budgetViewModel,
                        transactionViewModel: transactionViewModel
                    )
                        .padding(Constants.UI.Padding.screenMargin)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showAddView = true
                    }) {
                        Image(systemName: "plus")
                            .accessibilityLabel("Add Item")
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        showNotifications = true
                    }) {
                        Image(systemName: "bell")
                            .accessibilityLabel("Notifications")
                    }
                    
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .accessibilityLabel("Settings")
                    }
                }
            }
            .background(Constants.Colors.backgroundPrimary)
            .sheet(isPresented: $showSettings) {
                SettingsView(dataClearingService: dataClearingService)
            }
            .sheet(isPresented: $showNotifications) {
                NotificationView()
            }
            .sheet(isPresented: $showAddView) {
                AddView(loanViewModel: loanViewModel, budgetViewModel: budgetViewModel, transactionViewModel: transactionViewModel)
            }
        }
    }
}

// MARK: - Overview Content
private struct OverviewContent: View {
    let onTabSwitch: (Int) -> Void
    @ObservedObject var loanViewModel: LoanViewModel
    @ObservedObject var budgetViewModel: BudgetViewModel
    @ObservedObject var transactionViewModel: TransactionViewModel
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Balance Chart Section
            BalanceChartView(
                transactionViewModel: transactionViewModel,
                budgetViewModel: budgetViewModel,
                loanViewModel: loanViewModel
            )
            
            // Monthly Overview Section
            MonthlyOverviewSection(transactionViewModel: transactionViewModel)
            
            // Recent Transactions Section
            RecentTransactionsSection(
                transactionViewModel: transactionViewModel,
                onTabSwitch: onTabSwitch
            )
            
            // Budgets Overview Section
            BudgetsOverviewSection(budgetViewModel: budgetViewModel, onTabSwitch: onTabSwitch)
            
            // Loans Overview Section
            LoanOverviewSection(loanViewModel: loanViewModel, onTabSwitch: onTabSwitch)
            
            // Financial Insights Section
            FinancialInsightsSection(transactionViewModel: transactionViewModel)
            
            Spacer(minLength: Constants.UI.Spacing.xl)
        }
    }
}

#Preview {
    OverviewView(
        onTabSwitch: { _ in },
        loanViewModel: LoanViewModel(),
        budgetViewModel: BudgetViewModel(),
        transactionViewModel: TransactionViewModel(),
        dataClearingService: DataClearingService()
    )
}
