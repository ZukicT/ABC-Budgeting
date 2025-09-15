import SwiftUI
import Charts

// MARK: - Loan Detail View
struct LoanDetailView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    let loan: LoanItem
    let onUpdate: (LoanItem) -> Void
    
    @State private var payments: [LoanPayment] = []
    @State private var showEditLoan = false
    @State private var showAddPayment = false
    @State private var selectedTimeframe: PaymentTimeframe = .all
    
    // MARK: - Computed Properties
    private var filteredPayments: [LoanPayment] {
        switch selectedTimeframe {
        case .all:
            return payments
        case .last3Months:
            let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
            return payments.filter { $0.paymentDate >= threeMonthsAgo }
        case .last6Months:
            let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
            return payments.filter { $0.paymentDate >= sixMonthsAgo }
        case .lastYear:
            let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
            return payments.filter { $0.paymentDate >= oneYearAgo }
        }
    }
    
    private var totalPaid: Double {
        payments.reduce(0) { $0 + $1.amount }
    }
    
    private var totalPrincipal: Double {
        payments.reduce(0) { $0 + $1.principalAmount }
    }
    
    private var totalInterest: Double {
        payments.reduce(0) { $0 + $1.interestAmount }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                RobinhoodColors.background.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Header Card
                        headerCard
                            .padding(.top, 20)
                        
                        // Progress Section
                        if loan.status == .active {
                            progressSection
                                .padding(.top, 24)
                        }
                        
                        // Payment History Section
                        paymentHistorySection
                            .padding(.top, 24)
                        
                        // Payment Chart Section
                        if !payments.isEmpty {
                            paymentChartSection
                                .padding(.top, 24)
                        }
                        
                        // Loan Details Section
                        loanDetailsSection
                            .padding(.top, 24)
                    }
                    .padding(.bottom, 100) // For FAB spacing
                }
            }
            .navigationTitle(loan.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(RobinhoodColors.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button("Edit") {
                            showEditLoan = true
                        }
                        .foregroundColor(RobinhoodColors.primary)
                        
                        if loan.status == .active {
                            Button("Add Payment") {
                                showAddPayment = true
                            }
                            .foregroundColor(RobinhoodColors.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showEditLoan) {
                EditLoanView(loan: loan) { updatedLoan in
                    onUpdate(updatedLoan)
                    showEditLoan = false
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(16)
                .presentationCompactAdaptation(.sheet)
            }
            .sheet(isPresented: $showAddPayment) {
                AddPaymentView(loan: loan) { newPayment in
                    payments.append(newPayment)
                    showAddPayment = false
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(16)
                .presentationCompactAdaptation(.sheet)
            }
            .onAppear {
                loadPayments()
            }
        }
    }
    
    // MARK: - View Components
    
    /// Header card with loan overview
    private var headerCard: some View {
        VStack(spacing: 16) {
            // Icon and Basic Info
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(loan.iconBackground)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: loan.iconName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(loan.iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(loan.name)
                        .font(RobinhoodTypography.title2)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Text(loan.lender)
                        .font(RobinhoodTypography.body)
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(loan.status.color)
                            .frame(width: 8, height: 8)
                        
                        Text(loan.status.label)
                            .font(RobinhoodTypography.caption)
                            .foregroundColor(loan.status.color)
                    }
                }
                
                Spacer()
            }
            
            // Financial Overview
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Balance")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    Text(loan.currentBalance.currencyString)
                        .font(RobinhoodTypography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(RobinhoodColors.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Monthly Payment")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    Text(loan.monthlyPayment.currencyString)
                        .font(RobinhoodTypography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(RobinhoodColors.textPrimary)
                }
            }
            
            // Interest Rate
            HStack {
                Text("Interest Rate")
                    .font(RobinhoodTypography.caption)
                    .foregroundColor(RobinhoodColors.textSecondary)
                
                Spacer()
                
                Text(String(format: "%.2f%%", loan.interestRate))
                    .font(RobinhoodTypography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(RobinhoodColors.primary)
            }
        }
        .padding(20)
        .background(RobinhoodColors.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    /// Progress section for active loans
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress")
                .font(RobinhoodTypography.title3)
                .foregroundColor(RobinhoodColors.textPrimary)
                .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                // Progress Bar
                VStack(spacing: 8) {
                    HStack {
                        Text("Paid Off")
                            .font(RobinhoodTypography.caption)
                            .foregroundColor(RobinhoodColors.textSecondary)
                        
                        Spacer()
                        
                        Text(String(format: "%.1f%%", loan.progressPercentage))
                            .font(RobinhoodTypography.caption)
                            .fontWeight(.medium)
                            .foregroundColor(RobinhoodColors.textSecondary)
                    }
                    
                    ProgressView(value: loan.progressPercentage / 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: RobinhoodColors.primary))
                        .scaleEffect(x: 1, y: 0.5)
                }
                
                // Progress Stats
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Original Amount")
                            .font(RobinhoodTypography.caption2)
                            .foregroundColor(RobinhoodColors.textTertiary)
                        
                        Text(loan.originalAmount.currencyString)
                            .font(RobinhoodTypography.caption)
                            .fontWeight(.medium)
                            .foregroundColor(RobinhoodColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("Total Paid")
                            .font(RobinhoodTypography.caption2)
                            .foregroundColor(RobinhoodColors.textTertiary)
                        
                        Text(loan.totalPaid.currencyString)
                            .font(RobinhoodTypography.caption)
                            .fontWeight(.medium)
                            .foregroundColor(RobinhoodColors.success)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Remaining")
                            .font(RobinhoodTypography.caption2)
                            .foregroundColor(RobinhoodColors.textTertiary)
                        
                        Text(loan.currentBalance.currencyString)
                            .font(RobinhoodTypography.caption)
                            .fontWeight(.medium)
                            .foregroundColor(RobinhoodColors.error)
                    }
                }
                
                // Next Payment Info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Next Payment")
                            .font(RobinhoodTypography.caption)
                            .foregroundColor(RobinhoodColors.textSecondary)
                        
                        Text(loan.nextPaymentDate.formatted(date: .abbreviated, time: .omitted))
                            .font(RobinhoodTypography.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(loan.isOverdue ? RobinhoodColors.error : RobinhoodColors.textPrimary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Days Remaining")
                            .font(RobinhoodTypography.caption)
                            .foregroundColor(RobinhoodColors.textSecondary)
                        
                        Text("\(loan.daysUntilNextPayment)")
                            .font(RobinhoodTypography.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(loan.isOverdue ? RobinhoodColors.error : RobinhoodColors.primary)
                    }
                }
            }
            .padding(20)
            .background(RobinhoodColors.cardBackground)
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
    }
    
    /// Payment history section
    private var paymentHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Payment History")
                    .font(RobinhoodTypography.title3)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                Spacer()
                
                if !payments.isEmpty {
                    Menu {
                        ForEach(PaymentTimeframe.allCases) { timeframe in
                            Button(action: {
                                selectedTimeframe = timeframe
                            }) {
                                HStack {
                                    Text(timeframe.label)
                                    if selectedTimeframe == timeframe {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedTimeframe.label)
                                .font(RobinhoodTypography.caption)
                                .foregroundColor(RobinhoodColors.primary)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(RobinhoodColors.primary)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            if payments.isEmpty {
                emptyPaymentsView
            } else {
                paymentsListView
            }
        }
    }
    
    /// Empty payments view
    private var emptyPaymentsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.trianglebadge.exclamationmark")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(RobinhoodColors.textSecondary)
            
            Text("No Payments Recorded")
                .font(RobinhoodTypography.headline)
                .foregroundColor(RobinhoodColors.textPrimary)
            
            Text("Add your first payment to start tracking your loan progress")
                .font(RobinhoodTypography.body)
                .foregroundColor(RobinhoodColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if loan.status == .active {
                Button(action: { showAddPayment = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Add Payment")
                            .font(RobinhoodTypography.caption)
                    }
                    .foregroundColor(Color.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(RobinhoodColors.primary)
                    .cornerRadius(8)
                }
            }
        }
        .padding(40)
        .background(RobinhoodColors.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    /// Payments list view
    private var paymentsListView: some View {
        VStack(spacing: 0) {
            ForEach(filteredPayments.sorted(by: { $0.paymentDate > $1.paymentDate })) { payment in
                PaymentRow(payment: payment)
                
                if payment.id != filteredPayments.last?.id {
                    Divider()
                        .background(RobinhoodColors.border)
                        .padding(.horizontal, 20)
                }
            }
        }
        .background(RobinhoodColors.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
    
    /// Payment chart section
    private var paymentChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Breakdown")
                .font(RobinhoodTypography.title3)
                .foregroundColor(RobinhoodColors.textPrimary)
                .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                // Chart
                if #available(iOS 16.0, *) {
                    PaymentBreakdownChart(payments: filteredPayments)
                        .frame(height: 200)
                }
                
                // Summary Stats
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Paid")
                            .font(RobinhoodTypography.caption2)
                            .foregroundColor(RobinhoodColors.textTertiary)
                        
                        Text(totalPaid.currencyString)
                            .font(RobinhoodTypography.headline)
                            .fontWeight(.bold)
                            .foregroundColor(RobinhoodColors.success)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 4) {
                        Text("Principal")
                            .font(RobinhoodTypography.caption2)
                            .foregroundColor(RobinhoodColors.textTertiary)
                        
                        Text(totalPrincipal.currencyString)
                            .font(RobinhoodTypography.caption)
                            .fontWeight(.medium)
                            .foregroundColor(RobinhoodColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Interest")
                            .font(RobinhoodTypography.caption2)
                            .foregroundColor(RobinhoodColors.textTertiary)
                        
                        Text(totalInterest.currencyString)
                            .font(RobinhoodTypography.caption)
                            .fontWeight(.medium)
                            .foregroundColor(RobinhoodColors.error)
                    }
                }
            }
            .padding(20)
            .background(RobinhoodColors.cardBackground)
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
    }
    
    /// Loan details section
    private var loanDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Loan Details")
                .font(RobinhoodTypography.title3)
                .foregroundColor(RobinhoodColors.textPrimary)
                .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                DetailRow(title: "Loan Type", value: loan.loanType.label)
                DetailRow(title: "Start Date", value: loan.startDate.formatted(date: .abbreviated, time: .omitted))
                DetailRow(title: "End Date", value: loan.endDate.formatted(date: .abbreviated, time: .omitted))
                DetailRow(title: "Remaining Payments", value: "\(loan.remainingPayments)")
                
                if let notes = loan.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(RobinhoodTypography.caption)
                            .foregroundColor(RobinhoodColors.textSecondary)
                        
                        Text(notes)
                            .font(RobinhoodTypography.body)
                            .foregroundColor(RobinhoodColors.textPrimary)
                    }
                }
            }
            .padding(20)
            .background(RobinhoodColors.cardBackground)
            .cornerRadius(16)
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadPayments() {
        payments = LoanPayment.makeMockData(for: loan.id)
    }
}

// MARK: - Payment Timeframe
enum PaymentTimeframe: String, CaseIterable, Identifiable {
    case all = "All"
    case last3Months = "Last 3 Months"
    case last6Months = "Last 6 Months"
    case lastYear = "Last Year"
    
    var id: String { rawValue }
    var label: String { rawValue }
}

// MARK: - Payment Row Component
struct PaymentRow: View {
    let payment: LoanPayment
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(payment.paymentDate.formatted(date: .abbreviated, time: .omitted))
                    .font(RobinhoodTypography.caption)
                    .foregroundColor(RobinhoodColors.textSecondary)
                
                Text(payment.amount.currencyString)
                    .font(RobinhoodTypography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(RobinhoodColors.textPrimary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 12) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Principal")
                            .font(RobinhoodTypography.caption2)
                            .foregroundColor(RobinhoodColors.textTertiary)
                        
                        Text(payment.principalAmount.currencyString)
                            .font(RobinhoodTypography.caption)
                            .fontWeight(.medium)
                            .foregroundColor(RobinhoodColors.textSecondary)
                    }
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Interest")
                            .font(RobinhoodTypography.caption2)
                            .foregroundColor(RobinhoodColors.textTertiary)
                        
                        Text(payment.interestAmount.currencyString)
                            .font(RobinhoodTypography.caption)
                            .fontWeight(.medium)
                            .foregroundColor(RobinhoodColors.error)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(RobinhoodTypography.caption)
                .foregroundColor(RobinhoodColors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(RobinhoodTypography.caption)
                .fontWeight(.medium)
                .foregroundColor(RobinhoodColors.textPrimary)
        }
    }
}

// MARK: - Payment Breakdown Chart (iOS 16+)
@available(iOS 16.0, *)
struct PaymentBreakdownChart: View {
    let payments: [LoanPayment]
    
    var body: some View {
        Chart {
            ForEach(payments.sorted(by: { $0.paymentDate < $1.paymentDate })) { payment in
                BarMark(
                    x: .value("Date", payment.paymentDate),
                    y: .value("Amount", payment.principalAmount)
                )
                .foregroundStyle(RobinhoodColors.success)
                
                BarMark(
                    x: .value("Date", payment.paymentDate),
                    y: .value("Amount", payment.interestAmount)
                )
                .foregroundStyle(RobinhoodColors.error)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(amount.currencyString)
                            .font(RobinhoodTypography.caption2)
                            .foregroundColor(RobinhoodColors.textSecondary)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date.formatted(.dateTime.month(.abbreviated).day()))
                            .font(RobinhoodTypography.caption2)
                            .foregroundColor(RobinhoodColors.textSecondary)
                    }
                }
            }
        }
    }
}

#Preview {
    LoanDetailView(
        loan: LoanItem.makeMockData().first!,
        onUpdate: { _ in }
    )
}
