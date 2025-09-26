import SwiftUI

struct LoanView: View {
    @StateObject private var viewModel = LoanViewModel()
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
                viewModel.loadLoans()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showNotifications) {
                NotificationView()
            }
            .sheet(isPresented: $showAddView) {
                AddView(loanViewModel: viewModel, budgetViewModel: BudgetViewModel(), transactionViewModel: TransactionViewModel())
            }
            .sheet(item: $selectedLoan) { loan in
                LoanDetailView(loan: loan, viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Constants.UI.Spacing.medium) {
            // Header with title and total counter
            HStack(alignment: .center) {
                // Title only
                Text("Loans")
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
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    LoadingStateView(message: "Loading loans...")
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorStateView(message: errorMessage) {
                        viewModel.loadLoans()
                    }
                } else if viewModel.loans.isEmpty {
                    LoanBlankStateView {
                        showAddView = true
                    }
                } else {
                    loanContent
                }
            }
            .padding(Constants.UI.Padding.screenMargin)
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
        .cornerRadius(Constants.UI.CornerRadius.secondary)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.secondary)
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
                        .accessibilityLabel("Add Loan")
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
    
    var body: some View {
        VStack(spacing: 20) {
            // Primary Focus: Total Debt
            VStack(spacing: 8) {
                Text("Total Debt")
                    .font(Constants.Typography.Caption.font)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(viewModel.formattedTotalDebt)
                    .font(Constants.Typography.H1.font)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            
            // Secondary Information Row
            HStack(spacing: 24) {
                // Monthly Payment
                VStack(spacing: 6) {
                    Text("Monthly Payment")
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text(viewModel.formattedTotalMonthlyPayment)
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.semibold)
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
                    Text("Next Due")
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    if let nextDue = viewModel.nextDueDate {
                        Text(nextDue, format: .dateTime.month(.abbreviated).day().year(.twoDigits))
                            .font(Constants.Typography.Body.font)
                            .fontWeight(.semibold)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("N/A")
                            .font(Constants.Typography.Body.font)
                            .fontWeight(.medium)
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
            RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.secondary)
                .fill(Constants.Colors.textPrimary.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.secondary)
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
                    Rectangle()
                        .fill(loanTypeColor)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: loanTypeIcon)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .accessibilityHidden(true)
                
                // Loan Name and Status Tag
                VStack(alignment: .leading, spacing: 4) {
                    Text(loan.name)
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    StatusTag(status: currentStatus)
                }
                
                Spacer()
                
                // Remaining Amount - Most Prominent
                Text(loan.remainingAmount, format: .currency(code: "USD"))
                    .font(Constants.Typography.H3.font)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            
            // Bottom Row: Details and Monthly Payment
            HStack(spacing: Constants.UI.Spacing.medium) {
                // Loan Details
                HStack(spacing: 6) {
                    Text("\(loan.interestRate, specifier: "%.1f")% APR")
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.medium)
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
                Text("\(loan.monthlyPayment, format: .currency(code: "USD"))/mo")
                    .font(Constants.Typography.Caption.font)
                    .fontWeight(.semibold)
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
    
    var body: some View {
        HStack {
            Text("LOANS")
                .font(Constants.Typography.Caption.font)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colors.textSecondary)
            
            Spacer()
            
            Text("\(loanCount) total")
                .font(Constants.Typography.Caption.font)
                .fontWeight(.medium)
                .foregroundColor(Constants.Colors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Constants.Colors.textPrimary.opacity(0.08))
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
                        .fill(loanTypeColor)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: loanTypeIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Loan Name and Status
                VStack(alignment: .leading, spacing: 4) {
                    Text(loan.name)
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    StatusTag(status: currentStatus)
                }
                
                Spacer()
                
                // Remaining Amount (Most Important)
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Remaining")
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(loan.remainingAmount, format: .currency(code: "USD"))
                        .font(Constants.Typography.H3.font)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            
            // Bottom Row: Monthly Payment and Due Date
            HStack {
                // Monthly Payment
                VStack(alignment: .leading, spacing: 2) {
                    Text("Monthly Payment")
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(loan.monthlyPayment, format: .currency(code: "USD"))
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.semibold)
                        .foregroundColor(Constants.Colors.error)
                }
                
                Spacer()
                
                // Due Date
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Due Date")
                        .font(Constants.Typography.Caption.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(loan.dueDate, format: .dateTime.month(.abbreviated).day().year(.twoDigits))
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.medium)
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
                .fill(Constants.Colors.textPrimary.opacity(0.08))
                .frame(height: 0.5),
            alignment: .bottom
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(loan.name), \(loan.remainingAmount, format: .currency(code: "USD")) remaining, \(currentStatus.displayName) status, due \(loan.dueDate, format: .dateTime.month(.abbreviated).day().year(.twoDigits))")
    }
}

#Preview {
    LoanView()
}
