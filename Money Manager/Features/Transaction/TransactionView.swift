import SwiftUI

struct TransactionView: View {
    @StateObject private var viewModel = TransactionViewModel()
    @State private var selectedCategory = "All"
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showAddView = false
    @State private var selectedTransaction: Transaction?
    
    private let categories = ["All", "Food", "Transport", "Shopping", "Entertainment", "Bills", "Other"]
    
    // MARK: - Computed Properties
    private var groupedTransactions: [(month: String, transactions: [Transaction])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        let filteredTransactions = selectedCategory == "All" 
            ? viewModel.transactions 
            : viewModel.transactions.filter { $0.category == selectedCategory }
        
        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            formatter.string(from: transaction.date)
        }
        
        return grouped.map { (month: $0.key, transactions: $0.value) }.sorted { $0.month > $1.month }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
                contentSection
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .background(Constants.Colors.backgroundPrimary)
            .onAppear {
                viewModel.loadTransactions()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showNotifications) {
                NotificationView()
            }
            .sheet(isPresented: $showAddView) {
                AddView(
                    loanViewModel: LoanViewModel(), 
                    budgetViewModel: BudgetViewModel(),
                    transactionViewModel: viewModel
                )
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionDetailView(transactionId: transaction.id, transactionViewModel: viewModel)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            // Header with title and total counter
            HStack(alignment: .center) {
                // Title only
                Text("Transactions")
                    .font(Constants.Typography.H1.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
            }
            .padding(.top, -Constants.UI.Spacing.medium)
            
            // Category Tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.UI.Spacing.small) {
                    ForEach(categories, id: \.self) { category in
                        CategoryTag(
                            title: category,
                            isSelected: selectedCategory == category,
                            action: {
                                selectedCategory = category
                            }
                        )
                    }
                }
                .padding(.horizontal, Constants.UI.Padding.screenMargin)
            }
            .padding(.horizontal, -Constants.UI.Padding.screenMargin)
        }
        .padding(Constants.UI.Padding.screenMargin)
        .background(Constants.Colors.backgroundPrimary)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        Group {
            if viewModel.isLoading {
                LoadingStateView(message: "Loading transactions...")
            } else if let errorMessage = viewModel.errorMessage {
                ErrorStateView(message: errorMessage) {
                    viewModel.loadTransactions()
                }
            } else if viewModel.transactions.isEmpty {
                TransactionEmptyState(
                    actionTitle: "Add Transaction",
                    action: {
                        showAddView = true
                    }
                )
            } else {
                transactionList
            }
        }
    }
    
    // MARK: - Transaction List
    private var transactionList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(groupedTransactions.enumerated()), id: \.offset) { monthIndex, monthGroup in
                    VStack(spacing: 0) {
                        // Month Header
                        MonthHeader(
                            month: monthGroup.month,
                            transactionCount: monthGroup.transactions.count
                        )
                        
                        // Transactions for this month
                        ForEach(Array(monthGroup.transactions.enumerated()), id: \.element.id) { transactionIndex, transaction in
                            VStack(spacing: 0) {
                                Button(action: {
                                    selectedTransaction = transaction
                                }) {
                                    TransactionCard(transaction: transaction)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Separation line (except for last transaction in month)
                                if transactionIndex < monthGroup.transactions.count - 1 {
                                    Rectangle()
                                        .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                                        .frame(height: 1)
                                        .padding(.horizontal, Constants.UI.Padding.screenMargin)
                                }
                            }
                        }
                        
                        // Month separator (except for last month)
                        if monthIndex < groupedTransactions.count - 1 {
                            Rectangle()
                                .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                                .frame(height: 1)
                                .padding(.horizontal, Constants.UI.Padding.screenMargin)
                                .padding(.vertical, Constants.UI.Spacing.medium)
                        }
                    }
                }
            }
            .padding(Constants.UI.Padding.screenMargin)
        }
    }
    
    // MARK: - Toolbar Content
    private var toolbarContent: some ToolbarContent {
        Group {
            // Plus Button - Left Side
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showAddView = true
                }) {
                    Image(systemName: "plus")
                        .accessibilityLabel("Add Transaction")
                }
            }
            
            // Notifications and Settings - Right Side
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Notifications Button
                Button(action: {
                    showNotifications = true
                }) {
                    Image(systemName: "bell")
                        .accessibilityLabel("Notifications")
                }
                
                // Settings Button
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .accessibilityLabel("Settings")
                }
            }
        }
    }
}


// MARK: - Transaction Card

// MARK: - Category Tag
private struct CategoryTag: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.UI.Spacing.small) {
                // Add icon for "All" category
                if title == "All" {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isSelected ? Constants.Colors.backgroundPrimary : Constants.Colors.textPrimary)
                }
                
                Text(title)
                    .font(Constants.Typography.BodySmall.font)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? Constants.Colors.backgroundPrimary : Constants.Colors.textPrimary)
            }
            .padding(.horizontal, Constants.UI.Spacing.medium)
            .padding(.vertical, Constants.UI.Spacing.small)
            .background(
                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.secondary)
                    .fill(isSelected ? Constants.Colors.textPrimary : Constants.Colors.textPrimary.opacity(0.08))
            )
        }
        .accessibilityLabel("\(title) category")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Month Header
private struct MonthHeader: View {
    let month: String
    let transactionCount: Int
    
    var body: some View {
        HStack {
            Text(month)
                .font(Constants.Typography.H3.font)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.textPrimary)
            
            Spacer()
            
            Text("\(transactionCount) transaction\(transactionCount == 1 ? "" : "s")")
                .font(Constants.Typography.Caption.font)
                .foregroundColor(Constants.Colors.textSecondary)
        }
        .padding(.vertical, Constants.UI.Spacing.medium)
        .padding(.horizontal, Constants.UI.Padding.screenMargin)
        .background(Constants.Colors.textPrimary.opacity(0.08))
        .cornerRadius(Constants.UI.CornerRadius.secondary)
    }
}

#Preview {
    TransactionView()
}
