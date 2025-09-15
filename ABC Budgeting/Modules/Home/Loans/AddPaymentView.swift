import SwiftUI

// MARK: - Add Payment View
struct AddPaymentView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    let loan: LoanItem
    let onSave: (LoanPayment) -> Void
    
    @State private var amount = ""
    @State private var principalAmount = ""
    @State private var interestAmount = ""
    @State private var paymentDate = Date()
    @State private var notes = ""
    @State private var isScheduled = false
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !amount.isEmpty &&
        !principalAmount.isEmpty &&
        !interestAmount.isEmpty &&
        Double(amount) != nil &&
        Double(principalAmount) != nil &&
        Double(interestAmount) != nil
    }
    
    private var calculatedInterest: Double {
        guard let principal = Double(principalAmount) else { return 0 }
        return max(0, (Double(amount) ?? 0) - principal)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                RobinhoodColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Payment Amount Section
                        paymentAmountSection
                        
                        // Breakdown Section
                        breakdownSection
                        
                        // Date Section
                        dateSection
                        
                        // Notes Section
                        notesSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(RobinhoodColors.primary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePayment()
                    }
                    .foregroundColor(isFormValid ? RobinhoodColors.primary : RobinhoodColors.textTertiary)
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    /// Header section with loan info
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Loan Info Card
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(loan.iconBackground)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: loan.iconName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(loan.iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(loan.name)
                        .font(RobinhoodTypography.headline)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Text(loan.lender)
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Current Balance")
                        .font(RobinhoodTypography.caption2)
                        .foregroundColor(RobinhoodColors.textTertiary)
                    
                    Text(loan.currentBalance.currencyString)
                        .font(RobinhoodTypography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(RobinhoodColors.textPrimary)
                }
            }
            .padding(16)
            .background(RobinhoodColors.cardBackground)
            .cornerRadius(12)
            
            // Title
            VStack(alignment: .leading, spacing: 8) {
                Text("Record Payment")
                    .font(RobinhoodTypography.title2)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                Text("Add a payment to track your loan progress")
                    .font(RobinhoodTypography.body)
                    .foregroundColor(RobinhoodColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    /// Payment amount section
    private var paymentAmountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Amount")
                .font(RobinhoodTypography.headline)
                .foregroundColor(RobinhoodColors.textPrimary)
            
            VStack(spacing: 12) {
                LoanFormField(
                    title: "Total Payment Amount",
                    placeholder: "$0.00",
                    text: $amount,
                    keyboardType: .decimalPad
                )
                
                // Quick amount buttons
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Amounts")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    HStack(spacing: 12) {
                        QuickAmountButton(
                            title: "Min Payment",
                            amount: loan.monthlyPayment
                        ) {
                            amount = String(loan.monthlyPayment)
                            calculateBreakdown()
                        }
                        
                        QuickAmountButton(
                            title: "2x Payment",
                            amount: loan.monthlyPayment * 2
                        ) {
                            amount = String(loan.monthlyPayment * 2)
                            calculateBreakdown()
                        }
                        
                        QuickAmountButton(
                            title: "Full Balance",
                            amount: loan.currentBalance
                        ) {
                            amount = String(loan.currentBalance)
                            calculateBreakdown()
                        }
                    }
                }
            }
        }
    }
    
    /// Breakdown section
    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Breakdown")
                .font(RobinhoodTypography.headline)
                .foregroundColor(RobinhoodColors.textPrimary)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    LoanFormField(
                        title: "Principal Amount",
                        placeholder: "$0.00",
                        text: $principalAmount,
                        keyboardType: .decimalPad
                    )
                    
                    LoanFormField(
                        title: "Interest Amount",
                        placeholder: "$0.00",
                        text: $interestAmount,
                        keyboardType: .decimalPad
                    )
                }
                
                // Auto-calculate button
                Button(action: calculateBreakdown) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 14, weight: .medium))
                        Text("Auto-Calculate")
                            .font(RobinhoodTypography.caption)
                    }
                    .foregroundColor(RobinhoodColors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(RobinhoodColors.primary.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Validation message
                if !isFormValid && !amount.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(RobinhoodColors.warning)
                        
                        Text("Principal + Interest must equal total amount")
                            .font(RobinhoodTypography.caption2)
                            .foregroundColor(RobinhoodColors.warning)
                    }
                }
            }
        }
    }
    
    /// Date section
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Date")
                .font(RobinhoodTypography.headline)
                .foregroundColor(RobinhoodColors.textPrimary)
            
            VStack(spacing: 12) {
                DatePickerField(
                    title: "Payment Date",
                    date: $paymentDate
                )
                
                // Quick date buttons
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Dates")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    HStack(spacing: 12) {
                        QuickDateButton(
                            title: "Today",
                            date: Date()
                        ) {
                            paymentDate = Date()
                        }
                        
                        QuickDateButton(
                            title: "Yesterday",
                            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                        ) {
                            paymentDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
                        }
                        
                        QuickDateButton(
                            title: "Last Week",
                            date: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
                        ) {
                            paymentDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
                        }
                    }
                }
            }
        }
    }
    
    /// Notes section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(RobinhoodTypography.headline)
                .foregroundColor(RobinhoodColors.textPrimary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Additional Information")
                    .font(RobinhoodTypography.caption)
                    .foregroundColor(RobinhoodColors.textSecondary)
                
                TextField("Optional notes about this payment...", text: $notes, axis: .vertical)
                    .font(RobinhoodTypography.body)
                    .foregroundColor(RobinhoodColors.textPrimary)
                    .padding(12)
                    .background(RobinhoodColors.cardBackground)
                    .cornerRadius(8)
                    .lineLimit(3...6)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func calculateBreakdown() {
        guard let totalAmount = Double(amount) else { return }
        
        // Simple calculation: assume 80% principal, 20% interest
        // In a real app, this would be more sophisticated
        let calculatedPrincipal = totalAmount * 0.8
        let calculatedInterest = totalAmount * 0.2
        
        principalAmount = String(calculatedPrincipal)
        interestAmount = String(calculatedInterest)
    }
    
    private func savePayment() {
        guard let amountValue = Double(amount),
              let principalValue = Double(principalAmount),
              let interestValue = Double(interestAmount) else {
            return
        }
        
        let newPayment = LoanPayment(
            id: UUID(),
            loanId: loan.id,
            amount: amountValue,
            principalAmount: principalValue,
            interestAmount: interestValue,
            paymentDate: paymentDate,
            isScheduled: isScheduled,
            notes: notes.isEmpty ? nil : notes
        )
        
        onSave(newPayment)
        dismiss()
    }
}

// MARK: - Quick Amount Button Component
struct QuickAmountButton: View {
    let title: String
    let amount: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(RobinhoodTypography.caption2)
                    .foregroundColor(RobinhoodColors.textSecondary)
                
                Text(amount.currencyString)
                    .font(RobinhoodTypography.caption)
                    .fontWeight(.medium)
                    .foregroundColor(RobinhoodColors.textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RobinhoodColors.cardBackground)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quick Date Button Component
struct QuickDateButton: View {
    let title: String
    let date: Date
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(RobinhoodTypography.caption2)
                    .foregroundColor(RobinhoodColors.textSecondary)
                
                Text(date.formatted(.dateTime.month(.abbreviated).day()))
                    .font(RobinhoodTypography.caption)
                    .fontWeight(.medium)
                    .foregroundColor(RobinhoodColors.textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RobinhoodColors.cardBackground)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddPaymentView(
        loan: LoanItem.makeMockData().first!,
        onSave: { _ in }
    )
}
