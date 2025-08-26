import SwiftUI

struct MainTabCoordinator: View {
    @State private var displayName: String = UserDefaults.standard.string(forKey: "displayName") ?? "Display Name"
    @State private var selectedTab: Int = 0 // Track selected tab
    @State private var goals: [GoalFormData] = [
        // Hardcoded mock goal to ensure it's always there
        GoalFormData(
            name: "Vacation Fund",
            subtitle: "Save for summer vacation",
            targetAmount: 2000,
            savedAmount: 800,
            targetDate: Date().addingTimeInterval(90 * 24 * 60 * 60), // 90 days from now
            notes: "Saving for a nice summer vacation",
            iconName: "airplane",
            iconColorName: "blue"
        ),
        GoalFormData(
            name: "New Laptop",
            subtitle: "Save for new computer",
            targetAmount: 1500,
            savedAmount: 450,
            targetDate: Date().addingTimeInterval(120 * 24 * 60 * 60), // 120 days from now
            notes: "Need a new laptop for work",
            iconName: "laptopcomputer",
            iconColorName: "green"
        )
    ]
    
    @State private var transactions: [Transaction] = [
        // Hardcoded mock transactions
        Transaction(
            id: UUID(),
            title: "Salary",
            subtitle: "Monthly income",
            amount: 3000,
            iconName: "dollarsign.circle",
            iconColorName: "mint",
            iconBackgroundName: "mint.opacity15",
            category: .income,
            isIncome: true,
            linkedGoalName: nil,
            date: Date()
        ),
        Transaction(
            id: UUID(),
            title: "Groceries",
            subtitle: "Weekly shopping",
            amount: 120,
            iconName: "cart",
            iconColorName: "orange",
            iconBackgroundName: "orange.opacity15",
            category: .essentials,
            isIncome: false,
            linkedGoalName: nil,
            date: Date()
        ),
        Transaction(
            id: UUID(),
            title: "Netflix",
            subtitle: "Monthly subscription",
            amount: 15,
            iconName: "tv",
            iconColorName: "red",
            iconBackgroundName: "red.opacity15",
            category: .leisure,
            isIncome: false,
            linkedGoalName: nil,
            date: Date()
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            MainHeaderView(userName: displayName, showNotificationDot: hasUpcomingRecurringReminders)
            TabView(selection: $selectedTab) {
                OverviewView(transactions: transactions, goals: goals, onSeeAllGoals: { selectedTab = 2 }, onSeeAllTransactions: { selectedTab = 1 })
                    .onAppear {
                        print("DEBUG: OverviewView appeared with \(goals.count) goals")
                    }
                    .tabItem {
                        Label("Overview", systemImage: "house")
                    }
                    .tag(0)
                TransactionsView(transactions: $transactions, goals: $goals)
                    .tabItem {
                        Label("Transactions", systemImage: "text.rectangle.page")
                    }
                    .tag(1)
                BudgetView(goals: $goals)
                    .tabItem {
                        Label("Budget", systemImage: "creditcard")
                    }
                    .tag(2)
                SettingsView(transactions: $transactions, goals: $goals)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(3)
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

    // Returns true if there are recurring transactions (expenses or incomes) with reminders enabled and due soon
    private var hasUpcomingRecurringReminders: Bool {
        let now = Date()
        // For demo: consider a transaction as 'recurring with reminder' if its subtitle contains 'remind' or 'recurring', and its date is within the next 7 days
        // In production, this should check explicit recurring/reminder properties
        return transactions.contains { tx in
            let isRecurring = tx.subtitle.localizedCaseInsensitiveContains("recurring") || tx.subtitle.localizedCaseInsensitiveContains("remind")
            let isUpcoming = tx.date > now && tx.date < Calendar.current.date(byAdding: .day, value: 7, to: now)!
            return isRecurring && isUpcoming
        }
    }
} 
