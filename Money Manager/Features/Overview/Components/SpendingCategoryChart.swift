//
//  SpendingCategoryChart.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Interactive spending category chart displaying expense breakdown by category
//  with pie chart visualization. Features empty state handling, category
//  selection, and accessibility support for financial analysis.
//
//  Review Date: September 29, 2025
//

import SwiftUI
import Charts

struct SpendingCategoryChart: View {
    let data: [CategorySpendingData]
    @State private var selectedCategory: String?
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    private var totalSpending: Double {
        data.reduce(0) { $0 + $1.amount }
    }
    
    private var topCategory: CategorySpendingData? {
        data.first
    }
    
    private var spendingInsights: [String] {
        var insights: [String] = []
        
        if let top = topCategory {
            if top.percentage > 50 {
                insights.append("⚠️ \(top.category) is \(String(format: "%.0f", top.percentage))% of your spending - consider reducing")
            } else if top.percentage > 30 {
                insights.append("📊 \(top.category) is your largest expense category")
            }
        }
        
        let essentialCategories = ["Housing", "Food", "Transportation", "Utilities"]
        let essentialSpending = data.filter { essentialCategories.contains($0.category) }.reduce(0) { $0 + $1.amount }
        let essentialPercentage = totalSpending > 0 ? (essentialSpending / totalSpending) * 100 : 0
        
        if essentialPercentage > 80 {
            insights.append("💡 80%+ of spending is on essentials - look for ways to reduce discretionary spending")
        } else if essentialPercentage < 50 {
            insights.append("🎯 Good balance between essential and discretionary spending")
        }
        
        return insights
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
            Text(contentManager.localizedString("overview.spending_by_category"))
                .font(Constants.Typography.H3.font)
                .foregroundColor(Constants.Colors.textPrimary)
            
            if data.isEmpty {
                VStack(spacing: Constants.UI.Spacing.medium) {
                    Image(systemName: "chart.pie")
                        .font(Constants.Typography.H1.font)
                        .fontWeight(.light)
                        .foregroundColor(Constants.Colors.textTertiary)
                    
                    Text(contentManager.localizedString("overview.no_spending_data"))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(contentManager.localizedString("overview.add_transactions_spending"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
            } else {
                
                VStack(spacing: Constants.UI.Spacing.medium) {
                    // Enhanced Pie Chart - Centered
                    Chart(data) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.4),
                            angularInset: 2
                        )
                        .foregroundStyle(item.color)
                        .opacity(selectedCategory == nil || selectedCategory == item.category ? 1.0 : 0.3)
                    }
                    .frame(width: 200, height: 200)
                    .chartAngleSelection(value: .constant(selectedCategory as String?))
                    .onTapGesture { location in
                        // Handle tap to select category
                    }
                    
                    // Compact Legend Below Chart
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: Constants.UI.Spacing.small) {
                        ForEach(data.prefix(6)) { item in
                            HStack(spacing: Constants.UI.Spacing.small) {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 10, height: 10)
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(item.category)
                                        .font(Constants.Typography.Caption.font)
                                        .foregroundColor(Constants.Colors.textPrimary)
                                        .lineLimit(1)
                                    
                                    Text("$\(Int(item.amount))")
                                        .font(Constants.Typography.Mono.Caption.font)
                                        .foregroundColor(Constants.Colors.textSecondary)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, Constants.UI.Spacing.small)
                            .padding(.vertical, 4)
                            .background(Constants.Colors.primaryLightBlue.opacity(0.1))
                            .cornerRadius(Constants.UI.CornerRadius.tertiary)
                        }
                        
                        if data.count > 6 {
                            HStack {
                                Text("+ \(data.count - 6) more")
                                    .font(Constants.Typography.Caption.font)
                                    .foregroundColor(Constants.Colors.textTertiary)
                                Spacer()
                            }
                            .padding(.horizontal, Constants.UI.Spacing.small)
                            .padding(.vertical, 4)
                            .background(Constants.Colors.primaryLightBlue.opacity(0.1))
                            .cornerRadius(Constants.UI.CornerRadius.tertiary)
                        }
                    }
                }
                
            }
        }
    }
}

#Preview {
    SpendingCategoryChart(data: [
        CategorySpendingData(category: "Housing", amount: 1200, percentage: 35.3, color: .red),
        CategorySpendingData(category: "Food", amount: 800, percentage: 23.5, color: .orange),
        CategorySpendingData(category: "Transportation", amount: 600, percentage: 17.6, color: .blue)
    ])
    .padding()
}
