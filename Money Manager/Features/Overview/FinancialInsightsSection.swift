import SwiftUI

struct FinancialInsightsSection: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @State private var incomeExpenseData: [IncomeExpenseData] = []
    @State private var categorySpendingData: [CategorySpendingData] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Section Header
            HStack {
                Text(contentManager.localizedString("overview.financial_insights_title"))
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
            }
            
            // Charts Content
            VStack(spacing: Constants.UI.Spacing.large) {
                // Income vs Expense Chart
                IncomeExpenseChart(data: incomeExpenseData)
                
                // Spending Category Chart
                SpendingCategoryChart(data: categorySpendingData)
            }
        }
        .onAppear {
            refreshData()
        }
        .onChange(of: transactionViewModel.transactions.count) { _, _ in
            refreshData()
        }
    }
    
    // MARK: - Data Processing
    private func refreshData() {
        isLoading = true
        errorMessage = nil
        
        // Calculate insights data from actual transactions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.calculateInsightsData()
            self.isLoading = false
        }
    }
    
    private func calculateInsightsData() {
        guard !transactionViewModel.transactions.isEmpty else {
            incomeExpenseData = []
            categorySpendingData = []
            return
        }
        
        // Calculate income vs expense data
        let calendar = Calendar.current
        let now = Date()
        let currentMonthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        let currentMonthTransactions = transactionViewModel.transactions.filter { $0.date >= currentMonthStart }
        
        let income = currentMonthTransactions.filter { $0.amount > 0 }.reduce(0) { $0 + $1.amount }
        let expenses = currentMonthTransactions.filter { $0.amount < 0 }.reduce(0) { $0 + abs($1.amount) }
        
        incomeExpenseData = [
            IncomeExpenseData(month: "Current Month", income: income, expenses: expenses)
        ]
        
        // Calculate category spending data
        let expenseTransactions = currentMonthTransactions.filter { $0.amount < 0 }
        let categoryGroups = Dictionary(grouping: expenseTransactions) { $0.category }
        
        categorySpendingData = categoryGroups.map { (category, transactions) in
            let total = transactions.reduce(0) { $0 + abs($1.amount) }
            let percentage = expenses > 0 ? total / expenses : 0
            return CategorySpendingData(
                category: category,
                amount: total,
                percentage: percentage,
                color: getColorForCategory(category)
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    private func getColorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "housing", "rent", "mortgage": return Constants.Colors.error
        case "food", "groceries", "dining": return Constants.Colors.warning
        case "transportation", "transport", "gas": return Constants.Colors.info
        case "entertainment", "fun": return Constants.Colors.success
        case "utilities", "bills": return Constants.Colors.primaryOrange
        case "healthcare", "medical": return Constants.Colors.textSecondary
        default: return Constants.Colors.textTertiary
        }
    }
}

#Preview {
    FinancialInsightsSection(transactionViewModel: TransactionViewModel())
        .padding()
}