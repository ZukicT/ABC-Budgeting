import SwiftUI
// Remove the incorrect import. If needed, add a typealias below.
// import Modules.Home.Budget.GoalFormView
// If GoalFormData is not visible, add:
// typealias GoalFormData = Modules_Home_Budget_GoalFormView.GoalFormData

struct MainTabCoordinator: View {
    @State private var displayName: String = UserDefaults.standard.string(forKey: "displayName") ?? "Display Name"
    @State private var goals: [GoalFormData] = [] // Shared goals state

    var body: some View {
        VStack(spacing: 0) {
            MainHeaderView(userName: displayName, showNotificationDot: true)
            TabView {
                OverviewView()
                    .tabItem {
                        Label("Overview", systemImage: "chart.pie")
                    }
                TransactionsView(goals: $goals)
                    .tabItem {
                        Label("Transactions", systemImage: "list.bullet.rectangle")
                    }
                BudgetView(goals: $goals)
                    .tabItem {
                        Label("Budget", systemImage: "creditcard")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
            }
            .accentColor(AppColors.brandBlack)
            .ignoresSafeArea(.keyboard)
            .background(AppColors.background)
        }
        .background(Color.white.ignoresSafeArea(edges: .top))
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            displayName = UserDefaults.standard.string(forKey: "displayName") ?? "Display Name"
        }
    }
} 