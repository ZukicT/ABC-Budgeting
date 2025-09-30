//
//  LoanView.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Main loan management view displaying loan list with filtering, tracking,
//  and CRUD operations. Handles loan display, category filtering, payment
//  tracking, and navigation to loan detail and edit views.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct LoanView: View {
    @ObservedObject var viewModel: LoanViewModel
    @ObservedObject var dataClearingService: DataClearingService
    @ObservedObject var budgetViewModel: BudgetViewModel
    @ObservedObject var transactionViewModel: TransactionViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var showSettings = false
    @State private var showNotifications = false
    @State private var showAddView = false
    @State private var selectedLoan: Loan?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
                contentSection
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .background(Constants.Colors.backgroundPrimary)
            .onAppear {
                // Only load if data hasn't been loaded yet to prevent loading on every tab switch
                if !viewModel.hasDataLoaded {
                    viewModel.loadLoans()
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(dataClearingService: dataClearingService)
            }
            .sheet(isPresented: $showNotifications) {
                NotificationView()
            }
            .sheet(isPresented: $showAddView) {
                AddView(loanViewModel: viewModel, budgetViewModel: budgetViewModel, transactionViewModel: transactionViewModel)
            }
            .sheet(item: $selectedLoan) { loan in
                LoanDetailView(loan: loan, viewModel: viewModel)
                    .presentationDetents([.height(550), .medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(20)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            // Header with title and total counter
            HStack(alignment: .center) {
                // Title only
                Text(contentManager.localizedString("tab.loans"))
                    .font(Constants.Typography.H1.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
            }
            .padding(.top, -Constants.UI.Spacing.medium)
            
            // Category Filter
            LoanCategoryFilterView(selectedCategory: $viewModel.selectedCategory)
        }
        .padding(Constants.UI.Padding.screenMargin)
        .background(Constants.Colors.backgroundPrimary)
    }
    
    // MARK: - Content Section
    private var contentSection: some View {
        Group {
            if viewModel.isLoading {
                LoadingStateView(message: contentManager.localizedString("loan.loading"))
            } else if let errorMessage = viewModel.errorMessage {
                ErrorStateView(message: errorMessage) {
                    viewModel.loadLoans()
                }
            } else if viewModel.loans.isEmpty {
                LoanEmptyState {
                    showAddView = true
                }
            } else {
                ScrollView {
                    loanContent
                        .padding(Constants.UI.Padding.screenMargin)
                }
            }
        }
    }
    
    // MARK: - Loan Content
    private var loanContent: some View {
        VStack(spacing: Constants.UI.Spacing.large) {
            // Loan Summary Section
            LoanSummarySection(viewModel: viewModel)
            
            // Mobile-Optimized Loan List
            loanListSection
        }
    }
    
    // MARK: - Loan List Section
    private var loanListSection: some View {
        VStack(spacing: 0) {
            // Table Header
            LoanTableHeader(loanCount: viewModel.filteredLoans.count)
            
            // Mobile-Optimized Rows
            LazyVStack(spacing: 0) {
                ForEach(Array(viewModel.filteredLoans.enumerated()), id: \.element.id) { index, loan in
                    Button(action: {
                        selectedLoan = loan
                    }) {
                        MobileLoanRow(loan: loan, isEven: index % 2 == 0)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .background(Constants.Colors.backgroundPrimary)
        .cornerRadius(Constants.UI.cardCornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .stroke(Constants.Colors.textPrimary.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Toolbar Content
    private var toolbarContent: some ToolbarContent {
        Group {
            // Plus Button - Left Side
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showAddView = true
                }) {
                    Image(systemName: "plus")
                        .accessibilityLabel(contentManager.localizedString("accessibility.add_loan"))
                }
            }
            
            // Notifications and Settings - Right Side
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Notifications Button
                Button(action: {
                    showNotifications = true
                }) {
                    Image(systemName: "bell")
                        .accessibilityLabel("Notifications")
                }
                
                // Settings Button
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .accessibilityLabel("Settings")
                }
            }
        }
    }
}


// MARK: - Enhanced Loan Summary Section
private struct LoanSummarySection: View {
    let viewModel: LoanViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            // Primary Focus: Total Debt
            VStack(spacing: 8) {
                Text(contentManager.localizedString("loan.total_debt"))
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(viewModel.formattedTotalDebt)
                    .font(Constants.Typography.H1.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            
            // Secondary Information Row
            HStack(spacing: 24) {
                // Monthly Payment
                VStack(spacing: 6) {
                    Text(contentManager.localizedString("loan.monthly_payment"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text(viewModel.formattedTotalMonthlyPayment)
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(Constants.Colors.error)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(Constants.Colors.textPrimary.opacity(0.2))
                    .frame(width: 1, height: 40)
                
                // Next Payment Due
                VStack(spacing: 6) {
                    Text(contentManager.localizedString("loan.next_due"))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    if let nextDue = viewModel.nextDueDate {
                        Text(nextDue, format: .dateTime.month(.abbreviated).day().year(.twoDigits))
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text(contentManager.localizedString("loan.na"))
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .fill(Constants.Colors.textPrimary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                        .stroke(Constants.Colors.textPrimary.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Status Tag (using shared component)
// StatusTag is now imported from Shared/Components/StatusTag.swift

// MARK: - Loan Card
private struct LoanCard: View {
    let loan: Loan
    
    private var loanTypeColor: Color {
        loan.category.color
    }
    
    private var loanTypeIcon: String {
        switch loan.category {
        case .auto:
            return "car.fill"
        case .student:
            return "graduationcap.fill"
        case .creditCard:
            return "creditcard.fill"
        case .mortgage:
            return "house.fill"
        case .personal:
            return "person.fill"
        case .other:
            return "doc.text.fill"
        }
    }
    
    private var currentStatus: LoanPaymentStatus {
        loan.calculatedStatus
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.small) {
            // Top Row: Icon, Name, Status Tag, and Remaining Amount
            HStack(spacing: Constants.UI.Spacing.medium) {
                // Loan Type Icon
                ZStack {
                    RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                        .fill(Constants.Colors.cleanBlack)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: loanTypeIcon)
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(.white)
                }
                .accessibilityHidden(true)
                
                // Loan Name and Status Tag
                VStack(alignment: .leading, spacing: 4) {
                    Text(loan.name)
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    StatusTag(status: currentStatus)
                }
                
                Spacer()
                
                // Remaining Amount - Most Prominent
                Text(loan.remainingAmount, format: .currency(code: "USD"))
                    .font(Constants.Typography.Mono.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            
            // Bottom Row: Details and Monthly Payment
            HStack(spacing: Constants.UI.Spacing.medium) {
                // Loan Details
                HStack(spacing: 6) {
                    Text("\\(loan.interestRate, specifier: \"%.1f\")% \\(contentManager.localizedString(\"loan.apr\"))")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text("•")
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textTertiary)
                    
                    Text(loan.dueDate, format: .dateTime.month(.abbreviated).day().year(.twoDigits))
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
                
                // Monthly Payment
                Text("\\(loan.monthlyPayment, format: .currency(code: \"USD\"))\\(contentManager.localizedString(\"loan.per_month\"))")
                    .font(Constants.Typography.Mono.Caption.font)
                    .foregroundColor(Constants.Colors.error)
            }
        }
        .padding(Constants.UI.Padding.cardInternal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(loan.name) loan: \(loan.remainingAmount, format: .currency(code: "USD")) remaining, monthly payment \(loan.monthlyPayment, format: .currency(code: "USD"))")
    }
}

// MARK: - Enhanced Table Components

private struct LoanTableHeader: View {
    let loanCount: Int
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        HStack {
            Text(contentManager.localizedString("loan.loans"))
                .font(Constants.Typography.Caption.font)
                .foregroundColor(Constants.Colors.textSecondary)
            
            Spacer()
            
            Text("\(loanCount) \(contentManager.localizedString("budget.total"))")
                .font(Constants.Typography.Caption.font)
                .foregroundColor(Constants.Colors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Constants.Colors.textPrimary.opacity(0.05))
    }
}

private struct MobileLoanRow: View {
    let loan: Loan
    let isEven: Bool
    
    private var loanTypeColor: Color {
        loan.category.color
    }
    
    private var loanTypeIcon: String {
        switch loan.category {
        case .auto:
            return "car.fill"
        case .student:
            return "graduationcap.fill"
        case .creditCard:
            return "creditcard.fill"
        case .mortgage:
            return "house.fill"
        case .personal:
            return "person.fill"
        case .other:
            return "doc.text.fill"
        }
    }
    
    private var currentStatus: LoanPaymentStatus {
        loan.calculatedStatus
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Top Row: Icon, Name, and Status
            HStack(spacing: 12) {
                // Loan Type Icon
                ZStack {
                    RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                        .fill(Constants.Colors.cleanBlack)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: loanTypeIcon)
                        .font(Constants.Typography.H3.font)
                        .foregroundColor(.white)
                }
                
                // Loan Name and Status
                VStack(alignment: .leading, spacing: 4) {
                    Text(loan.name)
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    StatusTag(status: currentStatus)
                }
                
                Spacer()
                
                // Remaining Amount (Most Important)
                VStack(alignment: .trailing, spacing: 2) {
                    Text("budget.remaining".localized)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(loan.remainingAmount, format: .currency(code: "USD"))
                        .font(Constants.Typography.Mono.H3.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            
            // Bottom Row: Monthly Payment and Due Date
            HStack {
                // Monthly Payment
                VStack(alignment: .leading, spacing: 2) {
                    Text("loan.monthly_payment".localized)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(loan.monthlyPayment, format: .currency(code: "USD"))
                        .font(Constants.Typography.Mono.Body.font)
                        .foregroundColor(Constants.Colors.error)
                }
                
                Spacer()
                
                // Due Date
                VStack(alignment: .trailing, spacing: 2) {
                    Text("loan.due_date".localized)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(loan.dueDate, format: .dateTime.month(.abbreviated).day().year(.twoDigits))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            isEven ? Constants.Colors.backgroundPrimary : Constants.Colors.textPrimary.opacity(0.08)
        )
        .overlay(
            Rectangle()
                .fill(Constants.Colors.textPrimary.opacity(0.05))
                .frame(height: 0.5),
            alignment: .bottom
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(loan.name), \(loan.remainingAmount, format: .currency(code: "USD")) remaining, \(currentStatus.displayName) status, due \(loan.dueDate, format: .dateTime.month(.abbreviated).day().year(.twoDigits))")
    }
}

#Preview {
    LoanView(
        viewModel: LoanViewModel(), 
        dataClearingService: DataClearingService(),
        budgetViewModel: BudgetViewModel(),
        transactionViewModel: TransactionViewModel()
    )
}
