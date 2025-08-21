import SwiftUI
import Charts

enum SpendingPeriod: String, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case biweekly = "Bi-Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    var id: String { rawValue }
}

// Dynamically calculate income and expense breakdowns from user data
private func calculateIncomeExpenseTableData(transactions: [Transaction]) -> [(label: String, expense: Double, income: Double)] {
    let now = Date()
    let calendar = Calendar.current
    

    
    // Helper to get the monthly equivalent of a transaction (for recurring)
    func monthlyEquivalent(for transaction: Transaction) -> Double {
        let isRecurring = transaction.subtitle.localizedCaseInsensitiveContains("recurring")
        guard isRecurring else { return 0 }
        let amount = abs(transaction.amount)
        if transaction.subtitle.localizedCaseInsensitiveContains("daily") {
            return amount * 30.0 // 30 days in a month
        } else if transaction.subtitle.localizedCaseInsensitiveContains("weekly") {
            return amount * 4.33 // 4.33 weeks in a month
        } else if transaction.subtitle.localizedCaseInsensitiveContains("monthly") {
            return amount
        } else if transaction.subtitle.localizedCaseInsensitiveContains("yearly") {
            return amount / 12.0 // 12 months in a year
        } else {
            // Default to monthly
            return amount
        }
    }
    // Sum all recurring as monthly equivalent
    let recurringMonthly = transactions.filter { !$0.isIncome }
        .map { monthlyEquivalent(for: $0) }
        .reduce(0, +)
    // Add one-time transactions for current month
    let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
    let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? now
    let oneTimeMonthly = transactions.filter {
        !$0.isIncome && !$0.subtitle.localizedCaseInsensitiveContains("recurring") &&
        $0.date >= monthStart && $0.date < monthEnd
    }.reduce(0) { $0 + $0.amount }
    let monthlyExpenses = recurringMonthly + oneTimeMonthly
    let yearlyExpenses = monthlyExpenses * 12.0
    let biWeeklyExpenses = yearlyExpenses / 26.0
    let weeklyExpenses = yearlyExpenses / 52.0
    let hourlyExpenses = yearlyExpenses / 2080.0
    // Table rows: Hour, Week, Bi-Week, Month, Year
    return [
        (label: "Hour", spending: hourlyExpenses, income: hourlyExpenses),
        (label: "Week", spending: weeklyExpenses, income: weeklyExpenses),
        (label: "Bi-Week", spending: biWeeklyExpenses, income: biWeeklyExpenses),
        (label: "Month", spending: monthlyExpenses, income: monthlyExpenses),
        (label: "Year", spending: yearlyExpenses, income: yearlyExpenses)
    ]
}

struct OverviewView: View {
    let transactions: [Transaction]
    let goals: [GoalFormData]
    @State private var spendingPeriod: SpendingPeriod = .monthly
    @AppStorage("startingBalance") private var startingBalance: Double = 0
    @AppStorage("preferredCurrency") private var preferredCurrency: String = "USD"
    
    // Debug: Print goals when they change
    private var debugGoals: String {
        "Goals count: \(goals.count), Names: \(goals.map { $0.name })"
    }
    
    // Calculate total balance from starting balance and all transactions
    // Use isIncome property to determine if it's income or expense
    private var totalBalance: Double {
        let allIncome = transactions.filter { $0.isIncome }.reduce(0) { $0 + $0.amount }
        let allExpenses = transactions.filter { !$0.isIncome }.reduce(0) { $0 + $0.amount }
        return startingBalance + allIncome - allExpenses
    }
    
    // Calculate current month income and expenses
    // Use isIncome property to determine if it's income or expense
    private var currentMonthIncome: Double {
        let now = Date()
        let calendar = Calendar.current
        return transactions.filter {
            $0.isIncome && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $0.amount }
    }
    private var currentMonthExpenses: Double {
        let now = Date()
        let calendar = Calendar.current
        return transactions.filter {
            !$0.isIncome && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }.reduce(0) { $0 + $0.amount }
    }
    
    // Computed property for chart data (real user data)
    private var spendingDiversityData: [SpendingDiversityDonutChartView.CategoryData] {
        let now = Date()
        let calendar = Calendar.current
        let (start, end): (Date, Date) = {
            switch spendingPeriod {
            case .weekly:
                let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
                return (weekStart, now)
            case .biweekly:
                let biweekStart = calendar.date(byAdding: .day, value: -13, to: now) ?? now
                return (biweekStart, now)
            case .monthly:
                let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
                return (monthStart, now)
            case .yearly:
                let yearStart = calendar.date(from: calendar.dateComponents([.year], from: now)) ?? now
                return (yearStart, now)
            }
        }()
        
        // Filter transactions for the period and exclude income
        let periodTxs = transactions.filter { 
            $0.date >= start && 
            $0.date < end && 
            !$0.isIncome 
        }
        
        // Group transactions by category and calculate totals
        let categoryTotals = Dictionary(grouping: periodTxs) { $0.category }
            .mapValues { transactions in
                transactions.reduce(0) { $0 + $0.amount }
            }
        
        // Map categories to their display properties
        let categoryData: [SpendingDiversityDonutChartView.CategoryData] = TransactionCategory.allCases
            .filter { $0 != .income } // Exclude income category
            .map { category in
                let value = categoryTotals[category] ?? 0
                
                // Get the most used icon for this category from the transactions
                let categoryTransactions = periodTxs.filter { $0.category == category }
                let iconCounts = Dictionary(grouping: categoryTransactions) { $0.iconName }
                    .mapValues { $0.count }
                let mostUsedIcon = iconCounts.max(by: { $0.value < $1.value })?.key ?? category.symbol
                
                // Calculate average spent per month for this category
                let avgSpent = value / Double(calendar.dateComponents([.day], from: start, to: end).day ?? 30) * 30
                
                return SpendingDiversityDonutChartView.CategoryData(
                    category: category.label,
                    value: value,
                    color: category.color,
                    symbol: mostUsedIcon,
                    avgSpent: avgSpent
                )
            }
            .filter { $0.value > 0 } // Only include categories with transactions
        
        return categoryData
    }
    var body: some View {
        let currencyCode = preferredCurrency.components(separatedBy: " ").first ?? "USD"
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Section Title
                    Text("Overview")
                        .font(.title.bold())
                        .foregroundColor(.primary)
                        .padding(.top, AppPaddings.sectionTitleTop)
                        .padding(.bottom, AppPaddings.sectionTitleBottom)
                    // Combined Balance/Income/Expenses Card (vertical stack)
                    ZStack {
                        RoundedRectangle(cornerRadius: AppPaddings.cardRadius, style: .continuous)
                            .fill(AppColors.brandBlack)
                        VStack(alignment: .leading, spacing: 0) {
                            // Total Balance (top row)
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Total Balance")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.85))
                                Text(totalBalance, format: .currency(code: currencyCode).precision(.fractionLength(2)))
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.top, 32)
                            .padding(.horizontal, 32)
                            // Divider between balance and income/expenses
                            Divider()
                                .frame(height: 1)
                                .background(Color.white.opacity(0.18))
                                .padding(.vertical, 16)
                                .padding(.horizontal, 32)
                            // Income & Expenses (vertical stack)
                            VStack(alignment: .leading, spacing: 12) {
                                // Income
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 4) {
                                        Text("Income")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.85))
                                        Text("(This Month)")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.65))
                                    }
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.up")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(AppColors.brandGreen)
                                        Text(currentMonthIncome, format: .currency(code: currencyCode).precision(.fractionLength(2)))
                                            .font(.title3.bold())
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                // Divider between income and expenses
                                Divider()
                                    .frame(height: 1)
                                    .background(Color.white.opacity(0.18))
                                
                                // Expenses
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 4) {
                                        Text("Expenses")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.85))
                                        Text("(This Month)")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.65))
                                    }
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.down")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(AppColors.brandRed)
                                        Text(currentMonthExpenses, format: .currency(code: currencyCode).precision(.fractionLength(2)))
                                            .font(.title3.bold())
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.bottom, 32)
                            .padding(.horizontal, 32)
                        }
                    }
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: AppPaddings.cardRadius, style: .continuous))
                    // Insights Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Insights")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                                .padding(.leading, 4)
                            Spacer()
                        }
                        .padding(.top, AppPaddings.sectionTitleTop)
                        VStack(spacing: 16) {
                            let incomeExpenseTableData = calculateIncomeExpenseTableData(transactions: transactions)
                            ChartCard(title: "Income Required", subtitle: "Minimum income needed for each period.", chartHeight: 510, titleAlignment: .leading) {
                                VStack(spacing: 12) {
                                    IncomeRequiredChartView(
                                        data: incomeExpenseTableData.map { .init(label: $0.label, value: $0.income) },
                                        barColor: AppColors.brandGreen
                                    )
                                    // Table below the chart
                                    VStack(spacing: 0) {
                                        HStack {
                                            Text("Period")
                                                .font(.caption.bold())
                                                .frame(minWidth: 60, alignment: .leading)
                                            Spacer()
                                            Text("Income Required")
                                                .font(.caption.bold())
                                                .frame(minWidth: 80, alignment: .trailing)
                                        }
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 8)
                                        .background(Color(.systemGray6))
                                        ForEach(incomeExpenseTableData.indices, id: \ .self) { idx in
                                            let row = incomeExpenseTableData[idx]
                                            HStack {
                                                Text(row.label)
                                                    .font(.caption)
                                                    .frame(minWidth: 60, alignment: .leading)
                                                Spacer()
                                                Text(row.income, format: .currency(code: currencyCode).precision(.fractionLength(2)))
                                                    .font(.caption)
                                                    .foregroundColor(AppColors.brandGreen)
                                                    .frame(minWidth: 80, alignment: .trailing)
                                            }
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 8)
                                            .background(Color.white.opacity(idx % 2 == 0 ? 0.95 : 0.85))
                                            if idx < incomeExpenseTableData.count - 1 {
                                                Divider()
                                                    .padding(.leading, 4)
                                            }
                                        }
                                    }
                                    .background(
                                        RoundedRectangle(cornerRadius: AppPaddings.cardRadius, style: .continuous)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                                    .padding(.top, 8)
                                }
                            }
                            ChartCard(title: "Spending Diversity", subtitle: "Distribution of spending by category.", chartHeight: 340, titleAlignment: .leading) {
                                VStack(spacing: 16) {
                                    Picker("Period", selection: $spendingPeriod) {
                                        ForEach(SpendingPeriod.allCases) { period in
                                            Text(period.rawValue).tag(period)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                    .tint(AppColors.brandBlack)
                                    .padding(.top, 48)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 8)
                                    ZStack(alignment: .bottom) {
                                        if spendingDiversityData.allSatisfy({ $0.value == 0 }) {
                                            ZStack {
                                                GeometryReader { geo in
                                                    let size = min(geo.size.width, geo.size.height)
                                                    ZStack {
                                                        Circle()
                                                            .strokeBorder(AppColors.brandBlack.opacity(0.18), lineWidth: 38)
                                                            .frame(width: size, height: size)
                                                        Image(systemName: "chart.pie")
                                                            .font(.system(size: 36, weight: .regular))
                                                            .foregroundColor(.secondary)
                                                    }
                                                    .frame(width: size, height: size)
                                                    .position(x: geo.size.width/2, y: geo.size.height/2)
                                                }
                                                .frame(height: 220)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        } else {
                                            SpendingDiversityDonutChartView(data: spendingDiversityData, preferredCurrency: currencyCode)
                                        }
                                    }
                                    .padding(.bottom, 24)
                                }
                            }
                        }
                    }
                    
                    // Savings Goals Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Savings Goals")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                                .padding(.leading, 4)
                            Spacer()
                            Button(action: {
                                // Navigation logic to switch to Budget tab goes here
                            }) {
                                Text("See All")
                                    .font(.subheadline.bold())
                                    .foregroundColor(AppColors.brandBlue)
                                }
                                .accessibilityLabel("See all savings goals")
                        }
                        .padding(.top, AppPaddings.sectionTitleTop)
                        .padding(.bottom, AppPaddings.sectionTitleBottom)
                        
                        if goals.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "target")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.secondary)
                                Text("No savings goals yet")
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(.secondary)
                                Text("Create your first savings goal in the Budget tab to see it here.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                // Debug info
                                Text("Debug: goals count = \(goals.count)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.top, 8)
                                Text(debugGoals)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppPaddings.large)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(goals.prefix(3), id: \.id) { goal in
                                    SavingsGoalRow(goal: goal, currencyCode: preferredCurrency)
                                }
                            }
                            .padding(.bottom, AppPaddings.large)
                        }
                    }
                    
                    // Recent Transactions Section
                    // Section Title (detached from list)
                    HStack {
                        Text("Recent Transactions")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                            .padding(.leading, 4)
                        Spacer()
                        Button(action: {
                            // Navigation logic to switch to Transactions tab goes here
                        }) {
                            Text("See All")
                                .font(.subheadline.bold())
                                .foregroundColor(AppColors.brandBlue)
                        }
                        .accessibilityLabel("See all transactions")
                    }
                    .padding(.top, AppPaddings.sectionTitleTop)
                    .padding(.bottom, AppPaddings.sectionTitleBottom)
                    // Transaction List (separate from title)
                    if transactions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.secondary)
                            Text("No recent transactions yet")
                                .font(.body.weight(.semibold))
                                .foregroundColor(.secondary)
                            Text("Your recent transactions will appear here once you add them.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppPaddings.large)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(transactions.prefix(5), id: \ .id) { transaction in
                                TransactionRow(transaction: transaction)
                            }
                        }
                        .padding(.bottom, AppPaddings.large)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .onAppear {
            print("DEBUG: OverviewView appeared with \(goals.count) goals: \(goals.map { $0.name })")
        }
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
            .foregroundColor(.secondary)
            .font(.subheadline)
        self.titleAlignment = titleAlignment
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppColors.card)
                .frame(height: chartHeight)
                .overlay(
                    content
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                )
        }
        .padding(16)
        .background(AppColors.card)
        .cornerRadius(18)
        .shadow(color: AppColors.cardShadow, radius: 4, y: 2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - SwiftCharts Bar Chart for Income Required
struct IncomeRequiredChartView: View {
    struct IncomeData: Identifiable {
        let id = UUID()
        let label: String
        let value: Double // income required
    }
    let data: [IncomeData]
    let barColor: Color
    var body: some View {
        Chart(data, id: \.id) { item in
            BarMark(
                x: .value("Period", item.label),
                y: .value("Income Required", item.value)
            )
            .foregroundStyle(barColor)
            .cornerRadius(4)
        }
        .chartYAxis {
            let maxValue = data.map { $0.value }.max() ?? 1
            let step = maxValue > 10000 ? 5000.0 : (maxValue > 1000 ? 1000.0 : (maxValue > 100 ? 100.0 : 10.0))
            let ticks = Array(stride(from: 0.0, through: maxValue, by: step))
            AxisMarks(position: .leading, values: ticks) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: FloatingPointFormatStyle<Double>().precision(.fractionLength(2)))
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYScale(domain: 0...(data.map { $0.value }.max() ?? 1))
        .frame(height: 280)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - SwiftCharts Donut Chart for Spending Diversity
struct SpendingDiversityDonutChartView: View {
    struct CategoryData: Identifiable, Equatable {
        let id = UUID()
        let category: String
        let value: Double
        let color: Color
        let symbol: String
        let avgSpent: Double
    }
    let data: [CategoryData]
    let preferredCurrency: String
    @StateObject private var viewModel: DonutChartViewModel

    init(data: [CategoryData], preferredCurrency: String) {
        self.data = data
        self.preferredCurrency = preferredCurrency
        let categories = data.map { DonutChartCategory(
            name: $0.category,
            value: $0.value,
            color: $0.color,
            symbol: $0.symbol
        )}
        _viewModel = StateObject(wrappedValue: DonutChartViewModel(categories: categories))
    }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                let size = min(geo.size.width, geo.size.height)
                HStack {
                    Spacer()
            DonutChartView(
                        viewModel: viewModel,
                        currencyCode: preferredCurrency
            )
                    .frame(width: size, height: size)
                    Spacer()
                }
            }
            .frame(height: 220)
            legend
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .onChange(of: data) { _, _ in }
    }

    private var legend: some View {
        if data.allSatisfy({ $0.value == 0 }) {
            return AnyView(
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                    Text("No spending data for this period")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 16)
            )
        } else {
            let selected = viewModel.selectedCategory ?? viewModel.categories.first
            let avgSpentString = data.first(where: { $0.category == selected?.name })?.avgSpent.formatted(.currency(code: preferredCurrency).precision(.fractionLength(2))) ?? ""
            let legendText = avgSpentString.isEmpty ? "" : "Avg spent: \(avgSpentString)/mo"
            return AnyView(
                VStack(alignment: .leading, spacing: 6) {
                    if let selected {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(selected.color)
                                .frame(width: 16, height: 16)
                            Text(selected.name)
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                        }
                    }
                    if !legendText.isEmpty {
                        Text(legendText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 10)
                .padding(.top, 8)
            )
        }
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
                    .foregroundColor(.primary)
                Picker("Period", selection: $selectedPeriod) {
                    Text("1W").tag("1W")
                    Text("1M").tag("1M")
                    Text("3M").tag("3M")
                    Text("YTD").tag("YTD")
                    Text("1Y").tag("1Y")
                }
                .pickerStyle(.segmented)
                .tint(AppColors.brandBlack)
            }
        }
    }
}

// MARK: - Savings Goal Row Component
struct SavingsGoalRow: View {
    let goal: GoalFormData
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
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon, name, and progress
            HStack(spacing: 12) {
                // Icon
                Image(systemName: goal.iconName)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(goal.iconColor)
                    .frame(width: 48, height: 48)
                    .background(goal.iconColor.opacity(0.15))
                    .clipShape(Circle())
                
                // Goal info
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if let notes = goal.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // Progress percentage
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(progressPercentage * 100))%")
                        .font(.title3.bold())
                        .foregroundColor(goal.iconColor)
                    Text("Complete")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    // Progress bar
                    RoundedRectangle(cornerRadius: 4)
                        .fill(goal.iconColor)
                        .frame(width: geometry.size.width * progressPercentage, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: progressPercentage)
                }
            }
            .frame(height: 8)
            
            // Financial details
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Saved")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(goal.savedAmount, format: .currency(code: currencyCode))
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Target")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(goal.targetAmount, format: .currency(code: currencyCode))
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Remaining")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(remainingAmount, format: .currency(code: currencyCode))
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Days remaining
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(daysRemaining)")
                        .font(.title3.bold())
                        .foregroundColor(daysRemaining < 30 ? .red : .primary)
                    Text("days left")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(AppColors.card)
        .cornerRadius(AppPaddings.cardRadius)
        .shadow(color: AppColors.cardShadow, radius: 2, y: 1)
    }
}
