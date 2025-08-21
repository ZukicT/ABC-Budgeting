import SwiftUI

struct MainTabCoordinator: View {
    @State private var displayName: String = UserDefaults.standard.string(forKey: "displayName") ?? "Display Name"
    @State private var goals: [GoalFormData] = [] // Shared goals state
    
    @State private var transactions: [Transaction] = []
    
    // Initialize with mock data for testing
    init() {
        // Create a mock goal for testing
        let mockGoal = GoalFormData(
            name: "Test Goal",
            subtitle: "Test subtitle",
            targetAmount: 1000,
            savedAmount: 300,
            targetDate: Date().addingTimeInterval(30 * 24 * 60 * 60), // 30 days from now
            notes: "Test notes",
            iconName: "star",
            iconColorName: "blue"
        )
        
        // Create some mock transactions for testing
        let mockTransactions = [
            Transaction(
                id: UUID(),
                title: "Salary",
                subtitle: "Monthly income",
                amount: 2000,
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
                amount: 150,
                iconName: "cart",
                iconColorName: "orange",
                iconBackgroundName: "orange.opacity15",
                category: .essentials,
                isIncome: false,
                linkedGoalName: nil,
                date: Date()
            )
        ]
        
        // Initialize the State properties
        _goals = State(initialValue: [mockGoal])
        _transactions = State(initialValue: mockTransactions)
    }

    var body: some View {
        VStack(spacing: 0) {
            MainHeaderView(userName: displayName, showNotificationDot: hasUpcomingRecurringReminders)
            TabView {
                OverviewView(transactions: transactions, goals: goals)
                    .onAppear {
                        print("DEBUG: OverviewView appeared with \(goals.count) goals")
                    }
                    .tabItem {
                        Label("Overview", systemImage: "house")
                    }
                TransactionsView(transactions: $transactions, goals: $goals)
                    .tabItem {
                        Label("Transactions", systemImage: "text.rectangle.page")
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
