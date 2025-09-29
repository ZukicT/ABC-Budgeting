import SwiftUI

struct LoanOverviewSection: View {
    @ObservedObject var loanViewModel: LoanViewModel
    @State private var selectedLoan: Loan?
    @State private var totalRemainingBalance: Double = 0.0
    @State private var totalMonthlyPayments: Double = 0.0
    @State private var overdueCount: Int = 0
    @State private var loanOverviewItems: [LoanOverviewItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    let onTabSwitch: (Int) -> Void
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Section Header
            HStack {
                Text(contentManager.localizedString("overview.loans_title"))
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                // See All Button
                Button(action: {
                    onTabSwitch(3) // Switch to Loans tab
                }) {
                    Text(contentManager.localizedString("button.view_all"))
                        .font(Constants.Typography.BodySmall.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                .accessibilityLabel("View all loans")
            }
            
            if isLoading {
                LoadingStateView(message: "Loading loans...")
            } else if let errorMessage = errorMessage {
                ErrorStateView(message: errorMessage) {
                    refreshData()
                }
            } else if loanViewModel.loans.isEmpty {
                LoanEmptyState(
                    actionTitle: contentManager.localizedString("cta.add_loan"),
                    action: {
                        // TODO: Navigate to add loan
                    }
                )
            } else {
                // Loans Overview Content - Single Comprehensive Card
                LoanOverviewCard(
                    totalRemainingBalance: totalRemainingBalance,
                    totalMonthlyPayments: totalMonthlyPayments,
                    overdueCount: overdueCount,
                    loanCount: loanOverviewItems.count,
                    loanItems: loanOverviewItems
                )
            }
        }
        .onAppear {
            refreshData()
        }
        .onChange(of: loanViewModel.loans.count) { _, _ in
            refreshData()
        }
        .sheet(item: $selectedLoan) { loan in
            LoanDetailView(loan: loan, viewModel: loanViewModel)
        }
    }
    
    // MARK: - Data Processing
    private func refreshData() {
        isLoading = true
        errorMessage = nil
        
        // Calculate loan data from actual loanViewModel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.calculateLoanData()
            self.isLoading = false
        }
    }
    
    private func calculateLoanData() {
        guard !loanViewModel.loans.isEmpty else {
            totalRemainingBalance = 0.0
            totalMonthlyPayments = 0.0
            overdueCount = 0
            loanOverviewItems = []
            return
        }
        
        // Calculate totals from actual loans
        totalRemainingBalance = loanViewModel.loans.reduce(0) { $0 + $1.remainingAmount }
        totalMonthlyPayments = loanViewModel.loans.reduce(0) { $0 + $1.monthlyPayment }
        
        // Calculate overdue count (loans past due date)
        let now = Date()
        overdueCount = loanViewModel.loans.filter { loan in
            (loan.nextPaymentDueDate ?? loan.dueDate) < now && loan.paymentStatus != .paid
        }.count
        
        // Create loan overview items
        loanOverviewItems = loanViewModel.loans.map { loan in
            let progressPercentage = calculateProgressPercentage(loan)
            let isOverdue = isLoanOverdue(loan)
            let statusColor = getStatusColor(loan, isOverdue: isOverdue)
            
            return LoanOverviewItem(
                loan: loan,
                remainingBalance: loan.remainingAmount,
                monthlyPayment: loan.monthlyPayment,
                progressPercentage: progressPercentage,
                nextDueDate: loan.nextPaymentDueDate ?? loan.dueDate,
                isOverdue: isOverdue,
                statusColor: statusColor
            )
        }
    }
    
    // MARK: - Helper Functions
    private func calculateProgressPercentage(_ loan: Loan) -> Double {
        let paidAmount = loan.principalAmount - loan.remainingAmount
        return (paidAmount / loan.principalAmount) * 100
    }
    
    private func isLoanOverdue(_ loan: Loan) -> Bool {
        let dueDate = loan.nextPaymentDueDate ?? loan.dueDate
        return dueDate < Date()
    }
    
    private func getStatusColor(_ loan: Loan, isOverdue: Bool) -> Color {
        if isOverdue {
            return Constants.Colors.error
        } else {
            let dueDate = loan.nextPaymentDueDate ?? loan.dueDate
            if dueDate < Date().addingTimeInterval(86400 * 7) { // Due within 7 days
                return Constants.Colors.warning
            } else {
                return Constants.Colors.success
            }
        }
    }
}

// MARK: - Loan Overview Card
private struct LoanOverviewCard: View {
    let totalRemainingBalance: Double
    let totalMonthlyPayments: Double
    let overdueCount: Int
    let loanCount: Int
    let loanItems: [LoanOverviewItem]
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    private var categoryBreakdown: [(String, Double, Color)] {
        let grouped = Dictionary(grouping: loanItems) { $0.loan.category.displayName }
        return grouped.map { (category, items) in
            let total = items.reduce(0) { $0 + $1.remainingBalance }
            let percentage = total / totalRemainingBalance
            let color = items.first?.loan.category.color ?? Constants.Colors.textSecondary
            return (category, percentage, color)
        }.sorted { $0.1 > $1.1 }
    }
    
    private var averageInterestRate: Double {
        guard !loanItems.isEmpty else { return 0 }
        let totalRate = loanItems.reduce(0) { $0 + $1.loan.interestRate }
        return totalRate / Double(loanItems.count)
    }
    
    private var highestInterestLoan: LoanOverviewItem? {
        loanItems.max { $0.loan.interestRate < $1.loan.interestRate }
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Header Section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(contentManager.localizedString("loan.overview.active_loans"))
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Text("\\(loanCount) \\(loanCount == 1 ? contentManager.localizedString(\"loan.count\") : contentManager.localizedString(\"loan.count_plural\"))")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
                
                // Status Badge
                if overdueCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Constants.Colors.error)
                            .font(.system(size: 12, weight: .medium))
                        
                        Text("\(overdueCount) overdue")
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.error)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, Constants.UI.Spacing.small)
                    .padding(.vertical, 4)
                    .background(Constants.Colors.error.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            // Main Metrics Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Constants.UI.Spacing.medium) {
                // Total Debt
                VStack(alignment: .leading, spacing: 4) {
                    Text(contentManager.localizedString("loan.overview.total_debt"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(CurrencyUtility.formatAmount(totalRemainingBalance))
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.error)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Monthly Payments
                VStack(alignment: .leading, spacing: 4) {
                    Text(contentManager.localizedString("loan.overview.monthly_payments"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(CurrencyUtility.formatAmount(totalMonthlyPayments))
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.warning)
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Insights Section
            VStack(spacing: Constants.UI.Spacing.medium) {
                // Interest Rate Insights
                HStack(spacing: Constants.UI.Spacing.medium) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(contentManager.localizedString("loan.overview.avg_interest_rate"))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                        
                        Text(String(format: "%.1f%%", averageInterestRate))
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.primaryOrange)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let highestLoan = highestInterestLoan {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(contentManager.localizedString("loan.overview.highest_rate"))
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(Constants.Colors.textSecondary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(String(format: "%.1f%%", highestLoan.loan.interestRate))
                                    .font(Constants.Typography.Body.font)
                                    .foregroundColor(Constants.Colors.error)
                                    .fontWeight(.bold)
                                
                                Text(highestLoan.loan.name)
                                    .font(.caption2)
                                    .foregroundColor(Constants.Colors.textTertiary)
                                    .lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                // Category Breakdown
                if !categoryBreakdown.isEmpty {
                    VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                        Text(contentManager.localizedString("loan.overview.debt_by_category"))
                            .font(Constants.Typography.BodySmall.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                            .fontWeight(.medium)
                        
                        VStack(spacing: 6) {
                            ForEach(Array(categoryBreakdown.prefix(3).enumerated()), id: \.offset) { index, item in
                                HStack(spacing: Constants.UI.Spacing.small) {
                                    Circle()
                                        .fill(Constants.Colors.primaryOrange)
                                        .frame(width: 8, height: 8)
                                    
                                    Text(item.0)
                                        .font(Constants.Typography.Caption.font)
                                        .foregroundColor(Constants.Colors.textPrimary)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(item.1 * 100))%")
                                        .font(Constants.Typography.Caption.font)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                        .fontWeight(.medium)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding(Constants.UI.Spacing.large)
        .background(Constants.Colors.textPrimary.opacity(0.05))
        .cornerRadius(Constants.UI.cardCornerRadius)
    }
}

// MARK: - Value Format Enum
private enum ValueFormat {
    case currency
    case percentage
}


#Preview {
    LoanOverviewSection(loanViewModel: LoanViewModel(), onTabSwitch: { _ in })
}
