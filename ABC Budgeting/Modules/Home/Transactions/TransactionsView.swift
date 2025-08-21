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
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    filterChipsSection
                    contentSection
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
        case "orange.opacity15": return Color.orange.opacity(0.15)
        case "purple.opacity15": return Color.purple.opacity(0.15)
        case "green.opacity15": return Color.green.opacity(0.15)
        case "mint.opacity15": return Color.mint.opacity(0.15)
        case "red.opacity15": return Color.red.opacity(0.15)
        case "gray.opacity15": return Color.gray.opacity(0.15)
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
                // Sheet Header with brandBlack background and rounded top corners
                ZStack(alignment: .topLeading) {
                    AppColors.brandBlack
                        .clipShape(
                            RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                        )
                        .edgesIgnoringSafeArea(.top)
                        .frame(height: 56)
                    HStack {
                        Button("Cancel") { dismiss() }
                            .foregroundColor(.white)
                            .font(.body.weight(.semibold))
                            .padding(.leading, AppPaddings.section)
                        Spacer()
                    }
                    .frame(height: 56)
                }
                .accessibilityElement(children: .combine)
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        amountSection
                        titleSection
                        iconPickerSection
                        incomeOrExpenseSection
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
        Text("Add Transaction")
            .font(.largeTitle.bold())
            .padding(.top, AppPaddings.sectionTitleTop)
    }
    private var amountSection: some View {
        let preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD (US Dollar)"
        let currencyCode = preferredCurrency.components(separatedBy: " ").first ?? "USD"
        let currencySymbol = Locale.availableIdentifiers.compactMap { Locale(identifier: $0) }
            .first(where: { $0.currency?.identifier == currencyCode })?.currencySymbol ?? "$"
        return VStack(alignment: .leading, spacing: 8) {
            Text("Amount").font(.headline)
            ZStack(alignment: .leading) {
                Text(currencySymbol)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.secondary)
                    .padding(.leading, 12)
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .foregroundColor((Double(amount) ?? 0) >= 0 ? .green : .red)
                    .padding(.vertical, AppPaddings.inputField)
                    .padding(.trailing, AppPaddings.inputField)
                    .background(Color.white)
                    .cornerRadius(12)
            }
        }
    }
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title").font(.headline)
            TextField("e.g. Coffee, Rent", text: $title)
                .padding(AppPaddings.inputField)
                .background(Color.white)
                .cornerRadius(12)
        }
    }
    private var iconPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Icon").font(.headline)
            // Category row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppPaddings.small) {
                    ForEach(TransactionCategory.allCases) { cat in
                        Button(action: {
                            selectedCategory = cat
                            category = cat
                            iconName = cat.symbol
                            iconColorName = cat.color.toHex()
                            iconBackgroundName = cat.color.toHex() + ".opacity15"
                        }) {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(cat.color.opacity(0.18))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: cat.symbol)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(selectedCategory == cat ? .white : cat.color)
                                }
                                Text(cat.label)
                                    .font(.caption)
                                    .foregroundColor(selectedCategory == cat ? .white : .primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .frame(width: 72, height: 72)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selectedCategory == cat ? cat.color : Color.clear)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(cat.label)
                        .accessibilityAddTraits(selectedCategory == cat ? .isSelected : .isButton)
                    }
                }
            }
            // Icon row for selected category
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppPaddings.small) {
                    ForEach(selectedCategory.icons, id: \.self) { icon in
                        Button(action: {
                            iconName = icon
                            iconColorName = selectedCategory.color.toHex()
                            iconBackgroundName = selectedCategory.color.toHex() + ".opacity15"
                        }) {
                            ZStack {
                                Circle()
                                    .fill(selectedCategory.color.opacity(0.18))
                                    .frame(width: iconName == icon ? 56 : 48, height: iconName == icon ? 56 : 48)
                                Image(systemName: icon)
                                    .font(.system(size: iconName == icon ? 24 : 22, weight: .semibold))
                                    .foregroundColor(iconName == icon ? .white : selectedCategory.color)
                            }
                            .frame(width: iconName == icon ? 56 : 64, height: iconName == icon ? 56 : 64)
                            .background(
                                Circle()
                                    .fill(iconName == icon ? selectedCategory.color : Color.clear)
                            )
                            .overlay(
                                Circle()
                                    .stroke(selectedCategory.color, lineWidth: iconName == icon ? 2 : 0)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(icon)
                        .accessibilityAddTraits(iconName == icon ? .isSelected : .isButton)
                    }
                }
                .padding(.top, 4)
                .padding(.vertical, 8)
            }
        }
    }
    private var incomeOrExpenseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Type of Transaction").font(.headline)
            BrandSegmentedPicker(selection: $incomeOrExpense, options: IncomeOrExpense.allCases, accessibilityLabel: "Income or Expense")
        }
    }
    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Type").font(.headline)
            BrandSegmentedPicker(selection: isRecurringBinding, options: [BoolOption(false), BoolOption(true)], accessibilityLabel: "Transaction Type")
        }
    }
    private var frequencySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Frequency").font(.headline)
            BrandSegmentedPicker(selection: $recurringFrequency, options: RecurringFrequency.allCases, accessibilityLabel: "Recurring Frequency")
        }
    }
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date").font(.headline)
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
        }
    }
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $notifyMe) {
                Text("Notify me").font(.headline)
            }
            .tint(AppColors.brandGreen)
        }
    }
    private var goalLinkSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Link to Saving Goal (optional)").font(.headline)
            if availableGoals.isEmpty {
                Text("No goals available").font(.subheadline).foregroundColor(.secondary)
            } else {
                Picker("Select a goal", selection: $selectedGoal) {
                    Text("None").tag(Optional<GoalFormData>.none)
                    ForEach(availableGoals, id: \.name) { goal in
                        HStack {
                            Image(systemName: goal.iconName)
                                .foregroundColor(goal.iconColor)
                            Text(goal.name)
                        }.tag(Optional(goal))
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes").font(.headline)
            TextField("Add a note...", text: $notes, axis: .vertical)
                .padding(AppPaddings.inputField)
                .background(Color.white)
                .cornerRadius(12)
        }
    }
    private var saveButtonSection: some View {
        Button(action: save) {
            Text("Save Transaction")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(title.isEmpty || amount.isEmpty ? Color(.systemGray4) : AppColors.brandBlack)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(title.isEmpty || amount.isEmpty)
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
