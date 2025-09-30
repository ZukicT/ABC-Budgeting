//
//  MonthlyOverviewSection.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Monthly overview section displaying key financial metrics for the current
//  month. Shows income, expenses, and trend indicators with month-over-month
//  comparison and comprehensive financial analysis.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct MonthlyOverviewSection: View {
    @ObservedObject var transactionViewModel: TransactionViewModel
    @StateObject private var viewModel = MonthlyOverviewViewModel()
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    private let monthAbbreviationFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            HStack {
                Text(contentManager.localizedString("chart.monthly_overview"))
                    .font(Constants.Typography.H2.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
            }
            
            if viewModel.isLoading {
                MonthlyOverviewLoadingView()
            } else if let data = viewModel.monthlyData {
                MonthlyOverviewCard(data: data, monthFormatter: monthAbbreviationFormatter)
            } else if let error = viewModel.errorMessage {
                MonthlyOverviewErrorView(error: error)
            } else {
                // Empty state when no data is available
                MonthlyOverviewEmptyView()
            }
        }
        .onAppear {
            // Note: Consider implementing pull-to-refresh functionality
            // Note: Add error retry mechanism for failed data loads
            viewModel.refreshData(transactions: transactionViewModel.transactions)
        }
    }
}

// MARK: - Monthly Overview Card
/// Card component displaying monthly financial metrics in a grid layout
private struct MonthlyOverviewCard: View {
    let data: MonthlyOverviewData
    let monthFormatter: DateFormatter
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            // MARK: - Financial Metrics Grid
            // Two-column grid displaying income and expenses with trend indicators
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: Constants.UI.Spacing.small) {
                // Monthly Income Card
                MetricCard(
                    title: contentManager.localizedString("income.label"),
                    value: data.currentMonth.income,
                    previousValue: data.previousMonth.income,
                    format: .currency,
                    color: Constants.Colors.success,
                    monthDate: data.currentMonth.date,
                    monthFormatter: monthFormatter
                )
                
                // Monthly Expenses Card
                MetricCard(
                    title: contentManager.localizedString("expense.label"),
                    value: data.currentMonth.expenses,
                    previousValue: data.previousMonth.expenses,
                    format: .currency,
                    color: Constants.Colors.error,
                    monthDate: data.currentMonth.date,
                    monthFormatter: monthFormatter
                )
            }
        }
    }
    
}

// MARK: - Monthly Overview Empty View
/// Empty state view when no monthly data is available
private struct MonthlyOverviewEmptyView: View {
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(Constants.Typography.H3.font)
                .fontWeight(.light)
                .foregroundColor(Constants.Colors.textTertiary)
            
            Text(contentManager.localizedString("chart.no_monthly_data"))
                .font(Constants.Typography.Body.font)
                .foregroundColor(Constants.Colors.textSecondary)
            
            Text(contentManager.localizedString("chart.add_transactions_message"))
                .font(Constants.Typography.Caption.font)
                .foregroundColor(Constants.Colors.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.UI.cardCornerRadius)
        .shadow(color: Constants.Colors.borderPrimary, radius: 0)
    }
}

// MARK: - Metric Card
/// Individual metric card displaying title, value, and trend indicator
private struct MetricCard: View {
    let title: String
    let value: Double
    let previousValue: Double
    let format: ValueFormat
    let color: Color
    let monthDate: Date
    let monthFormatter: DateFormatter
    
    /// Supported value formats for display
    enum ValueFormat {
        case currency
        case percentage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
            // MARK: - Card Title with Month
            HStack {
                Text(title)
                    .font(Constants.Typography.BodySmall.font)
                    .foregroundColor(Constants.Colors.textSecondary)
                
                Spacer()
                
                Text(monthFormatter.string(from: monthDate))
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textTertiary)
            }
            
            // MARK: - Card Value with Percentage
            HStack(alignment: .bottom, spacing: Constants.UI.Spacing.micro) {
                Text(formattedValue)
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // Percentage change next to value
                TrendIndicator(
                    currentValue: value,
                    previousValue: previousValue,
                    color: color
                )
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.UI.Spacing.small)
        .background(Constants.Colors.textPrimary.opacity(0.05)) // WCAG AA compliant background
        .cornerRadius(Constants.UI.cardCornerRadius)
    }
    
    /// Formats the value based on the specified format type
    private var formattedValue: String {
        switch format {
        case .currency:
            return currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
        case .percentage:
            return String(format: "%.1f%%", value)
        }
    }
}

// MARK: - Trend Indicator
/// Component showing trend direction and percentage change from previous period
private struct TrendIndicator: View {
    let currentValue: Double
    let previousValue: Double
    let color: Color
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    /// Determines trend direction based on value comparison
    private var trendDirection: TrendDirection {
        if currentValue > previousValue {
            return .up
        } else if currentValue < previousValue {
            return .down
        } else {
            return .neutral
        }
    }
    
    /// Calculates percentage change from previous value
    private var changePercentage: Double {
        guard previousValue != 0 else { 
            // If no previous data, show 100% for any current value > 0
            return currentValue > 0 ? 100.0 : 0.0
        }
        return ((currentValue - previousValue) / abs(previousValue)) * 100
    }
    
    /// Determines if we should show the trend indicator
    private var shouldShowTrend: Bool {
        // Show trend if we have current data, regardless of previous data
        return currentValue > 0 || previousValue > 0
    }
    
    var body: some View {
        if shouldShowTrend {
            HStack(spacing: Constants.UI.Spacing.micro) {
                // Trend triangle icon
                Image(systemName: trendDirection.symbol)
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(color)
                    .rotationEffect(trendDirection.rotation)
                
                // Percentage change text
                Text("\(String(format: "%.1f", abs(changePercentage)))%")
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(color)
            }
        } else {
            // Show "New" indicator when there's current data but no previous data
            Text(contentManager.localizedString("chart.new"))
                .font(Constants.Typography.Caption.font)
                .foregroundColor(color)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(color.opacity(0.1))
                .cornerRadius(Constants.UI.CornerRadius.quaternary)
        }
    }
    
    /// Trend direction enum with associated symbols and colors
    enum TrendDirection {
        case up, down, neutral
        
        /// SF Symbol name for trend direction
        var symbol: String {
            switch self {
            case .up: return "triangle.fill"
            case .down: return "triangle.fill"
            case .neutral: return "minus"
            }
        }
        
        
        /// Rotation angle for triangle direction
        var rotation: Angle {
            switch self {
            case .up: return .degrees(0)
            case .down: return .degrees(180)
            case .neutral: return .degrees(0)
            }
        }
    }
}


// MARK: - Loading View
/// Loading state component displayed while fetching monthly data
private struct MonthlyOverviewLoadingView: View {
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            HStack {
                Text(contentManager.localizedString("chart.loading_monthly"))
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textSecondary)
                
                Spacer()
            }
            
            // Loading spinner with brand color
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.success))
        }
    }
}

// MARK: - Error View
/// Error state component displayed when data loading fails
private struct MonthlyOverviewErrorView: View {
    let error: String
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            HStack {
                // Error icon
                Image(systemName: "exclamationmark.triangle")
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.error)
                
                Text(contentManager.localizedString("chart.failed_load"))
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
            }
            
            // Error details
            Text(error)
                .font(Constants.Typography.Caption.font)
                .foregroundColor(Constants.Colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Formatters
/// Currency formatter for displaying monetary values
private let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.maximumFractionDigits = 0
    return formatter
}()



#Preview {
    MonthlyOverviewSection(transactionViewModel: TransactionViewModel())
        .padding()
        .background(Constants.Colors.backgroundPrimary)
}
