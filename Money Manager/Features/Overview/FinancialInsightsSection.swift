import SwiftUI

struct FinancialInsightsSection: View {
    @StateObject private var viewModel = FinancialInsightsViewModel()
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Section Header
            HStack {
                Text("Financial Insights")
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                // Refresh Button
                Button(action: {
                    viewModel.refreshData()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                .accessibilityLabel("Refresh insights data")
            }
            
            // Charts Content
            VStack(spacing: Constants.UI.Spacing.large) {
                // Income vs Expense Chart
                IncomeExpenseChart(data: viewModel.incomeExpenseData)
                
                // Spending Category Chart
                SpendingCategoryChart(data: viewModel.categorySpendingData)
                
                // Income Needed Chart
                IncomeNeededChart()
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
}

#Preview {
    FinancialInsightsSection()
        .padding()
}