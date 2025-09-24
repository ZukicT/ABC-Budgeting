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
    @State private var showingLoanTypePicker = false
    
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
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.UI.Spacing.large) {
                    // Form Fields
                    VStack(spacing: Constants.UI.Spacing.medium) {
                        // Loan Name Field
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                            Text("Loan Name")
                                .font(Constants.Typography.H3.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            TextField("Enter loan name", text: $name)
                                .font(Constants.Typography.Body.font)
                                .padding(Constants.UI.Spacing.medium)
                                .background(Constants.Colors.backgroundSecondary)
                                .cornerRadius(Constants.UI.cardCornerRadius)
                        }
                        
                        // Principal Amount Field
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                            Text("Principal Amount")
                                .font(Constants.Typography.H3.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            HStack {
                                Text("$")
                                    .font(Constants.Typography.Body.font)
                                    .fontWeight(.medium)
                                    .foregroundColor(Constants.Colors.textSecondary)
                                
                                TextField("0.00", text: $principalAmount)
                                    .keyboardType(.decimalPad)
                                    .font(Constants.Typography.Body.font)
                            }
                            .padding(Constants.UI.Spacing.medium)
                            .background(Constants.Colors.backgroundSecondary)
                            .cornerRadius(Constants.UI.cardCornerRadius)
                        }
                        
                        // Remaining Amount Field
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                            Text("Remaining Amount")
                                .font(Constants.Typography.H3.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            HStack {
                                Text("$")
                                    .font(Constants.Typography.Body.font)
                                    .fontWeight(.medium)
                                    .foregroundColor(Constants.Colors.textSecondary)
                                
                                TextField("0.00", text: $remainingAmount)
                                    .keyboardType(.decimalPad)
                                    .font(Constants.Typography.Body.font)
                            }
                            .padding(Constants.UI.Spacing.medium)
                            .background(Constants.Colors.backgroundSecondary)
                            .cornerRadius(Constants.UI.cardCornerRadius)
                        }
                        
                        // Interest Rate Field
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                            Text("Interest Rate (APR)")
                                .font(Constants.Typography.H3.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            HStack {
                                TextField("0.0", text: $interestRate)
                                    .keyboardType(.decimalPad)
                                    .font(Constants.Typography.Body.font)
                                
                                Text("%")
                                    .font(Constants.Typography.Body.font)
                                    .fontWeight(.medium)
                                    .foregroundColor(Constants.Colors.textSecondary)
                            }
                            .padding(Constants.UI.Spacing.medium)
                            .background(Constants.Colors.backgroundSecondary)
                            .cornerRadius(Constants.UI.cardCornerRadius)
                        }
                        
                        // Monthly Payment Field
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                            Text("Monthly Payment")
                                .font(Constants.Typography.H3.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            HStack {
                                Text("$")
                                    .font(Constants.Typography.Body.font)
                                    .fontWeight(.medium)
                                    .foregroundColor(Constants.Colors.textSecondary)
                                
                                TextField("0.00", text: $monthlyPayment)
                                    .keyboardType(.decimalPad)
                                    .font(Constants.Typography.Body.font)
                            }
                            .padding(Constants.UI.Spacing.medium)
                            .background(Constants.Colors.backgroundSecondary)
                            .cornerRadius(Constants.UI.cardCornerRadius)
                        }
                        
                        // Due Date Field
                        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                            Text("Next Payment Due")
                                .font(Constants.Typography.H3.font)
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            HStack {
                                DatePicker("", selection: $selectedDueDate, displayedComponents: [.date])
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                                Spacer(minLength: 0)
                            }
                            .padding(Constants.UI.Spacing.medium)
                            .background(Constants.Colors.backgroundSecondary)
                            .cornerRadius(Constants.UI.cardCornerRadius)
                        }
                    }
                    .padding(.horizontal, Constants.UI.Padding.screenMargin)
                    .padding(.top, Constants.UI.Spacing.large)
                    
                    Spacer(minLength: Constants.UI.Spacing.section)
                }
            }
            .navigationTitle("Edit Loan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveLoan()
                    }
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
        }
    }
    
    
    private func saveLoan() {
        guard let principal = Double(principalAmount),
              let remaining = Double(remainingAmount),
              let interest = Double(interestRate),
              let monthly = Double(monthlyPayment),
              principal > 0,
              remaining >= 0,
              interest >= 0,
              monthly > 0 else { return }
        
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
        
        dismiss()
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
