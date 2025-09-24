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
            
            Text("$5,500.00")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Constants.Colors.textPrimary)
            
            // Income/Expense metrics moved here
            VStack(alignment: .leading, spacing: 1) {
                // Income
                HStack(alignment: .center, spacing: 2) {
                    Text("▲")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.success)
                    
                    Text("$3,500")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.success)
                    
                    Text("(+12.5%)")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.success)
                    
                    Text("Jan Income")
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
                    
                    Text("$2,800")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.error)
                    
                    Text("(-8.3%)")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.error)
                    
                    Text("Jan Expenses")
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
                    ForEach(["1D", "1W", "1M", "3M", "YTD", "1Y", "All"], id: \.self) { period in
                        Button(action: {
                            // Time period selection logic
                        }) {
                            Text(period)
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(period == "1M" ? Constants.Colors.backgroundPrimary : Constants.Colors.textPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(period == "1M" ? Constants.Colors.textPrimary : Color.clear)
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
                    RuleMark(y: .value("Baseline", 5500.0))
                        .foregroundStyle(Constants.Colors.textSecondary.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    
                    // Simple line chart with area fill
                    ForEach(sampleData, id: \.id) { dataPoint in
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
                        .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                        
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
        let data = sampleData
        let baseline = 5500.0
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
    
    // Sample data for the chart - balanced above/below baseline
    private var sampleData: [BalanceDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        var data: [BalanceDataPoint] = []
        
        // Create a clear pattern: start high, dip low, recover high
        let pattern: [Double] = [
            6200, 6500, 6800, 7200, 7500,  // High section (green)
            7000, 6000, 4800, 4200, 3800,  // Drop section (red)
            3500, 3200, 3000, 2800, 2600,  // Low section (red)
            3000, 3800, 4500, 5200, 5800,  // Recovery section (green)
            6200, 6800, 7200, 7500, 7800,  // High section (green)
            7000, 6500, 6000, 5500, 5000   // Gradual decline (mixed)
        ]
        
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: now) ?? now
            let balance = pattern[i]
            
            data.append(BalanceDataPoint(date: date, balance: balance))
        }
        
        return data.sorted { $0.date < $1.date }
    }
    
}


#Preview {
    BalanceChartView()
        .padding()
}


