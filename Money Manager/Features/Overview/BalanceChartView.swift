import SwiftUI
import Charts

// MARK: - Data Models
struct BalanceDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let balance: Double
}

struct ChartSegment: Identifiable {
    let id = UUID()
    let data: [BalanceDataPoint]
    let color: Color
    let isAboveBaseline: Bool
}

// MARK: - Balance Chart View
struct BalanceChartView: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject var budgetViewModel: BudgetViewModel
    @ObservedObject var loanViewModel: LoanViewModel
    @State private var selectedTimeRange: TimeRange = .oneMonth
    
    enum TimeRange: String, CaseIterable {
        case oneDay = "1D"
        case oneWeek = "1W"
        case oneMonth = "1M"
        case threeMonths = "3M"
        case yearToDate = "YTD"
        case oneYear = "1Y"
        case all = "All"
    }
    
    // MARK: - Computed Properties for Real Data
    
    private var totalBalance: Double {
        let totalIncome = transactionViewModel.transactions
            .filter { $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
        
        let totalExpenses = transactionViewModel.transactions
            .filter { $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
        
        return totalIncome - totalExpenses
    }
    
    private var monthlyIncome: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return transactionViewModel.transactions
            .filter { $0.date >= startOfMonth && $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var monthlyExpenses: Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return transactionViewModel.transactions
            .filter { $0.date >= startOfMonth && $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
    }
    
    private var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: Date())
    }
    
    private var incomeChangePercentage: Double {
        let calendar = Calendar.current
        let now = Date()
        let currentMonthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart) ?? now
        let previousMonthEnd = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        
        let currentIncome = monthlyIncome
        
        let previousIncome = transactionViewModel.transactions
            .filter { $0.date >= previousMonthStart && $0.date < previousMonthEnd && $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
        
        guard previousIncome > 0 else { return 0 }
        return ((currentIncome - previousIncome) / previousIncome) * 100
    }
    
    private var expenseChangePercentage: Double {
        let calendar = Calendar.current
        let now = Date()
        let currentMonthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: currentMonthStart) ?? now
        let previousMonthEnd = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        
        let currentExpenses = monthlyExpenses
        
        let previousExpenses = transactionViewModel.transactions
            .filter { $0.date >= previousMonthStart && $0.date < previousMonthEnd && $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
        
        guard previousExpenses > 0 else { return 0 }
        return ((currentExpenses - previousExpenses) / previousExpenses) * 100
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.small) {
            // Header Section (now includes metrics)
            headerSection
            
            // Spacing between metrics and chart
            Spacer()
                .frame(height: Constants.UI.Spacing.medium)
            
            // Chart Area
            chartArea
            
            // Time Period Selector
            timePeriodSelector
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Total Balance")
                .font(Constants.Typography.Caption.font)
                .foregroundColor(Constants.Colors.textSecondary)
            
            Text(totalBalance.formatted(.currency(code: "USD")))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Constants.Colors.textPrimary)
            
            // Income/Expense metrics moved here
            VStack(alignment: .leading, spacing: 1) {
                // Income
                HStack(alignment: .center, spacing: 2) {
                    Text("▲")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.success)
                    
                    Text(monthlyIncome.formatted(.currency(code: "USD")))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.success)
                    
                    Text("(\(incomeChangePercentage > 0 ? "+" : "")\(String(format: "%.1f", incomeChangePercentage))%)")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.success)
                    
                    Text("\(currentMonthName) Income")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Spacer()
                }
                .lineLimit(1)
                
                // Expenses
                HStack(alignment: .center, spacing: 2) {
                    Text("▼")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.error)
                    
                    Text(monthlyExpenses.formatted(.currency(code: "USD")))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.error)
                    
                    Text("(\(expenseChangePercentage > 0 ? "+" : "")\(String(format: "%.1f", expenseChangePercentage))%)")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.error)
                    
                    Text("\(currentMonthName) Expenses")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Spacer()
                }
                .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    
    private var timePeriodSelector: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(TimeRange.allCases, id: \.self) { period in
                        Button(action: {
                            selectedTimeRange = period
                        }) {
                            Text(period.rawValue)
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(period == selectedTimeRange ? Constants.Colors.backgroundPrimary : Constants.Colors.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.secondary)
                                        .fill(period == selectedTimeRange ? Constants.Colors.textPrimary : Color.clear)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, Constants.UI.Padding.screenMargin)
            }
            .padding(.horizontal, -Constants.UI.Padding.screenMargin)
            
            // Separation line
            Rectangle()
                .fill(Constants.Colors.textSecondary.opacity(0.2))
                .frame(height: 1)
                .padding(.top, 12)
        }
    }
    
    private var chartArea: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .trailing) {
                
                Chart {
                    // Baseline reference line (starting balance) - lighter
                    RuleMark(y: .value("Baseline", totalBalance))
                        .foregroundStyle(Constants.Colors.textSecondary.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    
                    // Simple line chart with area fill
                    ForEach(chartData, id: \.id) { dataPoint in
                        // Area fill
                        AreaMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Balance", dataPoint.balance)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Constants.Colors.success.opacity(0.3),
                                    Constants.Colors.success.opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        // Line
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Balance", dataPoint.balance)
                        )
                        .foregroundStyle(Constants.Colors.success)
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        
                        // Data points
                        PointMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Balance", dataPoint.balance)
                        )
                        .foregroundStyle(Constants.Colors.success)
                        .symbolSize(10)
                        .opacity(0.9)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 200)
                .padding(.horizontal, Constants.UI.Padding.screenMargin)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Constants.Colors.backgroundPrimary)
                )
                
            }
        }
        .padding(.horizontal, -Constants.UI.Padding.screenMargin)
    }
    
    // Chart segments with proper color transitions
    private var chartSegments: [ChartSegment] {
        let data = chartData
        let baseline = totalBalance
        var segments: [ChartSegment] = []
        var currentSegment: [BalanceDataPoint] = []
        var currentAboveBaseline: Bool? = nil
        
        for (_, dataPoint) in data.enumerated() {
            let isAboveBaseline = dataPoint.balance >= baseline
            
            if currentAboveBaseline == nil {
                // First data point
                currentAboveBaseline = isAboveBaseline
                currentSegment.append(dataPoint)
            } else if isAboveBaseline == currentAboveBaseline {
                // Same as current segment, continue
                currentSegment.append(dataPoint)
            } else {
                // Different from current segment, finish current and start new
                if !currentSegment.isEmpty {
                    let segmentColor = currentAboveBaseline! ? Constants.Colors.success : Constants.Colors.error
                    segments.append(ChartSegment(
                        data: currentSegment,
                        color: segmentColor,
                        isAboveBaseline: currentAboveBaseline!
                    ))
                }
                currentSegment = [dataPoint]
                currentAboveBaseline = isAboveBaseline
            }
        }
        
        // Add the last segment
        if !currentSegment.isEmpty {
            let segmentColor = currentAboveBaseline! ? Constants.Colors.success : Constants.Colors.error
            segments.append(ChartSegment(
                data: currentSegment,
                color: segmentColor,
                isAboveBaseline: currentAboveBaseline!
            ))
        }
        
        return segments
    }
    
    // Real calculated data for the chart based on actual transactions
    private var chartData: [BalanceDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        var data: [BalanceDataPoint] = []
        
        // Get date range based on selected time range
        let dateRange = getDateRange(for: selectedTimeRange)
        let startDate = dateRange.start
        let endDate = dateRange.end
        
        // Generate data points for the selected time range with appropriate granularity
        let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        let dataPoints = getOptimalDataPointCount(for: selectedTimeRange, totalDays: days)
        let stepSize = max(1, days / dataPoints)
        
        for i in stride(from: 0, to: days, by: stepSize) {
            let date = calendar.date(byAdding: .day, value: i, to: startDate) ?? startDate
            let balance = calculateBalanceForDate(date)
            data.append(BalanceDataPoint(date: date, balance: balance))
        }
        
        // Always include the end date for completeness
        if !data.isEmpty && data.last?.date != endDate {
            let balance = calculateBalanceForDate(endDate)
            data.append(BalanceDataPoint(date: endDate, balance: balance))
        }
        
        return data.sorted { $0.date < $1.date }
    }
    
    // Get optimal number of data points based on time range
    private func getOptimalDataPointCount(for timeRange: TimeRange, totalDays: Int) -> Int {
        switch timeRange {
        case .oneDay:
            return min(24, totalDays) // Hourly data for 1 day
        case .oneWeek:
            return min(7, totalDays) // Daily data for 1 week
        case .oneMonth:
            return min(30, totalDays) // Daily data for 1 month
        case .threeMonths:
            return min(30, totalDays) // Every 3 days for 3 months
        case .yearToDate:
            return min(30, totalDays) // Monthly data for YTD
        case .oneYear:
            return min(30, totalDays) // Monthly data for 1 year
        case .all:
            return min(30, totalDays) // Monthly data for all time
        }
    }
    
    // Calculate balance for a specific date
    private func calculateBalanceForDate(_ date: Date) -> Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        
        // Get transactions up to this date
        let transactionsUpToDate = transactionViewModel.transactions.filter { transaction in
            transaction.date < endOfDay
        }
        
        // Calculate running balance with proper error handling
        let totalIncome = transactionsUpToDate
            .filter { $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
        
        let totalExpenses = transactionsUpToDate
            .filter { $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
        
        // Start with a base balance (this should ideally come from user settings)
        let baseBalance = getBaseBalance()
        let calculatedBalance = baseBalance + totalIncome - totalExpenses
        
        // Ensure balance is never negative for display purposes
        return max(0, calculatedBalance)
    }
    
    // Get base balance - this should ideally come from user settings or previous data
    private func getBaseBalance() -> Double {
        // For now, use a default base balance
        // In a real app, this would come from user settings or previous balance data
        return 1000.0
    }
    
    // Get date range for selected time period
    private func getDateRange(for timeRange: TimeRange) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch timeRange {
        case .oneDay:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? now
            return (start, end)
        case .oneWeek:
            let start = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return (start, now)
        case .oneMonth:
            let start = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return (start, now)
        case .threeMonths:
            let start = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            return (start, now)
        case .yearToDate:
            let start = calendar.dateInterval(of: .year, for: now)?.start ?? now
            return (start, now)
        case .oneYear:
            let start = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return (start, now)
        case .all:
            // Get the earliest transaction date or 1 year ago
            let earliestTransaction = transactionViewModel.transactions.min { $0.date < $1.date }
            let start = earliestTransaction?.date ?? calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return (start, now)
        }
    }
    
}


#Preview {
    BalanceChartView(
        transactionViewModel: TransactionViewModel(),
        budgetViewModel: BudgetViewModel(),
        loanViewModel: LoanViewModel()
    )
        .padding()
}


