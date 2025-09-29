import SwiftUI
import Charts

struct SpendingCategoryChart: View {
    let data: [CategorySpendingData]
    @State private var selectedCategory: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
            Text("Spending by Category")
                .font(Constants.Typography.H3.font)
                .foregroundColor(Constants.Colors.textPrimary)
            
            if data.isEmpty {
                // Empty State
                VStack(spacing: Constants.UI.Spacing.medium) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 48, weight: .light))
                        .foregroundColor(Constants.Colors.textTertiary)
                    
                    Text("No Spending Data")
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text("Add transactions to see your spending breakdown by category")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            } else {
                HStack(spacing: Constants.UI.Spacing.large) {
                    // Pie Chart
                    Chart(data) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.4),
                            angularInset: 2
                        )
                        .foregroundStyle(item.color)
                        .opacity(selectedCategory == nil || selectedCategory == item.category ? 1.0 : 0.3)
                    }
                    .frame(width: 150, height: 150)
                    .chartAngleSelection(value: .constant(selectedCategory as String?))
                    .onTapGesture { location in
                        // Handle tap to select category
                    }
                    
                    // Legend
                    VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                        ForEach(data) { item in
                            HStack {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 12, height: 12)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.category)
                                        .font(Constants.Typography.BodySmall.font)
                                        .foregroundColor(Constants.Colors.textPrimary)
                                    
                                    Text("$\(Int(item.amount)) (\(String(format: "%.1f", item.percentage))%)")
                                        .font(Constants.Typography.Caption.font)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.leading, Constants.UI.Spacing.small)
                }
            }
        }
        .padding(Constants.UI.Spacing.medium)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.UI.cardCornerRadius)
        .shadow(color: Constants.Colors.borderPrimary, radius: 0)
    }
}

#Preview {
    SpendingCategoryChart(data: [
        CategorySpendingData(category: "Housing", amount: 1200, percentage: 35.3, color: .red),
        CategorySpendingData(category: "Food", amount: 800, percentage: 23.5, color: .orange),
        CategorySpendingData(category: "Transportation", amount: 600, percentage: 17.6, color: .blue)
    ])
    .padding()
}
