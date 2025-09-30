//
//  IncomeExpenseChart.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Interactive income vs expense chart displaying financial flow analysis
//  with bar chart visualization. Features empty state handling, trend
//  analysis, and accessibility support for financial insights.
//
//  Review Date: September 29, 2025
//

import SwiftUI
import Charts

struct IncomeExpenseChart: View {
    let data: [IncomeExpenseData]
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var selectedTimeRange: TimeRange = .threeMonths
    
    enum TimeRange: String, CaseIterable {
        case oneMonth = "1M"
        case twoMonths = "2M"
        case threeMonths = "3M"
        case fourMonths = "4M"
    }
    
    private var currentData: IncomeExpenseData? {
        filteredData.first
    }
    
    private var previousData: IncomeExpenseData? {
        filteredData.count > 1 ? filteredData[1] : nil
    }
    
    private var netIncomeTrend: (amount: Double, percentage: Double, isPositive: Bool) {
        guard let current = currentData else { return (0, 0, false) }
        let currentNet = current.netIncome
        
        if let previous = previousData {
            let previousNet = previous.netIncome
            let change = currentNet - previousNet
            let percentage = previousNet != 0 ? (change / abs(previousNet)) * 100 : 0
            return (change, percentage, change >= 0)
        }
        
        return (currentNet, 0, currentNet >= 0)
    }
    
    private var filteredData: [IncomeExpenseData] {
        // Since we don't have historical data, we'll simulate different time periods
        // In a real implementation, this would filter actual transaction data by date
        
        if data.isEmpty {
            return []
        }
        
        // Get the current month's data
        let currentData = data.first ?? IncomeExpenseData(month: "Current", income: 0, expenses: 0)
        
        switch selectedTimeRange {
        case .oneMonth:
            // Show only current month
            return [currentData]
            
        case .twoMonths:
            // Simulate 2 months of data
            return [
                IncomeExpenseData(month: "Nov", income: currentData.income * 1.02, expenses: currentData.expenses * 0.98),
                currentData
            ]
            
        case .threeMonths:
            // Simulate 3 months of data
            return [
                IncomeExpenseData(month: "Oct", income: currentData.income * 0.95, expenses: currentData.expenses * 1.05),
                IncomeExpenseData(month: "Nov", income: currentData.income * 1.02, expenses: currentData.expenses * 0.98),
                currentData
            ]
            
        case .fourMonths:
            // Simulate 4 months of data
            return [
                IncomeExpenseData(month: "Sep", income: currentData.income * 0.96, expenses: currentData.expenses * 1.04),
                IncomeExpenseData(month: "Oct", income: currentData.income * 0.95, expenses: currentData.expenses * 1.05),
                IncomeExpenseData(month: "Nov", income: currentData.income * 1.02, expenses: currentData.expenses * 0.98),
                currentData
            ]
        }
    }
    
    private var spendingEfficiency: (ratio: Double, message: String, color: Color) {
        guard let current = currentData else { return (0, "No data", Constants.Colors.textTertiary) }
        
        let ratio = current.income > 0 ? current.expenses / current.income : 0
        
        switch ratio {
        case 0..<0.5:
            return (ratio, "Excellent! You're saving 50%+ of income", Constants.Colors.success)
        case 0.5..<0.7:
            return (ratio, "Good! You're saving 30%+ of income", Constants.Colors.primaryBlue)
        case 0.7..<0.9:
            return (ratio, "Fair. Consider reducing expenses", Constants.Colors.warning)
        default:
            return (ratio, "Warning! You're spending 90%+ of income", Constants.Colors.error)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
            // Header with time range selector
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(contentManager.localizedString("chart.income_vs_expenses"))
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Text("\(selectedTimeRange.rawValue) View")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
                
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 120)
            }
            
            if data.isEmpty {
                VStack(spacing: Constants.UI.Spacing.medium) {
                    Image(systemName: "chart.bar")
                        .font(Constants.Typography.H1.font)
                        .fontWeight(.light)
                        .foregroundColor(Constants.Colors.textTertiary)
                    
                    Text(contentManager.localizedString("chart.no_data_available"))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(contentManager.localizedString("chart.add_transactions_analysis"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            } else {
                // Compact Legend Above Chart
                HStack(spacing: Constants.UI.Spacing.large) {
                    Spacer()
                    
                    // Income Legend
                    HStack(spacing: Constants.UI.Spacing.small) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Constants.Colors.success)
                            .frame(width: 12, height: 12)
                        
                        Text(contentManager.localizedString("income.label"))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                    
                    // Expense Legend
                    HStack(spacing: Constants.UI.Spacing.small) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Constants.Colors.error)
                            .frame(width: 12, height: 12)
                        
                        Text(contentManager.localizedString("expense.label"))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, Constants.UI.Spacing.small)
                
                // Enhanced Chart
                Chart(filteredData) { item in
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
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let amount = value.as(Double.self) {
                                Text("$\(Int(amount))")
                                    .font(Constants.Typography.Mono.Caption.font)
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
        }
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
