import SwiftUI

// MARK: - Add Loan View
struct AddLoanView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    let onSave: (LoanItem) -> Void
    
    @State private var name = ""
    @State private var lender = ""
    @State private var originalAmount = ""
    @State private var currentBalance = ""
    @State private var interestRate = ""
    @State private var monthlyPayment = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(365 * 24 * 60 * 60) // 1 year from now
    @State private var selectedLoanType: LoanType = .personal
    @State private var selectedStatus: LoanStatus = .active
    @State private var notes = ""
    @State private var selectedIconName = "creditcard"
    @State private var selectedIconColor = "blue"
    
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
            .navigationTitle("Add Loan")
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
            Text("Loan Details")
                .font(RobinhoodTypography.title2)
                .foregroundColor(RobinhoodColors.textPrimary)
            
            Text("Add a new loan to track your debt and payments")
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
        
        let newLoan = LoanItem(
            id: UUID(),
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
        
        onSave(newLoan)
        dismiss()
    }
    
    private var availableColors: [String] {
        ["blue", "green", "orange", "purple", "red", "mint", "indigo", "pink", "yellow", "gray"]
    }
}

// MARK: - Loan Form Field Component
struct LoanFormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(RobinhoodTypography.caption)
                .foregroundColor(RobinhoodColors.textSecondary)
            
            TextField(placeholder, text: $text)
                .font(RobinhoodTypography.body)
                .foregroundColor(RobinhoodColors.textPrimary)
                .keyboardType(keyboardType)
                .padding(12)
                .background(RobinhoodColors.cardBackground)
                .cornerRadius(8)
        }
    }
}

// MARK: - Date Picker Field Component
struct DatePickerField: View {
    let title: String
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(RobinhoodTypography.caption)
                .foregroundColor(RobinhoodColors.textSecondary)
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
                .font(RobinhoodTypography.body)
                .foregroundColor(RobinhoodColors.textPrimary)
                .padding(12)
                .background(RobinhoodColors.cardBackground)
                .cornerRadius(8)
        }
    }
}

// MARK: - Loan Type Picker Component
struct LoanTypePicker: View {
    @Binding var selectedType: LoanType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Loan Type")
                .font(RobinhoodTypography.caption)
                .foregroundColor(RobinhoodColors.textSecondary)
            
            Menu {
                ForEach(LoanType.allCases) { type in
                    Button(action: {
                        selectedType = type
                    }) {
                        HStack {
                            Image(systemName: type.iconName)
                            Text(type.label)
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: selectedType.iconName)
                        .foregroundColor(selectedType.color)
                    
                    Text(selectedType.label)
                        .font(RobinhoodTypography.body)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(RobinhoodColors.textSecondary)
                }
                .padding(12)
                .background(RobinhoodColors.cardBackground)
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - Loan Status Picker Component
struct LoanStatusPicker: View {
    @Binding var selectedStatus: LoanStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .font(RobinhoodTypography.caption)
                .foregroundColor(RobinhoodColors.textSecondary)
            
            Menu {
                ForEach(LoanStatus.allCases) { status in
                    Button(action: {
                        selectedStatus = status
                    }) {
                        HStack {
                            Image(systemName: status.iconName)
                            Text(status.label)
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: selectedStatus.iconName)
                        .foregroundColor(selectedStatus.color)
                    
                    Text(selectedStatus.label)
                        .font(RobinhoodTypography.body)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(RobinhoodColors.textSecondary)
                }
                .padding(12)
                .background(RobinhoodColors.cardBackground)
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - Icon Button Component
struct IconButton: View {
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? RobinhoodColors.primary : RobinhoodColors.cardBackground)
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? Color.black : RobinhoodColors.textPrimary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Color Button Component
struct ColorButton: View {
    let colorName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.fromName(colorName))
                    .frame(width: 32, height: 32)
                
                if isSelected {
                    Circle()
                        .frame(width: 32, height: 32)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensions
extension LoanType {
    var availableIcons: [String] {
        switch self {
        case .student:
            return ["graduationcap", "book", "pencil", "studentdesk"]
        case .auto:
            return ["car", "car.fill", "truck", "suv"]
        case .personal:
            return ["person", "person.circle", "creditcard", "dollarsign.circle"]
        case .mortgage:
            return ["house", "house.fill", "building", "building.2"]
        case .business:
            return ["building.2", "building.2.fill", "briefcase", "chart.line.uptrend.xyaxis"]
        case .creditCard:
            return ["creditcard", "creditcard.fill", "rectangle.portrait.and.arrow.right"]
        case .other:
            return ["questionmark.circle", "ellipsis", "plus.circle", "star"]
        }
    }
}

#Preview {
    AddLoanView { _ in }
}
