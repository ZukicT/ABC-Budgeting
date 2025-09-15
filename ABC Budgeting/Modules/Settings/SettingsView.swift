import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("preferredCurrency") private var selectedCurrency: String = "USD (US Dollar)"
    @AppStorage("displayName") private var displayName: String = "User Name"
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("baselineBalance") private var baselineBalance: Double = 0.0
    @State private var showClearDataAlert = false
    @State private var showEditNameSheet = false
    @State private var showCurrencyPicker = false
    @State private var showBaselineBalanceSheet = false
    @State private var showExportPreview = false
    @State private var showImportSheet = false
    @State private var tempDisplayName: String = ""
    @State private var newBaselineBalance: String = ""
    @State private var importText: String = ""
    @State private var importError: String? = nil
    @State private var importPreview: ImportPreview? = nil
    @Binding var transactions: [TransactionItem]
    @Binding var goals: [GoalFormItem]
    let currencies = CurrencyList.all
    
    var body: some View {
        ZStack {
            RobinhoodColors.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Modern Header
                    headerSection
                    
                    // Settings Sections
                    accountSection
                    preferencesSection
                    dataSection
                    aboutSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .alert("Clear All Data", isPresented: $showClearDataAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All Data", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This action cannot be undone. All your data, including transactions, goals, and preferences will be permanently deleted.")
        }
        .sheet(isPresented: $showBaselineBalanceSheet) {
            baselineBalanceSheet
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(16)
                .presentationCompactAdaptation(.sheet)
        }
        .sheet(isPresented: $showEditNameSheet) {
            editNameSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(16)
                .presentationCompactAdaptation(.sheet)
        }
        .sheet(isPresented: $showExportPreview) {
            exportPreviewSheet
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(16)
                .presentationCompactAdaptation(.sheet)
        }
        .sheet(isPresented: $showImportSheet) {
            importSheet
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(16)
                .presentationCompactAdaptation(.sheet)
        }
        .sheet(isPresented: $showCurrencyPicker) {
            currencyPickerSheet
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(.regularMaterial)
                .presentationCornerRadius(16)
                .presentationCompactAdaptation(.sheet)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Title and subtitle
            VStack(alignment: .leading, spacing: 8) {
                Text("Settings")
                    .font(RobinhoodTypography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(RobinhoodColors.textPrimary)
                
                Text("Manage your account and preferences")
                    .font(RobinhoodTypography.body)
                    .foregroundColor(RobinhoodColors.textSecondary)
            }
            .padding(.top, 20)
        }
    }
    
    // MARK: - Account Section
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text("Account")
                .font(RobinhoodTypography.title2)
                .fontWeight(.bold)
                .foregroundColor(RobinhoodColors.textPrimary)
                .padding(.bottom, 8)
            
            // Account settings card
            VStack(spacing: 0) {
                // Display Name
                RobinhoodSettingRow(
                    icon: "person.circle.fill",
                    iconColor: RobinhoodColors.primary,
                    title: "Display Name",
                    subtitle: displayName.isEmpty ? "Not set" : displayName,
                    action: {
                        tempDisplayName = displayName
                        showEditNameSheet = true
                    },
                    actionIcon: "pencil"
                )
                
                Divider()
                    .background(RobinhoodColors.border.opacity(0.3))
                    .padding(.leading, 56)
                
                // Starting Balance
                RobinhoodSettingRow(
                    icon: "dollarsign.circle.fill",
                    iconColor: RobinhoodColors.success,
                    title: "Starting Balance",
                    subtitle: "$\(String(format: "%.2f", baselineBalance))",
                    action: {
                        showBaselineBalanceSheet = true
                    },
                    actionIcon: "pencil"
                )
                
                Divider()
                    .background(RobinhoodColors.border.opacity(0.3))
                    .padding(.leading, 56)
                
                // Currency
                RobinhoodSettingRow(
                    icon: "globe",
                    iconColor: RobinhoodColors.primary,
                    title: "Currency",
                    subtitle: selectedCurrency,
                    action: { showCurrencyPicker = true },
                    actionIcon: "chevron.right"
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(RobinhoodColors.cardBackground)
            )
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Preferences Section
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text("Preferences")
                .font(RobinhoodTypography.title2)
                .fontWeight(.bold)
                .foregroundColor(RobinhoodColors.textPrimary)
                .padding(.bottom, 8)
            
            // Preferences card
            VStack(spacing: 0) {
                // Notifications toggle
                RobinhoodToggleRow(
                    icon: "bell.fill",
                    iconColor: RobinhoodColors.warning,
                    title: "Notifications",
                    subtitle: notificationsEnabled ? "On" : "Off",
                    isOn: $notificationsEnabled
                )
                
                Divider()
                    .background(RobinhoodColors.border.opacity(0.3))
                    .padding(.leading, 56)
                
                // Haptics toggle
                RobinhoodToggleRow(
                    icon: "hand.tap.fill",
                    iconColor: RobinhoodColors.primary,
                    title: "Haptic Feedback",
                    subtitle: hapticsEnabled ? "On" : "Off",
                    isOn: $hapticsEnabled
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(RobinhoodColors.cardBackground)
            )
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Data Section
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text("Data Management")
                .font(RobinhoodTypography.title2)
                .fontWeight(.bold)
                .foregroundColor(RobinhoodColors.textPrimary)
                .padding(.bottom, 8)
            
            // Data management card
            VStack(spacing: 0) {
                // Import data
                RobinhoodSettingRow(
                    icon: "square.and.arrow.down",
                    iconColor: RobinhoodColors.success,
                    title: "Import Data",
                    subtitle: "Import transactions and goals from CSV",
                    action: { showImportSheet = true },
                    actionIcon: "chevron.right"
                )
                
                Divider()
                    .background(RobinhoodColors.border.opacity(0.3))
                    .padding(.leading, 56)
                
                // Export data
                RobinhoodSettingRow(
                    icon: "square.and.arrow.up",
                    iconColor: RobinhoodColors.primary,
                    title: "Export Data",
                    subtitle: "Export your data to CSV format",
                    action: { showExportPreview = true },
                    actionIcon: "chevron.right"
                )
                
                Divider()
                    .background(RobinhoodColors.border.opacity(0.3))
                    .padding(.leading, 56)
                
                // Clear data
                RobinhoodSettingRow(
                    icon: "trash.fill",
                    iconColor: RobinhoodColors.error,
                    title: "Clear All Data",
                    subtitle: "Permanently delete all data",
                    action: { showClearDataAlert = true },
                    actionIcon: "chevron.right"
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(RobinhoodColors.cardBackground)
            )
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text("About")
                .font(RobinhoodTypography.title2)
                .fontWeight(.bold)
                .foregroundColor(RobinhoodColors.textPrimary)
                .padding(.bottom, 8)
            
            // About card
            NavigationLink(destination: aboutView) {
                RobinhoodSettingRow(
                    icon: "info.circle.fill",
                    iconColor: RobinhoodColors.primary,
                    title: "About ABC Budgeting",
                    subtitle: "Version 1.0.0",
                    action: {},
                    actionIcon: "chevron.right"
                )
            }
            .buttonStyle(PlainButtonStyle())
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(RobinhoodColors.cardBackground)
            )
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Edit Name Sheet
    private var editNameSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Edit Display Name")
                        .font(.title2.weight(.bold))
                        .foregroundColor(RobinhoodColors.primary)
                    Text("Enter your preferred display name")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Input field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Display Name")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(RobinhoodColors.primary)
                    
                    TextField("Enter your name", text: $tempDisplayName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Save button
                Button(action: {
                    if !tempDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        displayName = tempDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
                        showEditNameSheet = false
                    }
                }) {
                    Text("Save Changes")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(tempDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(.systemGray4) : AppColors.black)
                        )
                }
                .disabled(tempDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showEditNameSheet = false
                    }
                }
            }
        }
    }
    
    // MARK: - Currency Picker Sheet
    private var currencyPickerSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Select Currency")
                        .font(.title2.weight(.bold))
                        .foregroundColor(RobinhoodColors.primary)
                    Text("Choose your preferred currency")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Currency list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(currencies, id: \.self) { currency in
                            Button(action: {
                                selectedCurrency = currency
                                showCurrencyPicker = false
                            }) {
                                HStack(spacing: 16) {
                                    Circle()
                                        .fill(selectedCurrency == currency ? AppColors.secondary : Color(.systemGray6))
                                        .frame(width: 12, height: 12)
                                    
                                    Text(currency)
                                        .font(.body.weight(.medium))
                                        .foregroundColor(RobinhoodColors.primary)
                                    
                                    Spacer()
                                    
                                    if selectedCurrency == currency {
                                        Image(systemName: "checkmark")
                                            .font(.caption.weight(.bold))
                                            .foregroundColor(AppColors.secondary)
                                    }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(AppColors.card)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showCurrencyPicker = false
                    }
                }
            }
        }
    }
    
    // MARK: - Baseline Balance Sheet
    private var baselineBalanceSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Set Baseline Balance")
                        .font(.title2.weight(.bold))
                        .foregroundColor(RobinhoodColors.primary)
                    Text("Enter your starting account balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Input field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Baseline Balance")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(RobinhoodColors.primary)
                    
                    TextField("0.00", text: $newBaselineBalance)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                        .keyboardType(.decimalPad)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Save button
                Button(action: {
                    if let balance = Double(newBaselineBalance) {
                        baselineBalance = balance
                        showBaselineBalanceSheet = false
                    }
                }) {
                    Text("Save Changes")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(newBaselineBalance.isEmpty ? Color(.systemGray4) : AppColors.black)
                        )
                }
                .disabled(newBaselineBalance.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Baseline Balance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showBaselineBalanceSheet = false
                    }
                }
            }
        }
    }
    
    // MARK: - Export Preview Sheet
    private var exportPreviewSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Export Data Preview")
                        .font(.title2.weight(.bold))
                        .foregroundColor(RobinhoodColors.primary)
                    Text("Review your data before export")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Summary cards
                ScrollView {
                    VStack(spacing: 16) {
                        // Summary cards
                        HStack(spacing: 16) {
                            summaryCard(title: "Transactions", count: transactions.count, icon: "text.rectangle.page", color: AppColors.primary)
                            summaryCard(title: "Goals", count: goals.count, icon: "target", color: AppColors.secondary)
                        }
                        
                        // Transactions preview
                        if !transactions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Recent Transactions")
                                        .font(.headline.weight(.semibold))
                                        .foregroundColor(RobinhoodColors.primary)
                                    Spacer()
                                }
                                
                                VStack(spacing: 8) {
                                    ForEach(Array(transactions.prefix(5).enumerated()), id: \.element.id) { index, transaction in
                                        HStack(spacing: 12) {
                                            Image(systemName: transaction.iconName)
                                                .font(.caption)
                                                .foregroundColor(transaction.iconColor)
                                                .frame(width: 24, height: 24)
                                                .background(transaction.iconBackground)
                                                .clipShape(Circle())
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(transaction.title)
                                                    .font(.subheadline.weight(.medium))
                                                    .foregroundColor(RobinhoodColors.primary)
                                                Text(transaction.subtitle)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Text(transaction.amount, format: .currency(code: selectedCurrency.components(separatedBy: " ").first ?? "USD"))
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(transaction.isIncome ? RobinhoodColors.primary : .red)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(.systemGray6))
                                        )
                                        
                                        if index < min(4, transactions.count - 1) {
                                            Divider()
                                                .padding(.leading, 36)
                                        }
                                    }
                                }
                                
                                if transactions.count > 5 {
                                    HStack {
                                        Spacer()
                                        Text("... and \(transactions.count - 5) more transactions")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(.top, 8)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Goals preview
                        if !goals.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Savings Goals")
                                        .font(.headline.weight(.semibold))
                                        .foregroundColor(RobinhoodColors.primary)
                                    Spacer()
                                }
                                
                                VStack(spacing: 8) {
                                    ForEach(Array(goals.prefix(3).enumerated()), id: \.element.name) { index, goal in
                                        HStack(spacing: 12) {
                                            Image(systemName: goal.iconName)
                                                .font(.caption)
                                                .foregroundColor(goal.iconColor)
                                                .frame(width: 24, height: 24)
                                                .background(goal.iconColor.opacity(0.15))
                                                .clipShape(Circle())
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(goal.name)
                                                    .font(.subheadline.weight(.medium))
                                                    .foregroundColor(RobinhoodColors.primary)
                                                Text("Target: \(goal.targetAmount, format: .currency(code: selectedCurrency.components(separatedBy: " ").first ?? "USD"))")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Text(goal.savedAmount, format: .currency(code: selectedCurrency.components(separatedBy: " ").first ?? "USD"))
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(AppColors.secondary)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(.systemGray6))
                                        )
                                        
                                        if index < min(2, goals.count - 1) {
                                            Divider()
                                                .padding(.leading, 36)
                                        }
                                    }
                                }
                                
                                if goals.count > 3 {
                                    HStack {
                                        Spacer()
                                        Text("... and \(goals.count - 3) more goals")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    .padding(.top, 8)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                }
                
                // Export button
                Button(action: {
                    exportData()
                    showExportPreview = false
                }) {
                    Text("Export to CSV")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(AppColors.black)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Export Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showExportPreview = false
                    }
                }
            }
        }
    }
    
    // MARK: - Import Sheet
    private var importSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Import Data")
                        .font(.title2.weight(.bold))
                        .foregroundColor(RobinhoodColors.primary)
                    Text("Paste your CSV data below")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // CSV input
                VStack(alignment: .leading, spacing: 8) {
                    Text("CSV Data")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(RobinhoodColors.primary)
                    
                    TextEditor(text: $importText)
                        .font(.body.monospaced())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                        .frame(height: 200)
                }
                .padding(.horizontal, 20)
                
                // Error display
                if let error = importError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
                
                // Action buttons
                HStack(spacing: 16) {
                    Button(action: {
                        loadSampleData()
                    }) {
                        Text("Load Sample")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(AppColors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                            )
                    }
                    
                    Button(action: {
                        parseCSV()
                    }) {
                        Text("Parse CSV")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(importText.isEmpty ? Color(.systemGray4) : AppColors.primary)
                            )
                    }
                    .disabled(importText.isEmpty)
                }
                .padding(.horizontal, 20)
                
                // Preview section
                if let preview = importPreview {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Import Preview")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(RobinhoodColors.primary)
                            Spacer()
                        }
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Transactions: \(preview.transactions.count)")
                                    .font(.subheadline)
                                    .foregroundColor(RobinhoodColors.primary)
                                Spacer()
                            }
                            
                            HStack {
                                Text("Goals: \(preview.goals.count)")
                                    .font(.subheadline)
                                    .foregroundColor(RobinhoodColors.primary)
                                Spacer()
                            }
                            
                            HStack {
                                Text("User Settings: \(preview.userSettings.displayName)")
                                    .font(.subheadline)
                                    .foregroundColor(RobinhoodColors.primary)
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Import button
                        Button(action: {
                            importData()
                        }) {
                            Text("Import Data")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(AppColors.black)
                                )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .navigationTitle("Import Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showImportSheet = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func clearAllData() {
        transactions.removeAll()
        goals.removeAll()
        
        // Reset user preferences
        baselineBalance = 0.0
        displayName = "User Name"
        selectedCurrency = "USD (US Dollar)"
        notificationsEnabled = true
        hapticsEnabled = true
        
        // Show baseline balance sheet
        showBaselineBalanceSheet = true
    }
    
    private func summaryCard(title: String, count: Int, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(spacing: 4) {
                Text("\(count)")
                    .font(.title.weight(.bold))
                                        .foregroundColor(RobinhoodColors.primary)
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
        )
    }
    
    private func exportData() {
        var csv = "Type,Title,Subtitle,Amount,Icon,IconColor,IconBackground,Category,IsIncome,LinkedGoal,Date\n"
        
        // Export transactions
        for transaction in transactions {
            let date = transaction.date.formatted(date: .abbreviated, time: .omitted)
            csv += "Transaction,\(transaction.title),\(transaction.subtitle),\(transaction.amount),\(transaction.iconName),\(transaction.iconColorName),\(transaction.iconBackgroundName),\(transaction.category.rawValue),\(transaction.isIncome),\(transaction.linkedGoalName ?? ""),\(date)\n"
        }
        
        // Export goals - Fixed: GoalFormItem doesn't have iconBackgroundName
        for goal in goals {
            let date = goal.targetDate.formatted(date: .abbreviated, time: .omitted)
            csv += "Goal,\(goal.name),\(goal.subtitle ?? ""),\(goal.targetAmount),\(goal.iconName),\(goal.iconColorName),\(goal.iconColorName),savings,false,\(goal.name),\(date)\n"
        }
        
        // Export user settings
        csv += "\(displayName),\(selectedCurrency),\(baselineBalance),\(notificationsEnabled),\(hapticsEnabled)\n"
        
        // Share CSV
        let activityVC = UIActivityViewController(activityItems: [csv], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func loadSampleData() {
        importText = sampleCSV
        importError = nil
        importPreview = nil
    }
    
    private func parseCSV() {
        importError = nil
        importPreview = nil
        
        let lines = importText.components(separatedBy: .newlines)
        
        if lines.count < 2 {
            importError = "CSV content is empty"
            return
        }
        
        do {
            let preview = try parseCSVContent(lines)
            importPreview = preview
        } catch {
            importError = "Error parsing CSV: \(error.localizedDescription)"
        }
    }
    
    private func parseCSVContent(_ lines: [String]) throws -> ImportPreview {
        var transactions: [TransactionItem] = []
        var goals: [GoalFormItem] = []
        var userSettings = ImportPreview.UserSettingsImport(
            displayName: "User Name",
            preferredCurrency: "USD (US Dollar)",
            baselineBalance: 0.0,
            notificationsEnabled: true,
            hapticsEnabled: true
        )
        
        // Parse CSV lines
        for line in lines.dropFirst() { // Skip header
            let columns = line.components(separatedBy: ",")
            if columns.count >= 11 {
                let type = columns[0]
                
                if type == "Transaction" {
                    // Parse transaction
                    let transaction = TransactionItem(
                        id: UUID(),
                        title: columns[1],
                        subtitle: columns[2],
                        amount: Double(columns[3]) ?? 0.0,
                        iconName: columns[4],
                        iconColorName: columns[5],
                        iconBackgroundName: columns[6],
                        category: TransactionCategoryType(rawValue: columns[7]) ?? .other,
                        isIncome: columns[8] == "true",
                        linkedGoalName: columns[9].isEmpty ? nil : columns[9],
                        date: Date()
                    )
                    transactions.append(transaction)
                } else if type == "Goal" {
                    // Parse goal - Fixed: GoalFormItem doesn't have iconBackgroundName
                    let goal = GoalFormItem(
                        name: columns[1],
                        subtitle: columns[2].isEmpty ? nil : columns[2],
                        targetAmount: Double(columns[3]) ?? 0.0,
                        savedAmount: 0.0,
                        targetDate: Date(),
                        notes: nil,
                        iconName: columns[4],
                        iconColorName: columns[5]
                    )
                    goals.append(goal)
                } else if type == "UserSettings" {
                    // Parse user settings
                    userSettings = ImportPreview.UserSettingsImport(
                        displayName: columns[1],
                        preferredCurrency: columns[2],
                        baselineBalance: Double(columns[3]) ?? 0.0,
                        notificationsEnabled: columns[4] == "true",
                        hapticsEnabled: columns[5] == "true"
                    )
                }
            }
        }
        
        return ImportPreview(
            transactions: transactions,
            goals: goals,
            userSettings: userSettings
        )
    }
    
    private func importData() {
        guard let preview = importPreview else { return }
        
        // Import data
        transactions = preview.transactions
        goals = preview.goals
        
        // Update user settings
        displayName = preview.userSettings.displayName
        selectedCurrency = preview.userSettings.preferredCurrency
        baselineBalance = preview.userSettings.baselineBalance
        notificationsEnabled = preview.userSettings.notificationsEnabled
        hapticsEnabled = preview.userSettings.hapticsEnabled
        
        // Close sheet
        showImportSheet = false
    }
    
    // MARK: - Sample CSV Data
    private var sampleCSV: String {
        """
        Type,Title,Subtitle,Amount,Icon,IconColor,IconBackground,Category,IsIncome,LinkedGoal,Date
        Transaction,Salary,Monthly income,2000,dollarsign.circle,green,green.opacity15,income,true,,2024-01-15
        Transaction,Grocery Shopping,Food expenses,150,cart,orange,orange.opacity15,essentials,false,,2024-01-14
        Goal,Vacation Fund,Save for summer vacation,5000,airplane,blue,blue.opacity15,savings,false,Vacation Fund,2024-06-01
        UserSettings,John Doe,USD (US Dollar),5000,true,true
        """
    }
    
    // MARK: - Import Error
    enum ImportError: LocalizedError {
        case invalidFormat(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidFormat(let message):
                return message
            }
        }
    }
    
    // MARK: - About View
    private var aboutView: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // App Icon
                ZStack {
                    Circle()
                        .fill(AppColors.black.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundColor(AppColors.black)
                }
                
                VStack(spacing: 16) {
                    Text("ABC Budgeting")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(RobinhoodColors.primary)
                    
                    Text("Smart financial planning made simple")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 24) {
                    aboutInfoRow(icon: "info.circle", title: "Version", value: "1.0.0")
                    aboutInfoRow(icon: "calendar", title: "Released", value: "2024")
                    aboutInfoRow(icon: "building.2", title: "Developer", value: "Spookers")
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                )
                
                Spacer()
                
                Text("© 2024 Spookers. All rights reserved.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, AppPaddings.section)
            .padding(.top, 60)
            .padding(.bottom, 40)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func aboutInfoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            
            Text(title)
                .font(.body.weight(.medium))
                                        .foregroundColor(RobinhoodColors.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Robinhood Setting Row Components

struct RobinhoodSettingRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    let actionIcon: String
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(RobinhoodTypography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(RobinhoodColors.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(RobinhoodTypography.body)
                        .foregroundColor(RobinhoodColors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Action icon
                Image(systemName: actionIcon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(RobinhoodColors.textTertiary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RobinhoodToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(RobinhoodTypography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(RobinhoodColors.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Text(subtitle)
                    .font(RobinhoodTypography.body)
                    .foregroundColor(RobinhoodColors.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: RobinhoodColors.success))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            transactions: .constant([]),
            goals: .constant([])
        )
    }
}
#endif
