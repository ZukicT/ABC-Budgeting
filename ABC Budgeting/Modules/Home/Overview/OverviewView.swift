import SwiftUI
import Charts

enum SpendingPeriod: String, CaseIterable, Identifiable {
    case weekly = "Weekly"
    case biweekly = "Bi-Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    var id: String { rawValue }
}

// Add this near the top of the file, outside any struct
private let incomeSpendingTableData: [(label: String, spending: Double, income: Double)] = [
    (label: "Hour", spending: 12.0, income: 15.0),
    (label: "Week", spending: 480.0, income: 600.0),
    (label: "Bi-Week", spending: 950.0, income: 1200.0),
    (label: "Month", spending: 2100.0, income: 2600.0),
    (label: "Year", spending: 25000.0, income: 31200.0)
]

struct OverviewView: View {
    @State private var spendingPeriod: SpendingPeriod = .monthly
    @AppStorage("startingBalance") private var totalBalance: Double = 0
    @AppStorage("preferredCurrency") private var preferredCurrency: String = "USD"
    
    // Computed property for chart data
    private var spendingDiversityData: [SpendingDiversityDonutChartView.CategoryData] {
        switch spendingPeriod {
        case .weekly:
            return [
                .init(category: "Food", value: 50, color: AppColors.brandGreen, symbol: "fork.knife", avgSpent: 50),
                .init(category: "Transport", value: 20, color: AppColors.brandBlue, symbol: "car.fill", avgSpent: 20),
                .init(category: "Entertainment", value: 15, color: AppColors.brandPurple, symbol: "music.note", avgSpent: 15),
                .init(category: "Utilities", value: 10, color: AppColors.brandYellow, symbol: "bolt.fill", avgSpent: 10),
                .init(category: "Other", value: 5, color: AppColors.brandPink, symbol: "ellipsis", avgSpent: 5)
            ]
        case .biweekly:
            return [
                .init(category: "Food", value: 100, color: AppColors.brandGreen, symbol: "fork.knife", avgSpent: 50),
                .init(category: "Transport", value: 40, color: AppColors.brandBlue, symbol: "car.fill", avgSpent: 20),
                .init(category: "Entertainment", value: 30, color: AppColors.brandPurple, symbol: "music.note", avgSpent: 15),
                .init(category: "Utilities", value: 20, color: AppColors.brandYellow, symbol: "bolt.fill", avgSpent: 10),
                .init(category: "Other", value: 10, color: AppColors.brandPink, symbol: "ellipsis", avgSpent: 5)
            ]
        case .monthly:
            return [
                .init(category: "Food", value: 200, color: AppColors.brandGreen, symbol: "fork.knife", avgSpent: 200),
                .init(category: "Transport", value: 75, color: AppColors.brandBlue, symbol: "car.fill", avgSpent: 75),
                .init(category: "Entertainment", value: 50, color: AppColors.brandPurple, symbol: "music.note", avgSpent: 50),
                .init(category: "Utilities", value: 38, color: AppColors.brandYellow, symbol: "bolt.fill", avgSpent: 38),
                .init(category: "Other", value: 25, color: AppColors.brandPink, symbol: "ellipsis", avgSpent: 25)
            ]
        case .yearly:
            return [
                .init(category: "Food", value: 800, color: AppColors.brandGreen, symbol: "fork.knife", avgSpent: 200),
                .init(category: "Transport", value: 300, color: AppColors.brandBlue, symbol: "car.fill", avgSpent: 75),
                .init(category: "Entertainment", value: 200, color: AppColors.brandPurple, symbol: "music.note", avgSpent: 50),
                .init(category: "Utilities", value: 150, color: AppColors.brandYellow, symbol: "bolt.fill", avgSpent: 38),
                .init(category: "Other", value: 100, color: AppColors.brandPink, symbol: "ellipsis", avgSpent: 25)
            ]
        }
    }
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Total Balance Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(AppColors.brandBlack)
                        // Decorative shapes (top right, bottom left)
                        HStack {
                            Spacer()
                            Circle()
                                .fill(AppColors.brandBlue)
                                .frame(width: 70, height: 70)
                                .offset(x: 60, y: -36)
                            Circle()
                                .fill(AppColors.brandYellow)
                                .frame(width: 80, height: 90)
                                .offset(x: 25, y: -40)
                        }
                        .frame(height: 0)
                        HStack {
                            Circle()
                                .fill(AppColors.brandGreen)
                                .frame(width: 60, height: 60)
                                .offset(x: -20, y: 40)
                            Spacer()
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Total Balance")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.85))
                            Text(totalBalance, format: .currency(code: preferredCurrency).precision(.fractionLength(2)))
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 20)
                        .padding(.leading, 24)
                    }
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    // Income/Outcome Card
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(AppColors.brandBlack)
                        // Decorative shapes (top left, bottom right)
                        HStack {
                            Circle()
                                .fill(AppColors.brandPurple)
                                .frame(width: 36, height: 36)
                                .offset(x: -18, y: -18)
                            Spacer()
                        }
                        .frame(height: 0)
                        HStack {
                            Spacer()
                            Circle()
                                .fill(AppColors.brandYellow)
                                .frame(width: 28, height: 28)
                                .offset(x: 18, y: 18)
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        HStack(spacing: 32) {
                            VStack(alignment: .center, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.down")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(AppColors.brandGreen)
                                    Text("Income")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.85))
                                }
                                Text(20000, format: .currency(code: preferredCurrency).precision(.fractionLength(0)))
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            Divider()
                                .frame(width: 1, height: 44)
                                .background(Color.white.opacity(0.18))
                            VStack(alignment: .center, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(AppColors.brandRed)
                                    Text("Outcome")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.85))
                                }
                                Text(17000, format: .currency(code: preferredCurrency).precision(.fractionLength(0)))
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 24)
                    }
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
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
                            ChartCard(title: "Income Required", subtitle: "Minimum income needed for each period.", chartHeight: 450, titleAlignment: .leading) {
                                VStack(spacing: 12) {
                                    IncomeRequiredChartView(
                                        data: [
                                            .init(label: "Hour", value: 15, spending: 12),
                                            .init(label: "Week", value: 600, spending: 480),
                                            .init(label: "Bi-Week", value: 1200, spending: 950),
                                            .init(label: "Month", value: 2600, spending: 2100),
                                            .init(label: "Year", value: 31200, spending: 25000)
                                        ],
                                        barColor: AppColors.brandGreen
                                    )
                                    // Legend below the chart
                                    HStack(spacing: 20) {
                                        HStack(spacing: 6) {
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(AppColors.brandRed)
                                                .frame(width: 22, height: 12)
                                            Text("Spending")
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                        }
                                        HStack(spacing: 6) {
                                            RoundedRectangle(cornerRadius: 3)
                                                .fill(AppColors.brandGreen)
                                                .frame(width: 22, height: 12)
                                            Text("Income Required")
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                        }
                                    }
                                    .padding(.top, 4)
                                    // Table below the legend
                                    VStack(spacing: 4) {
                                        HStack {
                                            Text("Period")
                                                .font(.caption.bold())
                                                .frame(minWidth: 60, alignment: .leading)
                                            Spacer()
                                            Text("Spending")
                                                .font(.caption.bold())
                                                .frame(minWidth: 60, alignment: .trailing)
                                            Text("Income Required")
                                                .font(.caption.bold())
                                                .frame(minWidth: 80, alignment: .trailing)
                                        }
                                        ForEach(incomeSpendingTableData, id: \.label) { row in
                                            HStack {
                                                Text(row.label)
                                                    .font(.caption)
                                                    .frame(minWidth: 60, alignment: .leading)
                                                Spacer()
                                                Text(row.spending, format: .currency(code: preferredCurrency).precision(.fractionLength(0)))
                                                    .font(.caption)
                                                    .foregroundColor(AppColors.brandRed)
                                                    .frame(minWidth: 60, alignment: .trailing)
                                                Text(row.income, format: .currency(code: preferredCurrency).precision(.fractionLength(0)))
                                                    .font(.caption)
                                                    .foregroundColor(AppColors.brandGreen)
                                                    .frame(minWidth: 80, alignment: .trailing)
                                            }
                                        }
                                    }
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
                                        SpendingDiversityDonutChartView(data: spendingDiversityData, preferredCurrency: preferredCurrency)
                                    }
                                    .padding(.bottom, 24)
                                }
                            }
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
                    // Transaction List (separate from title)
                    VStack(spacing: 12) {
                        ForEach(Transaction.makeMockData().prefix(5), id: \ .id) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                    }
                    .padding(.bottom, 24)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
            }
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
        let spending: Double // rough spending for the period
    }
    struct BarGroup: Identifiable {
        let id: String
        let type: String
        let label: String
        let value: Double
    }
    let data: [IncomeData]
    let barColor: Color
    var body: some View {
        let groupedData: [BarGroup] = data.flatMap { item in
            [
                BarGroup(id: "Spending-\(item.label)", type: "Spending", label: item.label, value: item.spending),
                BarGroup(id: "Income-\(item.label)", type: "Income", label: item.label, value: item.value)
            ]
        }
        Chart(groupedData, id: \.id) { bar in
            BarMark(
                x: .value("Period", bar.label),
                y: .value(bar.type, bar.value)
            )
            .foregroundStyle(bar.type == "Spending" ? AppColors.brandRed : barColor)
            .cornerRadius(4)
            .position(by: .value("Type", bar.type))
        }
        .chartYAxis {
            let maxValue = max(data.map { max($0.value, $0.spending) }.max() ?? 1, 1)
            let step = maxValue > 10000 ? 5000.0 : (maxValue > 1000 ? 1000.0 : (maxValue > 100 ? 100.0 : 10.0))
            let ticks = Array(stride(from: 0.0, through: maxValue, by: step))
            AxisMarks(position: .leading, values: ticks) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel(format: FloatingPointFormatStyle<Double>().precision(.fractionLength(0)))
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel()
            }
        }
        .chartYScale(domain: 0...max(data.map { max($0.value, $0.spending) }.max() ?? 1, 1))
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
        let selected = viewModel.selectedCategory ?? viewModel.categories.first
        let avgSpentString = data.first(where: { $0.category == selected?.name })?.avgSpent.formatted(.currency(code: preferredCurrency).precision(.fractionLength(0))) ?? ""
        let legendText = avgSpentString.isEmpty ? "" : "Avg spent: \(avgSpentString)/mo"
        return VStack(alignment: .leading, spacing: 6) {
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
