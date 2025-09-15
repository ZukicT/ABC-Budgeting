import SwiftUI

// MARK: - Edit Loan View
struct EditLoanView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    let loan: LoanItem
    let onSave: (LoanItem) -> Void
    
    @State private var name: String
    @State private var lender: String
    @State private var originalAmount: String
    @State private var currentBalance: String
    @State private var interestRate: String
    @State private var monthlyPayment: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var selectedLoanType: LoanType
    @State private var selectedStatus: LoanStatus
    @State private var notes: String
    @State private var selectedIconName: String
    @State private var selectedIconColor: String
    
    // MARK: - Initialization
    init(loan: LoanItem, onSave: @escaping (LoanItem) -> Void) {
        self.loan = loan
        self.onSave = onSave
        
        // Initialize state with loan data
        _name = State(initialValue: loan.name)
        _lender = State(initialValue: loan.lender)
        _originalAmount = State(initialValue: String(loan.originalAmount))
        _currentBalance = State(initialValue: String(loan.currentBalance))
        _interestRate = State(initialValue: String(loan.interestRate))
        _monthlyPayment = State(initialValue: String(loan.monthlyPayment))
        _startDate = State(initialValue: loan.startDate)
        _endDate = State(initialValue: loan.endDate)
        _selectedLoanType = State(initialValue: loan.loanType)
        _selectedStatus = State(initialValue: loan.status)
        _notes = State(initialValue: loan.notes ?? "")
        _selectedIconName = State(initialValue: loan.iconName)
        _selectedIconColor = State(initialValue: loan.iconColorName)
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !name.isEmpty &&
        !lender.isEmpty &&
        !originalAmount.isEmpty &&
        !currentBalance.isEmpty &&
        !interestRate.isEmpty &&
        !monthlyPayment.isEmpty &&
        Double(originalAmount) != nil &&
        Double(currentBalance) != nil &&
        Double(interestRate) != nil &&
        Double(monthlyPayment) != nil
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
                        
                        // Form Fields
                        formSection
                        
                        // Icon Selection
                        iconSelectionSection
                        
                        // Notes Section
                        notesSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Edit Loan")
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
                        saveLoan()
                    }
                    .foregroundColor(isFormValid ? RobinhoodColors.primary : RobinhoodColors.textTertiary)
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    /// Header section with title and description
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Edit Loan Details")
                .font(RobinhoodTypography.title2)
                .foregroundColor(RobinhoodColors.textPrimary)
            
            Text("Update your loan information")
                .font(RobinhoodTypography.body)
                .foregroundColor(RobinhoodColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// Form fields section
    private var formSection: some View {
        VStack(spacing: 16) {
            // Basic Information
            VStack(alignment: .leading, spacing: 12) {
                Text("Basic Information")
                    .font(RobinhoodTypography.headline)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                VStack(spacing: 12) {
                    LoanFormField(
                        title: "Loan Name",
                        placeholder: "e.g., Student Loan",
                        text: $name
                    )
                    
                    LoanFormField(
                        title: "Lender",
                        placeholder: "e.g., Federal Student Aid",
                        text: $lender
                    )
                    
                    LoanTypePicker(selectedType: $selectedLoanType)
                }
            }
            
            // Financial Information
            VStack(alignment: .leading, spacing: 12) {
                Text("Financial Information")
                    .font(RobinhoodTypography.headline)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        LoanFormField(
                            title: "Original Amount",
                            placeholder: "$0.00",
                            text: $originalAmount,
                            keyboardType: .decimalPad
                        )
                        
                        LoanFormField(
                            title: "Current Balance",
                            placeholder: "$0.00",
                            text: $currentBalance,
                            keyboardType: .decimalPad
                        )
                    }
                    
                    HStack(spacing: 12) {
                        LoanFormField(
                            title: "Interest Rate (%)",
                            placeholder: "0.0",
                            text: $interestRate,
                            keyboardType: .decimalPad
                        )
                        
                        LoanFormField(
                            title: "Monthly Payment",
                            placeholder: "$0.00",
                            text: $monthlyPayment,
                            keyboardType: .decimalPad
                        )
                    }
                }
            }
            
            // Dates
            VStack(alignment: .leading, spacing: 12) {
                Text("Loan Period")
                    .font(RobinhoodTypography.headline)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        DatePickerField(
                            title: "Start Date",
                            date: $startDate
                        )
                        
                        DatePickerField(
                            title: "End Date",
                            date: $endDate
                        )
                    }
                    
                    LoanStatusPicker(selectedStatus: $selectedStatus)
                }
            }
        }
    }
    
    /// Icon selection section
    private var iconSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Icon & Color")
                .font(RobinhoodTypography.headline)
                .foregroundColor(RobinhoodColors.textPrimary)
            
            VStack(spacing: 16) {
                // Icon Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Icon")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(selectedLoanType.availableIcons, id: \.self) { iconName in
                            IconButton(
                                iconName: iconName,
                                isSelected: selectedIconName == iconName
                            ) {
                                selectedIconName = iconName
                            }
                        }
                    }
                }
                
                // Color Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Color")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(availableColors, id: \.self) { colorName in
                            ColorButton(
                                colorName: colorName,
                                isSelected: selectedIconColor == colorName
                            ) {
                                selectedIconColor = colorName
                            }
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
                
                TextField("Optional notes about this loan...", text: $notes, axis: .vertical)
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
    
    private func saveLoan() {
        guard let originalAmountValue = Double(originalAmount),
              let currentBalanceValue = Double(currentBalance),
              let interestRateValue = Double(interestRate),
              let monthlyPaymentValue = Double(monthlyPayment) else {
            return
        }
        
        let updatedLoan = LoanItem(
            id: loan.id,
            name: name,
            lender: lender,
            originalAmount: originalAmountValue,
            currentBalance: currentBalanceValue,
            interestRate: interestRateValue,
            monthlyPayment: monthlyPaymentValue,
            startDate: startDate,
            endDate: endDate,
            loanType: selectedLoanType,
            status: selectedStatus,
            notes: notes.isEmpty ? nil : notes,
            iconName: selectedIconName,
            iconColorName: selectedIconColor,
            iconBackgroundName: "\(selectedIconColor).opacity15"
        )
        
        onSave(updatedLoan)
        dismiss()
    }
    
    private var availableColors: [String] {
        ["blue", "green", "orange", "purple", "red", "mint", "indigo", "pink", "yellow", "gray"]
    }
}

#Preview {
    EditLoanView(
        loan: LoanItem.makeMockData().first!,
        onSave: { _ in }
    )
}
