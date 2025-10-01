//
//  BalanceChartView.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Interactive balance chart with touch interaction, tooltips, and real-time
//  data updates. Uses trend-based coloring and clean line design for
//  professional appearance with comprehensive accessibility support.
//
//  Review Date: September 29, 2025
//

import SwiftUI
import Charts

// MARK: - Data Models

enum TrendDirection {
    case positive
    case negative
    case neutral
}

struct BalanceDataPoint: Identifiable {
    let id: UUID
    let date: Date
    let balance: Double
    let change: Double?
    let changePercentage: Double?
    
    init(date: Date, balance: Double, change: Double? = nil, changePercentage: Double? = nil) {
        self.id = UUID()
        self.date = date
        self.balance = balance
        self.change = change
        self.changePercentage = changePercentage
    }
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
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var selectedTimeRange: TimeRange = .oneMonth
    @State private var selectedDataPoint: BalanceDataPoint?
    @State private var isLoading = false
    @State private var showTooltip = false
    @State private var hasLoggedNegativeBalance = false
    
    enum TimeRange: String, CaseIterable {
        case oneDay = "1D"
        case oneWeek = "1W"
        case oneMonth = "1M"
        case threeMonths = "3M"
        case yearToDate = "YTD"
        case oneYear = "1Y"
        case all = "All"
    }
    
    private var totalBalance: Double {
        let totalIncome = transactionViewModel.transactions
            .filter { $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
        
        let totalExpenses = transactionViewModel.transactions
            .filter { $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
        
        let startingBalance = CurrencyUtility.startingBalance
        return startingBalance + totalIncome - totalExpenses
    }
    
    private var currentPeriodIncome: Double {
        let dateRange = getDateRange(for: selectedTimeRange)
        return transactionViewModel.transactions
            .filter { $0.date >= dateRange.start && $0.date <= dateRange.end && $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var currentPeriodExpenses: Double {
        let dateRange = getDateRange(for: selectedTimeRange)
        return transactionViewModel.transactions
            .filter { $0.date >= dateRange.start && $0.date <= dateRange.end && $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
    }
    
    private var overallTrend: TrendDirection {
        let data = chartData
        guard data.count >= 2 else { return .neutral }
        
        let firstBalance = data.first?.balance ?? 0
        let lastBalance = data.last?.balance ?? 0
        
        if lastBalance > firstBalance {
            return .positive
        } else if lastBalance < firstBalance {
            return .negative
        } else {
            return .neutral
        }
    }
    
    private var lineColor: Color {
        switch overallTrend {
        case .positive:
            return Constants.Colors.success // Blue
        case .negative:
            return Constants.Colors.primaryPink // Brand Pink
        case .neutral:
            return Constants.Colors.textSecondary
        }
    }
    
    private var currentPeriodLabel: String {
        switch selectedTimeRange {
        case .oneDay:
            return contentManager.localizedString("period.today")
        case .oneWeek:
            return contentManager.localizedString("period.this_week")
        case .oneMonth:
            return contentManager.localizedString("period.this_month")
        case .threeMonths:
            return contentManager.localizedString("period.last_3_months")
        case .yearToDate:
            return contentManager.localizedString("period.ytd")
        case .oneYear:
            return contentManager.localizedString("period.last_year")
        case .all:
            return contentManager.localizedString("period.all_time")
        }
    }
    
    private var incomeChangePercentage: Double {
        let currentIncome = currentPeriodIncome
        let previousIncome = getPreviousPeriodIncome()
        
        guard previousIncome != 0 else { 
            // If no previous data but we have current data, show 100% increase
            return currentIncome > 0 ? 100.0 : 0.0
        }
        return ((currentIncome - previousIncome) / previousIncome) * 100
    }
    
    private var expenseChangePercentage: Double {
        let currentExpenses = currentPeriodExpenses
        let previousExpenses = getPreviousPeriodExpenses()
        
        guard previousExpenses != 0 else { 
            // If no previous data but we have current data, show 100% increase
            return currentExpenses > 0 ? 100.0 : 0.0
        }
        return ((currentExpenses - previousExpenses) / previousExpenses) * 100
    }
    
    // MARK: - Helper Functions
    
    private func getDateRange(for timeRange: TimeRange) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch timeRange {
        case .oneDay:
            let startOfDay = calendar.startOfDay(for: now)
            return (startOfDay, now)
            
        case .oneWeek:
            let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
            return (weekAgo, now)
            
        case .oneMonth:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return (monthAgo, now)
            
        case .threeMonths:
            let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            return (threeMonthsAgo, now)
            
        case .yearToDate:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            return (startOfYear, now)
            
        case .oneYear:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return (yearAgo, now)
            
        case .all:
            // For "All", get the earliest transaction date or a reasonable default
            let earliestTransaction = transactionViewModel.transactions.min { $0.date < $1.date }
            let startDate = earliestTransaction?.date ?? calendar.date(byAdding: .year, value: -2, to: now) ?? now
            return (startDate, now)
        }
    }
    
    private func getPreviousPeriodIncome() -> Double {
        let currentRange = getDateRange(for: selectedTimeRange)
        let periodDuration = currentRange.end.timeIntervalSince(currentRange.start)
        let previousStart = currentRange.start.addingTimeInterval(-periodDuration)
        let previousEnd = currentRange.start
        
        return transactionViewModel.transactions
            .filter { $0.date >= previousStart && $0.date < previousEnd && $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func getPreviousPeriodExpenses() -> Double {
        let currentRange = getDateRange(for: selectedTimeRange)
        let periodDuration = currentRange.end.timeIntervalSince(currentRange.start)
        let previousStart = currentRange.start.addingTimeInterval(-periodDuration)
        let previousEnd = currentRange.start
        
        return transactionViewModel.transactions
            .filter { $0.date >= previousStart && $0.date < previousEnd && $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
    }
    
    /// Calculates the starting balance for the selected time period
    private func getStartingBalanceForPeriod() -> Double {
        let dateRange = getDateRange(for: selectedTimeRange)
        let periodStartDate = dateRange.start
        
        // Calculate balance at the start of the selected period
        let transactionsBeforePeriod = transactionViewModel.transactions
            .filter { $0.date < periodStartDate }
        
        let incomeBeforePeriod = transactionsBeforePeriod
            .filter { $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
        
        let expensesBeforePeriod = transactionsBeforePeriod
            .filter { $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
        
        return CurrencyUtility.startingBalance + incomeBeforePeriod - expensesBeforePeriod
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.small) {
            headerSection
            
            Spacer()
                .frame(height: Constants.UI.Spacing.medium)
            
            if isLoading {
                loadingView
            } else {
                chartArea
            }
            
            timePeriodSelector
        }
        .onAppear {
            refreshChartData()
        }
        .onChange(of: selectedTimeRange) { _, _ in
            refreshChartData()
        }
        .onChange(of: transactionViewModel.transactions.count) { _, _ in
            refreshChartData()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.success))
            Text(contentManager.localizedString("chart.loading"))
                .font(Constants.Typography.Body.font)
                .foregroundColor(Constants.Colors.textSecondary)
        }
        .frame(height: 200)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(contentManager.localizedString("chart.total_balance"))
                .font(Constants.Typography.Caption.font)
                .foregroundColor(Constants.Colors.textSecondary)
            
            Text(totalBalance.formatted(.currency(code: "USD")))
                .font(Constants.Typography.Mono.H1.font)
                .foregroundColor(Constants.Colors.textPrimary)
            
            // Income/Expense metrics moved here
            VStack(alignment: .leading, spacing: 1) {
                // Income
                HStack(alignment: .center, spacing: 2) {
                    Text(contentManager.localizedString("chart.up_arrow"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.success)
                    
                    Text(currentPeriodIncome.formatted(.currency(code: "USD")))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.success)
                    
                    let periodStartingBalance = getStartingBalanceForPeriod()
                    let incomePercentageOfStartingBalance = periodStartingBalance > 0 ? (currentPeriodIncome / periodStartingBalance) * 100 : 0
                    Text("(\(String(format: "%.1f", incomePercentageOfStartingBalance))%)")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.success)
                    
                    Text("\(currentPeriodLabel) \(contentManager.localizedString("income.label"))")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Spacer()
                }
                .lineLimit(1)
                
                // Expenses
                HStack(alignment: .center, spacing: 2) {
                    Text(contentManager.localizedString("chart.down_arrow"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.error)
                    
                    Text(currentPeriodExpenses.formatted(.currency(code: "USD")))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.error)
                    
                    let periodStartingBalance = getStartingBalanceForPeriod()
                    let expensePercentageOfStartingBalance = periodStartingBalance > 0 ? (currentPeriodExpenses / periodStartingBalance) * 100 : 0
                    Text("(\(String(format: "%.1f", expensePercentageOfStartingBalance))%)")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.error)
                    
                    Text("\(currentPeriodLabel) \(contentManager.localizedString("expense.label"))")
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
                    RuleMark(y: .value("Baseline", 0))
                        .foregroundStyle(Constants.Colors.textSecondary.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    
                    ForEach(chartData, id: \.id) { dataPoint in
                        AreaMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Balance", dataPoint.balance)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    lineColor.opacity(0.3),
                                    lineColor.opacity(0.05)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Balance", dataPoint.balance)
                        )
                        .foregroundStyle(lineColor)
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartBackground { chartProxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let location = value.location
                                        if let date = chartProxy.value(atX: location.x, as: Date.self) {
                                            if let dataPoint = chartData.first(where: { 
                                                Calendar.current.isDate($0.date, inSameDayAs: date)
                                            }) {
                                                selectedDataPoint = dataPoint
                                                showTooltip = true
                                                
                                                HapticFeedbackManager.light()
                                            }
                                        }
                                    }
                                    .onEnded { _ in
                                        showTooltip = false
                                        selectedDataPoint = nil
                                    }
                            )
                    }
                }
                .frame(height: 200)
                .padding(.horizontal, Constants.UI.Padding.screenMargin)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Constants.Colors.backgroundPrimary)
                )
                
                if showTooltip, let dataPoint = selectedDataPoint {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatCurrency(dataPoint.balance))
                            .font(Constants.Typography.H3.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                        
                        if let change = dataPoint.change, let percentage = dataPoint.changePercentage {
                            HStack(spacing: 4) {
                                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                    .font(Constants.Typography.Caption.font)
                                Text("\(change >= 0 ? "+" : "")\(formatCurrency(change)) (\(String(format: "%.1f", percentage))%)")
                                    .font(Constants.Typography.Caption.font)
                            }
                            .foregroundColor(change >= 0 ? Constants.Colors.success : Constants.Colors.error)
                        }
                        
                        Text(selectedTimeRange == .oneDay ? formatTime(dataPoint.date) : formatDate(dataPoint.date))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                            .fill(Constants.Colors.cardBackground)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                    .offset(x: -20, y: -20)
                }
            }
        }
        .padding(.horizontal, -Constants.UI.Padding.screenMargin)
    }
    
    private var chartSegments: [ChartSegment] {
        let data = chartData
        let baseline = totalBalance
        var segments: [ChartSegment] = []
        var currentSegment: [BalanceDataPoint] = []
        var currentAboveBaseline: Bool? = nil
        
        for (_, dataPoint) in data.enumerated() {
            let isAboveBaseline = dataPoint.balance >= baseline
            
            if currentAboveBaseline == nil {
                currentAboveBaseline = isAboveBaseline
                currentSegment.append(dataPoint)
            } else if isAboveBaseline == currentAboveBaseline {
                currentSegment.append(dataPoint)
            } else {
                if !currentSegment.isEmpty, let aboveBaseline = currentAboveBaseline {
                    segments.append(ChartSegment(
                        data: currentSegment,
                        color: lineColor,
                        isAboveBaseline: aboveBaseline
                    ))
                }
                currentSegment = [dataPoint]
                currentAboveBaseline = isAboveBaseline
            }
        }
        
        if !currentSegment.isEmpty, let aboveBaseline = currentAboveBaseline {
            segments.append(ChartSegment(
                data: currentSegment,
                color: lineColor,
                isAboveBaseline: aboveBaseline
            ))
        }
        
        return segments
    }
    
    private var chartData: [BalanceDataPoint] {
        let calendar = Calendar.current
        var data: [BalanceDataPoint] = []
        
        let dateRange = getDateRange(for: selectedTimeRange)
        let startDate = dateRange.start
        let endDate = dateRange.end
        
        // Cache base balance to avoid repeated UserDefaults calls
        let baseBalance = getBaseBalance()
        
        if selectedTimeRange == .oneDay {
            // For 1D view, generate hourly data points
            let hours = calendar.dateComponents([.hour], from: startDate, to: endDate).hour ?? 24
            let stepSize = getOptimalStepSize(for: selectedTimeRange, totalDays: hours)
            
            for i in stride(from: 0, to: hours, by: stepSize) {
                let date = calendar.date(byAdding: .hour, value: i, to: startDate) ?? startDate
                let balance = calculateBalanceForDate(date, baseBalance: baseBalance)
                
                let previousBalance = data.last?.balance ?? baseBalance
                let change = balance - previousBalance
                let changePercentage = previousBalance != 0 ? (change / abs(previousBalance)) * 100 : 0
                
                data.append(BalanceDataPoint(
                    date: date, 
                    balance: balance, 
                    change: data.isEmpty ? nil : change,
                    changePercentage: data.isEmpty ? nil : changePercentage
                ))
            }
        } else {
            // For other views, use daily data points
            let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 1
            let stepSize = getOptimalStepSize(for: selectedTimeRange, totalDays: days)
            
            for i in stride(from: 0, to: days, by: stepSize) {
                let date = calendar.date(byAdding: .day, value: i, to: startDate) ?? startDate
                let balance = calculateBalanceForDate(date, baseBalance: baseBalance)
                
                let previousBalance = data.last?.balance ?? baseBalance
                let change = balance - previousBalance
                let changePercentage = previousBalance != 0 ? (change / abs(previousBalance)) * 100 : 0
                
                data.append(BalanceDataPoint(
                    date: date, 
                    balance: balance, 
                    change: data.isEmpty ? nil : change,
                    changePercentage: data.isEmpty ? nil : changePercentage
                ))
            }
        }
        
        if !data.isEmpty && data.last?.date != endDate {
            let balance = calculateBalanceForDate(endDate, baseBalance: baseBalance)
            let previousBalance = data.last?.balance ?? baseBalance
            let change = balance - previousBalance
            let changePercentage = previousBalance != 0 ? (change / abs(previousBalance)) * 100 : 0
            
            data.append(BalanceDataPoint(
                date: endDate, 
                balance: balance,
                change: change,
                changePercentage: changePercentage
            ))
        }
        
        return data.sorted { $0.date < $1.date }
    }
    
    private func getOptimalStepSize(for timeRange: TimeRange, totalDays: Int) -> Int {
        switch timeRange {
        case .oneDay:
            return 1 // Hourly data for 1 day
        case .oneWeek:
            return 1
        case .oneMonth:
            return 1
        case .threeMonths:
            return 1
        case .yearToDate:
            return 7
        case .oneYear:
            return 7
        case .all:
            return 30
        }
    }
    
    private func calculateBalanceForDate(_ date: Date, baseBalance: Double? = nil) -> Double {
        let calendar = Calendar.current
        let endTime: Date
        
        if selectedTimeRange == .oneDay {
            // For hourly data, use the exact date as the cutoff
            endTime = date
        } else {
            // For daily data, use end of day
            let startOfDay = calendar.startOfDay(for: date)
            endTime = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        }
        
        let transactionsUpToDate = transactionViewModel.transactions.filter { transaction in
            transaction.date < endTime
        }
        
        let totalIncome = transactionsUpToDate
            .filter { $0.amount > 0 }
            .reduce(0) { $0 + $1.amount }
        
        let totalExpenses = transactionsUpToDate
            .filter { $0.amount < 0 }
            .reduce(0) { $0 + abs($1.amount) }
        
        let baseBalanceValue = baseBalance ?? getBaseBalance()
        let calculatedBalance = baseBalanceValue + totalIncome - totalExpenses
        
        // Only log negative balances once per session to avoid spam
        if calculatedBalance < 0 && !hasLoggedNegativeBalance {
            DebugLogger.balanceCalculation("Negative balance detected: \(calculatedBalance) at \(date)")
            DebugLogger.balanceCalculation("Base balance: \(baseBalanceValue), Income: \(totalIncome), Expenses: \(totalExpenses), Transactions: \(transactionsUpToDate.count)")
            hasLoggedNegativeBalance = true
        }
        
        return calculatedBalance
    }
    
    private func getBaseBalance() -> Double {
        return CurrencyUtility.startingBalance
    }
    
    private func refreshChartData() {
        isLoading = true
        
        // Use Task for proper Swift 6 concurrency
        Task { @MainActor in
            // Pre-calculate chart data on main actor
            let _ = chartData
            
            // Simulate some processing time if needed
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            isLoading = false
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
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


