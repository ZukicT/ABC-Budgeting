import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    // Shared ViewModels - created once and shared across all tabs
    @StateObject private var loanViewModel = LoanViewModel()
    @StateObject private var budgetViewModel = BudgetViewModel()
    @StateObject private var transactionViewModel = TransactionViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            OverviewView(
                onTabSwitch: { tab in
                    selectedTab = tab
                },
                loanViewModel: loanViewModel,
                budgetViewModel: budgetViewModel,
                transactionViewModel: transactionViewModel
            )
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Overview")
                }
                .tag(0)
                .accessibilityLabel("Overview tab")
                .accessibilityHint("View your financial overview and summary")
            
            TransactionView(viewModel: transactionViewModel)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Transactions")
                }
                .tag(1)
                .accessibilityLabel("Transactions tab")
                .accessibilityHint("View and manage your transactions")
            
            BudgetView(viewModel: budgetViewModel)
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Budget")
                }
                .tag(2)
                .accessibilityLabel("Budget tab")
                .accessibilityHint("Manage your budget and spending limits")
            
            LoanView(viewModel: loanViewModel)
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Loans")
                }
                .tag(3)
                .accessibilityLabel("Loans tab")
                .accessibilityHint("View and manage your loans")
        }
        .accentColor(Constants.Colors.robinNeonGreen)
        .preferredColorScheme(.none) // Respects system appearance
        .onAppear {
            // Preload all data when the app starts for seamless tab switching
            preloadAllData()
        }
    }
    
    private func preloadAllData() {
        // Preload all ViewModels in the background to ensure instant tab switching
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                // Load all data simultaneously for instant tab switching
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