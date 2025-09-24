import SwiftUI

struct LoanOverviewSection: View {
    @StateObject private var viewModel = LoanOverviewViewModel()
    @ObservedObject var loanViewModel: LoanViewModel
    @State private var selectedLoan: Loan?
    
    let onTabSwitch: (Int) -> Void
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Section Header
            HStack {
                Text("Loans Overview")
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                // See All Button
                Button(action: {
                    onTabSwitch(3) // Switch to Loans tab
                }) {
                    Text("See All")
                        .font(Constants.Typography.BodySmall.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                .accessibilityLabel("View all loans")
            }
            
            if viewModel.isLoading {
                LoadingStateView(message: "Loading loans...")
            } else if let errorMessage = viewModel.errorMessage {
                ErrorStateView(message: errorMessage) {
                    viewModel.refreshData()
                }
            } else if viewModel.loanOverviewItems.isEmpty {
                EmptyStateView(
                    icon: "creditcard",
                    title: "No Active Loans",
                    message: "Your active loans will appear here.",
                    actionTitle: "Add Loan",
                    action: {
                        // TODO: Navigate to add loan
                    }
                )
            } else {
                // Loans Overview Content - Simplified Summary Only
                LoanSummaryCard(
                    totalRemainingBalance: viewModel.totalRemainingBalance,
                    totalMonthlyPayments: viewModel.totalMonthlyPayments,
                    overdueCount: viewModel.overdueCount
                )
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
        .sheet(item: $selectedLoan) { loan in
            LoanDetailView(loan: loan, viewModel: loanViewModel)
        }
    }
}

// MARK: - Loan Summary Card
private struct LoanSummaryCard: View {
    let totalRemainingBalance: Double
    let totalMonthlyPayments: Double
    let overdueCount: Int
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            // Key Metrics Grid - Similar to Monthly Overview
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Constants.UI.Spacing.small) {
                // Total Debt
                MetricCard(
                    title: "Total Debt",
                    value: totalRemainingBalance,
                    format: .currency,
                    color: Constants.Colors.error
                )
                
                // Monthly Payments
                MetricCard(
                    title: "Monthly Payments",
                    value: totalMonthlyPayments,
                    format: .currency,
                    color: Constants.Colors.warning
                )
            }
            
            // Overdue Status - Only show if there are overdue loans
            if overdueCount > 0 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Constants.Colors.error)
                        .font(.system(size: 14, weight: .medium))
                    
                    Text("\(overdueCount) loan\(overdueCount == 1 ? "" : "s") overdue")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.error)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                .padding(.horizontal, Constants.UI.Spacing.small)
                .padding(.vertical, 4)
                .background(Constants.Colors.error.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - Metric Card (Reused from Monthly Overview pattern)
private struct MetricCard: View {
    let title: String
    let value: Double
    let format: ValueFormat
    let color: Color
    
    enum ValueFormat {
        case currency
        case percentage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
            Text(title)
                .font(Constants.Typography.BodySmall.font)
                .foregroundColor(Constants.Colors.textSecondary)
            
            Text(formattedValue)
                .font(Constants.Typography.H3.font)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.UI.Spacing.small)
        .background(Constants.Colors.textPrimary.opacity(0.05)) // WCAG AA compliant background
        .cornerRadius(Constants.UI.cornerRadius)
    }
    
    private var formattedValue: String {
        switch format {
        case .currency:
            return currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
        case .percentage:
            return String(format: "%.1f%%", value)
        }
    }
}

// MARK: - Formatters
private let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.maximumFractionDigits = 0
    return formatter
}()


#Preview {
    LoanOverviewSection(loanViewModel: LoanViewModel(), onTabSwitch: { _ in })
}
