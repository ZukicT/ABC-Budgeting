import SwiftUI

struct LoanDetailView: View {
    let loan: Loan
    @ObservedObject var viewModel: LoanViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var editableLoan: Loan
    
    init(loan: Loan, viewModel: LoanViewModel) {
        self.loan = loan
        self.viewModel = viewModel
        self._editableLoan = State(initialValue: loan)
    }
    
    private var loanTypeColor: Color {
        switch loan.name.lowercased() {
        case let name where name.contains("auto") || name.contains("car"):
            return Constants.Colors.info
        case let name where name.contains("student"):
            return Constants.Colors.success
        case let name where name.contains("credit"):
            return Constants.Colors.error
        case let name where name.contains("home") || name.contains("mortgage"):
            return Constants.Colors.warning
        default:
            return Constants.Colors.textSecondary
        }
    }
    
    private var loanTypeIcon: String {
        switch loan.name.lowercased() {
        case let name where name.contains("auto") || name.contains("car"):
            return "car.fill"
        case let name where name.contains("student"):
            return "graduationcap.fill"
        case let name where name.contains("credit"):
            return "creditcard.fill"
        case let name where name.contains("home") || name.contains("mortgage"):
            return "house.fill"
        default:
            return "doc.text.fill"
        }
    }
    
    private var progressPercentage: Double {
        (loan.principalAmount - loan.remainingAmount) / loan.principalAmount
    }
    
    private var totalPaid: Double {
        loan.principalAmount - loan.remainingAmount
    }
    
    private var estimatedMonthsRemaining: Int {
        guard loan.monthlyPayment > 0 else { return 0 }
        return Int(ceil(loan.remainingAmount / loan.monthlyPayment))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.UI.Spacing.large) {
                    // Header Section
                    VStack(spacing: Constants.UI.Spacing.medium) {
                        // Loan Type Icon
                        ZStack {
                            Circle()
                                .fill(loanTypeColor)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: loanTypeIcon)
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .accessibilityHidden(true)
                        
                        // Loan Name
                        Text(loan.name)
                            .font(Constants.Typography.H1.font)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                        
                        // Remaining Amount
                        Text(loan.remainingAmount, format: .currency(code: "USD"))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(Constants.Colors.textPrimary)
                            .accessibilityLabel("Remaining amount: \(loan.remainingAmount, format: .currency(code: "USD"))")
                    }
                    .padding(.top, Constants.UI.Spacing.large)
                    
                    // Key Metrics Card
                    VStack(spacing: Constants.UI.Spacing.medium) {
                        // Progress Section
                        VStack(spacing: Constants.UI.Spacing.small) {
                            HStack {
                                Text("Progress")
                                    .font(Constants.Typography.H3.font)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Constants.Colors.textPrimary)
                                
                                Spacer()
                                
                                Text("\(Int(progressPercentage * 100))%")
                                    .font(Constants.Typography.H3.font)
                                    .fontWeight(.bold)
                                    .foregroundColor(loanTypeColor)
                            }
                            
                            // Progress Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background
                                    Rectangle()
                                        .fill(Constants.Colors.backgroundTertiary)
                                        .frame(height: 6)
                                        .cornerRadius(Constants.UI.CornerRadius.quaternary)
                                    
                                    // Progress Fill
                                    Rectangle()
                                        .fill(loanTypeColor)
                                        .frame(width: geometry.size.width * progressPercentage, height: 6)
                                        .cornerRadius(Constants.UI.CornerRadius.quaternary)
                                }
                            }
                            .frame(height: 6)
                        }
                        
                        // Payment Status
                        HStack {
                            Text("Payment Status")
                                .font(Constants.Typography.Body.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            Spacer()
                            
                            StatusTag(status: loan.calculatedStatus)
                        }
                    }
                    .padding(.horizontal, Constants.UI.Spacing.medium)
                    .padding(.vertical, Constants.UI.Spacing.medium)
                    .background(Constants.Colors.backgroundSecondary)
                    .cornerRadius(Constants.UI.cardCornerRadius)
                    
                    // Details Section
                    VStack(spacing: Constants.UI.Spacing.medium) {
                        // Principal Amount
                        DetailRow(
                            title: "Principal Amount",
                            value: loan.principalAmount.formatted(.currency(code: "USD")),
                            icon: "dollarsign.circle.fill",
                            iconColor: Constants.Colors.textPrimary
                        )
                        
                        // Total Paid
                        DetailRow(
                            title: "Total Paid",
                            value: totalPaid.formatted(.currency(code: "USD")),
                            icon: "checkmark.circle.fill",
                            iconColor: Constants.Colors.success
                        )
                        
                        // Interest Rate
                        DetailRow(
                            title: "Interest Rate (APR)",
                            value: String(format: "%.2f%%", loan.interestRate),
                            icon: "percent",
                            iconColor: Constants.Colors.warning
                        )
                        
                        // Monthly Payment
                        DetailRow(
                            title: "Monthly Payment",
                            value: loan.monthlyPayment.formatted(.currency(code: "USD")),
                            icon: "calendar",
                            iconColor: Constants.Colors.error
                        )
                        
                        // Due Date
                        DetailRow(
                            title: "Next Payment Due",
                            value: loan.dueDate.formatted(date: .abbreviated, time: .omitted),
                            icon: "clock",
                            iconColor: Constants.Colors.info
                        )
                        
                        // Estimated Months Remaining
                        DetailRow(
                            title: "Estimated Months Remaining",
                            value: "\(estimatedMonthsRemaining) months",
                            icon: "hourglass",
                            iconColor: Constants.Colors.textSecondary
                        )
                    }
                    .padding(.horizontal, Constants.UI.Padding.screenMargin)
                    
                    // Action Buttons
                    VStack(spacing: Constants.UI.Spacing.medium) {
                        // Edit Button
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Loan")
                            }
                            .font(Constants.Typography.Button.font)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Constants.UI.Spacing.medium)
                            .background(Constants.Colors.cleanBlack)
                            .cornerRadius(Constants.UI.cardCornerRadius)
                        }
                        .accessibilityLabel("Edit loan")
                        
                        // Delete Button
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Loan")
                            }
                            .font(Constants.Typography.Button.font)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Constants.UI.Spacing.medium)
                            .background(Constants.Colors.error)
                            .cornerRadius(Constants.UI.cardCornerRadius)
                        }
                        .accessibilityLabel("Delete loan")
                    }
                    .padding(.horizontal, Constants.UI.Padding.screenMargin)
                    .padding(.bottom, Constants.UI.Spacing.section)
                }
            }
            .navigationTitle("Loan Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                LoanEditView(loan: $editableLoan, viewModel: viewModel)
            }
            .alert("Delete Loan", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteLoan(loan)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this loan? This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Helper Functions
    private func loanTypeFromName(_ name: String) -> String {
        switch name.lowercased() {
        case let name where name.contains("auto") || name.contains("car"):
            return "Auto Loan"
        case let name where name.contains("student"):
            return "Student Loan"
        case let name where name.contains("credit"):
            return "Credit Card"
        case let name where name.contains("home") || name.contains("mortgage"):
            return "Home Loan"
        default:
            return "Personal Loan"
        }
    }
}

// MARK: - Detail Row Component
private struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: Constants.UI.Spacing.medium) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(iconColor)
            }
            .accessibilityHidden(true)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Constants.Typography.Caption.font)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textSecondary)
                
                Text(value)
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
            }
            
            Spacer()
        }
        .padding(.vertical, Constants.UI.Spacing.small)
        .padding(.horizontal, Constants.UI.Spacing.medium)
        .background(Constants.Colors.backgroundSecondary)
        .cornerRadius(Constants.UI.cardCornerRadius)
    }
}

#Preview {
    LoanDetailView(
        loan: Loan(
            name: "Auto Loan",
            principalAmount: 25000.0,
            remainingAmount: 18500.0,
            interestRate: 4.5,
            monthlyPayment: 450.0,
            dueDate: Date().addingTimeInterval(86400 * 15),
            paymentStatus: .current,
            lastPaymentDate: Date().addingTimeInterval(-86400 * 30),
            nextPaymentDueDate: Date().addingTimeInterval(86400 * 15),
            category: .auto
        ),
        viewModel: LoanViewModel()
    )
}

