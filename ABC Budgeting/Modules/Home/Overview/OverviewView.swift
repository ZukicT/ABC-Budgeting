import SwiftUI
import Charts


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
    }.reduce(0) { sum, transaction in sum + transaction.amount }
    let monthlyExpenses = recurringMonthly + oneTimeMonthly
    let yearlyExpenses = monthlyExpenses * 12.0
    let biWeeklyExpenses = yearlyExpenses / 26.0
    let weeklyExpenses = yearlyExpenses / 52.0
    let hourlyExpenses = yearlyExpenses / 2080.0
    // Table rows: Hour, Week, Bi-Week, Month, Year
    return [
        (label: "Hour", expense: hourlyExpenses, income: hourlyExpenses),
        (label: "Week", expense: weeklyExpenses, income: weeklyExpenses),
        (label: "Bi-Week", expense: biWeeklyExpenses, income: biWeeklyExpenses),
        (label: "Month", expense: monthlyExpenses, income: monthlyExpenses),
        (label: "Year", expense: yearlyExpenses, income: yearlyExpenses)
    ]
}

private func createShortLabel(for label: String) -> String {
    switch label {
    case "Hour": return "Hr"
    case "Week": return "Wk"
    case "Bi-Week": return "2Wk"
    case "Month": return "Mo"
    case "Year": return "Yr"
    default: return label
    }
}

struct OverviewView: View {
    let transactions: [Transaction]
    let goals: [GoalFormData]
    let onSeeAllGoals: () -> Void
    let onSeeAllTransactions: () -> Void
    let onAddTransaction: (Transaction) -> Void
    @AppStorage("baselineBalance") private var startingBalance: Double = 0
    @AppStorage("preferredCurrency") private var preferredCurrency: String = "USD"
    @State private var showAddTransaction = false
    @State private var preSelectedTransactionType: IncomeOrExpense = .expense
    
    // Debug: Print goals when they change
    private var debugGoals: String {
        "Goals count: \(goals.count), Names: \(goals.map { $0.name })"
    }
    
    // Calculate total balance from starting balance and all transactions
    // Use isIncome property to determine if it's income or expense
    private var totalBalance: Double {
        let allIncome = transactions.filter { $0.isIncome }.reduce(0) { sum, transaction in sum + transaction.amount }
        let allExpenses = transactions.filter { !$0.isIncome }.reduce(0) { sum, transaction in sum + transaction.amount }
        return startingBalance + allIncome - allExpenses
    }
    
    // Calculate current month income and expenses
    // Use isIncome property to determine if it's income or expense
    private var currentMonthIncome: Double {
        let now = Date()
        let calendar = Calendar.current
        return transactions.filter {
            $0.isIncome && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }.reduce(0) { sum, transaction in sum + transaction.amount }
    }
    
    // Calculate this week's income
    private var thisWeekIncome: Double {
        let now = Date()
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
        return transactions.filter {
            $0.isIncome && $0.date >= weekStart && $0.date <= now
        }.reduce(0) { sum, transaction in sum + transaction.amount }
    }
    private var currentMonthExpenses: Double {
        let now = Date()
        let calendar = Calendar.current
        return transactions.filter {
            !$0.isIncome && calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }.reduce(0) { sum, transaction in sum + transaction.amount }
    }
    
    var body: some View {
        let currencyCode = preferredCurrency.components(separatedBy: " ").first ?? "USD"
        ZStack {
            // Subtle light gray gradient background
            LinearGradient(
                colors: [Color(hex: "f8fafc"), Color(hex: "e2e8f0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Curved blue gradient balance card
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "0a38c3"), Color(hex: "0a38c3"), Color(hex: "1e40af")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Balance")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(totalBalance, format: .currency(code: currencyCode).precision(.fractionLength(2)))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if thisWeekIncome > 0 {
                                Text("+\(thisWeekIncome, format: .currency(code: currencyCode).precision(.fractionLength(2))) this week")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.vertical, 32)
                    }
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Color(hex: "0a38c3").opacity(0.25), radius: 12, y: 6)
                    .padding(.top, AppPaddings.sectionTitleTop)
                    
                    // Quick action buttons
                    HStack(spacing: 16) {
                        // Income button
                        Button(action: {
                            preSelectedTransactionType = .income
                            showAddTransaction = true
                        }) {
                            Text("+ Income")
                                .font(.headline.weight(.bold))
                                .foregroundColor(Color(hex: "065f46"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(hex: "07e95e"))
                                )
                        }
                        .accessibilityLabel("Add income transaction")
                        
                        // Expense button
                        Button(action: {
                            preSelectedTransactionType = .expense
                            showAddTransaction = true
                        }) {
                            Text("- Expense")
                                .font(.headline.weight(.bold))
                                .foregroundColor(Color(hex: "dc2626"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(hex: "fecaca"))
                                )
                        }
                        .accessibilityLabel("Add expense transaction")
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                    
                    // Savings Goals Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Savings Goals")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                                .padding(.leading, 4)
                            Spacer()
                            Button(action: onSeeAllGoals) {
                                Text("See All")
                                    .font(.subheadline.bold())
                                    .foregroundColor(AppColors.brandBlue)
                                }
                                .accessibilityLabel("See all savings goals")
                        }
                        .padding(.top, AppPaddings.sectionTitleTop)
                        .padding(.bottom, AppPaddings.sectionTitleBottom)
                        
                        if goals.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "target")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 64, height: 64)
                                    .foregroundColor(.secondary.opacity(0.6))
                                VStack(spacing: 8) {
                                    Text("No savings goals yet")
                                        .font(.title3.weight(.semibold))
                                        .foregroundColor(.secondary)
                                    Text("Create your first savings goal in the Budget tab to see it here.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(3)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                            )
                        } else {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(goals.prefix(4), id: \.id) { goal in
                                    CompactSavingsGoalCard(goal: goal, currencyCode: preferredCurrency)
                                }
                            }
                            .padding(.bottom, AppPaddings.large)
                        }
                    }
                    
                    // Recent Transactions Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Transactions")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                                .padding(.leading, 4)
                            Spacer()
                            Button(action: onSeeAllTransactions) {
                                Text("See All")
                                    .font(.subheadline.bold())
                                    .foregroundColor(AppColors.brandBlue)
                            }
                            .accessibilityLabel("See all transactions")
                        }
                        .padding(.top, AppPaddings.sectionTitleTop)
                        .padding(.bottom, AppPaddings.sectionTitleBottom)
                        
                        // Transaction List
                        if transactions.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "tray")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 64, height: 64)
                                    .foregroundColor(.secondary.opacity(0.6))
                                VStack(spacing: 8) {
                                    Text("No recent transactions yet")
                                        .font(.title3.weight(.semibold))
                                        .foregroundColor(.secondary)
                                    Text("Your recent transactions will appear here once you add them.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .lineLimit(3)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                            )
                        } else {
                            VStack(spacing: 12) {
                                ForEach(transactions.prefix(5), id: \ .id) { transaction in
                                    TransactionRow(transaction: transaction)
                                }
                            }
                            .padding(.bottom, AppPaddings.large)
                        }
                    }
                    
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
                        .padding(.bottom, AppPaddings.sectionTitleBottom)
                        VStack(spacing: 16) {
                            let incomeExpenseTableData = calculateIncomeExpenseTableData(transactions: transactions)
                            // Income Required Card
                            ChartCard(title: "Income Required", subtitle: "How much you need to earn to cover your expenses.", chartHeight: 430, titleAlignment: .leading) {
                                IncomeRequiredChartWithTableView(
                                    data: incomeExpenseTableData.map { 
                                        .init(
                                            label: $0.label, 
                                            value: $0.income,
                                            shortLabel: createShortLabel(for: $0.label)
                                        ) 
                                    },
                                    barColor: AppColors.secondary,
                                    currencyCode: currencyCode
                                )
                            }
                            
                            // Spending Breakdown Card
                            ChartCard(title: "Spending Breakdown", subtitle: "Your monthly expenses by category.", chartHeight: 400, titleAlignment: .leading) {
                                SpendingBreakdownChartView(
                                    transactions: transactions,
                                    currencyCode: currencyCode
                                )
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            PreSelectedAddTransactionView(
                availableGoals: goals,
                preSelectedType: preSelectedTransactionType
            ) { newTransaction in
                onAddTransaction(newTransaction)
                showAddTransaction = false
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            print("DEBUG: OverviewView appeared with \(goals.count) goals")
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
                        .foregroundColor(.secondary)
                        .frame(minWidth: 50, alignment: .leading)
                    Spacer()
                    Text("Income Required")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
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
                            .foregroundColor(.primary)
                            .frame(minWidth: 50, alignment: .leading)
                        Spacer()
                        Text(row.value, format: .currency(code: currencyCode).precision(.fractionLength(0)))
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
                    .stroke(AppColors.chartAxis.opacity(0.2), lineWidth: 1)
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
            // Chart with enhanced styling
            Chart(data, id: \.id) { item in
                BarMark(
                    x: .value("Period", item.shortLabel),
                    y: .value("Income Required", item.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [barColor.opacity(0.8), barColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(6)
                .opacity(0.9)
            }
            .chartYAxis {
                let maxValue = data.map { $0.value }.max() ?? 1
                let step = maxValue > 10000 ? 5000.0 : (maxValue > 1000 ? 1000.0 : (maxValue > 100 ? 100.0 : 10.0))
                let ticks = Array(stride(from: 0.0, through: maxValue, by: step))
                AxisMarks(position: .leading, values: ticks) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                        .foregroundStyle(AppColors.chartAxis)
                    AxisTick()
                        .foregroundStyle(AppColors.chartAxis)
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(doubleValue.formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
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
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .chartYScale(domain: 0...(data.map { $0.value }.max() ?? 1))
            .frame(height: 160)
            .padding(.horizontal, 4)
            
            // Summary statistics
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("Average")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                        Button(action: {
                            showAverageInfo = true
                        }) {
                            Image(systemName: "info.circle")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    Text(calculateAverage().formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(barColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Button(action: {
                            showHighestInfo = true
                        }) {
                            Image(systemName: "info.circle")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        Text("Highest")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                    Text(calculateHighest().formatted(.currency(code: currencyCode).precision(.fractionLength(0))))
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(barColor)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(barColor.opacity(0.08))
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
                    .foregroundColor(.primary)
                Picker("Period", selection: $selectedPeriod) {
                    Text("1W").tag("1W")
                    Text("1M").tag("1M")
                    Text("3M").tag("3M")
                    Text("YTD").tag("YTD")
                    Text("1Y").tag("1Y")
                }
                .pickerStyle(.segmented)
                .tint(AppColors.black)
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
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if let subtitle = goal.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar with enhanced styling
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray6))
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
                        .foregroundColor(.secondary)
                    Text(goal.savedAmount, format: .currency(code: currencyCode))
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(AppColors.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Target")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                    Text(goal.targetAmount, format: .currency(code: currencyCode))
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Remaining")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                    Text(remainingAmount, format: .currency(code: currencyCode))
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(AppColors.primary)
                }
                
                Spacer()
                
                // Days remaining with enhanced styling
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(daysRemaining < 30 ? .red : .secondary)
                        Text("\(daysRemaining)")
                            .font(.title3.weight(.bold))
                            .foregroundColor(daysRemaining < 30 ? .red : .primary)
                    }
                    Text("days left")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                }
            }
            
            // Notes section if available
            if let notes = goal.notes, !notes.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
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
    let goal: GoalFormData
    let currencyCode: String
    
    private var progressPercentage: Double {
        guard goal.targetAmount > 0 else { return 0 }
        return min(goal.savedAmount / goal.targetAmount, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon and name
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(goal.iconColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: goal.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(goal.iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("\(Int(progressPercentage * 100))%")
                        .font(.caption.weight(.bold))
                        .foregroundColor(goal.iconColor)
                }
                
                Spacer()
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray6))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(goal.iconColor)
                        .frame(width: geometry.size.width * progressPercentage, height: 6)
                        .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                }
            }
            .frame(height: 6)
            
            // Amount info
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.savedAmount, format: .currency(code: currencyCode))
                    .font(.caption.weight(.bold))
                    .foregroundColor(Color(hex: "07e95e"))
                
                Text("of \(goal.targetAmount, format: .currency(code: currencyCode))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        )
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Spending Breakdown Chart View
struct SpendingBreakdownChartView: View {
    let transactions: [Transaction]
    let currencyCode: String
    
    private var spendingData: [SpendingCategory] {
        let expenseTransactions = transactions.filter { !$0.isIncome }
        let categoryGroups = Dictionary(grouping: expenseTransactions) { $0.category }
        
        let allCategories: [SpendingCategory] = categoryGroups.compactMap { (category, transactions) in
            // Only include non-income categories and ensure we have transactions
            guard !transactions.isEmpty else { return nil }
            
            let totalAmount = transactions.reduce(0) { $0 + $1.amount }
            // Only include categories with positive amounts and minimum threshold for visibility
            guard totalAmount > 0.01 else { return nil }
            
            return SpendingCategory(
                name: getSimplifiedCategoryName(category),
                amount: totalAmount,
                transactionCount: transactions.count
            )
        }
        
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
                transactionCount: otherCount
            ))
        }
        
        return mainCategories.sorted { $0.amount > $1.amount }
    }
    
    private var totalSpending: Double {
        spendingData.reduce(0) { $0 + $1.amount }
    }
    
    private func getSimplifiedCategoryName(_ category: TransactionCategory) -> String {
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
                        .foregroundColor(.secondary.opacity(0.6))
                    Text("No spending data yet")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.secondary)
                    Text("Add some expense transactions to see your spending breakdown")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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
                            .fill(Color.gray.opacity(0.15))
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
                        Text(totalSpending, format: .currency(code: currencyCode).precision(.fractionLength(0)))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .dynamicTypeSize(.large)
                        
                        Text("Monthly Spending")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
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
                            .foregroundColor(.secondary)
                            .frame(minWidth: 50, alignment: .leading)
                        Spacer()
                        Text("Amount")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
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
                                .foregroundColor(.primary)
                                .frame(minWidth: 50, alignment: .leading)
                            Spacer()
                            Text(category.amount, format: .currency(code: currencyCode).precision(.fractionLength(0)))
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.red)
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
                        .stroke(AppColors.chartAxis.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Spending breakdown chart showing \(spendingData.count) categories")
    }
    
    private func getCategoryColor(for categoryName: String) -> Color {
        switch categoryName {
        case "Food": return .orange
        case "Leisure": return .purple
        case "Savings": return .green
        case "Income": return .mint
        case "Bills": return .red
        case "Other": return .gray
        default: return .gray
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

// MARK: - Spending Category Model
struct SpendingCategory: Equatable {
    let name: String
    let amount: Double
    let transactionCount: Int
}

// MARK: - PreSelected Add Transaction View
struct PreSelectedAddTransactionView: View {
    let availableGoals: [GoalFormData]
    let preSelectedType: IncomeOrExpense
    let onSave: (Transaction) -> Void
    
    var body: some View {
        AddTransactionViewWithPreselection(
            availableGoals: availableGoals,
            preSelectedType: preSelectedType
        ) { transaction in
            onSave(transaction)
        }
    }
}

