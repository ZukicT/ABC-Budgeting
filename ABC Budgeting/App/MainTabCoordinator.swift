import SwiftUI

struct MainTabCoordinator: View {
    @State private var displayName: String = UserDefaults.standard.string(forKey: "displayName") ?? "Display Name"
    @State private var selectedTab: Int = 0 // Track selected tab
    @StateObject private var notificationService = NotificationService()
    @State private var showNotifications = false
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
            MainHeaderView(
                userName: displayName, 
                showNotificationDot: notificationService.unreadCount > 0,
                onNotificationTap: {
                    showNotifications = true
                }
            )
            TabView(selection: $selectedTab) {
                OverviewView(
                    transactions: transactions, 
                    goals: goals, 
                    onSeeAllGoals: { selectedTab = 2 }, 
                    onSeeAllTransactions: { selectedTab = 1 },
                    onAddTransaction: { newTransaction in
                        transactions.insert(newTransaction, at: 0)
                        // Add notification for new transaction
                        notificationService.addNewTransactionNotification(for: newTransaction)
                    }
                )
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
            .accentColor(AppColors.primary)
            .tint(AppColors.primary)
            .ignoresSafeArea(.keyboard)
            .background(AppColors.background)
        }
        .background(Color.white.ignoresSafeArea(edges: .top))
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            displayName = UserDefaults.standard.string(forKey: "displayName") ?? "Display Name"
        }
        .sheet(isPresented: $showNotifications) {
            NotificationView(notificationService: notificationService)
        }
        .onAppear {
            // Add some demo notifications on first launch
            if notificationService.notifications.isEmpty {
                notificationService.addDemoNotifications()
            }
            
            // Check for upcoming transactions and create notifications
            checkForUpcomingTransactions()
        }
    }

    // Check for upcoming transactions and create notifications
    private func checkForUpcomingTransactions() {
        let now = Date()
        let calendar = Calendar.current
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: now) ?? now
        
        // Check for recurring transactions due soon
        for transaction in transactions {
            let isRecurring = transaction.subtitle.localizedCaseInsensitiveContains("recurring") || 
                            transaction.subtitle.localizedCaseInsensitiveContains("monthly") ||
                            transaction.subtitle.localizedCaseInsensitiveContains("weekly") ||
                            transaction.subtitle.localizedCaseInsensitiveContains("daily")
            
            if isRecurring {
                // For demo purposes, create upcoming notifications for recurring transactions
                // In production, this would calculate the next occurrence date
                let nextOccurrence = calendar.date(byAdding: .day, value: 3, to: now) ?? now
                
                if nextOccurrence <= nextWeek {
                    notificationService.addUpcomingTransactionNotification(for: transaction)
                }
            }
        }
        
        // Check for transactions due in the next few days
        for transaction in transactions {
            if transaction.date > now && transaction.date <= nextWeek {
                notificationService.addUpcomingTransactionNotification(for: transaction)
            }
        }
    }
} 
