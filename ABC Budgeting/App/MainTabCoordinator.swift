import SwiftUI

// MARK: - Search Bar Component
struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
    let onSearch: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            if isSearching {
                HStack(spacing: 8) {
                    TextField("Search transactions", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 16))
                        .submitLabel(.search)
                        .onSubmit {
                            onSearch()
                        }
                        .onTapGesture {
                            // Ensure the field is focused when tapped
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .accessibilityLabel("Clear search")
                    }
                    
                    Button("Cancel") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            searchText = ""
                            isSearching = false
                        }
                        hideKeyboard()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.accentColor)
                }
                .transition(.opacity.combined(with: .scale))
            } else {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSearching = true
                    }
                }) {
                    Text("Search transactions")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6).opacity(0.1))
        )
        .frame(maxWidth: 350)
        .animation(.easeInOut(duration: 0.2), value: isSearching)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct MainTabCoordinator: View {
    @State private var displayName: String = UserDefaults.standard.string(forKey: "displayName") ?? "Display Name"
    @State private var selectedTab: Int = 0 // Track selected tab
    @StateObject private var notificationService = NotificationService()
    @State private var showNotifications = false
    @State private var showSettings = false
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var goals: [GoalFormItem] = [
        // Hardcoded mock goal to ensure it's always there
        GoalFormItem(
            name: "Vacation Fund",
            subtitle: "Save for summer vacation",
            targetAmount: 2000,
            savedAmount: 800,
            targetDate: Date().addingTimeInterval(90 * 24 * 60 * 60), // 90 days from now
            notes: "Saving for a nice summer vacation",
            iconName: "airplane",
            iconColorName: "blue"
        ),
        GoalFormItem(
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
    
    @State private var loans: [LoanItem] = LoanItem.makeMockData()
    
    @State private var transactions: [TransactionItem] = [
        // Hardcoded mock transactions
        TransactionItem(
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
        TransactionItem(
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
        TransactionItem(
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
        TabView(selection: $selectedTab) {
            NavigationView {
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
                    // View appeared
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            // Notification Button
                            Button(action: {
                                showNotifications = true
                            }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(RobinhoodColors.primary)
                                    if notificationService.unreadCount > 0 {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 0, y: 2)
                                    }
                                }
                            }
                            .accessibilityLabel("Notifications")
                            .accessibilityAddTraits(.isButton)
                            
                            // Settings Button
                            Button(action: {
                                showSettings = true
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(RobinhoodColors.primary)
                            }
                            .accessibilityLabel("Settings")
                            .accessibilityAddTraits(.isButton)
                        }
                    }
                }
            }
            .tabItem {
                Label("Overview", systemImage: "house")
            }
            .tag(0)
            
            NavigationView {
                TransactionsView(searchText: $searchText, isSearching: $isSearching)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        SearchBarView(
                            searchText: $searchText,
                            isSearching: $isSearching,
                            onSearch: performSearch
                        )
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            // Notification Button
                            Button(action: {
                                showNotifications = true
                            }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(RobinhoodColors.primary)
                                    if notificationService.unreadCount > 0 {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 0, y: 2)
                                    }
                                }
                            }
                            .accessibilityLabel("Notifications")
                            .accessibilityAddTraits(.isButton)
                            
                            // Settings Button
                            Button(action: {
                                showSettings = true
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(RobinhoodColors.primary)
                            }
                            .accessibilityLabel("Settings")
                            .accessibilityAddTraits(.isButton)
                        }
                    }
                }
            }
            .tabItem {
                Label("Transactions", systemImage: "text.rectangle.page")
            }
            .tag(1)
            
            NavigationView {
                BudgetView(goals: $goals)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            // Notification Button
                            Button(action: {
                                showNotifications = true
                            }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(RobinhoodColors.primary)
                                    if notificationService.unreadCount > 0 {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 0, y: 2)
                                    }
                                }
                            }
                            .accessibilityLabel("Notifications")
                            .accessibilityAddTraits(.isButton)
                            
                            // Settings Button
                            Button(action: {
                                showSettings = true
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(RobinhoodColors.primary)
                            }
                            .accessibilityLabel("Settings")
                            .accessibilityAddTraits(.isButton)
                        }
                    }
                }
            }
            .tabItem {
                Label("Budget", systemImage: "creditcard")
            }
            .tag(2)
            
            NavigationView {
                LoansView(searchText: $searchText, isSearching: $isSearching)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        SearchBarView(
                            searchText: $searchText,
                            isSearching: $isSearching,
                            onSearch: performSearch
                        )
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            // Notification Button
                            Button(action: {
                                showNotifications = true
                            }) {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(RobinhoodColors.primary)
                                    if notificationService.unreadCount > 0 {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 0, y: 2)
                                    }
                                }
                            }
                            .accessibilityLabel("Notifications")
                            .accessibilityAddTraits(.isButton)
                            
                            // Settings Button
                            Button(action: {
                                showSettings = true
                            }) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(RobinhoodColors.primary)
                            }
                            .accessibilityLabel("Settings")
                            .accessibilityAddTraits(.isButton)
                        }
                    }
                }
            }
            .tabItem {
                Label("Loans", systemImage: "banknote")
            }
            .tag(3)
        }
        .accentColor(AppColors.primary)
        .tint(AppColors.primary)
        .ignoresSafeArea(.keyboard)
        .background(AppColors.background)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            displayName = UserDefaults.standard.string(forKey: "displayName") ?? "Display Name"
        }
        .sheet(isPresented: $showNotifications) {
            NotificationView(notificationService: notificationService)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(16)
                .presentationCompactAdaptation(.sheet)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(transactions: $transactions, goals: $goals)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(16)
                .presentationCompactAdaptation(.sheet)
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
    
    // Perform search functionality
    private func performSearch() {
        // This function will be called when the user submits the search
        // The actual filtering logic will be implemented in the TransactionsView
        // For now, we just dismiss the keyboard
        hideKeyboard()
    }
    
    // Helper function to hide keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
} 
