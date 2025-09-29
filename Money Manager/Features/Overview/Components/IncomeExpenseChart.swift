import SwiftUI
import Charts

struct IncomeExpenseChart: View {
    let data: [IncomeExpenseData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
            Text("Income vs Expenses")
                .font(Constants.Typography.H3.font)
                .foregroundColor(Constants.Colors.textPrimary)
            
            if data.isEmpty {
                // Empty State
                VStack(spacing: Constants.UI.Spacing.medium) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(Constants.Colors.textTertiary)
                    
                    Text("No Data Available")
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text("Add transactions to see your income vs expenses analysis")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            } else {
                Chart(data) { item in
                    BarMark(
                        x: .value("Month", item.month),
                        y: .value("Amount", item.income),
                        width: .ratio(0.3)
                    )
                    .foregroundStyle(Constants.Colors.success)
                    .position(by: .value("Type", "Income"))
                    
                    BarMark(
                        x: .value("Month", item.month),
                        y: .value("Amount", item.expenses),
                        width: .ratio(0.3)
                    )
                    .foregroundStyle(Constants.Colors.error)
                    .position(by: .value("Type", "Expenses"))
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text("$\(Int(amount))")
                                    .font(Constants.Typography.Caption.font)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let month = value.as(String.self) {
                                Text(month)
                                    .font(Constants.Typography.Caption.font)
                            }
                        }
                    }
                }
                
                // Custom Color Key/Legend
                HStack(spacing: Constants.UI.Spacing.large) {
                    // Income Legend
                    HStack(spacing: Constants.UI.Spacing.small) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Constants.Colors.success)
                            .frame(width: 12, height: 12)
                        
                        Text("Income")
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                    
                    // Expense Legend
                    HStack(spacing: Constants.UI.Spacing.small) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Constants.Colors.error)
                            .frame(width: 12, height: 12)
                        
                        Text("Expenses")
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding(.top, Constants.UI.Spacing.small)
            }
        }
        .padding(Constants.UI.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.UI.cardCornerRadius)
        .shadow(color: Constants.Colors.borderPrimary, radius: 0)
    }
}

#Preview {
    IncomeExpenseChart(data: [
        IncomeExpenseData(month: "Jan", income: 5000, expenses: 3200),
        IncomeExpenseData(month: "Feb", income: 5200, expenses: 3100),
        IncomeExpenseData(month: "Mar", income: 4800, expenses: 3400)
    ])
    .padding()
}
