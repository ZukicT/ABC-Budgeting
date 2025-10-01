//
//  MainTabView.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Main tab bar interface that manages navigation between core app features.
//  Handles shared ViewModels, data preloading, and accessibility support
//  for Overview, Transactions, Budget, and Loans tabs.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    @StateObject private var loanViewModel = LoanViewModel()
    @StateObject private var budgetViewModel = BudgetViewModel()
    @StateObject private var transactionViewModel = TransactionViewModel()
    @StateObject private var dataClearingService = DataClearingService()
    @StateObject private var budgetTransactionService = BudgetTransactionService()
    
    
    var body: some View {
        TabView(selection: $selectedTab) {
            OverviewView(
                onTabSwitch: { tab in
                    selectedTab = tab
                },
                loanViewModel: loanViewModel,
                budgetViewModel: budgetViewModel,
                transactionViewModel: transactionViewModel,
                dataClearingService: dataClearingService,
                budgetTransactionService: budgetTransactionService
            )
                .tabItem {
                    Image(systemName: "house.fill")
                    Text(contentManager.localizedString("tab.overview"))
                }
                .tag(0)
                .accessibilityLabel("Overview tab")
                .accessibilityHint("View your financial overview and summary")
            
            TransactionView(
                viewModel: transactionViewModel, 
                dataClearingService: dataClearingService,
                loanViewModel: loanViewModel,
                budgetViewModel: budgetViewModel,
                budgetTransactionService: budgetTransactionService
            )
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text(contentManager.localizedString("tab.transactions"))
                }
                .tag(1)
                .accessibilityLabel("Transactions tab")
                .accessibilityHint("View and manage your transactions")
            
            BudgetView(
                viewModel: budgetViewModel, 
                dataClearingService: dataClearingService,
                loanViewModel: loanViewModel,
                transactionViewModel: transactionViewModel,
                budgetTransactionService: budgetTransactionService
            )
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text(contentManager.localizedString("tab.budget"))
                }
                .tag(2)
                .accessibilityLabel("Budget tab")
                .accessibilityHint("Manage your budget and spending limits")
            
            LoanView(
                viewModel: loanViewModel, 
                dataClearingService: dataClearingService,
                budgetViewModel: budgetViewModel,
                transactionViewModel: transactionViewModel,
                budgetTransactionService: budgetTransactionService
            )
                .tabItem {
                    Image(systemName: "building.columns.fill")
                    Text(contentManager.localizedString("tab.loans"))
                }
                .tag(3)
                .accessibilityLabel("Loans tab")
                .accessibilityHint("View and manage your loans")
        }
        .accentColor(Color(red: 0.341, green: 0.455, blue: 0.804)) // Brand color for selected tabs
        .preferredColorScheme(.none) // Respects system appearance
        .onAppear {
            // Configure tab bar appearance safely
            DispatchQueue.main.async {
                // Use a safer approach - only set properties that are guaranteed to work
                let ctaButtonColor = UIColor(red: 0.247, green: 0.239, blue: 0.337, alpha: 1.0)
                
                // Set unselected item tint color (this is the safest approach)
                UITabBar.appearance().unselectedItemTintColor = ctaButtonColor
                
                // Configure appearance with minimal settings to avoid swizzling issues
                let appearance = UITabBarAppearance()
                appearance.configureWithDefaultBackground()
                
                // Only set the properties we need
                appearance.stackedLayoutAppearance.normal.iconColor = ctaButtonColor
                
                // Apply appearance safely
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            
            // Initialize ViewModels and data
            dataClearingService.setViewModels(
                transactionViewModel: transactionViewModel,
                budgetViewModel: budgetViewModel,
                loanViewModel: loanViewModel
            )
            
            budgetTransactionService.setViewModels(
                transactionViewModel: transactionViewModel,
                budgetViewModel: budgetViewModel
            )
            
            transactionViewModel.setBudgetTransactionService(budgetTransactionService)
            preloadAllData()
        }
    }
    
    private func preloadAllData() {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                if !transactionViewModel.hasDataLoaded {
                    transactionViewModel.loadTransactions()
                }
                if !budgetViewModel.hasDataLoaded {
                    budgetViewModel.loadBudgets()
                }
                if !loanViewModel.hasDataLoaded {
                    loanViewModel.loadLoans()
                }
            }
        }
    }
    
}

#Preview {
    MainTabView()
}