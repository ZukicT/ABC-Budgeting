import SwiftUI
import Charts

/// Wage Calculator Chart showing hourly to yearly salary conversion
struct IncomeNeededChart: View {
    @StateObject private var viewModel = WageCalculatorViewModel()
    @State private var targetYearlySalary: Double = 75000.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
            // MARK: - Header
            HStack {
                Text("Wage Calculator")
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
            }
            
            if viewModel.isLoading {
                LoadingView()
            } else if let wageData = viewModel.wageData {
                // MARK: - Wage Chart
                WageChart(wageData: wageData)
                
                // MARK: - Wage Summary Cards
                WageSummaryCards(wageData: wageData)
                
                // MARK: - Work Schedule Impact
                WorkScheduleImpact(wageData: wageData)
                
            } else if let error = viewModel.errorMessage {
                ErrorView(error: error) {
                    viewModel.refreshData()
                }
            }
        }
        .onAppear {
            viewModel.updateTargetYearlySalary(targetYearlySalary)
        }
    }
}

// MARK: - Wage Summary Cards
private struct WageSummaryCards: View {
    let wageData: WageData
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: Constants.UI.Spacing.small) {
            // Hourly Wage
            WageCard(
                title: "Hourly Wage",
                value: wageData.hourlyWage,
                timeRange: "per hour",
                color: Constants.Colors.success
            )
            
            // Daily Wage
            WageCard(
                title: "Daily Wage",
                value: wageData.dailyWage,
                timeRange: "per day",
                color: Constants.Colors.info
            )
            
            // Weekly Wage
            WageCard(
                title: "Weekly Wage",
                value: wageData.weeklyWage,
                timeRange: "per week",
                color: Constants.Colors.warning
            )
            
            // Monthly Wage
            WageCard(
                title: "Monthly Wage",
                value: wageData.monthlyWage,
                timeRange: "per month",
                color: Constants.Colors.error
            )
        }
    }
}

// MARK: - Wage Card
private struct WageCard: View {
    let title: String
    let value: Double
    let timeRange: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
            Text(title)
                .font(Constants.Typography.BodySmall.font)
                .foregroundColor(Constants.Colors.textSecondary)
            
            Text(formatValue(value))
                .font(Constants.Typography.H3.font)
                .fontWeight(.bold)
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(timeRange)
                .font(Constants.Typography.Caption.font)
                .foregroundColor(Constants.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.UI.Spacing.small)
        .background(Constants.Colors.textPrimary.opacity(0.05))
        .cornerRadius(Constants.UI.CornerRadius.secondary)
    }
    
    private func formatValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Wage Chart
private struct WageChart: View {
    let wageData: WageData
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
            Text("Wage Breakdown")
                .font(Constants.Typography.H3.font)
                .foregroundColor(Constants.Colors.textPrimary)
            
            Chart([
                ("Hourly", wageData.hourlyWage, Constants.Colors.success),
                ("Daily", wageData.dailyWage, Constants.Colors.info),
                ("Weekly", wageData.weeklyWage, Constants.Colors.warning),
                ("Monthly", wageData.monthlyWage, Constants.Colors.error),
                ("Yearly", wageData.yearlySalary, Constants.Colors.textPrimary)
            ], id: \.0) { timeRange, amount, color in
                BarMark(
                    x: .value("Time Range", timeRange),
                    y: .value("Amount", amount),
                    width: .ratio(0.6)
                )
                .foregroundStyle(color)
                .cornerRadius(Constants.UI.CornerRadius.quaternary)
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
                        if let timeRange = value.as(String.self) {
                            Text(timeRange)
                                .font(Constants.Typography.Caption.font)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Work Schedule Impact
private struct WorkScheduleImpact: View {
    let wageData: WageData
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
            Text("Work Schedule Impact")
                .font(Constants.Typography.H3.font)
                .foregroundColor(Constants.Colors.textPrimary)
            
            HStack(spacing: Constants.UI.Spacing.medium) {
                // Full Time (40 hours)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Full Time (40h/week)")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(formatValue(wageData.hourlyWage))
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.success)
                }
                
                Spacer()
                
                // Part Time (20 hours)
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Part Time (20h/week)")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(formatValue(wageData.hourlyWage * 2))
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.warning)
                }
            }
            
            // Note
            HStack {
                Text("Note: Part-time requires 2x hourly rate to reach same yearly salary")
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textTertiary)
                
                Spacer()
            }
        }
        .padding(Constants.UI.Spacing.small)
        .background(Constants.Colors.textPrimary.opacity(0.05))
        .cornerRadius(Constants.UI.CornerRadius.secondary)
    }
    
    private func formatValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}


// MARK: - Loading View
private struct LoadingView: View {
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.success))
            
            Text("Calculating income projections...")
                .font(Constants.Typography.Body.font)
                .foregroundColor(Constants.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.UI.Spacing.large)
    }
}

// MARK: - Error View
private struct ErrorView: View {
    let error: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Constants.Colors.error)
            
            Text("Failed to load income projections")
                .font(Constants.Typography.Body.font)
                .foregroundColor(Constants.Colors.textPrimary)
            
            Text(error)
                .font(Constants.Typography.Caption.font)
                .foregroundColor(Constants.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
            .tint(Constants.Colors.success)
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.UI.Spacing.large)
    }
}

#Preview {
    IncomeNeededChart()
        .padding()
}
