//
//  MainTabView.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
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
                dataClearingService: dataClearingService
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
                budgetViewModel: budgetViewModel
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
                transactionViewModel: transactionViewModel
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
                transactionViewModel: transactionViewModel
            )
                .tabItem {
                    Image(systemName: "building.columns.fill")
                    Text(contentManager.localizedString("tab.loans"))
                }
                .tag(3)
                .accessibilityLabel("Loans tab")
                .accessibilityHint("View and manage your loans")
        }
        .accentColor(Constants.Colors.accentColor) // Selected tab color
        .preferredColorScheme(.none) // Respects system appearance
        .onAppear {
            // Configure tab bar appearance for unselected tab colors
            DispatchQueue.main.async {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor.systemBackground
                
                // Set unselected tab item colors - use our custom dark gray (#3F3D56)
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor(red: 0.247, green: 0.239, blue: 0.337, alpha: 1.0)
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor(red: 0.247, green: 0.239, blue: 0.337, alpha: 1.0)
                ]
                
                // Set selected tab item colors - use our brand blue (#5774CD)
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 0.341, green: 0.455, blue: 0.804, alpha: 1.0)
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: UIColor(red: 0.341, green: 0.455, blue: 0.804, alpha: 1.0)
                ]
                
                // Apply to all appearance types
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