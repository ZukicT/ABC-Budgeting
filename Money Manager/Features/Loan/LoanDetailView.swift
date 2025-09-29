import SwiftUI

struct LoanDetailView: View {
    let loan: Loan
    @ObservedObject var viewModel: LoanViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
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
        VStack(spacing: 0) {
            // Header Section - Compact layout with icon repositioned
            VStack(spacing: 16) {
                // Top row with icon and amount
                HStack(spacing: 16) {
                    // Loan Type Icon - Visual loan indicator (smaller size)
                    LoanTypeIcon(loanName: loan.name, size: 50)
                        .accessibilityLabel("Loan type: \(loan.name)")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Remaining Amount - Primary focus (smaller font)
                        Text(loan.remainingAmount.formatted(.currency(code: "USD")))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Constants.Colors.textPrimary)
                            .accessibilityLabel("Remaining amount: \(loan.remainingAmount.formatted(.currency(code: "USD")))")
                            .accessibilityAddTraits(.isStaticText)
                        
                        // Loan Name - Secondary
                        Text(loan.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Constants.Colors.textPrimary)
                            .accessibilityLabel("Loan name: \(loan.name)")
                            .accessibilityAddTraits(.isStaticText)
                    }
                    
                    Spacer()
                }
                
                // Progress Percentage - Tertiary
                Text("\(Int(progressPercentage * 100))\(contentManager.localizedString("loan.paid_percentage"))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(loanTypeColor)
                    .accessibilityLabel("Progress: \(Int(progressPercentage * 100)) percent paid")
                    .accessibilityAddTraits(.isStaticText)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Progress Bar Section
            VStack(spacing: 12) {
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Rectangle()
                            .fill(Constants.Colors.textTertiary.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        // Progress Fill
                        Rectangle()
                            .fill(loanTypeColor)
                            .frame(width: geometry.size.width * progressPercentage, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            
            // Details Section - Essential information only
            VStack(spacing: 16) {
                // Principal Amount
                HStack {
                    Text("loan.principal".localized)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Constants.Colors.textTertiary)
                        .tracking(1.0)
                    Spacer()
                    Text(loan.principalAmount.formatted(.currency(code: "USD")))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Constants.Colors.textPrimary)
                }
                .padding(.horizontal, 24)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Principal amount: \(loan.principalAmount.formatted(.currency(code: "USD")))")
                
                Divider()
                    .background(Constants.Colors.textTertiary.opacity(0.3))
                    .padding(.horizontal, 24)
                
                // Monthly Payment
                HStack {
                    Text("loan.monthly_payment_caps".localized)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Constants.Colors.textTertiary)
                        .tracking(1.0)
                    Spacer()
                    Text(loan.monthlyPayment.formatted(.currency(code: "USD")))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Constants.Colors.error)
                }
                .padding(.horizontal, 24)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Monthly payment: \(loan.monthlyPayment.formatted(.currency(code: "USD")))")
                
                Divider()
                    .background(Constants.Colors.textTertiary.opacity(0.3))
                    .padding(.horizontal, 24)
                
                // Interest Rate
                HStack {
                    Text("loan.interest_rate_caps".localized)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Constants.Colors.textTertiary)
                        .tracking(1.0)
                    Spacer()
                    Text(String(format: "%.2f%%", loan.interestRate))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Constants.Colors.warning)
                }
                .padding(.horizontal, 24)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Interest rate: \(String(format: "%.2f%%", loan.interestRate))")
                
                Divider()
                    .background(Constants.Colors.textTertiary.opacity(0.3))
                    .padding(.horizontal, 24)
                
                // Due Date
                HStack {
                    Text("loan.due_date_caps".localized)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Constants.Colors.textTertiary)
                        .tracking(1.0)
                    Spacer()
                    Text(loan.dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Constants.Colors.info)
                }
                .padding(.horizontal, 24)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Due date: \(loan.dueDate.formatted(date: .abbreviated, time: .omitted))")
            }
            .padding(.bottom, 20)
            
            // Action Buttons - Horizontal layout for compact design
            HStack(spacing: 12) {
                // Edit Button - Primary action
                Button(action: {
                    showingEditSheet = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .semibold))
                        Text("loan.edit".localized)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Constants.Colors.cleanBlack)
                    .cornerRadius(12)
                }
                .accessibilityLabel(contentManager.localizedString("accessibility.edit_loan"))
                .accessibilityHint("Double tap to edit this loan")
                
                // Delete Button - Secondary action
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .semibold))
                        Text("loan.delete".localized)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Constants.Colors.error)
                    .cornerRadius(12)
                }
                .accessibilityLabel(contentManager.localizedString("accessibility.delete_loan"))
                .accessibilityHint("Double tap to delete this loan")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .sheet(isPresented: $showingEditSheet) {
            LoanEditView(loan: $editableLoan, viewModel: viewModel)
                .presentationDetents([.height(650), .medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
        }
        .alert(contentManager.localizedString("alert.confirm_delete"), isPresented: $showingDeleteAlert) {
            Button(contentManager.localizedString("button.cancel"), role: .cancel) { }
            Button(contentManager.localizedString("button.delete"), role: .destructive) {
                viewModel.deleteLoan(loan)
                dismiss()
            }
        } message: {
            Text(contentManager.localizedString("alert.delete_loan_message"))
        }
    }
    
    // MARK: - Helper Functions
    private func loanTypeFromName(_ name: String) -> String {
        switch name.lowercased() {
        case let name where name.contains("auto") || name.contains("car"):
            return contentManager.localizedString("loan.auto_loan")
        case let name where name.contains("student"):
            return contentManager.localizedString("loan.student_loan")
        case let name where name.contains("credit"):
            return contentManager.localizedString("loan.credit_card")
        case let name where name.contains("home") || name.contains("mortgage"):
            return contentManager.localizedString("loan.home_loan")
        default:
            return contentManager.localizedString("loan.personal_loan")
        }
    }
}

// MARK: - Loan Type Icon Component
private struct LoanTypeIcon: View {
    let loanName: String
    let size: CGFloat
    
    private var iconInfo: (name: String, color: Color) {
        switch loanName.lowercased() {
        case let name where name.contains("auto") || name.contains("car"):
            return ("car.fill", Constants.Colors.info)
        case let name where name.contains("student"):
            return ("graduationcap.fill", Constants.Colors.success)
        case let name where name.contains("credit"):
            return ("creditcard.fill", Constants.Colors.error)
        case let name where name.contains("home") || name.contains("mortgage"):
            return ("house.fill", Constants.Colors.warning)
        default:
            return ("doc.text.fill", Constants.Colors.textSecondary)
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size / 4)
                .fill(iconInfo.color.opacity(0.15))
                .frame(width: size, height: size)
            
            Image(systemName: iconInfo.name)
                .font(.system(size: size * 0.5, weight: .medium))
                .foregroundColor(iconInfo.color)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loan type icon for \(loanName)")
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

