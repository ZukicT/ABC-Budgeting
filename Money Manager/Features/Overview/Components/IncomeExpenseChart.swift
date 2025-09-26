import SwiftUI
import Charts

struct IncomeExpenseChart: View {
    let data: [IncomeExpenseData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
            Text("Income vs Expenses")
                .font(Constants.Typography.H3.font)
                .foregroundColor(Constants.Colors.textPrimary)
            
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
            .chartLegend(position: .bottom)
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
        }
        .padding(Constants.UI.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.UI.CornerRadius.secondary)
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
