import SwiftUI
import Foundation

// MARK: - TransactionsView

struct TransactionsView: View {
    // MARK: - Properties
    @Environment(\.dependencies) private var dependencies
    @StateObject private var viewModel: TransactionsViewModel
    @State private var showAddTransaction = false
    @State private var selectedTransaction: Transaction? = nil
    @Binding var searchText: String
    @Binding var isSearching: Bool
    
    // MARK: - Initialization
    
    init(searchText: Binding<String> = .constant(""), isSearching: Binding<Bool> = .constant(false)) {
        self._searchText = searchText
        self._isSearching = isSearching
        // Initialize with dependencies - will be injected via environment
        self._viewModel = StateObject(wrappedValue: TransactionsViewModel(
            transactionRepository: DependencyContainer.shared.transactionRepo,
            goalRepository: DependencyContainer.shared.goalRepo
        ))
    }
    
    // MARK: - Computed Properties
    
    private var searchFilteredTransactions: [Transaction] {
        if searchText.isEmpty {
            return viewModel.filteredTransactions
        } else {
            return viewModel.filteredTransactions.filter { transaction in
                (transaction.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (transaction.subtitle?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (transaction.category?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                RobinhoodColors.background.ignoresSafeArea()
                
                if viewModel.isLoading {
                    loadingView
                } else {
                    mainContentView
                }
                
                floatingActionButton
            }
            .sheet(isPresented: $showAddTransaction) {
                addTransactionSheet
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.regularMaterial)
                    .presentationCornerRadius(16)
                    .presentationCompactAdaptation(.sheet)
            }
            .sheet(item: $selectedTransaction) { transaction in
                transactionDetailSheet(for: transaction)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.regularMaterial)
                    .presentationCornerRadius(16)
                    .presentationCompactAdaptation(.sheet)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
            .onAppear {
                Task {
                    await viewModel.loadTransactions()
                }
            }
        }
    }
    
    
    // MARK: - View Components
    
    /// Get currency code from user preferences
    private func getCurrencyCode() -> String {
        let preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD (US Dollar)"
        return preferredCurrency.components(separatedBy: " ").first ?? "USD"
    }
    
    /// Loading view displayed while data is being fetched
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(RobinhoodColors.primary)
            Text("Loading transactions...")
                .font(RobinhoodTypography.body)
                .foregroundColor(RobinhoodColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Main content view with transactions - static header and scrollable content
    private var mainContentView: some View {
        VStack(spacing: 0) {
            // Static header section - fixed at top
            VStack(spacing: 0) {
                headerSection
                filterChipsSection
            }
            .background(RobinhoodColors.background)
            .zIndex(1)
            
            // Scrollable content section
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    contentSection
                }
                .padding(.bottom, 80) // For FAB spacing
            }
            .background(RobinhoodColors.background)
        }
    }
    
    /// Floating action button for adding transactions
    private var floatingActionButton: some View {
        Button(action: { showAddTransaction = true }) {
            ZStack {
                Circle()
                    .fill(RobinhoodColors.primary)
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.black)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
    
    /// Sheet for adding new transactions
    private var addTransactionSheet: some View {
        AddTransactionView { amount, category, description, isIncome in
            Task {
                await viewModel.createTransaction(
                    amount: amount,
                    category: category,
                    description: description,
                    isIncome: isIncome
                )
            }
            showAddTransaction = false
        }
    }
    
    /// Sheet for displaying transaction details
    private func transactionDetailSheet(for transaction: Transaction) -> some View {
        TransactionDetailView(transaction: transaction) { updatedTransaction in
            Task {
                await viewModel.updateTransaction(updatedTransaction)
            }
        }
    }

    /// Modern header section with title and summary
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Transactions")
                        .font(RobinhoodTypography.largeTitle)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Text("Track your income and expenses")
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                }
                
                Spacer()
                
                // Quick stats
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(viewModel.filteredTransactions.count)")
                        .font(RobinhoodTypography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Text("Total")
                        .font(RobinhoodTypography.caption2)
                        .foregroundColor(RobinhoodColors.textTertiary)
                }
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }

    /// Modern filter chips for category selection
    private var filterChipsSection: some View {
        FilterChips(selected: $viewModel.selectedCategory)
            .padding(.top, 16)
            .padding(.horizontal, 20)
    }

    /// Main content section
    private var contentSection: some View {
        Group {
            if isSearching && searchText.isEmpty {
                emptySearchStateSection
            } else if searchFilteredTransactions.isEmpty {
                if searchText.isEmpty {
                    emptyStateSection
                } else {
                    noSearchResultsSection
                }
            } else {
                transactionListSection
            }
        }
    }

    /// Modern empty state when no transactions are available
    private var emptyStateSection: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 20) {
                // Modern icon with background
                ZStack {
                    Circle()
                        .fill(RobinhoodColors.primary.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "creditcard")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(RobinhoodColors.primary)
                }
                
                VStack(spacing: 12) {
                    Text("No Transactions Yet")
                        .font(RobinhoodTypography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Text("Start tracking your finances by adding your first transaction")
                        .font(RobinhoodTypography.body)
                        .foregroundColor(RobinhoodColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                
                // Call to action button
                Button(action: { showAddTransaction = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Add First Transaction")
                            .font(RobinhoodTypography.callout)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Color.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(RobinhoodColors.primary)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
    
    /// Empty search state section (when search is active but no text entered)
    private var emptySearchStateSection: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 20) {
                // Search icon with background
                ZStack {
                    Circle()
                        .fill(RobinhoodColors.textTertiary.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(RobinhoodColors.textTertiary)
                }
                
                VStack(spacing: 12) {
                    Text("Search Transactions")
                        .font(RobinhoodTypography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Text("Enter a search term to find transactions")
                        .font(RobinhoodTypography.body)
                        .foregroundColor(RobinhoodColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
    
    /// No search results state
    private var noSearchResultsSection: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 20) {
                // Search icon with background
                ZStack {
                    Circle()
                        .fill(RobinhoodColors.textTertiary.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundColor(RobinhoodColors.textTertiary)
                }
                
                VStack(spacing: 12) {
                    Text("No Results Found")
                        .font(RobinhoodTypography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(RobinhoodColors.textPrimary)
                    
                    Text("No transactions match \"\(searchText)\"")
                        .font(RobinhoodTypography.body)
                        .foregroundColor(RobinhoodColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
                
                // Clear search button
                Button(action: { searchText = "" }) {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Clear Search")
                            .font(RobinhoodTypography.callout)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(RobinhoodColors.textSecondary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(RobinhoodColors.cardBackground)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }

    /// Modern list view for displaying transactions
    private var transactionListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(isSearching ? "Search Results" : "Recent Transactions")
                    .font(RobinhoodTypography.headline)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                Spacer()
                
                Text("\(searchFilteredTransactions.count) items")
                    .font(RobinhoodTypography.caption2)
                    .foregroundColor(RobinhoodColors.textTertiary)
            }
            .padding(.top, 24)
            .padding(.horizontal, 20)
            
            LazyVStack(spacing: 12) {
                ForEach(searchFilteredTransactions) { transaction in
                    Button(action: { selectedTransaction = transaction }) {
                        RobinhoodTransactionCard(
                            transaction: transaction.toTransactionItem(),
                            currencyCode: getCurrencyCode()
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 16)
            .padding(.horizontal, 20)
            .padding(.bottom, 100) // For FAB spacing
        }
    }
}

// MARK: - FilterChips

struct FilterChips: View {
    // MARK: - Properties
    @Binding var selected: TransactionCategoryType?
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                allButton
                categoryButtons
            }
        }
    }
    
    // MARK: - View Components
    
    /// Modern all categories button
    private var allButton: some View {
        Button(action: { selected = nil }) {
            Text("All")
                .font(RobinhoodTypography.callout)
                .fontWeight(.semibold)
                .foregroundColor(selected == nil ? Color.black : RobinhoodColors.textPrimary)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selected == nil ? RobinhoodColors.primary : RobinhoodColors.cardBackground)
                )
        }
        .accessibilityLabel("All")
        .accessibilityAddTraits(selected == nil ? .isSelected : .isButton)
    }
    
    /// Category filter buttons
    private var categoryButtons: some View {
        ForEach(TransactionCategoryType.allCases) { category in
            categoryButton(for: category)
        }
    }
    
    /// Modern individual category button
    private func categoryButton(for category: TransactionCategoryType) -> some View {
        Button(action: { selected = category }) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(selected == category ? Color.black : RobinhoodColors.success.opacity(0.15))
                        .frame(width: 20, height: 20)
                    Image(systemName: category.symbol)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(selected == category ? RobinhoodColors.success : RobinhoodColors.success)
                }
                Text(category.label)
                    .font(RobinhoodTypography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(selected == category ? Color.black : RobinhoodColors.textPrimary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 120)
                    .fill(selected == category ? RobinhoodColors.success : RobinhoodColors.cardBackground)
            )
        }
        .accessibilityLabel(category.label)
        .accessibilityAddTraits(selected == category ? .isSelected : .isButton)
    }
}

// MARK: - Robinhood Transaction Card

struct RobinhoodTransactionCard: View {
    let transaction: TransactionItem
    let currencyCode: String
    
    private var categoryIcon: String {
        switch transaction.category {
        case .essentials: return "fork.knife"
        case .leisure: return "gamecontroller"
        case .savings: return "banknote"
        case .income: return "dollarsign.circle"
        case .bills: return "doc.text"
        case .other: return "ellipsis"
        }
    }
    
    private var categoryColor: Color {
        switch transaction.category {
        case .essentials: return RobinhoodColors.error
        case .leisure: return RobinhoodColors.warning
        case .savings: return RobinhoodColors.success
        case .income: return RobinhoodColors.success
        case .bills: return RobinhoodColors.primary
        case .other: return RobinhoodColors.textTertiary
        }
    }
    
    private var amountColor: Color {
        transaction.isIncome ? RobinhoodColors.success : RobinhoodColors.error
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Category icon
            ZStack {
                Circle()
                    .fill(RobinhoodColors.success.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: categoryIcon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(RobinhoodColors.success)
            }
            
            // Transaction details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(RobinhoodTypography.headline)
                    .foregroundColor(RobinhoodColors.textPrimary)
                    .lineLimit(1)
                
                if !transaction.subtitle.isEmpty {
                    Text(transaction.subtitle)
                        .font(RobinhoodTypography.caption)
                        .foregroundColor(RobinhoodColors.textSecondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    Text(transaction.category.label)
                        .font(RobinhoodTypography.caption2)
                        .foregroundColor(RobinhoodColors.success)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 120)
                                .fill(RobinhoodColors.success.opacity(0.1))
                        )
                    
                    Text(transaction.date, format: .dateTime.month().day().hour().minute())
                        .font(RobinhoodTypography.caption2)
                        .foregroundColor(RobinhoodColors.textTertiary)
                }
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 2) {
                Text(transaction.amount.formatted(.currency(code: currencyCode).precision(.fractionLength(2))))
                    .font(RobinhoodTypography.callout)
                    .fontWeight(.bold)
                    .foregroundColor(amountColor)
                
                Text(transaction.isIncome ? "Income" : "Expense")
                    .font(RobinhoodTypography.caption2)
                    .foregroundColor(RobinhoodColors.textTertiary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(RobinhoodColors.cardBackground)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Legacy TransactionRow (kept for compatibility)

struct TransactionRow: View {
    // MARK: - Properties
    let transaction: TransactionItem
    @AppStorage("preferredCurrency") private var preferredCurrency: String = "USD"
    
    // MARK: - Computed Properties
    
    /// Currency code extracted from preferred currency string
    private var currencyCode: String {
        preferredCurrency.components(separatedBy: " ").first ?? "USD"
    }
    
    /// Color for the transaction amount based on income/expense
    private var transactionColor: Color {
        transaction.isIncome ? AppColors.success : AppColors.error
    }
    
    // MARK: - Body
    
    var body: some View {
        AppCard(style: .default, padding: .medium) {
            HStack(spacing: AppPaddings.lg) {
                iconSection
                transactionDetailsSection
                Spacer()
                amountSection
            }
        }
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - View Components
    
    /// Icon section with background circle
    private var iconSection: some View {
        ZStack {
            Circle()
                .fill(transaction.iconBackground)
                .frame(width: AppSizes.iconXXXLarge, height: AppSizes.iconXXXLarge)
            Image(systemName: transaction.iconName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(transaction.iconColor)
        }
    }
    
    /// Transaction details section
    private var transactionDetailsSection: some View {
        VStack(alignment: .leading, spacing: AppPaddings.xs) {
            Text(transaction.title)
                .font(.h5)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
            
            if !transaction.subtitle.isEmpty {
                Text(transaction.subtitle)
                    .font(.bodySmall)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            
            Text(transaction.date, format: .dateTime.month().day().hour().minute())
                .font(.caption)
                .foregroundColor(AppColors.textTertiary)
        }
    }
    
    /// Amount and category section
    private var amountSection: some View {
        VStack(alignment: .trailing, spacing: AppPaddings.xs) {
            Text(transaction.amount, format: .currency(code: currencyCode).precision(.fractionLength(2)))
                .font(.h5)
                .foregroundColor(transactionColor)
            
            Text(transaction.category.label)
                .font(.caption)
                .foregroundColor(transaction.category.color)
        }
    }
    
}











struct AddTransactionViewWithPreselection: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var title: String = ""
    @State private var category: TransactionCategoryType = .essentials
    @State private var iconName: String = TransactionCategoryType.essentials.symbol
    @State private var iconColorName: String = TransactionCategoryType.essentials.color.toHex()
    @State private var iconBackgroundName: String = "orange.opacity15"
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var isRecurringBool: Bool = false
    @State private var recurringFrequency: RecurringFrequency = .monthly
    @State private var notifyMe: Bool = false
    @State private var incomeOrExpense: IncomeOrExpense
    @State private var selectedCategory: TransactionCategoryType = .essentials
    let availableGoals: [GoalFormItem]
    @State private var selectedGoal: GoalFormItem? = nil
    var onSave: (TransactionItem) -> Void
    
    init(availableGoals: [GoalFormItem], preSelectedType: IncomeOrExpense, onSave: @escaping (TransactionItem) -> Void) {
        self.availableGoals = availableGoals
        self.onSave = onSave
        self._incomeOrExpense = State(initialValue: preSelectedType)
    }


    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Transaction type selection
                        transactionTypeSection
                    
                    // Form fields
                    VStack(spacing: 20) {
                        // Amount input
                        amountInputSection
                        
                        // Title input
                        titleInputSection
                        
                        // Category selection
                        categorySelectionSection
                        
                        // Date and recurring
                        dateAndRecurringSection
                        
                        // Goal linking
                        goalLinkingSection
                        
                        // Notes
                        notesSection
                    }
                    
                        // Save button
                        saveButtonSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    // MARK: - Transaction Type Selection
    private var transactionTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transaction Type")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                // Income button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        incomeOrExpense = .income
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title3.weight(.semibold))
                        
                        Text("Income")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundColor(incomeOrExpense == .income ? AppColors.secondary : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(incomeOrExpense == .income ? AppColors.secondary : Color.gray.opacity(0.2))
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add income transaction")
                
                // Expense button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        incomeOrExpense = .expense
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title3.weight(.semibold))
                        
                        Text("Expense")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundColor(incomeOrExpense == .expense ? AppColors.primary : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(incomeOrExpense == .expense ? AppColors.primary.opacity(0.1) : Color.gray.opacity(0.2))
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add expense transaction")
            }
        }
    }
    
    // MARK: - Amount Input Section
    private var amountInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amount")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            HStack {
                Text("$")
                    .font(.title.weight(.bold))
                    .foregroundColor(AppColors.primary)
                
                TextField("0.00", text: $amount)
                    .font(.title.weight(.bold))
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.plain)
                    .onChange(of: amount) { _, newValue in
                        // Format the amount as user types
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        if filtered != newValue {
                            amount = filtered
                        }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    // MARK: - Title Input Section
    private var titleInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Title")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            TextField("Enter transaction title", text: $title)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                )
        }
    }
    
    // MARK: - Category Selection Section
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(TransactionCategoryType.allCases, id: \.self) { category in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                            self.category = category
                            iconName = category.symbol
                            iconColorName = category.color.toHex()
                            iconBackgroundName = "\(category.color.toHex()).opacity15"
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: category.symbol)
                                .font(.title2.weight(.semibold))
                                .foregroundColor(selectedCategory == category ? .white : category.color)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(selectedCategory == category ? category.color : Color(.systemGray6))
                                )
                            
                            Text(category.label)
                                .font(.caption.weight(.medium))
                                .foregroundColor(selectedCategory == category ? RobinhoodColors.primary : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(selectedCategory == category ? category.color.opacity(0.1) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Date and Recurring Section
    private var dateAndRecurringSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Date picker
            VStack(alignment: .leading, spacing: 12) {
                Text("Date")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            
            // Recurring toggle
            VStack(alignment: .leading, spacing: 12) {
                Text("Recurring")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                
                Picker("Recurring", selection: $isRecurringBool) {
                    Text("One Time").tag(false)
                    Text("Recurring").tag(true)
                }
                .pickerStyle(.segmented)
                .tint(RobinhoodColors.primary)
                .background(RobinhoodColors.cardBackground)
                .cornerRadius(8)
            }
            
            // Recurring frequency (only show if recurring is enabled)
            if isRecurringBool {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Frequency")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                    
                    Picker("Frequency", selection: $recurringFrequency) {
                        ForEach(RecurringFrequency.allCases) { frequency in
                            Text(frequency.label).tag(frequency)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(RobinhoodColors.primary)
                    .background(RobinhoodColors.cardBackground)
                    .cornerRadius(8)
                }
            }
        }
    }
    
    // MARK: - Goal Linking Section
    private var goalLinkingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Link to Goal (Optional)")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            if availableGoals.isEmpty {
                Text("No goals available")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                Menu {
                    Button("No Goal") {
                        selectedGoal = nil
                    }
                    
                    ForEach(availableGoals, id: \.name) { goal in
                        Button(goal.name) {
                            selectedGoal = goal
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedGoal?.name ?? "Select a goal")
                            .font(.body)
                            .foregroundColor(selectedGoal == nil ? .secondary : RobinhoodColors.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray6))
                    )
                }
            }
        }
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes (Optional)")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            TextField("Add a note", text: $notes, axis: .vertical)
                .font(.body)
                .lineLimit(3...6)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                )
        }
    }
    
    // MARK: - Save Button Section
    private var saveButtonSection: some View {
        Button(action: save) {
            Text("Save Transaction")
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppColors.primary)
                )
        }
        .buttonStyle(.plain)
        .disabled(amount.isEmpty || title.isEmpty)
        .opacity(amount.isEmpty || title.isEmpty ? 0.6 : 1.0)
    }
    
    private func save() {
        let value = Double(amount.replacingOccurrences(of: "$", with: "")) ?? 0
        // Store the amount as positive, use isIncome to determine if it's income or expense
        
        let newTransaction = TransactionItem(
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
    
    // MARK: - Helper Functions
    
    /// Helper function to hide keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


