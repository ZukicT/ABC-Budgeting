import SwiftUI

// MARK: - Loans View
struct LoansView: View {
    // MARK: - Properties
    @State private var loans: [LoanItem] = LoanItem.makeMockData()
    @State private var showAddLoan = false
    @State private var selectedLoan: LoanItem? = nil
    @State private var selectedFilter: LoanFilter = .all
    @Binding var searchText: String
    @Binding var isSearching: Bool
    
    // MARK: - Computed Properties
    private var filteredLoans: [LoanItem] {
        var filtered = loans
        
        // Apply status filter
        switch selectedFilter {
        case .all:
            break
        case .active:
            filtered = filtered.filter { $0.status == .active }
        case .paidOff:
            filtered = filtered.filter { $0.status == .paidOff }
        case .overdue:
            filtered = filtered.filter { $0.isOverdue }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { loan in
                loan.name.localizedCaseInsensitiveContains(searchText) ||
                loan.lender.localizedCaseInsensitiveContains(searchText) ||
                loan.loanType.label.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    private var loanSummary: LoanSummary {
        LoanSummary.calculate(from: loans)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                RobinhoodColors.background.ignoresSafeArea()
                
                if loans.isEmpty {
                    emptyStateView
                } else {
                    mainContentView
                }
                
                floatingActionButton
            }
            .sheet(isPresented: $showAddLoan) {
                AddLoanView { newLoan in
                    loans.append(newLoan)
                    showAddLoan = false
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(16)
                .presentationCompactAdaptation(.sheet)
            }
            .sheet(item: $selectedLoan) { loan in
                LoanDetailView(loan: loan) { updatedLoan in
                    if let index = loans.firstIndex(where: { $0.id == updatedLoan.id }) {
                        loans[index] = updatedLoan
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(16)
                .presentationCompactAdaptation(.sheet)
            }
        }
    }
    
    // MARK: - View Components
    
    /// Empty state when no loans exist
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "creditcard.trianglebadge.exclamationmark")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(RobinhoodColors.textSecondary)
            
            VStack(spacing: 8) {
                Text("No Loans Yet")
                    .font(RobinhoodTypography.title2)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                Text("Add your first loan to start tracking your debt and payments")
                    .font(RobinhoodTypography.body)
                    .foregroundColor(RobinhoodColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: { showAddLoan = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Add Loan")
                        .font(RobinhoodTypography.headline)
                }
                .foregroundColor(Color.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(RobinhoodColors.primary)
                .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Main content view with loans list
    private var mainContentView: some View {
        VStack(spacing: 0) {
            // Static header section - fixed at top
            VStack(spacing: 0) {
                headerSection
                filterChipsSection
            }
            .background(RobinhoodColors.background)
            .zIndex(1)
            
            // Scrollable content section
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    contentSection
                }
                .padding(.bottom, 80) // For FAB spacing
            }
            .background(RobinhoodColors.background)
        }
    }
    
    /// Header section with title and subtitle
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Loans")
                        .font(RobinhoodTypography.largeTitle)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Text("Manage your loans and payments")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                }
                
                Spacer()
                
                // Quick stats
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(loans.count)")
                        .font(RobinhoodTypography.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Text("Total Loans")
                        .font(RobinhoodTypography.caption2)
                        .foregroundColor(RobinhoodColors.textSecondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .padding(.bottom, 16)
    }
    
    /// Content section with summary cards and loans list
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Summary Cards
            summaryCardsSection
                .padding(.top, 20)
            
            // Loans List
            loansListSection
                .padding(.top, 16)
        }
        .padding(.horizontal, 16)
    }
    
    /// Summary cards showing loan overview
    private var summaryCardsSection: some View {
        VStack(spacing: 16) {
            // First row - Total Debt (full width)
            SummaryCard(
                title: "Total Debt",
                value: loanSummary.totalDebt.currencyString,
                subtitle: "\(loanSummary.activeLoans) active loans",
                color: RobinhoodColors.error
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Second row - Two equal cards
            HStack(spacing: 12) {
                // Monthly Payments Card
                SummaryCard(
                    title: "Monthly Payments",
                    value: loanSummary.totalMonthlyPayments.currencyString,
                    subtitle: "Due this month",
                    color: RobinhoodColors.warning
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Average Rate Card
                SummaryCard(
                    title: "Avg Interest Rate",
                    value: String(format: "%.1f%%", loanSummary.averageInterestRate),
                    subtitle: "Across all loans",
                    color: RobinhoodColors.primary
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Third row - Next Payment (full width)
            SummaryCard(
                title: "Next Payment",
                value: loanSummary.nextPaymentDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A",
                subtitle: "Due date",
                color: RobinhoodColors.success
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 20)
    }
    
    /// Filter chips for loan status
    private var filterChipsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LoanFilter.allCases) { filter in
                    FilterChip(
                        title: filter.label,
                        isSelected: selectedFilter == filter,
                        count: getFilterCount(for: filter)
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    /// Loans list section
    private var loansListSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredLoans) { loan in
                LoanCard(loan: loan) {
                    selectedLoan = loan
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    /// Floating action button for adding loans
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showAddLoan = true }) {
                    ZStack {
                        Circle()
                            .fill(RobinhoodColors.primary)
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.black)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getFilterCount(for filter: LoanFilter) -> Int {
        switch filter {
        case .all:
            return loans.count
        case .active:
            return loans.filter { $0.status == .active }.count
        case .paidOff:
            return loans.filter { $0.status == .paidOff }.count
        case .overdue:
            return loans.filter { $0.isOverdue }.count
        }
    }
}

// MARK: - Loan Filter
enum LoanFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case paidOff = "Paid Off"
    case overdue = "Overdue"
    
    var id: String { rawValue }
    var label: String { rawValue }
}

// MARK: - Summary Card Component
struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(RobinhoodTypography.caption)
                .foregroundColor(RobinhoodColors.textSecondary)
            
            Text(value)
                .font(RobinhoodTypography.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(RobinhoodTypography.caption2)
                .foregroundColor(RobinhoodColors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RobinhoodColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Filter Chip Component
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(RobinhoodTypography.caption)
                    .fontWeight(.medium)
                
                if count > 0 {
                    Text("\(count)")
                        .font(RobinhoodTypography.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .foregroundColor(isSelected ? Color.black : RobinhoodColors.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? RobinhoodColors.primary : RobinhoodColors.cardBackground)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Loan Card Component
struct LoanCard: View {
    let loan: LoanItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(loan.iconBackground)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: loan.iconName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(loan.iconColor)
                    }
                    
                    // Loan Info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(loan.name)
                                .font(RobinhoodTypography.headline)
                                .foregroundColor(RobinhoodColors.textPrimary)
                            
                            Spacer()
                            
                            Text(loan.currentBalance.currencyString)
                                .font(RobinhoodTypography.headline)
                                .fontWeight(.bold)
                                .foregroundColor(RobinhoodColors.textPrimary)
                        }
                        
                        HStack {
                            Text(loan.lender)
                                .font(RobinhoodTypography.caption)
                                .foregroundColor(RobinhoodColors.textSecondary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(loan.status.color)
                                    .frame(width: 6, height: 6)
                                
                                Text(loan.status.label)
                                    .font(RobinhoodTypography.caption2)
                                    .foregroundColor(loan.status.color)
                            }
                        }
                    }
                }
                
                // Progress Bar
                if loan.status == .active {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Progress")
                                .font(RobinhoodTypography.caption2)
                                .foregroundColor(RobinhoodColors.textTertiary)
                            
                            Spacer()
                            
                            Text(String(format: "%.1f%%", loan.progressPercentage))
                                .font(RobinhoodTypography.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(RobinhoodColors.textSecondary)
                        }
                        
                        ProgressView(value: loan.progressPercentage / 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: RobinhoodColors.primary))
                            .scaleEffect(x: 1, y: 0.5)
                    }
                    .padding(.top, 12)
                }
                
                // Payment Info
                if loan.status == .active {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Monthly Payment")
                                .font(RobinhoodTypography.caption2)
                                .foregroundColor(RobinhoodColors.textTertiary)
                            
                            Text(loan.monthlyPayment.currencyString)
                                .font(RobinhoodTypography.caption)
                                .fontWeight(.medium)
                                .foregroundColor(RobinhoodColors.textSecondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Next Payment")
                                .font(RobinhoodTypography.caption2)
                                .foregroundColor(RobinhoodColors.textTertiary)
                            
                            Text(loan.nextPaymentDate.formatted(date: .abbreviated, time: .omitted))
                                .font(RobinhoodTypography.caption)
                                .fontWeight(.medium)
                                .foregroundColor(loan.isOverdue ? RobinhoodColors.error : RobinhoodColors.textSecondary)
                        }
                    }
                    .padding(.top, 12)
                }
            }
            .padding(16)
            .background(RobinhoodColors.cardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions
extension Double {
    var currencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }
}

#Preview {
    LoansView(searchText: .constant(""), isSearching: .constant(false))
}
