import SwiftUI

struct LoanEditView: View {
    @Binding var loan: Loan
    @ObservedObject var viewModel: LoanViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name: String
    @State private var principalAmount: String
    @State private var remainingAmount: String
    @State private var interestRate: String
    @State private var monthlyPayment: String
    @State private var selectedDueDate: Date
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var isSaving = false
    
    private let loanTypes = ["Personal", "Auto", "Home", "Student", "Credit Card", "Business", "Other"]
    
    init(loan: Binding<Loan>, viewModel: LoanViewModel) {
        self._loan = loan
        self.viewModel = viewModel
        self._name = State(initialValue: loan.wrappedValue.name)
        self._principalAmount = State(initialValue: String(loan.wrappedValue.principalAmount))
        self._remainingAmount = State(initialValue: String(loan.wrappedValue.remainingAmount))
        self._interestRate = State(initialValue: String(loan.wrappedValue.interestRate))
        self._monthlyPayment = State(initialValue: String(loan.wrappedValue.monthlyPayment))
        self._selectedDueDate = State(initialValue: loan.wrappedValue.dueDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section - Compact layout
            VStack(spacing: 16) {
                // Top Row: Title + Close Button
                HStack {
                    Text("Edit Loan")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Constants.Colors.textPrimary)
                        .accessibilityLabel("Edit Loan")
                        .accessibilityAddTraits(.isHeader)
                    
                    Spacer()
                    
                    // Close Button
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Constants.Colors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(Constants.Colors.textTertiary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Close edit view")
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Form Section - Compact layout
            ScrollView {
                VStack(spacing: 20) {
                    // Loan Name Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("LOAN NAME")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        TextField("Enter loan name", text: $name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Constants.Colors.textPrimary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Constants.Colors.textPrimary.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(!isValidName ? Constants.Colors.error.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                            .accessibilityLabel("Loan name")
                            .accessibilityHint("Enter the name of this loan")
                    }
                    
                    // Principal Amount Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("PRINCIPAL AMOUNT")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        HStack {
                            Text("$")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Constants.Colors.textSecondary)
                            
                            TextField("0.00", text: $principalAmount)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Constants.Colors.textPrimary)
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Constants.Colors.textPrimary.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(!isValidPrincipalAmount ? Constants.Colors.error.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Principal amount")
                        .accessibilityHint("Enter the original loan amount")
                    }
                    
                    // Remaining Amount Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("REMAINING AMOUNT")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        HStack {
                            Text("$")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Constants.Colors.textSecondary)
                            
                            TextField("0.00", text: $remainingAmount)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Constants.Colors.textPrimary)
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Constants.Colors.textPrimary.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(!isValidRemainingAmount ? Constants.Colors.error.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Remaining amount")
                        .accessibilityHint("Enter the remaining loan balance")
                    }
                    
                    // Interest Rate Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("INTEREST RATE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        HStack {
                            TextField("0.0", text: $interestRate)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Constants.Colors.textPrimary)
                                .keyboardType(.decimalPad)
                            
                            Text("%")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Constants.Colors.textSecondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Constants.Colors.textPrimary.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(!isValidInterestRate ? Constants.Colors.error.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Interest rate")
                        .accessibilityHint("Enter the annual percentage rate")
                    }
                    
                    // Monthly Payment Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("MONTHLY PAYMENT")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        HStack {
                            Text("$")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Constants.Colors.textSecondary)
                            
                            TextField("0.00", text: $monthlyPayment)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Constants.Colors.textPrimary)
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Constants.Colors.textPrimary.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(!isValidMonthlyPayment ? Constants.Colors.error.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Monthly payment")
                        .accessibilityHint("Enter the monthly payment amount")
                    }
                    
                    // Due Date Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DUE DATE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Constants.Colors.textTertiary)
                            .tracking(1.0)
                        
                        HStack {
                            DatePicker("", selection: $selectedDueDate, displayedComponents: [.date])
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            
            // Action Buttons - Horizontal layout for compact design
            HStack(spacing: 12) {
                // Save Button - Primary action
                Button(action: {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    saveLoan()
                }) {
                    HStack(spacing: 8) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Text(isSaving ? "Saving..." : "Save")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Constants.Colors.cleanBlack)
                    .cornerRadius(12)
                }
                .disabled(isSaving || !canSave)
                .accessibilityLabel(isSaving ? "Saving loan changes" : "Save loan changes")
                .accessibilityHint("Double tap to save your changes to this loan")
                
                // Cancel Button - Secondary action
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Cancel")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(Constants.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Constants.Colors.textPrimary.opacity(0.05))
                    .cornerRadius(12)
                }
                .accessibilityLabel("Cancel editing")
                .accessibilityHint("Double tap to discard changes and return to loan details")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .alert("Validation Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Computed Properties
    private var isValidName: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isValidPrincipalAmount: Bool {
        guard let amount = Double(principalAmount) else { return false }
        return amount > 0
    }
    
    private var isValidRemainingAmount: Bool {
        guard let amount = Double(remainingAmount) else { return false }
        return amount >= 0
    }
    
    private var isValidInterestRate: Bool {
        guard let rate = Double(interestRate) else { return false }
        return rate >= 0
    }
    
    private var isValidMonthlyPayment: Bool {
        guard let payment = Double(monthlyPayment) else { return false }
        return payment > 0
    }
    
    private var canSave: Bool {
        isValidName && isValidPrincipalAmount && isValidRemainingAmount && isValidInterestRate && isValidMonthlyPayment
    }
    
    
    private func saveLoan() {
        // Set loading state
        isSaving = true
        
        // Validate input
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a loan name."
            showingErrorAlert = true
            isSaving = false
            return
        }
        
        guard let principal = Double(principalAmount), principal > 0 else {
            errorMessage = "Please enter a valid principal amount greater than 0."
            showingErrorAlert = true
            isSaving = false
            return
        }
        
        guard let remaining = Double(remainingAmount), remaining >= 0 else {
            errorMessage = "Please enter a valid remaining amount (0 or greater)."
            showingErrorAlert = true
            isSaving = false
            return
        }
        
        guard let interest = Double(interestRate), interest >= 0 else {
            errorMessage = "Please enter a valid interest rate (0 or greater)."
            showingErrorAlert = true
            isSaving = false
            return
        }
        
        guard let monthly = Double(monthlyPayment), monthly > 0 else {
            errorMessage = "Please enter a valid monthly payment greater than 0."
            showingErrorAlert = true
            isSaving = false
            return
        }
        
        guard remaining <= principal else {
            errorMessage = "Remaining amount cannot be greater than principal amount."
            showingErrorAlert = true
            isSaving = false
            return
        }
        
        // Simulate save delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Create updated loan with same ID
            let updatedLoan = Loan(
                id: loan.id, // Preserve the original ID
                name: name,
                principalAmount: principal,
                remainingAmount: remaining,
                interestRate: interest,
                monthlyPayment: monthly,
                dueDate: selectedDueDate,
                paymentStatus: loan.paymentStatus, // Keep existing status
                lastPaymentDate: loan.lastPaymentDate, // Keep existing last payment date
                nextPaymentDueDate: selectedDueDate,
                category: loan.category // Keep existing category
            )
            
            // Update the loan in the view model
            viewModel.updateLoan(updatedLoan)
            
            // Update the binding
            loan = updatedLoan
            
            isSaving = false
            dismiss()
        }
    }
    
}


#Preview {
    LoanEditView(loan: .constant(Loan(
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
    )), viewModel: LoanViewModel())
}
