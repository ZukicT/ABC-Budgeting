import SwiftUI
import Charts


// MARK: - Overview View

struct OverviewView: View {
    let transactions: [TransactionItem]
    let goals: [GoalFormItem]
    let onSeeAllGoals: () -> Void
    let onSeeAllTransactions: () -> Void
    let onAddTransaction: (TransactionItem) -> Void
    
    @State private var showAddTransaction = false
    @State private var preSelectedTransactionType: TransactionType = .expense
    @AppStorage("preferredCurrency") private var preferredCurrency: String = "USD"
    @State private var selectedTimeframe: String = "1W"
    @State private var selectedDataPoint: BalanceDataPoint?
    
    private var currencyCode: String {
        preferredCurrency.components(separatedBy: " ").first ?? "USD"
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 0) {
                // Header with balance - Robinhood style
                balanceHeaderSection
                    .padding(.top, -20)
                
                // Quick Actions - Clean horizontal layout
                quickActionsSection
                    .padding(.top, 40)
                
                // Stats Cards - Professional grid
                statsCardsSection
                    .padding(.top, 24)
                
                // Goals Preview - Clean card design
                goalsPreviewSection
                    .padding(.top, 24)
                
                // Recent Activity - Streamlined list
                recentActivitySection
                    .padding(.top, 24)
                
                // Market Insights - Professional charts
                marketInsightsSection
                    .padding(.top, 24)
            .padding(.bottom, 100)
        }
            .padding(.horizontal, 16)
        }
        .background(RobinhoodColors.background)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Overview dashboard with balance, quick actions, stats, goals, and recent activity")
        .sheet(isPresented: $showAddTransaction) {
            PreSelectedAddTransactionView(
                availableGoals: goals,
                preSelectedType: preSelectedTransactionType == .income ? .income : .expense
            ) { newTransaction in
                onAddTransaction(newTransaction)
                showAddTransaction = false
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.regularMaterial)
            .presentationCornerRadius(16)
            .presentationCompactAdaptation(.sheet)
        }
    }
    
    // MARK: - View Components
    
    /// Balance header section - Enhanced design
    private var balanceHeaderSection: some View {
        VStack(spacing: 24) {
            // Balance information with improved hierarchy
            VStack(alignment: .leading, spacing: 12) {
                // Header with change indicator
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Balance")
                            .font(RobinhoodTypography.headline)
                            .foregroundColor(RobinhoodColors.textPrimary)
                        
                        HStack(spacing: 6) {
                            Text(selectedDataPoint != nil ? getSelectedPeriodLabel() : getCurrentPeriodLabel())
                                .font(RobinhoodTypography.caption)
                                .foregroundColor(RobinhoodColors.textSecondary)
                            
                            let change = selectedDataPoint != nil ? 
                                calculateChangeForDataPoint(selectedDataPoint!) : 
                                getCurrentPeriodChange()
                            
                            HStack(spacing: 2) {
                                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundColor(change >= 0 ? RobinhoodColors.primary : RobinhoodColors.error)
                                
                                Text(change >= 0 ? "+" : "")
                                    .font(RobinhoodTypography.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(change >= 0 ? RobinhoodColors.primary : RobinhoodColors.error)
                                
                                Text(change.formatted(.currency(code: currencyCode).precision(.fractionLength(2))))
                                    .font(RobinhoodTypography.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(change >= 0 ? RobinhoodColors.primary : RobinhoodColors.error)
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill((change >= 0 ? RobinhoodColors.primary : RobinhoodColors.error).opacity(0.15))
                            )
                        }
                    }
                    
                    Spacer()
                }
                
                // Balance value
                Text((selectedDataPoint?.balance ?? totalBalance).formatted(.currency(code: currencyCode).precision(.fractionLength(2))))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(RobinhoodColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            
            // Full-width line chart
            balanceTrendChart
                .background(
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Clear selection when tapping outside the chart
                            selectedDataPoint = nil
                        }
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, -20)
    }
    
    /// Balance trend chart - Full-width Robinhood-style line chart
    private var balanceTrendChart: some View {
        VStack(spacing: 16) {
            // Full-width line chart (no card styling)
            let chartData = generateBalanceTrendData()
            
            if chartData.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 32))
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    Text("No data available")
                        .font(RobinhoodTypography.callout)
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    Text("Add some transactions to see your balance trend")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            } else {
                RobinhoodLineChart(
                    data: chartData,
                    currencyCode: currencyCode,
                    selectedDataPoint: $selectedDataPoint
                )
                .frame(height: 200)
                .padding(.horizontal, 16)
            }
            
            // Timeframe selector below the chart - Proper HIG Segmented Control
            Picker("Timeframe", selection: $selectedTimeframe) {
                Text("1D").tag("1D")
                Text("1W").tag("1W")
                Text("1M").tag("1M")
                Text("3M").tag("3M")
                Text("YTD").tag("YTD")
                Text("1Y").tag("1Y")
            }
            .pickerStyle(.segmented)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(RobinhoodColors.cardBackground)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .onChange(of: selectedTimeframe) {
                // Haptic feedback for better responsiveness
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedDataPoint = nil // Reset selection when changing timeframe
                }
            }
        }
    }
    
    /// Generate balance trend data based on selected timeframe
    private func generateBalanceTrendData() -> [BalanceDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        var dataPoints: [BalanceDataPoint] = []
        
        let (periods, interval) = getTimeframeData(selectedTimeframe)
        
        // For 1D, show hourly data for the current day (12 AM to 11 PM)
        if selectedTimeframe == "1D" {
            let startOfDay = calendar.startOfDay(for: now)
            let startingBalance = calculateStartingBalance(for: selectedTimeframe, calendar: calendar)
            var runningBalance = startingBalance
            
            for hour in 0..<24 {
                let hourDate = calendar.date(byAdding: .hour, value: hour, to: startOfDay) ?? startOfDay
                let periodTransactions = getTransactionsForPeriod(date: hourDate, interval: .hour, calendar: calendar)
                
                let periodIncome = periodTransactions
                    .filter { $0.isIncome }
                    .reduce(0) { $0 + $1.amount }
                
                let periodExpenses = periodTransactions
                    .filter { !$0.isIncome }
                    .reduce(0) { $0 + $1.amount }
                
                // Update running balance
                runningBalance += (periodIncome - periodExpenses)
                
                dataPoints.append(BalanceDataPoint(
                    date: hourDate,
                    balance: runningBalance,
                    income: periodIncome,
                    expenses: periodExpenses
                ))
            }
        } else {
            // For other timeframes, use the existing logic
            let startingBalance = calculateStartingBalance(for: selectedTimeframe, calendar: calendar)
            var runningBalance = startingBalance
            
            for i in 0..<periods {
                let date = calendar.date(byAdding: interval, value: -(periods - 1) + i, to: now) ?? now
                let periodTransactions = getTransactionsForPeriod(date: date, interval: interval, calendar: calendar)
                
                let periodIncome = periodTransactions
                    .filter { $0.isIncome }
                    .reduce(0) { $0 + $1.amount }
                
                let periodExpenses = periodTransactions
                    .filter { !$0.isIncome }
                    .reduce(0) { $0 + $1.amount }
                
                // Update running balance
                runningBalance += (periodIncome - periodExpenses)
                
                dataPoints.append(BalanceDataPoint(
                    date: date,
                    balance: runningBalance,
                    income: periodIncome,
                    expenses: periodExpenses
                ))
            }
        }
        
        return dataPoints.sorted { $0.date < $1.date }
    }
    
    /// Calculate starting balance for the selected timeframe
    private func calculateStartingBalance(for timeframe: String, calendar: Calendar) -> Double {
        let now = Date()
        
        if timeframe == "1D" {
            // For 1D, start from the beginning of the current day
            let startOfDay = calendar.startOfDay(for: now)
            
            // Get all transactions from start of day to now
            let futureTransactions = transactions.filter { $0.date >= startOfDay }
            
            // Calculate net change from future transactions
            let futureIncome = futureTransactions
                .filter { $0.isIncome }
                .reduce(0) { $0 + $1.amount }
            
            let futureExpenses = futureTransactions
                .filter { !$0.isIncome }
                .reduce(0) { $0 + $1.amount }
            
            // Current balance minus future net change
            return totalBalance - (futureIncome - futureExpenses)
        } else {
            // For other timeframes, use the existing logic
            let (periods, interval) = getTimeframeData(timeframe)
            let startDate = calendar.date(byAdding: interval, value: -(periods - 1), to: now) ?? now
            
            // Get all transactions from start date to now
            let futureTransactions = transactions.filter { $0.date >= startDate }
            
            // Calculate net change from future transactions
            let futureIncome = futureTransactions
                .filter { $0.isIncome }
                .reduce(0) { $0 + $1.amount }
            
            let futureExpenses = futureTransactions
                .filter { !$0.isIncome }
                .reduce(0) { $0 + $1.amount }
            
            // Current balance minus future net change
            return totalBalance - (futureIncome - futureExpenses)
        }
    }
    
    /// Get transactions for a specific time period
    private func getTransactionsForPeriod(date: Date, interval: Calendar.Component, calendar: Calendar) -> [TransactionItem] {
        switch interval {
        case .hour:
            // For hourly data, get transactions within that hour
            let startOfHour = calendar.dateInterval(of: .hour, for: date)?.start ?? date
            let endOfHour = calendar.date(byAdding: .hour, value: 1, to: startOfHour) ?? date
            return transactions.filter { $0.date >= startOfHour && $0.date < endOfHour }
        case .day:
            // For daily data, get transactions within that day
            return transactions.filter { calendar.isDate($0.date, inSameDayAs: date) }
        case .weekOfYear:
            // For weekly data, get transactions within that week
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
            let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek) ?? date
            return transactions.filter { $0.date >= startOfWeek && $0.date < endOfWeek }
        case .month:
            // For monthly data, get transactions within that month
            let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? date
            return transactions.filter { $0.date >= startOfMonth && $0.date < endOfMonth }
        default:
            // For other intervals, get transactions within that day
            return transactions.filter { calendar.isDate($0.date, inSameDayAs: date) }
        }
    }
    
    /// Get timeframe data based on selection
    private func getTimeframeData(_ timeframe: String) -> (periods: Int, interval: Calendar.Component) {
        switch timeframe {
        case "1D": return (24, .hour) // 24 hours (12 AM to 11 PM for current day)
        case "1W": return (7, .day)   // Last 7 days
        case "1M": return (30, .day)  // Last 30 days
        case "3M": return (12, .weekOfYear) // Last 12 weeks (3 months)
        case "YTD": return (12, .month) // Year to date (12 months)
        case "1Y": return (12, .month) // Last 12 months
        default: return (7, .day)
        }
    }
    
    /// Calculate change for a specific data point
    private func calculateChangeForDataPoint(_ dataPoint: BalanceDataPoint) -> Double {
        let data = generateBalanceTrendData()
        guard let currentIndex = data.firstIndex(where: { $0.date == dataPoint.date }),
              currentIndex > 0 else { return 0 }
        
        let previousPoint = data[currentIndex - 1]
        return dataPoint.balance - previousPoint.balance
    }
    
    /// Get data point at tap location
    private func getDataPointAtLocation(_ location: CGPoint, in data: [BalanceDataPoint]) -> BalanceDataPoint? {
        guard !data.isEmpty else { return nil }
        
        let chartWidth: CGFloat = UIScreen.main.bounds.width - 32 // Account for padding
        let stepX = chartWidth / CGFloat(data.count - 1)
        let index = Int(location.x / stepX)
        
        guard index >= 0 && index < data.count else { return nil }
        return data[index]
    }
    
    /// Get data point count for a specific timeframe
    private func getDataPointCount(for timeframe: String) -> Int {
        let (periods, _) = getTimeframeData(timeframe)
        return periods
    }
    
    /// Get label for selected period
    private func getSelectedPeriodLabel() -> String {
        guard let selectedPoint = selectedDataPoint else { return "Selected period" }
        
        let formatter = DateFormatter()
        switch selectedTimeframe {
        case "1D":
            formatter.dateFormat = "h:mm a"
            return "At \(formatter.string(from: selectedPoint.date))"
        case "1W":
            formatter.dateFormat = "E, MMM d"
            return formatter.string(from: selectedPoint.date)
        case "1M":
            formatter.dateFormat = "MMM d"
            return formatter.string(from: selectedPoint.date)
        case "3M":
            formatter.dateFormat = "MMM d"
            return "Week of \(formatter.string(from: selectedPoint.date))"
        case "1Y":
            formatter.dateFormat = "MMM yyyy"
            return formatter.string(from: selectedPoint.date)
        default:
            return "Selected period"
        }
    }
    
    /// Get label for current period
    private func getCurrentPeriodLabel() -> String {
        switch selectedTimeframe {
        case "1D": return "Today (hourly)"
        case "1W": return "Last 7 days"
        case "1M": return "Last 30 days"
        case "3M": return "Last 3 months"
        case "YTD": return "Year to date"
        case "1Y": return "Last 12 months"
        default: return "This period"
        }
    }
    
    /// Get current period change
    private func getCurrentPeriodChange() -> Double {
        let data = generateBalanceTrendData()
        guard data.count >= 2 else { return 0 }
        
        let latest = data.last!
        let previous = data[data.count - 2]
        return latest.balance - previous.balance
    }
    
    /// Quick actions section - Clean horizontal layout
    private var quickActionsSection: some View {
        VStack(spacing: 24) {
            // Divider line above buttons
            Rectangle()
                .fill(RobinhoodColors.border)
                .frame(height: 1)
                .padding(.horizontal, 16)
            
            HStack(spacing: 12) {
                Button(action: {
                    preSelectedTransactionType = .income
                    showAddTransaction = true
                }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Add Income")
                        .font(RobinhoodTypography.headline)
                }
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(RobinhoodColors.primary)
                .cornerRadius(120)
            }
            
            Button(action: {
                preSelectedTransactionType = .expense
                showAddTransaction = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Add Expense")
                        .font(RobinhoodTypography.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(RobinhoodColors.error)
                .cornerRadius(120)
            }
            }
        }
    }
    
    /// Stats cards section - Professional grid
    private var statsCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            Text("Monthly Overview")
                .font(RobinhoodTypography.title3)
                .foregroundColor(RobinhoodColors.textPrimary)
                .padding(.horizontal, 4)
            
            // Cards Row
            HStack(spacing: 12) {
                // Monthly Income Card
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Income")
                            .font(RobinhoodTypography.title3)
                            .foregroundColor(RobinhoodColors.textPrimary)
                        
                        HStack(spacing: 6) {
                            Text("This month")
                                .font(RobinhoodTypography.caption)
                                .foregroundColor(RobinhoodColors.textSecondary)
                            
                            HStack(spacing: 2) {
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundColor(RobinhoodColors.success)
                                
                                Text("+5%")
                                    .font(RobinhoodTypography.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(RobinhoodColors.success)
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(RobinhoodColors.success.opacity(0.15))
                            )
                        }
                    }
                    
                    // Value
                    Text(currentMonthIncome.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                        .font(RobinhoodTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(RobinhoodColors.success)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(RobinhoodColors.cardBackground)
                )
                
                // Monthly Expenses Card
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Expenses")
                            .font(RobinhoodTypography.title3)
                            .foregroundColor(RobinhoodColors.textPrimary)
                        
                        HStack(spacing: 6) {
                            Text("This month")
                                .font(RobinhoodTypography.caption)
                                .foregroundColor(RobinhoodColors.textSecondary)
                            
                            HStack(spacing: 2) {
                                Image(systemName: "arrow.down")
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundColor(RobinhoodColors.error)
                                
                                Text("-2%")
                                    .font(RobinhoodTypography.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(RobinhoodColors.error)
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(RobinhoodColors.error.opacity(0.15))
                            )
                        }
                    }
                    
                    // Value
                    Text(currentMonthExpenses.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                        .font(RobinhoodTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(RobinhoodColors.error)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(RobinhoodColors.cardBackground)
                )
            }
        }
    }
    
    /// Goals preview section - Clean card design
    private var goalsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Goals")
                    .font(RobinhoodTypography.title3)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                Spacer()
                
                Button("View All") {
                    onSeeAllGoals()
                }
                .font(RobinhoodTypography.callout)
                .foregroundColor(RobinhoodColors.primary)
            }
            
            goalsPreviewGrid(goals: goals, currencyCode: currencyCode)
        }
    }
    
    /// Recent activity section - Streamlined list
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(RobinhoodTypography.title3)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                Spacer()
                
                Button("View All") {
                    onSeeAllTransactions()
                }
                .font(RobinhoodTypography.callout)
                .foregroundColor(RobinhoodColors.primary)
            }
            
            recentActivityList(transactions: transactions, currencyCode: currencyCode)
        }
    }
    
    /// Market insights section - Professional charts
    private var marketInsightsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Financial Insights")
                .font(RobinhoodTypography.title3)
                .foregroundColor(RobinhoodColors.textPrimary)
            
            VStack(spacing: 16) {
                // Income vs Expenses Bar Chart
                incomeVsExpensesChart(transactions: transactions, currencyCode: currencyCode)
                
                // Spending Breakdown Pie Chart
                spendingBreakdownChart(transactions: transactions, currencyCode: currencyCode)
                
                // Monthly Spending Trend
                monthlySpendingTrendChart(transactions: transactions, currencyCode: currencyCode)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func goalsPreviewGrid(goals: [GoalFormItem], currencyCode: String) -> some View {
        VStack(spacing: 12) {
            ForEach(goals.prefix(3), id: \.id) { goal in
                RobinhoodGoalCard(goal: goal, currencyCode: currencyCode)
            }
        }
    }
    
    private func recentActivityList(transactions: [TransactionItem], currencyCode: String) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(transactions.prefix(5).enumerated()), id: \.offset) { index, transaction in
                RobinhoodTransactionRow(transaction: transaction, currencyCode: currencyCode)
                
                if index < min(4, transactions.count - 1) {
                    Divider()
                        .background(RobinhoodColors.border)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RobinhoodColors.cardBackground)
        )
    }
    
    // MARK: - Chart Components
    
    /// Income vs Expenses Bar Chart - Following Apple HIG
    private func incomeVsExpensesChart(transactions: [TransactionItem], currencyCode: String) -> some View {
        let currentIncome = currentMonthIncome
        let currentExpenses = currentMonthExpenses
        let incomeGap = currentIncome - currentExpenses
        let isOnTrack = incomeGap >= 0
        
        let chartData = [
            ("Income", currentIncome, RobinhoodColors.success),
            ("Expenses", currentExpenses, RobinhoodColors.error)
        ]
        
        return VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Income vs Expenses")
                    .font(RobinhoodTypography.headline)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                Spacer()
                
                Image(systemName: isOnTrack ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(isOnTrack ? RobinhoodColors.success : RobinhoodColors.warning)
            }
            
            // Bar Chart
            Chart {
                ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                    BarMark(
                        x: .value("Category", data.0),
                        y: .value("Amount", data.1)
                    )
                    .foregroundStyle(data.2)
                    .cornerRadius(4)
                }
            }
            .frame(height: 120)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(amount.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                                .font(.caption2)
                                .foregroundColor(RobinhoodColors.textSecondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let category = value.as(String.self) {
                            Text(category)
                                .font(.caption)
                                .foregroundColor(RobinhoodColors.textPrimary)
                        }
                    }
                }
            }
            
            // Summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Net Result")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    Text(incomeGap.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                        .font(RobinhoodTypography.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(isOnTrack ? RobinhoodColors.success : RobinhoodColors.error)
                }
                
                Spacer()
                
                Text(isOnTrack ? "On track" : "Over budget")
                    .font(RobinhoodTypography.caption2)
                    .foregroundColor(isOnTrack ? RobinhoodColors.success : RobinhoodColors.warning)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RobinhoodColors.cardBackground)
        )
    }
    
    /// Spending Breakdown Pie Chart - Following Apple HIG
    private func spendingBreakdownChart(transactions: [TransactionItem], currencyCode: String) -> some View {
        let spendingCategories = getSpendingCategories(transactions: transactions)
        let totalSpending = spendingCategories.reduce(0) { $0 + $1.amount }
        
        return VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Spending by Category")
                    .font(RobinhoodTypography.headline)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                Text("This month's expense breakdown")
                    .font(RobinhoodTypography.caption)
                    .foregroundColor(RobinhoodColors.textSecondary)
            }
            
            if spendingCategories.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 32))
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    Text("No spending data")
                        .font(RobinhoodTypography.callout)
                        .foregroundColor(RobinhoodColors.textSecondary)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
            } else {
                HStack(spacing: 16) {
                    // Pie Chart
                    Chart {
                        ForEach(Array(spendingCategories.enumerated()), id: \.offset) { index, category in
                            SectorMark(
                                angle: .value("Amount", category.amount),
                                innerRadius: .ratio(0.4),
                                angularInset: 2
                            )
                            .foregroundStyle(category.color)
                            .opacity(0.8)
                        }
                    }
                    .frame(width: 120, height: 120)
                    .chartAngleSelection(value: .constant(nil as Double?))
                    
                    // Legend
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(spendingCategories.enumerated()), id: \.offset) { index, category in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 12, height: 12)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(category.name)
                                        .font(.caption)
                                        .foregroundColor(RobinhoodColors.textPrimary)
                                    
                                    Text("\(Int((category.amount / totalSpending) * 100))%")
                                        .font(.caption2)
                                        .foregroundColor(RobinhoodColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Text(category.amount.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                                    .font(.caption2)
                                    .foregroundColor(RobinhoodColors.textPrimary)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RobinhoodColors.cardBackground)
        )
    }
    
    /// Monthly Spending Trend Line Chart - Following Apple HIG
    private func monthlySpendingTrendChart(transactions: [TransactionItem], currencyCode: String) -> some View {
        let monthlyData = getMonthlySpendingData(transactions: transactions)
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        return VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("Monthly Spending Trend")
                    .font(RobinhoodTypography.headline)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                Text("6-month expense pattern")
                    .font(RobinhoodTypography.caption)
                    .foregroundColor(RobinhoodColors.textSecondary)
            }
            
            if monthlyData.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 32))
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    Text("Insufficient data for trend")
                        .font(RobinhoodTypography.callout)
                        .foregroundColor(RobinhoodColors.textSecondary)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(Array(monthlyData.enumerated()), id: \.offset) { index, data in
                        LineMark(
                            x: .value("Month", data.month),
                            y: .value("Amount", data.amount)
                        )
                        .foregroundStyle(RobinhoodColors.error)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        
                        AreaMark(
                            x: .value("Month", data.month),
                            y: .value("Amount", data.amount)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [RobinhoodColors.error.opacity(0.3), RobinhoodColors.error.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        // Current month highlight
                        if data.month == currentMonth {
                            PointMark(
                                x: .value("Month", data.month),
                                y: .value("Amount", data.amount)
                            )
                            .foregroundStyle(RobinhoodColors.error)
                            .symbolSize(50)
                        }
                    }
                }
                .frame(height: 120)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text(amount.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                                    .font(.caption2)
                                    .foregroundColor(RobinhoodColors.textSecondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let month = value.as(Int.self) {
                                Text(monthName(for: month))
                                    .font(.caption2)
                                    .foregroundColor(RobinhoodColors.textSecondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RobinhoodColors.cardBackground)
        )
    }
    
    
    // MARK: - Computed Properties
    
    private var totalBalance: Double {
        let income = transactions
            .filter { $0.isIncome }
            .reduce(0) { $0 + $1.amount }
        
        let expenses = transactions
            .filter { !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
        
        return income - expenses
    }
    
    private var currentMonthIncome: Double {
        let now = Date()
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return transactions
            .filter { $0.isIncome && $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var currentMonthExpenses: Double {
        let now = Date()
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        return transactions
            .filter { !$0.isIncome && $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var weeklyChange: Double {
        let now = Date()
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let startOfLastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: startOfWeek) ?? now
        let endOfLastWeek = calendar.date(byAdding: .day, value: 6, to: startOfLastWeek) ?? now
        
        let thisWeekIncome = transactions
            .filter { $0.isIncome && $0.date >= startOfWeek }
            .reduce(0) { $0 + $1.amount }
        
        let thisWeekExpenses = transactions
            .filter { !$0.isIncome && $0.date >= startOfWeek }
            .reduce(0) { $0 + $1.amount }
        
        let lastWeekIncome = transactions
            .filter { $0.isIncome && $0.date >= startOfLastWeek && $0.date <= endOfLastWeek }
            .reduce(0) { $0 + $1.amount }
        
        let lastWeekExpenses = transactions
            .filter { !$0.isIncome && $0.date >= startOfLastWeek && $0.date <= endOfLastWeek }
            .reduce(0) { $0 + $1.amount }
        
        let thisWeekNet = thisWeekIncome - thisWeekExpenses
        let lastWeekNet = lastWeekIncome - lastWeekExpenses
        
        return thisWeekNet - lastWeekNet
    }
}

// MARK: - Chart Data Models

struct SpendingCategory: Equatable {
    let name: String
    let amount: Double
    let color: Color
    let transactionCount: Int
    
    init(name: String, amount: Double, color: Color, transactionCount: Int = 1) {
        self.name = name
        self.amount = amount
        self.color = color
        self.transactionCount = transactionCount
    }
}

struct MonthlyData {
    let month: Int
    let amount: Double
}

// MARK: - Robinhood Style Components

/// Professional stat card component inspired by Robinhood
struct RobinhoodStatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let trend: TrendDirection?
    let trendValue: String?
    let color: Color
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        trend: TrendDirection? = nil,
        trendValue: String? = nil,
        color: Color = RobinhoodColors.primary
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.trend = trend
        self.trendValue = trendValue
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with trend
            HStack {
                Text(title)
                    .font(RobinhoodTypography.caption)
                    .foregroundColor(RobinhoodColors.textSecondary)
                
                Spacer()
                
                if let trend = trend, let trendValue = trendValue {
                    HStack(spacing: 4) {
                        Image(systemName: trend.icon)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(trend.color)
                        
                        Text(trendValue)
                            .font(RobinhoodTypography.caption2)
                            .foregroundColor(trend.color)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(trend.color.opacity(0.1))
                    )
                }
            }
            
            // Value
            Text(value)
                .font(RobinhoodTypography.title2)
                .foregroundColor(RobinhoodColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            // Subtitle
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(RobinhoodTypography.caption2)
                    .foregroundColor(RobinhoodColors.textTertiary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(RobinhoodColors.cardBackground)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

/// Trend direction for stat cards
enum TrendDirection {
    case up
    case down
    case neutral
    
    var icon: String {
        switch self {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .neutral: return "minus"
        }
    }
    
    var color: Color {
        switch self {
        case .up: return RobinhoodColors.success
        case .down: return RobinhoodColors.error
        case .neutral: return RobinhoodColors.textTertiary
        }
    }
    
    var message: String {
        switch self {
        case .up: return "Spending increased"
        case .down: return "Spending decreased"
        case .neutral: return "Spending unchanged"
        }
    }
}




    /// Spending breakdown card - Professional chart design
    // MARK: - Chart Data Helpers
    
    /// Get spending categories for pie chart
    private func getSpendingCategories(transactions: [TransactionItem]) -> [SpendingCategory] {
        let expenseTransactions = transactions.filter { !$0.isIncome }
        let grouped = Dictionary(grouping: expenseTransactions, by: { $0.category })
        
        let colors: [Color] = [
            RobinhoodColors.error,
            RobinhoodColors.warning,
            RobinhoodColors.primary,
            RobinhoodColors.primary,
            RobinhoodColors.secondary,
            RobinhoodColors.success,
            RobinhoodColors.textSecondary,
            RobinhoodColors.textTertiary
        ]
        
        return grouped.map { category, transactions in
            let totalAmount = transactions.reduce(0) { $0 + $1.amount }
            let colorIndex = abs(category.hashValue) % colors.count
            return SpendingCategory(
                name: category.rawValue,
                amount: totalAmount,
                color: colors[colorIndex],
                transactionCount: transactions.count
            )
        }.sorted { $0.amount > $1.amount }
    }
    
    /// Get monthly spending data for trend chart
    private func getMonthlySpendingData(transactions: [TransactionItem]) -> [MonthlyData] {
        let calendar = Calendar.current
        let now = Date()
        var monthlyData: [MonthlyData] = []
        
        // Get last 6 months
        for i in 0..<6 {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: now),
                  let monthInterval = calendar.dateInterval(of: .month, for: monthDate) else { continue }
            
            let monthSpending = transactions
                .filter { !$0.isIncome && $0.date >= monthInterval.start && $0.date < monthInterval.end }
                .reduce(0) { $0 + $1.amount }
            
            let month = calendar.component(.month, from: monthDate)
            monthlyData.append(MonthlyData(month: month, amount: monthSpending))
        }
        
        return monthlyData.reversed() // Show oldest to newest
    }
    
    /// Get month name for display
    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        let date = Calendar.current.date(from: DateComponents(month: month)) ?? Date()
        return formatter.string(from: date)
    }

// MARK: - Helper Functions

/// Get simplified category name
private func getSimplifiedCategoryName(_ category: TransactionCategoryType) -> String {
    return category.rawValue
}


/// Robinhood-style goal card component
struct RobinhoodGoalCard: View {
    let goal: GoalFormItem
    let currencyCode: String
    
    private var progressPercentage: Double {
        guard goal.targetAmount > 0 else { return 0 }
        return min(goal.savedAmount / goal.targetAmount, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with icon and goal info - matching loan cards exactly
            HStack(spacing: 12) {
                Image(systemName: goal.iconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(RobinhoodColors.success)
                    .frame(width: 24, height: 24)
                
                // Goal Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(goal.name)
                            .font(RobinhoodTypography.headline)
                            .foregroundColor(RobinhoodColors.textPrimary)
                        
                        Spacer()
                        
                        Text(goal.savedAmount.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                            .font(RobinhoodTypography.headline)
                            .fontWeight(.bold)
                            .foregroundColor(RobinhoodColors.textPrimary)
                    }
                    
                    HStack {
                        Text("\(Int(progressPercentage * 100))% Complete")
                            .font(RobinhoodTypography.caption)
                            .foregroundColor(RobinhoodColors.textSecondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(RobinhoodColors.success)
                                .frame(width: 6, height: 6)
                            
                            Text("Active")
                                .font(RobinhoodTypography.caption2)
                                .foregroundColor(RobinhoodColors.success)
                        }
                    }
                }
            }
            
            // Progress Bar - matching loan cards exactly
            VStack(spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(RobinhoodTypography.caption2)
                        .foregroundColor(RobinhoodColors.textTertiary)
                    
                    Spacer()
                }
                
                ProgressView(value: progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: RobinhoodColors.primary))
                    .scaleEffect(x: 1, y: 0.5)
            }
            .padding(.top, 12)
            
            // Target info - matching loan cards style
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Target Amount")
                        .font(RobinhoodTypography.caption2)
                        .foregroundColor(RobinhoodColors.textTertiary)
                    
                    Text(goal.targetAmount.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                        .font(RobinhoodTypography.caption)
                        .fontWeight(.medium)
                        .foregroundColor(RobinhoodColors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Remaining")
                        .font(RobinhoodTypography.caption2)
                        .foregroundColor(RobinhoodColors.textTertiary)
                    
                    Text((goal.targetAmount - goal.savedAmount).formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                        .font(RobinhoodTypography.caption)
                        .fontWeight(.medium)
                        .foregroundColor(RobinhoodColors.textSecondary)
                }
            }
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RobinhoodColors.cardBackground)
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Goal: \(goal.name), \(Int(progressPercentage * 100))% complete, \(goal.savedAmount.formatted(.currency(code: currencyCode).precision(.fractionLength(0)))) of \(goal.targetAmount.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))")
    }
}

/// Robinhood-style transaction row component
struct RobinhoodTransactionRow: View {
    let transaction: TransactionItem
    let currencyCode: String
    
    private var categoryIcon: String {
        switch transaction.category {
        case .essentials: return "fork.knife"
        case .leisure: return "gamecontroller"
        case .savings: return "banknote"
        case .income: return "dollarsign.circle"
        case .bills: return "doc.text"
        case .other: return "ellipsis"
        }
    }
    
    private var categoryColor: Color {
        switch transaction.category {
        case .essentials: return RobinhoodColors.warning
        case .leisure: return RobinhoodColors.primary
        case .savings: return RobinhoodColors.success
        case .income: return RobinhoodColors.success
        case .bills: return RobinhoodColors.error
        case .other: return RobinhoodColors.textTertiary
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Circle()
                .fill(categoryColor.opacity(0.1))
                .frame(width: AppSizes.iconXXLarge, height: AppSizes.iconXXLarge)
                .overlay(
                    Image(systemName: categoryIcon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(categoryColor)
                )
            
            // Transaction details
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(RobinhoodTypography.callout)
                    .foregroundColor(RobinhoodColors.textPrimary)
                    .lineLimit(1)
                
                Text(transaction.subtitle)
                    .font(RobinhoodTypography.caption)
                    .foregroundColor(RobinhoodColors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Amount
            Text(transaction.amount.formatted(.currency(code: currencyCode).precision(.fractionLength(2))))
                .font(RobinhoodTypography.callout)
                .foregroundColor(transaction.isIncome ? RobinhoodColors.success : RobinhoodColors.error)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(transaction.title), \(transaction.subtitle), \(transaction.amount.formatted(.currency(code: currencyCode).precision(.fractionLength(2))))")
    }
}

// MARK: - ChartCard Placeholder
struct ChartCard<Content: View>: View {
    let title: String
    let subtitle: String?
    let chartHeight: CGFloat
    let content: Content
    let titleAlignment: HorizontalAlignment
    init(title: String, subtitle: String? = nil, chartHeight: CGFloat = 260, titleAlignment: HorizontalAlignment, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.chartHeight = chartHeight
        self.content = content()
        self.titleAlignment = titleAlignment
    }
    init(title: String, subtitle: String? = nil, chartHeight: CGFloat = 260, titleAlignment: HorizontalAlignment) where Content == Text {
        self.title = title
        self.subtitle = subtitle
        self.chartHeight = chartHeight
        self.content = Text("[Chart]")
            .foregroundColor(RobinhoodColors.secondary)
            .font(.subheadline)
        self.titleAlignment = titleAlignment
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: titleAlignment, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }
            }
            
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(AppColors.card)
                .frame(height: chartHeight)
                .overlay(
                    content
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppColors.card)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Income Required Chart with Table
struct IncomeRequiredChartWithTableView: View {
    let data: [IncomeRequiredChartView.IncomeData]
    let barColor: Color
    let currencyCode: String
    
    var body: some View {
        VStack(spacing: 8) {
            // Chart
            IncomeRequiredChartView(
                data: data,
                barColor: barColor,
                currencyCode: currencyCode
            )
            
            // Table
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Period")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(RobinhoodColors.secondary)
                        .frame(minWidth: 50, alignment: .leading)
                    Spacer()
                    Text("Income Required")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(RobinhoodColors.secondary)
                        .frame(minWidth: 70, alignment: .trailing)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(AppColors.background.opacity(0.5))
                
                // Data rows
                ForEach(data.indices, id: \.self) { idx in
                    let row = data[idx]
                    HStack {
                        Text(row.label)
                            .font(.caption.weight(.medium))
                            .foregroundColor(RobinhoodColors.primary)
                            .frame(minWidth: 50, alignment: .leading)
                        Spacer()
                        Text(row.value.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                            .font(.caption.weight(.semibold))
                            .foregroundColor(AppColors.secondary)
                            .frame(minWidth: 70, alignment: .trailing)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        idx % 2 == 0 
                            ? Color.clear 
                            : AppColors.background.opacity(0.3)
                    )
                    
                    if idx < data.count - 1 {
                        Divider()
                            .background(AppColors.chartAxis.opacity(0.3))
                            .padding(.leading, 12)
                    }
                }
            }
            .padding(.top, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppColors.card)
            )
        }
    }
}

// MARK: - Enhanced Income Required Chart
struct IncomeRequiredChartView: View {
    struct IncomeData: Identifiable {
        let id = UUID()
        let label: String
        let value: Double // income required
        let shortLabel: String // for better display
    }
    let data: [IncomeData]
    let barColor: Color
    let currencyCode: String
    
    @State private var showAverageInfo = false
    @State private var showHighestInfo = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Chart with professional flat styling
            Chart(data, id: \.id) { item in
                BarMark(
                    x: .value("Period", item.shortLabel),
                    y: .value("Income Required", item.value)
                )
                .foregroundStyle(barColor)
                .cornerRadius(4)
            }
            .chartYAxis {
                let maxValue = data.map { $0.value }.max() ?? 1
                let step = maxValue > 10000 ? 5000.0 : (maxValue > 1000 ? 1000.0 : (maxValue > 100 ? 100.0 : 10.0))
                let ticks = Array(stride(from: 0.0, through: maxValue, by: step))
                AxisMarks(position: .leading, values: ticks) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(AppColors.chartAxis)
                    AxisTick()
                        .foregroundStyle(AppColors.chartAxis)
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(doubleValue.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                        .foregroundStyle(AppColors.chartAxis.opacity(0.3))
                    AxisTick()
                        .foregroundStyle(AppColors.chartAxis)
                    AxisValueLabel {
                        if let stringValue = value.as(String.self) {
                            Text(stringValue)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(AppColors.textPrimary)
                        }
                    }
                }
            }
            .chartYScale(domain: 0...(data.map { $0.value }.max() ?? 1))
            .frame(height: 160)
            .padding(.horizontal, 4)
            
            // Summary statistics - Professional flat design
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Average Required")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                    Text(calculateAverage().formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(barColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Peak Required")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppColors.textSecondary)
                    Text(calculateHighest().formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(barColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(AppColors.cardSecondary)
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Income required chart showing \(data.count) periods")
        .alert("Average Income Required", isPresented: $showAverageInfo) {
            Button("Got it") { }
        } message: {
            Text("The average amount you need to earn across all time periods (hourly, weekly, monthly, yearly) to cover your expenses.")
        }
        .alert("Highest Income Required", isPresented: $showHighestInfo) {
            Button("Got it") { }
        } message: {
            Text("The highest income requirement among all time periods, typically your yearly income need. This helps you plan your annual income goals.")
        }
    }
    
    private func calculateAverage() -> Double {
        data.map { $0.value }.reduce(0, +) / Double(data.count)
    }
    
    private func calculateHighest() -> Double {
        data.map { $0.value }.max() ?? 0
    }
}


// MARK: - SwiftCharts Area Chart for Total Balance Over Time
// (Remove the entire TotalBalanceOverTimeChartView struct)

// Refactor TotalBalanceOverTimeSection:
struct TotalBalanceOverTimeSection: View {
    @State private var selectedPeriod: String = "1M"
    var body: some View {
        ChartCard(title: "", chartHeight: 320, titleAlignment: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Total Balance Over Time")
                    .font(.headline)
                    .foregroundColor(RobinhoodColors.primary)
                Picker("Period", selection: $selectedPeriod) {
                    Text("1W").tag("1W")
                    Text("1M").tag("1M")
                    Text("3M").tag("3M")
                    Text("YTD").tag("YTD")
                    Text("1Y").tag("1Y")
                }
                .pickerStyle(.segmented)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(RobinhoodColors.cardBackground)
                )
            }
        }
    }
}

// MARK: - Savings Goal Row Component
struct SavingsGoalRow: View {
    let goal: GoalFormItem
    let currencyCode: String
    
    private var progressPercentage: Double {
        guard goal.targetAmount > 0 else { return 0 }
        return min(goal.savedAmount / goal.targetAmount, 1.0)
    }
    
    private var remainingAmount: Double {
        max(goal.targetAmount - goal.savedAmount, 0)
    }
    
    private var daysRemaining: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: goal.targetDate)
        return max(components.day ?? 0, 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with icon, name, and progress
            HStack(spacing: 16) {
                // Icon with enhanced styling
                ZStack {
                    Circle()
                        .fill(goal.iconColor.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: goal.iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(goal.iconColor)
                }
                
                // Goal info
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(RobinhoodColors.primary)
                        .lineLimit(1)
                    
                    if let subtitle = goal.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(RobinhoodColors.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Progress percentage with enhanced styling
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(progressPercentage * 100))%")
                        .font(.title2.weight(.bold))
                        .foregroundColor(goal.iconColor)
                    Text("Complete")
                        .font(.caption.weight(.medium))
                        .foregroundColor(RobinhoodColors.secondary)
                }
            }
            
            // Progress bar with enhanced styling
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 6)
                        .fill(RobinhoodColors.textTertiary.opacity(0.2))
                        .frame(height: 10)
                    
                    // Progress bar
                    RoundedRectangle(cornerRadius: 6)
                        .fill(goal.iconColor)
                        .frame(width: geometry.size.width * progressPercentage, height: 10)
                        .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                }
            }
            .frame(height: 10)
            
            // Financial details with enhanced layout
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Saved")
                        .font(.caption.weight(.medium))
                        .foregroundColor(RobinhoodColors.secondary)
                    Text(goal.savedAmount.formatted(.currency(code: currencyCode)))
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(AppColors.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Target")
                        .font(.caption.weight(.medium))
                        .foregroundColor(RobinhoodColors.secondary)
                    Text(goal.targetAmount.formatted(.currency(code: currencyCode)))
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(RobinhoodColors.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Remaining")
                        .font(.caption.weight(.medium))
                        .foregroundColor(RobinhoodColors.secondary)
                    Text(remainingAmount.formatted(.currency(code: currencyCode)))
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(AppColors.primary)
                }
                
                Spacer()
                
                // Days remaining with enhanced styling
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(daysRemaining < 30 ? RobinhoodColors.error : RobinhoodColors.secondary)
                        Text("\(daysRemaining)")
                            .font(.title3.weight(.bold))
                            .foregroundColor(daysRemaining < 30 ? RobinhoodColors.error : RobinhoodColors.primary)
                    }
                    Text("days left")
                        .font(.caption.weight(.medium))
                        .foregroundColor(RobinhoodColors.secondary)
                }
            }
            
            // Notes section if available
            if let notes = goal.notes, !notes.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(RobinhoodColors.secondary)
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(RobinhoodColors.secondary)
                        .lineLimit(2)
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
        )
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Compact Savings Goal Card for Overview
struct CompactSavingsGoalCard: View {
    let goal: GoalFormItem
    let currencyCode: String
    
    private var progressPercentage: Double {
        guard goal.targetAmount > 0 else { return 0 }
        return min(goal.savedAmount / goal.targetAmount, 1.0)
    }
    
    var body: some View {
        AppCard(style: .default, padding: .medium) {
            VStack(alignment: .leading, spacing: AppPaddings.lg) {
                // Header with icon and name
                HStack(spacing: AppPaddings.md) {
                    ZStack {
                        Circle()
                            .fill(goal.iconColor.opacity(0.12))
                            .frame(width: AppSizes.iconXLarge, height: AppSizes.iconXLarge)
                        Image(systemName: goal.iconName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(goal.iconColor)
                    }
                    
                    VStack(alignment: .leading, spacing: AppPaddings.xs) {
                        Text(goal.name)
                            .font(.h6)
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                        
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.labelSmall)
                            .foregroundColor(goal.iconColor)
                    }
                    
                    Spacer()
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(AppColors.cardSecondary)
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .fill(goal.iconColor)
                            .frame(width: geometry.size.width * progressPercentage, height: 8)
                            .animation(AppAnimations.easeInOut, value: progressPercentage)
                    }
                }
                .frame(height: 8)
                
                // Amount info
                VStack(alignment: .leading, spacing: AppPaddings.xs) {
                    Text(goal.savedAmount.formatted(.currency(code: currencyCode)))
                        .font(.h6)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("of \(goal.targetAmount.formatted(.currency(code: currencyCode)))")
                        .font(.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Spending Breakdown Chart View
struct SpendingBreakdownChartView: View {
    let transactions: [TransactionItem]
    let currencyCode: String
    
    private var spendingData: [SpendingCategory] {
        let expenseTransactions = transactions.filter { !$0.isIncome }
        let categoryGroups = Dictionary(grouping: expenseTransactions) { $0.category }
        
        let allCategories: [SpendingCategory] = categoryGroups
            .filter { !$0.value.isEmpty }
            .map { (category, transactions) in
                let totalAmount = transactions.reduce(0) { $0 + $1.amount }
                return SpendingCategory(
                    name: getSimplifiedCategoryName(category),
                    amount: totalAmount,
                    color: getCategoryColor(for: category.rawValue),
                    transactionCount: transactions.count
                )
            }
            .filter { $0.amount > 0.01 }
        
        let totalAmount = allCategories.reduce(0) { $0 + $1.amount }
        let minThreshold = totalAmount * 0.02 // 2% of total spending
        
        var mainCategories = allCategories.filter { $0.amount >= minThreshold }
        let smallCategories = allCategories.filter { $0.amount < minThreshold }
        
        // Combine small categories into "Other" if there are any
        if !smallCategories.isEmpty {
            let otherAmount = smallCategories.reduce(0) { $0 + $1.amount }
            let otherCount = smallCategories.reduce(0) { $0 + $1.transactionCount }
            mainCategories.append(SpendingCategory(
                name: "Other",
                amount: otherAmount,
                color: RobinhoodColors.textTertiary,
                transactionCount: otherCount
            ))
        }
        
        return mainCategories.sorted { $0.amount > $1.amount }
    }
    
    private var totalSpending: Double {
        spendingData.reduce(0) { $0 + $1.amount }
    }
    
    private func getSimplifiedCategoryName(_ category: TransactionCategoryType) -> String {
        switch category {
        case .essentials: return "Food"
        case .leisure: return "Leisure"
        case .savings: return "Savings"
        case .income: return "Income"
        case .bills: return "Bills"
        case .other: return "Other"
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if spendingData.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 48))
                        .foregroundColor(RobinhoodColors.secondary.opacity(0.6))
                    Text("No spending data yet")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(RobinhoodColors.secondary)
                    Text("Add some expense transactions to see your spending breakdown")
                        .font(.subheadline)
                        .foregroundColor(RobinhoodColors.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
            } else {
                
                // iOS Standard Donut Chart
                ZStack {
                    // Background circle - thicker towards center
                    GeometryReader { geometry in
                        let outerRadius: CGFloat = 120
                        let innerRadius: CGFloat = 80
                        
                        Circle()
                            .fill(RobinhoodColors.textTertiary.opacity(0.15))
                            .frame(width: outerRadius * 2, height: outerRadius * 2)
                            .overlay(
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: innerRadius * 2, height: innerRadius * 2)
                                    .blendMode(.destinationOut)
                            )
                    }
                    .frame(width: 240, height: 240)
                    
                    // Data segments with iOS-optimized colors and animations
                    ForEach(Array(spendingData.enumerated()), id: \.offset) { index, category in
                        let startAngle = calculateStartAngle(for: index)
                        let endAngle = calculateEndAngle(for: index)
                        let color = getCategoryColor(for: category.name)
                        
                        // Ensure we have a valid segment to draw with minimum size for visibility
                        let segmentSize = endAngle - startAngle
                        let minSegmentSize = 0.01 // Minimum 1% of circle for visibility
                        
                        if segmentSize >= minSegmentSize && category.amount > 0 {
                            // Create a thicker donut by using a filled arc instead of stroke
                            GeometryReader { geometry in
                                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                let outerRadius: CGFloat = 120
                                let innerRadius: CGFloat = 80 // Thicker towards center
                                
                                Path { path in
                                    path.addArc(
                                        center: center,
                                        radius: outerRadius,
                                        startAngle: .radians(startAngle * 2 * .pi),
                                        endAngle: .radians(endAngle * 2 * .pi),
                                        clockwise: false
                                    )
                                    path.addArc(
                                        center: center,
                                        radius: innerRadius,
                                        startAngle: .radians(endAngle * 2 * .pi),
                                        endAngle: .radians(startAngle * 2 * .pi),
                                        clockwise: true
                                    )
                                    path.closeSubpath()
                                }
                                .fill(color)
                                .rotationEffect(.degrees(-90))
                            }
                            .frame(width: 240, height: 240)
                            .animation(.easeInOut(duration: 0.6).delay(Double(index) * 0.05), value: spendingData)
                        }
                    }
                    
                    // Center content with total spending
                    VStack(spacing: 4) {
                        Text(totalSpending.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(RobinhoodColors.primary)
                            .dynamicTypeSize(.large)
                        
                        Text("Monthly Spending")
                            .font(.caption.weight(.medium))
                            .foregroundColor(RobinhoodColors.secondary)
                            .dynamicTypeSize(.medium)
                    }
                }
                .frame(height: 250)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Spending breakdown chart with \(spendingData.count) categories")
                
                // Category Table
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Category")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(RobinhoodColors.secondary)
                            .frame(minWidth: 50, alignment: .leading)
                        Spacer()
                        Text("Amount")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(RobinhoodColors.secondary)
                            .frame(minWidth: 70, alignment: .trailing)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(AppColors.background.opacity(0.5))
                    
                    // Data rows
                    ForEach(Array(spendingData.enumerated()), id: \.offset) { index, category in
                        HStack {
                            Text(category.name)
                                .font(.caption.weight(.medium))
                                .foregroundColor(RobinhoodColors.primary)
                                .frame(minWidth: 50, alignment: .leading)
                            Spacer()
                            Text(category.amount.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                                .font(.caption.weight(.semibold))
                                .foregroundColor(RobinhoodColors.error)
                                .frame(minWidth: 70, alignment: .trailing)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            index % 2 == 0 
                                ? Color.clear 
                                : AppColors.background.opacity(0.3)
                        )
                        
                        if index < spendingData.count - 1 {
                            Divider()
                                .background(AppColors.chartAxis.opacity(0.3))
                                .padding(.leading, 12)
                        }
                    }
                }
                .padding(.top, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppColors.card)
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Spending breakdown chart showing \(spendingData.count) categories")
    }
    
    private func getCategoryColor(for categoryName: String) -> Color {
        switch categoryName {
        case "Food": return RobinhoodColors.warning
        case "Leisure": return RobinhoodColors.secondary
        case "Savings": return RobinhoodColors.primary
        case "Income": return RobinhoodColors.primary
        case "Bills": return RobinhoodColors.error
        case "Other": return RobinhoodColors.textTertiary
        default: return RobinhoodColors.textTertiary
        }
    }
    
    private func getCategorySymbol(for categoryName: String) -> String {
        switch categoryName {
        case "Food": return "fork.knife"
        case "Leisure": return "gamecontroller"
        case "Savings": return "banknote"
        case "Income": return "dollarsign.circle"
        case "Bills": return "doc.text"
        case "Other": return "ellipsis"
        default: return "questionmark.circle"
        }
    }
    
    private func calculateStartAngle(for index: Int) -> Double {
        let previousTotal = spendingData.prefix(index).reduce(0) { $0 + ($1.amount / totalSpending) }
        return previousTotal
    }
    
    private func calculateEndAngle(for index: Int) -> Double {
        let currentTotal = spendingData.prefix(index + 1).reduce(0) { $0 + ($1.amount / totalSpending) }
        return currentTotal
    }
}


// MARK: - PreSelected Add Transaction View
struct PreSelectedAddTransactionView: View {
    let availableGoals: [GoalFormItem]
    let preSelectedType: IncomeOrExpense
    let onSave: (TransactionItem) -> Void
    
    var body: some View {
        AddTransactionViewWithPreselection(
            availableGoals: availableGoals,
            preSelectedType: preSelectedType
        ) { transaction in
            onSave(transaction)
        }
    }
}

// MARK: - Modern Components

/// Modern stat card component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                )
        )
    }
}

/// Simple goal card component for overview
struct ModernGoalCard: View {
    let goal: GoalFormItem
    let currencyCode: String
    
    private var progressPercentage: Double {
        guard goal.targetAmount > 0 else { return 0 }
        return min(goal.savedAmount / goal.targetAmount, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon and progress
            HStack {
                ZStack {
                    Circle()
                        .fill(goal.iconColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: goal.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(goal.iconColor)
                }
                
                Spacer()
                
                Text("\(Int(progressPercentage * 100))%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(goal.iconColor)
            }
            
            // Goal name
            Text(goal.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(2)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.border)
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(goal.iconColor)
                        .frame(width: geometry.size.width * progressPercentage, height: 6)
                        .animation(.easeInOut(duration: 0.3), value: progressPercentage)
                }
            }
            .frame(height: 6)
            
            // Amount info
            VStack(alignment: .leading, spacing: 2) {
                Text(goal.savedAmount.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("of \(goal.targetAmount.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                )
        )
    }
}

/// Modern transaction row component
struct ModernTransactionRow: View {
    let transaction: TransactionItem
    let currencyCode: String
    
    private var categoryIcon: String {
        switch transaction.category {
        case .essentials: return "fork.knife"
        case .leisure: return "gamecontroller"
        case .savings: return "banknote"
        case .income: return "dollarsign.circle"
        case .bills: return "doc.text"
        case .other: return "ellipsis"
        }
    }
    
    private var categoryColor: Color {
        switch transaction.category {
        case .essentials: return AppColors.categoryFood
        case .leisure: return AppColors.categoryLeisure
        case .savings: return AppColors.savings
        case .income: return AppColors.success
        case .bills: return AppColors.categoryBills
        case .other: return AppColors.textTertiary
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Circle()
                .fill(categoryColor.opacity(0.1))
                .frame(width: AppSizes.iconXXLarge, height: AppSizes.iconXXLarge)
                .overlay(
                    Image(systemName: categoryIcon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(categoryColor)
                )
            
            // Transaction details
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                
                Text(transaction.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Amount
            Text(transaction.amount.formatted(.currency(code: currencyCode).precision(.fractionLength(2))))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(transaction.isIncome ? AppColors.success : AppColors.error)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Modern Chart Components

/// Enhanced income chart with clear visual design
struct ModernIncomeChart: View {
    let data: [IncomeRequiredChartView.IncomeData]
    let currencyCode: String
    
    private var maxValue: Double {
        data.map { $0.value }.max() ?? 1
    }
    
    private var minValue: Double {
        data.map { $0.value }.min() ?? 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Chart with clear labels and values
            VStack(spacing: 8) {
                // Y-axis labels
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Income Required")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("(per time period)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text(maxValue.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                // Bar chart with clear visual hierarchy
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(data, id: \.id) { item in
                        VStack(spacing: 6) {
                            // Value label on top
                            Text(item.value.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                            
                            // Bar with gradient and clear height
                            VStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [AppColors.primary.opacity(0.8), AppColors.primary]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(
                                        width: 40,
                                        height: max(20, CGFloat((item.value - minValue) / (maxValue - minValue) * 80))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                    )
                            }
                            
                            // Time period label
                            Text(item.shortLabel)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 50)
                    }
                }
                .frame(height: 120)
                .padding(.horizontal, 8)
            }
            
            // Clear summary with context
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Monthly Target")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                        Text(data.first { $0.label == "Month" }?.value.formatted(.currency(code: currencyCode).precision(.fractionLength(0))) ?? "0")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 2) {
                        Text("Yearly Target")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                        Text(data.first { $0.label == "Year" }?.value.formatted(.currency(code: currencyCode).precision(.fractionLength(0))) ?? "0")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.primary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Hourly Rate")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                        Text(data.first { $0.label == "Hour" }?.value.formatted(.currency(code: currencyCode).precision(.fractionLength(0))) ?? "0")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}

/// Enhanced spending chart with clear visual design
struct ModernSpendingChart: View {
    let transactions: [TransactionItem]
    let currencyCode: String
    
    private var spendingData: [SpendingCategory] {
        let expenseTransactions = transactions.filter { !$0.isIncome }
        let categoryGroups = Dictionary(grouping: expenseTransactions) { $0.category }
        
        let allCategories: [SpendingCategory] = categoryGroups
            .filter { !$0.value.isEmpty }
            .map { (category, transactions) in
                let totalAmount = transactions.reduce(0) { $0 + $1.amount }
                return SpendingCategory(
                    name: getSimplifiedCategoryName(category),
                    amount: totalAmount,
                    color: getCategoryColor(for: category.rawValue),
                    transactionCount: transactions.count
                )
            }
            .filter { $0.amount > 0.01 }
        
        return allCategories.sorted { $0.amount > $1.amount }.prefix(5).map { $0 }
    }
    
    private var totalSpending: Double {
        spendingData.reduce(0) { $0 + $1.amount }
    }
    
    private func getSimplifiedCategoryName(_ category: TransactionCategoryType) -> String {
        switch category {
        case .essentials: return "Food & Essentials"
        case .leisure: return "Entertainment"
        case .savings: return "Savings"
        case .income: return "Income"
        case .bills: return "Bills & Utilities"
        case .other: return "Other"
        }
    }
    
    private func getCategoryColor(for categoryName: String) -> Color {
        switch categoryName {
        case "Food & Essentials": return AppColors.categoryFood
        case "Entertainment": return AppColors.categoryLeisure
        case "Savings": return AppColors.savings
        case "Income": return AppColors.success
        case "Bills & Utilities": return AppColors.categoryBills
        case "Other": return AppColors.textTertiary
        default: return AppColors.textTertiary
        }
    }
    
    private func getCategoryIcon(for categoryName: String) -> String {
        switch categoryName {
        case "Food & Essentials": return "fork.knife"
        case "Entertainment": return "gamecontroller"
        case "Savings": return "banknote"
        case "Income": return "dollarsign.circle"
        case "Bills & Utilities": return "doc.text"
        case "Other": return "ellipsis"
        default: return "questionmark.circle"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if spendingData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.textTertiary)
                    
                    VStack(spacing: 4) {
                        Text("No spending data")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppColors.textPrimary)
                        Text("Add some expenses to see your spending breakdown")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(height: 100)
            } else {
                // Chart header
                HStack {
                    Text("Spending by Category")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text("Total: \(totalSpending.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.error)
                }
                
                // Enhanced category bars with clear visual hierarchy
                VStack(spacing: 12) {
                    ForEach(Array(spendingData.enumerated()), id: \.offset) { index, category in
                        VStack(spacing: 8) {
                            // Category header with icon and percentage
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: getCategoryIcon(for: category.name))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(getCategoryColor(for: category.name))
                                        .frame(width: 16)
                                    
                                    Text(category.name)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(category.amount.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Text("\(Int((category.amount / totalSpending) * 100))%")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundColor(getCategoryColor(for: category.name))
                                }
                            }
                            
                            // Progress bar with clear visual design
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(AppColors.border)
                                        .frame(height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [getCategoryColor(for: category.name).opacity(0.7), getCategoryColor(for: category.name)]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(
                                            width: geometry.size.width * (category.amount / totalSpending),
                                            height: 8
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                        )
                                }
                            }
                            .frame(height: 8)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
    }
}

// MARK: - Helper Functions

func calculateIncomeExpenseTableData(transactions: [TransactionItem]) -> [(String, Double)] {
    let calendar = Calendar.current
    let now = Date()
    
    // Get current month data
    let currentMonthTransactions = transactions.filter { transaction in
        calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
    }
    
    let income = currentMonthTransactions
        .filter { $0.isIncome }
        .reduce(0) { $0 + $1.amount }
    
    let expenses = currentMonthTransactions
        .filter { !$0.isIncome }
        .reduce(0) { $0 + $1.amount }
    
    return [
        ("Income", income),
        ("Expenses", expenses)
    ]
}

func calculateSpendingTrend(transactions: [TransactionItem]) -> TrendDirection {
    let calendar = Calendar.current
    let now = Date()
    
    // Get current and previous month data
    let currentMonth = transactions.filter { transaction in
        calendar.isDate(transaction.date, equalTo: now, toGranularity: .month)
    }
    
    let previousMonth = transactions.filter { transaction in
        let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: now)!
        return calendar.isDate(transaction.date, equalTo: previousMonthDate, toGranularity: .month)
    }
    
    let currentSpending = currentMonth
        .filter { !$0.isIncome }
        .reduce(0) { $0 + $1.amount }
    
    let previousSpending = previousMonth
        .filter { !$0.isIncome }
        .reduce(0) { $0 + $1.amount }
    
    if currentSpending > previousSpending {
        return .up
    } else if currentSpending < previousSpending {
        return .down
    } else {
        return .neutral
    }
}

// MARK: - Balance Chart Components

/// Data point for balance trend chart
struct BalanceDataPoint {
    let date: Date
    let balance: Double
    let income: Double
    let expenses: Double
}

/// Full-width Robinhood-style line chart (no card styling)
struct RobinhoodLineChart: View {
    let data: [BalanceDataPoint]
    let currencyCode: String
    @Binding var selectedDataPoint: BalanceDataPoint?
    
    // Core interaction states
    @State private var dragLocation: CGPoint = .zero
    @State private var isDragging: Bool = false
    @State private var lastSelectedIndex: Int = -1
    
    // Smooth interpolation states
    @State private var interpolatedPoint: CGPoint = .zero
    @State private var interpolatedValue: Double = 0
    @State private var interpolatedDate: Date = Date()
    
    // Performance and UX states
    @State private var dragVelocity: CGPoint = .zero
    @State private var lastDragTime: Date = Date()
    @State private var animationPhase: Double = 0
    
    // Line boundary detection
    private let lineHitTestTolerance: CGFloat = 20.0 // Tolerance for line detection
    @State private var showBoundaryFeedback: Bool = false
    
    private var maxBalance: Double {
        data.map { $0.balance }.max() ?? 0
    }
    
    private var minBalance: Double {
        data.map { $0.balance }.min() ?? 0
    }
    
    private var balanceRange: Double {
        maxBalance - minBalance
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Clean dark background (no card styling)
                Rectangle()
                    .fill(RobinhoodColors.background)
                
                // Minimal horizontal reference line (like Robinhood)
                Rectangle()
                    .fill(RobinhoodColors.border.opacity(0.2))
                    .frame(height: 0.5)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Gradient background that fades off near the bottom (Robinhood style)
                Path { path in
                    guard !data.isEmpty else { return }
                    
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    // Create the same path as the line but for the gradient fill
                    for (index, point) in data.enumerated() {
                        let x: CGFloat
                        if data.count == 1 {
                            x = width / 2
                        } else {
                            let stepX = width / CGFloat(data.count - 1)
                            x = CGFloat(index) * stepX
                        }
                        
                        let normalizedBalance = balanceRange > 0 ? 
                            (point.balance - minBalance) / balanceRange : 0.5
                        let y = height - (CGFloat(normalizedBalance) * height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    
                    // Close the path to create a fill area
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            RobinhoodColors.primary.opacity(0.3),
                            RobinhoodColors.primary.opacity(0.1),
                            RobinhoodColors.primary.opacity(0.05),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Robinhood-style line chart with enhanced visual effects
                Path { path in
                    guard !data.isEmpty else { return }
                    
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    for (index, point) in data.enumerated() {
                        let x: CGFloat
                        if data.count == 1 {
                            x = width / 2
                        } else {
                            let stepX = width / CGFloat(data.count - 1)
                            x = CGFloat(index) * stepX
                        }
                        
                        let normalizedBalance = balanceRange > 0 ? 
                            (point.balance - minBalance) / balanceRange : 0.5
                        let y = height - (CGFloat(normalizedBalance) * height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            RobinhoodColors.primary,
                            RobinhoodColors.primary.opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
                .shadow(color: RobinhoodColors.primary.opacity(0.6), radius: 8, x: 0, y: 2)
                .shadow(color: RobinhoodColors.primary.opacity(0.3), radius: 4, x: 0, y: 1)
                
                // Circle at the end of the line (Robinhood style)
                if !data.isEmpty {
                    let lastPoint = data.last!
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    let lastX = data.count == 1 ? 
                        width / 2 : 
                        CGFloat(data.count - 1) * (width / CGFloat(data.count - 1))
                    
                    let normalizedBalance = balanceRange > 0 ? 
                        (lastPoint.balance - minBalance) / balanceRange : 0.5
                    let lastY = height - (CGFloat(normalizedBalance) * height)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white,
                                    RobinhoodColors.primary
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 6
                            )
                        )
                        .frame(width: 12, height: 12)
                        .position(x: lastX, y: lastY)
                        .shadow(color: RobinhoodColors.primary.opacity(0.8), radius: 6, x: 0, y: 0)
                        .shadow(color: RobinhoodColors.primary.opacity(0.4), radius: 3, x: 0, y: 0)
                }
                
                // Interactive overlay for smooth finger tracking with boundary detection
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .background(
                        // Subtle visual indicator for interactive area (only visible during development/debugging)
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        RobinhoodColors.primary.opacity(0.02),
                                        RobinhoodColors.primary.opacity(0.01)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(0) // Set to 0.1 for debugging, 0 for production
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                // First check if the touch is within the line bounds
                                guard isWithinLineBounds(at: value.location, in: geometry) else { 
                                    // Show feedback for out-of-bounds interaction
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showBoundaryFeedback = true
                                    }
                                    
                                    // Hide feedback after a short delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showBoundaryFeedback = false
                                        }
                                    }
                                    return 
                                }
                                
                                // For multi-point lines, also check if touch is near the actual line
                                if data.count > 1 && !isNearChartLine(at: value.location, in: geometry) {
                                    // Show feedback for interaction away from line
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showBoundaryFeedback = true
                                    }
                                    
                                    // Hide feedback after a short delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showBoundaryFeedback = false
                                        }
                                    }
                                    return
                                }
                                
                                // Hide any existing boundary feedback since we're now in bounds
                                if showBoundaryFeedback {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        showBoundaryFeedback = false
                                    }
                                }
                                
                                let currentTime = Date()
                                let timeDelta = currentTime.timeIntervalSince(lastDragTime)
                                
                                // Calculate velocity for smooth interactions
                                if timeDelta > 0 {
                                    dragVelocity = CGPoint(
                                        x: (value.location.x - dragLocation.x) / CGFloat(timeDelta),
                                        y: (value.location.y - dragLocation.y) / CGFloat(timeDelta)
                                    )
                                }
                                
                                // Clamp the location to line bounds for consistent behavior
                                let clampedLocation = clampToLineBounds(value.location, in: geometry)
                                
                                // Update state immediately for responsiveness
                                isDragging = true
                                dragLocation = clampedLocation
                                lastDragTime = currentTime
                                
                                // Start pulsing animation when dragging begins
                                if animationPhase == 0 {
                                    startAnimationPhase()
                                }
                                
                                // Calculate interpolated position and value for smooth tracking
                                let interpolatedData = getInterpolatedDataPoint(at: clampedLocation, in: geometry)
                                
                                // Update interpolated values with smooth transitions
                                withAnimation(.easeOut(duration: 0.05)) {
                                    interpolatedPoint = clampedLocation
                                    interpolatedValue = interpolatedData.value
                                    interpolatedDate = interpolatedData.date
                                }
                                
                                // Find closest actual data point for selection
                                if let closestPoint = getClosestDataPoint(at: clampedLocation, in: geometry) {
                                    // Enhanced haptic feedback with velocity consideration
                                    if let currentIndex = data.firstIndex(where: { $0.date == closestPoint.date }),
                                       currentIndex != lastSelectedIndex {
                                        
                                        // Vary haptic intensity based on velocity
                                        let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle = 
                                            abs(dragVelocity.x) > 100 ? .medium : .light
                                        
                                        let impactFeedback = UIImpactFeedbackGenerator(style: hapticStyle)
                                        impactFeedback.impactOccurred()
                                        lastSelectedIndex = currentIndex
                                    }
                                    
                                    // Update selected point with smooth transition
                                    selectedDataPoint = closestPoint
                                    
                                    // Note: Tooltip positioning is now handled by the enhanced tracking indicator
                                }
                            }
                            .onEnded { _ in
                                // Smooth end animation with velocity consideration
                                let endAnimation = abs(dragVelocity.x) > 50 ? 
                                    Animation.easeOut(duration: 0.3) : 
                                    Animation.easeInOut(duration: 0.2)
                                
                                withAnimation(endAnimation) {
                                    isDragging = false
                                    dragVelocity = .zero
                                }
                                
                                // Stop pulsing animation when dragging ends
                                stopAnimationPhase()
                                
                                // Delayed cleanup for better UX
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    if !isDragging && selectedDataPoint != nil {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            selectedDataPoint = nil
                                        }
                                    }
                                }
                            }
                    )
                    .onTapGesture { location in
                        // Check if tap is within line bounds and near the line
                        guard isWithinLineBounds(at: location, in: geometry) else { 
                            // Show feedback for out-of-bounds tap
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showBoundaryFeedback = true
                            }
                            
                            // Hide feedback after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showBoundaryFeedback = false
                                }
                            }
                            return 
                        }
                        
                        // For multi-point lines, check if tap is near the actual line
                        if data.count > 1 && !isNearChartLine(at: location, in: geometry) {
                            // Show feedback for tap away from line
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showBoundaryFeedback = true
                            }
                            
                            // Hide feedback after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showBoundaryFeedback = false
                                }
                            }
                            return
                        }
                        
                        // Clamp location to line bounds
                        let clampedLocation = clampToLineBounds(location, in: geometry)
                        
                        // Handle tap with immediate response
                        if let closestPoint = getClosestDataPoint(at: clampedLocation, in: geometry) {
                            selectedDataPoint = closestPoint
                            
                            // Provide haptic feedback for successful tap
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }
                    }
                
                // Enhanced smooth finger tracking indicator
                if isDragging {
                    let interpolatedY = getInterpolatedYPosition(at: interpolatedPoint, in: geometry)
                    let velocityFactor = min(abs(dragVelocity.x) / 200, 1.0)
                    
                    // Dynamic vertical crosshair with velocity-based opacity
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    RobinhoodColors.primary.opacity(0.7 + velocityFactor * 0.3),
                                    RobinhoodColors.primary.opacity(0.4 + velocityFactor * 0.2),
                                    RobinhoodColors.primary.opacity(0.1 + velocityFactor * 0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 1.5 + velocityFactor * 0.5)
                        .frame(height: geometry.size.height)
                        .position(x: interpolatedPoint.x, y: geometry.size.height / 2)
                        .shadow(color: RobinhoodColors.primary.opacity(0.5 + velocityFactor * 0.3), radius: 4 + velocityFactor * 2, x: 0, y: 0)
                        .animation(.easeOut(duration: 0.08), value: interpolatedPoint.x)
                    
                    // Enhanced horizontal crosshair with velocity effects
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    RobinhoodColors.primary.opacity(0.6 + velocityFactor * 0.4),
                                    RobinhoodColors.primary.opacity(0.2 + velocityFactor * 0.2)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 35 + velocityFactor * 10, height: 1.5 + velocityFactor * 0.5)
                        .position(x: interpolatedPoint.x, y: interpolatedY)
                        .shadow(color: RobinhoodColors.primary.opacity(0.4 + velocityFactor * 0.3), radius: 3 + velocityFactor, x: 0, y: 0)
                        .animation(.easeOut(duration: 0.08), value: interpolatedPoint.x)
                    
                    // Enhanced tracking dot with velocity-based scaling
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white,
                                    RobinhoodColors.primary,
                                    RobinhoodColors.primary.opacity(0.8)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 8 + velocityFactor * 2
                            )
                        )
                        .frame(width: 16 + velocityFactor * 4, height: 16 + velocityFactor * 4)
                        .position(x: interpolatedPoint.x, y: interpolatedY)
                        .shadow(color: RobinhoodColors.primary.opacity(0.9), radius: 12 + velocityFactor * 4, x: 0, y: 0)
                        .shadow(color: RobinhoodColors.primary.opacity(0.5), radius: 6 + velocityFactor * 2, x: 0, y: 0)
                        .shadow(color: Color.white.opacity(0.9), radius: 2 + velocityFactor, x: 0, y: 0)
                        .scaleEffect(1.2 + velocityFactor * 0.3)
                        .animation(.easeOut(duration: 0.08), value: interpolatedPoint.x)
                    
                    // Dynamic outer ring with velocity effects
                    Circle()
                        .stroke(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    RobinhoodColors.primary.opacity(0.7 + velocityFactor * 0.3),
                                    RobinhoodColors.primary.opacity(0.4 + velocityFactor * 0.2),
                                    RobinhoodColors.primary.opacity(0.1 + velocityFactor * 0.1),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 15 + velocityFactor * 5
                            ),
                            lineWidth: 2.5 + velocityFactor * 1
                        )
                        .frame(width: 30 + velocityFactor * 8, height: 30 + velocityFactor * 8)
                        .position(x: interpolatedPoint.x, y: interpolatedY)
                        .scaleEffect(1.1 + velocityFactor * 0.2)
                        .animation(.easeOut(duration: 0.08), value: interpolatedPoint.x)
                    
                    // Pulsing effect for active tracking
                    Circle()
                        .stroke(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    RobinhoodColors.primary.opacity(0.3),
                                    RobinhoodColors.primary.opacity(0.1),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 20 + velocityFactor * 10
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 40 + velocityFactor * 15, height: 40 + velocityFactor * 15)
                        .position(x: interpolatedPoint.x, y: interpolatedY)
                        .scaleEffect(1.0 + sin(animationPhase) * 0.1)
                        .opacity(0.8 + sin(animationPhase) * 0.2)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animationPhase)
                    
                    // Enhanced real-time tooltip with velocity-based styling
                    VStack(spacing: 6) {
                        // Main value with enhanced formatting
                        Text(interpolatedValue.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                            .font(.system(size: 15 + velocityFactor * 2, weight: .bold, design: .rounded))
                            .foregroundColor(RobinhoodColors.textPrimary)
                            .animation(.easeOut(duration: 0.1), value: interpolatedValue)
                        
                        // Date with better formatting
                        Text(interpolatedDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                            .font(.system(size: 12 + velocityFactor, weight: .medium))
                            .foregroundColor(RobinhoodColors.textSecondary)
                        
                        // Optional change indicator
                        if let selectedPoint = selectedDataPoint {
                            let change = interpolatedValue - selectedPoint.balance
                            if abs(change) > 0.01 {
                                HStack(spacing: 4) {
                                    Image(systemName: change > 0 ? "arrow.up.right" : "arrow.down.right")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(change > 0 ? RobinhoodColors.primary : RobinhoodColors.error)
                                    
                                    Text(change.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(change > 0 ? RobinhoodColors.primary : RobinhoodColors.error)
                                }
                                .animation(.easeOut(duration: 0.1), value: change)
                            }
                        }
                    }
                    .padding(.horizontal, 14 + velocityFactor * 2)
                    .padding(.vertical, 10 + velocityFactor)
                    .background(
                        RoundedRectangle(cornerRadius: 12 + velocityFactor)
                            .fill(RobinhoodColors.cardBackground)
                            .shadow(color: Color.black.opacity(0.5 + velocityFactor * 0.2), radius: 10 + velocityFactor * 3, x: 0, y: 5)
                            .shadow(color: RobinhoodColors.primary.opacity(0.15 + velocityFactor * 0.1), radius: 5 + velocityFactor * 2, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12 + velocityFactor)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        RobinhoodColors.primary.opacity(0.4 + velocityFactor * 0.2),
                                        RobinhoodColors.primary.opacity(0.1 + velocityFactor * 0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5 + velocityFactor * 0.5
                            )
                    )
                    .position(
                        x: calculateSmartTooltipX(x: interpolatedPoint.x, geometry: geometry),
                        y: calculateSmartTooltipY(y: interpolatedY, geometry: geometry) - 30
                    )
                    .animation(.easeOut(duration: 0.08), value: interpolatedPoint.x)
                }
                
                // Boundary feedback indicator
                if showBoundaryFeedback {
                    VStack {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(RobinhoodColors.warning)
                            Text("Tap on the chart line to interact")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(RobinhoodColors.textSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(RobinhoodColors.cardBackground)
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(RobinhoodColors.warning.opacity(0.3), lineWidth: 1)
                        )
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .animation(.easeInOut(duration: 0.3), value: showBoundaryFeedback)
                }
                
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Interactive balance trend chart showing daily balance changes")
        .accessibilityHint("Drag to explore data points and view detailed information")
        .accessibilityAddTraits(.allowsDirectInteraction)
        .onAppear {
            // Initialize animation phase
            animationPhase = 0
        }
        .onDisappear {
            // Clean up animations
            stopAnimationPhase()
        }
    }
    
    private func getInterpolatedDataPoint(at location: CGPoint, in geometry: GeometryProxy) -> (value: Double, date: Date) {
        guard !data.isEmpty else { return (value: 0, date: Date()) }
        
        let width = geometry.size.width
        let height = geometry.size.height
        
        // Clamp location to valid bounds
        let clampedX = max(0, min(location.x, width))
        let clampedY = max(0, min(location.y, height))
        let clampedLocation = CGPoint(x: clampedX, y: clampedY)
        
        // Handle single data point case
        if data.count == 1 {
            return (value: data[0].balance, date: data[0].date)
        }
        
        // Calculate step size for X coordinates
        let stepX = width / CGFloat(data.count - 1)
        
        // Find the exact position between data points
        let exactIndex = clampedLocation.x / stepX
        let lowerIndex = max(0, min(Int(exactIndex), data.count - 1))
        let upperIndex = max(0, min(lowerIndex + 1, data.count - 1))
        
        // Calculate interpolation factor (0.0 to 1.0)
        let interpolationFactor = max(0.0, min(1.0, exactIndex - CGFloat(lowerIndex)))
        
        // Interpolate between the two data points
        let lowerPoint = data[lowerIndex]
        let upperPoint = data[upperIndex]
        
        // Linear interpolation for balance value
        let interpolatedBalance = lowerPoint.balance + (upperPoint.balance - lowerPoint.balance) * Double(interpolationFactor)
        
        // Interpolate date (assuming equal time intervals)
        let timeInterval = upperPoint.date.timeIntervalSince(lowerPoint.date)
        let interpolatedDate = lowerPoint.date.addingTimeInterval(timeInterval * Double(interpolationFactor))
        
        return (value: interpolatedBalance, date: interpolatedDate)
    }
    
    private func getInterpolatedYPosition(at location: CGPoint, in geometry: GeometryProxy) -> CGFloat {
        let interpolatedData = getInterpolatedDataPoint(at: location, in: geometry)
        let height = geometry.size.height
        let normalizedBalance = balanceRange > 0 ? 
            (interpolatedData.value - minBalance) / balanceRange : 0.5
        return height - (CGFloat(normalizedBalance) * height)
    }
    
    private func getClosestDataPoint(at location: CGPoint, in geometry: GeometryProxy) -> BalanceDataPoint? {
        guard !data.isEmpty else { return nil }
        
        let width = geometry.size.width
        
        // Handle single data point case
        if data.count == 1 {
            return data[0]
        }
        
        // Calculate step size for X coordinates
        let stepX = width / CGFloat(data.count - 1)
        
        // Find the closest data point based on X position only
        // This ensures smooth horizontal tracking
        let exactIndex = location.x / stepX
        let index = Int(round(exactIndex))
        let clampedIndex = max(0, min(index, data.count - 1))
        
        return data[clampedIndex]
    }
    
    // MARK: - Line Boundary Detection
    private func isWithinLineBounds(at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        guard !data.isEmpty else { return false }
        
        let width = geometry.size.width
        let height = geometry.size.height
        
        // Calculate the actual line bounds
        let lineStartX = data.count == 1 ? width / 2 : 0
        let lineEndX = data.count == 1 ? width / 2 : width
        
        // Check if touch is within horizontal bounds of the line
        let isWithinHorizontalBounds = location.x >= lineStartX - lineHitTestTolerance && 
                                     location.x <= lineEndX + lineHitTestTolerance
        
        // Check if touch is within vertical bounds (considering the data range)
        let isWithinVerticalBounds = location.y >= 0 && location.y <= height
        
        return isWithinHorizontalBounds && isWithinVerticalBounds
    }
    
    private func isNearChartLine(at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        guard !data.isEmpty, data.count > 1 else { return true } // Single point is always valid
        
        let width = geometry.size.width
        let height = geometry.size.height
        
        // Calculate the closest point on the line to the touch location
        let stepX = width / CGFloat(data.count - 1)
        let exactIndex = location.x / stepX
        let lowerIndex = max(0, min(Int(exactIndex), data.count - 1))
        let upperIndex = max(0, min(lowerIndex + 1, data.count - 1))
        
        // Get the two nearest data points
        let lowerPoint = data[lowerIndex]
        let upperPoint = data[upperIndex]
        
        // Calculate Y positions for these points
        let lowerY = getYPositionForPoint(lowerPoint, in: geometry)
        let upperY = getYPositionForPoint(upperPoint, in: geometry)
        
        // Interpolate the Y position on the line at the touch X
        let interpolationFactor = max(0.0, min(1.0, exactIndex - CGFloat(lowerIndex)))
        let lineY = lowerY + (upperY - lowerY) * interpolationFactor
        
        // Check if touch is within tolerance of the line
        let distanceToLine = abs(location.y - lineY)
        return distanceToLine <= lineHitTestTolerance
    }
    
    private func getYPositionForPoint(_ point: BalanceDataPoint, in geometry: GeometryProxy) -> CGFloat {
        let height = geometry.size.height
        let normalizedBalance = balanceRange > 0 ? 
            (point.balance - minBalance) / balanceRange : 0.5
        return height - (CGFloat(normalizedBalance) * height)
    }
    
    private func clampToLineBounds(_ location: CGPoint, in geometry: GeometryProxy) -> CGPoint {
        guard !data.isEmpty else { return location }
        
        let width = geometry.size.width
        let height = geometry.size.height
        
        // Clamp X to line bounds
        let lineStartX = data.count == 1 ? width / 2 : 0
        let lineEndX = data.count == 1 ? width / 2 : width
        let clampedX = max(lineStartX, min(location.x, lineEndX))
        
        // Clamp Y to chart bounds
        let clampedY = max(0, min(location.y, height))
        
        return CGPoint(x: clampedX, y: clampedY)
    }
    
    // MARK: - Smart Tooltip Positioning
    private func calculateSmartTooltipX(x: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let tooltipWidth: CGFloat = 120
        let margin: CGFloat = 20
        
        if x < tooltipWidth / 2 + margin {
            return tooltipWidth / 2 + margin
        } else if x > geometry.size.width - tooltipWidth / 2 - margin {
            return geometry.size.width - tooltipWidth / 2 - margin
        } else {
            return x
        }
    }
    
    private func calculateSmartTooltipY(y: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let tooltipHeight: CGFloat = 60
        let margin: CGFloat = 20
        
        if y < tooltipHeight + margin {
            return y + tooltipHeight + margin
        } else {
            return y - margin
        }
    }
    
    // MARK: - Animation Management
    private func startAnimationPhase() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            animationPhase = .pi * 2
        }
    }
    
    private func stopAnimationPhase() {
        withAnimation(.easeOut(duration: 0.3)) {
            animationPhase = 0
        }
    }
}

