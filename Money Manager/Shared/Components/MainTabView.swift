import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            OverviewView(onTabSwitch: { tab in
                selectedTab = tab
            })
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Overview")
                }
                .tag(0)
                .accessibilityLabel("Overview tab")
                .accessibilityHint("View your financial overview and summary")
            
            TransactionView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Transactions")
                }
                .tag(1)
                .accessibilityLabel("Transactions tab")
                .accessibilityHint("View and manage your transactions")
            
            BudgetView()
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Budget")
                }
                .tag(2)
                .accessibilityLabel("Budget tab")
                .accessibilityHint("Manage your budget and spending limits")
            
            LoanView()
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
    }
}

#Preview {
    MainTabView()
}