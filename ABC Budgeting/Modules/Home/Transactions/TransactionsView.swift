import SwiftUI
import Foundation

struct TransactionsView: View {
    @State private var selectedCategory: TransactionCategory? = nil
    @Binding var transactions: [Transaction]
    @State private var showAddTransaction = false
    @Binding var goals: [GoalFormData]
    @State private var selectedTransaction: Transaction? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                        filterChipsSection
                        contentSection
                    }
                    .padding(.bottom, 80) // For FAB spacing
                }
                fabSection
            }
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionView(availableGoals: goals) { newTransaction in
                    // If the transaction is linked to a goal, update the goal's savedAmount
                    if let linkedGoalName = newTransaction.linkedGoalName,
                       let idx = goals.firstIndex(where: { $0.name == linkedGoalName }) {
                        let amount = newTransaction.amount
                        if amount > 0 {
                            goals[idx] = GoalFormData(
                                name: goals[idx].name,
                                subtitle: goals[idx].subtitle,
                                targetAmount: goals[idx].targetAmount,
                                savedAmount: goals[idx].savedAmount + amount,
                                targetDate: goals[idx].targetDate,
                                notes: goals[idx].notes,
                                iconName: goals[idx].iconName,
                                iconColorName: goals[idx].iconColorName
                            )
                        } else if amount < 0 {
                            goals[idx] = GoalFormData(
                                name: goals[idx].name,
                                subtitle: goals[idx].subtitle,
                                targetAmount: goals[idx].targetAmount,
                                savedAmount: goals[idx].savedAmount + amount,
                                targetDate: goals[idx].targetDate,
                                notes: goals[idx].notes,
                                iconName: goals[idx].iconName,
                                iconColorName: goals[idx].iconColorName
                            )
                        }
                    }
                    transactions.insert(newTransaction, at: 0)
                    showAddTransaction = false
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $selectedTransaction) { transaction in
                TransactionDetailView(transaction: transaction) { updatedTransaction in
                    if let idx = transactions.firstIndex(where: { $0.id == updatedTransaction.id }) {
                        transactions[idx] = updatedTransaction
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        Text("Transactions")
            .font(.title.bold())
            .foregroundColor(.primary)
            .padding(.top, 20)
            .padding(.horizontal)
    }

    private var filterChipsSection: some View {
        FilterChips(selected: $selectedCategory)
            .padding(.top, 12)
            .padding(.horizontal)
    }

    private var contentSection: some View {
        Group {
            if transactions.isEmpty {
                emptyStateSection
            } else {
                transactionListSection
            }
        }
    }

    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 40)
            Image("Transactions")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220, maxHeight: 220)
                .accessibilityLabel("No transactions yet")
            Text("No transactions yet")
                .font(.title3.weight(.semibold))
                .foregroundColor(.secondary)
            Text("Tap the + button to add your first transaction.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var transactionListSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Today")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
                    .padding(.horizontal)
                VStack(spacing: 16) {
                    ForEach(transactions.filter { selectedCategory == nil || $0.category == selectedCategory }) { transaction in
                        Button(action: { selectedTransaction = transaction }) {
                            TransactionRow(transaction: transaction)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal)
                .padding(.bottom, 80) // For FAB spacing
            }
        }
    }

    private var fabSection: some View {
        FloatingActionButton(action: {
            showAddTransaction = true
        })
        .padding(.trailing, AppPaddings.fabTrailing)
        .padding(.bottom, AppPaddings.fabBottom)
    }
}

// MARK: - Filter Chips
struct FilterChips: View {
    @Binding var selected: TransactionCategory?
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: { selected = nil }) {
                    Text("All")
                        .font(.subheadline.bold())
                        .foregroundColor(selected == nil ? .white : AppColors.tagUnselected)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selected == nil ? AppColors.brandBlack : AppColors.tagUnselectedBackground)
                        )
                }
                .accessibilityLabel("All")
                .accessibilityAddTraits(selected == nil ? .isSelected : .isButton)
                ForEach(TransactionCategory.allCases) { category in
                    Button(action: { selected = category }) {
                        HStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(category.color.opacity(0.18))
                                    .frame(width: 22, height: 22)
                                Image(systemName: category.symbol)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(selected == category ? .white : category.color)
                            }
                            Text(category.label)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(selected == category ? .white : AppColors.tagUnselected)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selected == category ? category.color : AppColors.tagUnselectedBackground)
                        )
                    }
                    .accessibilityLabel(category.label)
                    .accessibilityAddTraits(selected == category ? .isSelected : .isButton)
                }
            }
        }
    }
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: Transaction
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(transaction.iconBackground)
                    .frame(width: 40, height: 40)
                Image(systemName: transaction.iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(transaction.iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.body.bold())
                    .foregroundColor(.primary)
                Text(transaction.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(transaction.amount, format: .currency(code: "USD"))
                .font(.body.bold())
                .foregroundColor(transactionColor)
            // Category Tag removed
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 2, y: 1)
        )
        .accessibilityElement(children: .combine)
        .onAppear { }
    }
    // Helper to determine transaction color
    private var transactionColor: Color {
        // Green for income, red for expenses
        transaction.isIncome ? .green : .red
    }
}

// MARK: - Mock Data
struct Transaction: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let amount: Double
    let iconName: String
    let iconColorName: String
    let iconBackgroundName: String
    let category: TransactionCategory
    let isIncome: Bool
    let linkedGoalName: String?
    let date: Date

    var iconColor: Color { Color.fromName(iconColorName) }
    var iconBackground: Color { Color.fromName(iconBackgroundName) }

    static func makeMockData() -> [Transaction] {
        let now = Date()
        let calendar = Calendar.current
        return [
            Transaction(id: UUID(), title: "Adobe Illustrator", subtitle: "Subscription fee", amount: 32, iconName: "cart", iconColorName: "orange", iconBackgroundName: "orange.opacity15", category: .essentials, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -2, to: now)!),
            Transaction(id: UUID(), title: "Spotify", subtitle: "Music subscription", amount: 10, iconName: "music.note", iconColorName: "purple", iconBackgroundName: "purple.opacity15", category: .leisure, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -10, to: now)!),
            Transaction(id: UUID(), title: "Savings Deposit", subtitle: "Monthly savings", amount: 100, iconName: "banknote", iconColorName: "green", iconBackgroundName: "green.opacity15", category: .savings, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -15, to: now)!),
            Transaction(id: UUID(), title: "Salary", subtitle: "Monthly income", amount: 2000, iconName: "dollarsign.circle", iconColorName: "mint", iconBackgroundName: "mint.opacity15", category: .income, isIncome: true, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -20, to: now)!),
            Transaction(id: UUID(), title: "Electric Bill", subtitle: "Utilities", amount: 60, iconName: "doc.text", iconColorName: "red", iconBackgroundName: "red.opacity15", category: .bills, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -25, to: now)!),
            Transaction(id: UUID(), title: "Miscellaneous", subtitle: "Other expense", amount: 25, iconName: "ellipsis", iconColorName: "gray", iconBackgroundName: "gray.opacity15", category: .other, isIncome: false, linkedGoalName: nil, date: calendar.date(byAdding: .day, value: -30, to: now)!)
        ]
    }
}

extension Color {
    static func fromName(_ name: String) -> Color {
        switch name {
        case "orange": return .orange
        case "purple": return .purple
        case "green": return .green
        case "mint": return .mint
        case "red": return .red
        case "gray": return .gray
        case "blue": return .blue
        case "orange.opacity15": return Color.orange.opacity(0.15)
        case "purple.opacity15": return Color.purple.opacity(0.15)
        case "green.opacity15": return Color.green.opacity(0.15)
        case "mint.opacity15": return Color.mint.opacity(0.15)
        case "red.opacity15": return Color.red.opacity(0.15)
        case "gray.opacity15": return Color.gray.opacity(0.15)
        case "blue.opacity15": return Color.blue.opacity(0.15)
        default: return .gray
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

enum TransactionCategory: String, CaseIterable, Identifiable {
    case essentials, leisure, savings, income, bills, other

    var id: String { rawValue }
    var label: String {
        switch self {
        case .essentials: return "Essentials"
        case .leisure: return "Leisure"
        case .savings: return "Savings"
        case .income: return "Income"
        case .bills: return "Bills"
        case .other: return "Other"
        }
    }
    var symbol: String { icons.first ?? "questionmark" }
    var icons: [String] {
        switch self {
        case .essentials: return [
            "cart", "fork.knife", "bag", "cup.and.saucer", "takeoutbag.and.cup.and.straw", "cart.badge.plus", "cart.badge.minus", "basket"
        ]
        case .leisure: return [
            "gamecontroller", "music.note", "music.mic", "film", "sportscourt", "theatermasks", "paintpalette", "headphones"
        ]
        case .savings: return [
            "banknote", "dollarsign.circle", "laptopcomputer", "car", "house", "gift", "creditcard", "cart", "bag", "airplane"
        ]
        case .income: return [
            "dollarsign.circle", "creditcard", "arrow.down.circle", "arrow.up.circle", "wallet.pass"
        ]
        case .bills: return [
            "doc.text", "calendar", "creditcard", "envelope", "tray.full"
        ]
        case .other: return [
            "ellipsis", "questionmark.circle", "star", "circle", "square", "app"
        ]
        }
    }
    var color: Color {
        switch self {
        case .essentials: return .orange
        case .leisure: return .purple
        case .savings: return .green
        case .income: return .mint
        case .bills: return .red
        case .other: return .gray
        }
    }
}

enum RecurringFrequency: String, CaseIterable, Identifiable {
    case daily, weekly, monthly, yearly
    var id: String { rawValue }
    var label: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}

// MARK: - Custom Segmented Control
struct BrandSegmentedPicker<T: Hashable & Identifiable & CustomStringConvertible>: View {
    @Binding var selection: T
    var options: [T]
    var accessibilityLabel: String?
    @Namespace private var animationNamespace
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.systemGray5))
            HStack(spacing: 0) {
                ForEach(options) { option in
                    Button(action: { withAnimation(.spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0.25)) { selection = option } }) {
                        Text(option.description)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(selection == option ? .white : AppColors.brandBlack)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                ZStack {
                                    if selection == option {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(AppColors.brandBlack)
                                            .matchedGeometryEffect(id: "switcher", in: animationNamespace)
                                    }
                                }
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(option.description)
                    .accessibilityAddTraits(selection == option ? .isSelected : .isButton)
                }
            }
        }
        .frame(height: 44)
        .padding(.vertical, 2)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel ?? "")
    }
}

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var title: String = ""
    @State private var category: TransactionCategory = .essentials
    @State private var iconName: String = TransactionCategory.essentials.symbol
    @State private var iconColorName: String = TransactionCategory.essentials.color.toHex()
    @State private var iconBackgroundName: String = "orange.opacity15"
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var isRecurringBool: Bool = false
    @State private var recurringFrequency: RecurringFrequency = .monthly
    @State private var notifyMe: Bool = false
    @State private var incomeOrExpense: IncomeOrExpense = .expense
    @State private var selectedCategory: TransactionCategory = .essentials
    let availableGoals: [GoalFormData]
    @State private var selectedGoal: GoalFormData? = nil
    var onSave: (Transaction) -> Void

    // Bridge for BrandSegmentedPicker
    private var isRecurring: BoolOption {
        get { BoolOption(isRecurringBool) }
        set { isRecurringBool = newValue.value }
    }

    private var isRecurringBinding: Binding<BoolOption> {
        Binding<BoolOption>(
            get: { BoolOption(isRecurringBool) },
            set: { isRecurringBool = $0.value }
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Enhanced Sheet Header with gradient background
                ZStack(alignment: .topLeading) {
                    LinearGradient(
                        colors: [AppColors.brandBlack, AppColors.brandBlack.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(
                        RoundedCorner(radius: 28, corners: [.topLeft, .topRight])
                    )
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 64)
                    
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Cancel")
                                    .font(.body.weight(.semibold))
                            }
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.15))
                            )
                        }
                        .padding(.leading, AppPaddings.section)
                        
                        Spacer()
                        
                        Text("New Transaction")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Placeholder for balance
                        Color.clear
                            .frame(width: 80)
                    }
                    .frame(height: 64)
                }
                .accessibilityElement(children: .combine)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        amountSection
                        titleSection
                        incomeOrExpenseSection
                        iconPickerSection
                        typeSection
                        if isRecurringBool { frequencySection }
                        dateSection
                        notificationSection
                        goalLinkSection
                        notesSection
                        saveButtonSection
                    }
                    .padding(.horizontal, AppPaddings.section)
                    .padding(.bottom, AppPaddings.large)
                }
                .background(AppColors.background)
                .contentShape(Rectangle())
                .simultaneousGesture(TapGesture().onEnded { UIApplication.shared.endEditing() })
            }
            .toolbar { EmptyView() } // Remove default toolbar
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transaction Details")
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
            Text("Fill in the details below to add your transaction")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }
    
    private var amountSection: some View {
        let preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD (US Dollar)"
        let currencyCode = preferredCurrency.components(separatedBy: " ").first ?? "USD"
        let currencySymbol = Locale.availableIdentifiers.compactMap { Locale(identifier: $0) }
            .first(where: { $0.currency?.identifier == currencyCode })?.currencySymbol ?? "$"
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(AppColors.brandGreen)
                    .font(.title2)
                Text("Amount")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                
                HStack(spacing: 12) {
                    Text(currencySymbol)
                        .font(.title.weight(.bold))
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)
                    
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 20)
            }
            .frame(height: 72)
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "textformat")
                    .foregroundColor(AppColors.brandBlue)
                    .font(.title2)
                Text("Title")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            TextField("e.g. Coffee, Rent, Salary", text: $title)
                .font(.body)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                )
        }
    }
    
    private var incomeOrExpenseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .foregroundColor(AppColors.brandPurple)
                    .font(.title2)
                Text("Transaction Type")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            BrandSegmentedPicker(selection: $incomeOrExpense, options: IncomeOrExpense.allCases, accessibilityLabel: "Income or Expense")
                .padding(.horizontal, 4)
        }
    }
    
    private var iconPickerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(AppColors.brandOrange)
                    .font(.title2)
                Text("Category & Icon")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            // Category selection with enhanced visual feedback
            VStack(spacing: 12) {
                Text("Choose Category")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(TransactionCategory.allCases) { cat in
                        Button(action: {
                            selectedCategory = cat
                            category = cat
                            iconName = cat.symbol
                            iconColorName = cat.color.toHex()
                            iconBackgroundName = cat.color.toHex() + ".opacity15"
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(selectedCategory == cat ? cat.color : cat.color.opacity(0.15))
                                        .frame(width: 48, height: 48)
                                    
                                    Image(systemName: cat.symbol)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(selectedCategory == cat ? .white : cat.color)
                                }
                                
                                Text(cat.label)
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(selectedCategory == cat ? cat.color : .primary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedCategory == cat ? cat.color.opacity(0.1) : Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(selectedCategory == cat ? cat.color : Color.clear, lineWidth: 2)
                                    )
                            )
                            .shadow(color: selectedCategory == cat ? cat.color.opacity(0.2) : Color.black.opacity(0.05), radius: 8, y: 2)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(cat.label)
                        .accessibilityAddTraits(selectedCategory == cat ? .isSelected : .isButton)
                    }
                }
            }
            
            // Icon selection for selected category
            if !selectedCategory.icons.isEmpty {
                VStack(spacing: 12) {
                    Text("Choose Icon")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(selectedCategory.icons, id: \.self) { icon in
                                Button(action: {
                                    iconName = icon
                                    iconColorName = selectedCategory.color.toHex()
                                    iconBackgroundName = selectedCategory.color.toHex() + ".opacity15"
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(iconName == icon ? selectedCategory.color : selectedCategory.color.opacity(0.15))
                                            .frame(width: iconName == icon ? 56 : 48, height: iconName == icon ? 56 : 48)
                                        
                                        Image(systemName: icon)
                                            .font(.system(size: iconName == icon ? 24 : 20, weight: .semibold))
                                            .foregroundColor(iconName == icon ? .white : selectedCategory.color)
                                    }
                                    .overlay(
                                        Circle()
                                            .stroke(iconName == icon ? selectedCategory.color : Color.clear, lineWidth: 3)
                                    )
                                    .scaleEffect(iconName == icon ? 1.1 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: iconName == icon)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(icon)
                                .accessibilityAddTraits(iconName == icon ? .isSelected : .isButton)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
        }
    }
    
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "repeat.circle.fill")
                    .foregroundColor(AppColors.brandTeal)
                    .font(.title2)
                Text("Transaction Type")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            BrandSegmentedPicker(selection: isRecurringBinding, options: [BoolOption(false), BoolOption(true)], accessibilityLabel: "Transaction Type")
                .padding(.horizontal, 4)
        }
    }
    
    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(AppColors.brandIndigo)
                    .font(.title2)
                Text("Recurring Frequency")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            BrandSegmentedPicker(selection: $recurringFrequency, options: RecurringFrequency.allCases, accessibilityLabel: "Recurring Frequency")
                .padding(.horizontal, 4)
        }
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(AppColors.brandPink)
                    .font(.title2)
                Text("Date")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
        }
    }
    
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell.badge.fill")
                    .foregroundColor(AppColors.brandYellow)
                    .font(.title2)
                Text("Notifications")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Toggle(isOn: $notifyMe) {
                    EmptyView()
                }
                .tint(AppColors.brandGreen)
                .scaleEffect(0.9)
            }
            
            if notifyMe {
                Text("You'll be notified about this transaction")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 32)
            }
        }
    }
    
    private var goalLinkSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(AppColors.brandRed)
                    .font(.title2)
                Text("Link to Savings Goal")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            if availableGoals.isEmpty {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                        .font(.body)
                    Text("No savings goals available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
            } else {
                Menu {
                    Button("None") {
                        selectedGoal = nil
                    }
                    
                    ForEach(availableGoals, id: \.name) { goal in
                        Button(action: { selectedGoal = goal }) {
                            HStack {
                                Image(systemName: goal.iconName)
                                    .foregroundColor(goal.iconColor)
                                Text(goal.name)
                            }
                        }
                    }
                } label: {
                    HStack {
                        if let selectedGoal = selectedGoal {
                            HStack(spacing: 8) {
                                Image(systemName: selectedGoal.iconName)
                                    .foregroundColor(selectedGoal.iconColor)
                                    .font(.body)
                                Text(selectedGoal.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "target")
                                    .foregroundColor(.secondary)
                                    .font(.body)
                                Text("Select a goal (optional)")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                    )
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(AppColors.brandCyan)
                    .font(.title2)
                Text("Notes")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            TextField("Add a note about this transaction...", text: $notes, axis: .vertical)
                .font(.body)
                .lineLimit(3...6)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                )
        }
    }
    
    private var saveButtonSection: some View {
        VStack(spacing: 16) {
            Button(action: save) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                    Text("Save Transaction")
                        .font(.headline.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(title.isEmpty || amount.isEmpty ? Color(.systemGray4) : AppColors.brandBlack)
                        .shadow(color: title.isEmpty || amount.isEmpty ? Color.clear : AppColors.brandBlack.opacity(0.3), radius: 8, y: 4)
                )
                .foregroundColor(.white)
            }
            .disabled(title.isEmpty || amount.isEmpty)
            .scaleEffect(title.isEmpty || amount.isEmpty ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: title.isEmpty || amount.isEmpty)
            
            if title.isEmpty || amount.isEmpty {
                Text("Please fill in the title and amount to continue")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 8)
    }

    private func save() {
        let value = Double(amount.replacingOccurrences(of: "$", with: "")) ?? 0
        // Store the amount as positive, use isIncome to determine if it's income or expense
        
        let newTransaction = Transaction(
            id: UUID(),
            title: title,
            subtitle: notes,
            amount: value,
            iconName: iconName,
            iconColorName: iconColorName,
            iconBackgroundName: iconBackgroundName,
            category: category,
            isIncome: incomeOrExpense == .income,
            linkedGoalName: selectedGoal?.name,
            date: Date()
        )
        onSave(newTransaction)
        // If notifyMe is enabled, schedule notifications for 5 days before, 2 days before, and on the day of the transaction date.
        // Use the selected 'date' and 'recurringFrequency' to determine the next occurrence(s).
        // Notification scheduling logic should be implemented here (using UNUserNotificationCenter, etc.).
    }
}

// Helper for Bool option
struct BoolOption: Identifiable, Hashable, CustomStringConvertible {
    let value: Bool
    var id: Bool { value }
    var description: String { value ? "Recurring" : "One Time" }
    init(_ value: Bool) { self.value = value }
    static func == (lhs: BoolOption, rhs: BoolOption) -> Bool { lhs.value == rhs.value }
    func hash(into hasher: inout Hasher) { hasher.combine(value) }
}

// Conform RecurringFrequency to CustomStringConvertible
extension RecurringFrequency: CustomStringConvertible {
    var description: String { label }
}

// MARK: - IncomeOrExpense Enum
enum IncomeOrExpense: String, CaseIterable, Identifiable, CustomStringConvertible {
    case income = "Income"
    case expense = "Expense"
    var id: String { rawValue }
    var description: String { rawValue }
}

struct TransactionDetailView: View {
    let transaction: Transaction
    var onSave: (Transaction) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var note: String
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedAmount: String
    @State private var editedCategory: TransactionCategory
    @State private var editedIconName: String
    @State private var editedDate: Date
    @State private var editedLinkedGoalName: String?
    // For demo, we just update the local note. In a real app, this would persist to storage or view model.
    init(transaction: Transaction, onSave: @escaping (Transaction) -> Void) {
        self.transaction = transaction
        self.onSave = onSave
        _note = State(initialValue: transaction.subtitle)
        _editedTitle = State(initialValue: transaction.title)
        _editedAmount = State(initialValue: String(format: "%g", transaction.amount))
        _editedCategory = State(initialValue: transaction.category)
        _editedIconName = State(initialValue: transaction.iconName)
        _editedDate = State(initialValue: Date.now) // Replace with transaction.date if available
        _editedLinkedGoalName = State(initialValue: transaction.linkedGoalName)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { UIApplication.shared.endEditing() }
            Capsule()
                .fill(Color.secondary.opacity(0.25))
                .frame(width: 40, height: 5)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .onTapGesture { dismiss() }

            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(editedCategory.color.opacity(0.18))
                        .frame(width: 56, height: 56)
                    Image(systemName: editedIconName)
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(editedCategory.color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    if isEditing {
                        TextField("Title", text: $editedTitle)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        // Icon picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(editedCategory.icons, id: \.self) { icon in
                                    Button(action: { editedIconName = icon }) {
                                        ZStack {
                                            Circle()
                                                .fill(editedIconName == icon ? editedCategory.color : Color(.systemGray5))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: icon)
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(editedIconName == icon ? .white : editedCategory.color)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        Text(transaction.title)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        if !transaction.subtitle.isEmpty {
                            Text(transaction.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            Divider().padding(.vertical, 4)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Amount")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                    if isEditing {
                        let preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD (US Dollar)"
                        let currencyCode = preferredCurrency.components(separatedBy: " ").first ?? "USD"
                        let currencySymbol = Locale.availableIdentifiers.compactMap { Locale(identifier: $0) }
                            .first(where: { $0.currency?.identifier == currencyCode })?.currencySymbol ?? "$"
                        ZStack(alignment: .leading) {
                            Text(currencySymbol)
                                .font(.body.weight(.semibold))
                                .foregroundColor(.secondary)
                                .padding(.leading, 8)
                            TextField("0.00", text: $editedAmount)
                                .keyboardType(.decimalPad)
                                .font(.title3.weight(.semibold))
                                .foregroundColor((Double(editedAmount) ?? 0) >= 0 ? .green : .red)
                                .multilineTextAlignment(.trailing)
                                .padding(.leading, 32)
                                .frame(width: 100)
                        }
                    } else {
                        Text(transaction.amount, format: .currency(code: "USD"))
                            .font(.title3.weight(.semibold))
                            .foregroundColor(transaction.amount >= 0 ? .green : .red)
                    }
                }
                HStack {
                    Text("Category")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                    if isEditing {
                        Picker("Category", selection: $editedCategory) {
                            ForEach(TransactionCategory.allCases) { cat in
                                Text(cat.label).tag(cat)
                            }
                        }
                        .pickerStyle(.menu)
                    } else {
                        Label(transaction.category.label, systemImage: transaction.category.symbol)
                            .font(.body)
                            .foregroundColor(transaction.category.color)
                    }
                }
                if isEditing {
                    // Linked Goal Picker (if needed)
                }
                if let linkedGoalName = transaction.linkedGoalName {
                    HStack {
                        Text("Linked Goal")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                        if isEditing {
                            TextField("Linked Goal", text: Binding(
                                get: { editedLinkedGoalName ?? "" },
                                set: { editedLinkedGoalName = $0.isEmpty ? nil : $0 }
                            ))
                                .font(.body)
                                .foregroundColor(.primary)
                        } else {
                            Text(linkedGoalName)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    }
                }
                HStack {
                    Text("Date & Time")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                    if isEditing {
                        DatePicker("", selection: $editedDate, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                    } else {
                        Text(editedDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Note")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    if isEditing {
                        TextField("Add a note...", text: $note, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                            .foregroundColor(.primary)
                    } else {
                        Text(note.isEmpty ? "No note" : note)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
            }
            HStack {
                if isEditing {
                    Button(action: { isEditing = false }) {
                        Text("Cancel")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                    Button(action: {
                        // Save logic: create new Transaction and call onSave
                        let updatedTransaction = Transaction(
                            id: transaction.id,
                            title: editedTitle,
                            subtitle: note,
                            amount: Double(editedAmount) ?? 0,
                            iconName: editedIconName,
                            iconColorName: editedCategory.color.toHex(),
                            iconBackgroundName: editedCategory.color.toHex() + ".opacity15",
                            category: editedCategory,
                            isIncome: editedCategory == .income,
                            linkedGoalName: editedLinkedGoalName,
                            date: editedDate
                        )
                        onSave(updatedTransaction)
                        isEditing = false
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.brandBlack)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                } else {
                    Button(action: { isEditing = true }) {
                        Text("Edit")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.brandBlack)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// Helper to dismiss keyboard
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
