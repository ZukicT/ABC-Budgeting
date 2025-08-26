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
    @Binding var transactions: [Transaction]
    @Binding var goals: [GoalFormData]
    let currencies = CurrencyList.all
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    // Enhanced Header
                    headerSection
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            accountSection
                            preferencesSection
                            dataSection
                            aboutSection
                        }
                        .padding(.horizontal, AppPaddings.section)
                        .padding(.bottom, AppPaddings.large)
                    }
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
            }
            .sheet(isPresented: $showEditNameSheet) {
                editNameSheet
            }
            .sheet(isPresented: $showExportPreview) {
                exportPreviewSheet
            }
            .sheet(isPresented: $showImportSheet) {
                importSheet
            }
            .sheet(isPresented: $showCurrencyPicker) {
                currencyPickerSheet
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settings")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.primary)
            Text("Customize your app experience")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, AppPaddings.sectionTitleTop)
        .padding(.bottom, AppPaddings.sectionTitleBottom)
        .padding(.horizontal, AppPaddings.section)
    }
    
    // MARK: - Account Section
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Account", icon: "person.crop.circle.fill", color: AppColors.brandBlue)
            
            Button(action: {
                tempDisplayName = displayName
                showEditNameSheet = true
            }) {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppColors.brandBlue.opacity(0.15))
                            .frame(width: 56, height: 56)
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(AppColors.brandBlue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(displayName)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.primary)
                        Text("Tap to edit your display name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Preferences Section
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Preferences", icon: "gearshape.fill", color: AppColors.brandGreen)
            
            VStack(spacing: 0) {
                // Currency Picker
                preferenceRow(
                    icon: "dollarsign.circle.fill",
                    iconColor: AppColors.brandGreen,
                    title: "Currency",
                    subtitle: selectedCurrency,
                    showChevron: true,
                    isFirst: true,
                    isLast: false
                ) {
                    showCurrencyPicker = true
                }
                
                // Notifications Toggle
                preferenceRow(
                    icon: "bell.fill",
                    iconColor: AppColors.brandPurple,
                    title: "Notifications",
                    subtitle: notificationsEnabled ? "Enabled" : "Disabled",
                    showToggle: true,
                    toggleValue: $notificationsEnabled,
                    isFirst: false,
                    isLast: false,
                    action: {}
                )
                
                // Haptics Toggle
                preferenceRow(
                    icon: "iphone.radiowaves.left.and.right",
                    iconColor: AppColors.brandOrange,
                    title: "Haptic Feedback",
                    subtitle: hapticsEnabled ? "Enabled" : "Disabled",
                    showToggle: true,
                    toggleValue: $hapticsEnabled,
                    isFirst: false,
                    isLast: true,
                    action: {}
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
            )
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Data Section
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Data Management", icon: "externaldrive.fill", color: AppColors.brandRed)
            
            VStack(spacing: 0) {
                preferenceRow(
                    icon: "square.and.arrow.down",
                    iconColor: AppColors.brandBlue,
                    title: "Import Data",
                    subtitle: "Bring data from other apps",
                    showChevron: true,
                    isFirst: true,
                    isLast: false
                ) {
                    showImportSheet = true
                }
                
                preferenceRow(
                    icon: "square.and.arrow.up",
                    iconColor: AppColors.brandGreen,
                    title: "Export Data",
                    subtitle: "Backup your data",
                    showChevron: true,
                    isFirst: false,
                    isLast: false
                ) {
                    showExportPreview = true
                }
                
                preferenceRow(
                    icon: "trash",
                    iconColor: AppColors.brandRed,
                    title: "Clear All Data",
                    subtitle: "Permanently delete everything",
                    showChevron: true,
                    isFirst: false,
                    isLast: true
                ) {
                    showClearDataAlert = true
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
            )
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "About", icon: "info.circle.fill", color: AppColors.brandCyan)
            
            NavigationLink(destination: AboutView()) {
                preferenceRow(
                    icon: "info.circle.fill",
                    iconColor: AppColors.brandCyan,
                    title: "App Information",
                    subtitle: "Version 1.0.0",
                    showChevron: true,
                    isFirst: true,
                    isLast: true
                ) {}
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
            )
        }
    }
    
    // MARK: - Helper Views
    private func sectionHeader(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)
        }
    }
    
    private func preferenceRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        showChevron: Bool = false,
        showToggle: Bool = false,
        toggleValue: Binding<Bool>? = nil,
        isFirst: Bool = false,
        isLast: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.medium))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if showToggle, let toggleValue = toggleValue {
                    Toggle("", isOn: toggleValue)
                        .tint(AppColors.brandGreen)
                        .scaleEffect(0.8)
                } else if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        // Add separators between rows
                        VStack(spacing: 0) {
                            if !isFirst {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(height: 0.5)
                                    .padding(.leading, 76)
                            }
                            Spacer()
                            if !isLast {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(height: 0.5)
                                    .padding(.leading, 76)
                            }
                        }
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Edit Name Sheet
    private var editNameSheet: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Sheet Header
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
                        Button(action: { showEditNameSheet = false }) {
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
                        
                        Text("Edit Name")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Color.clear
                            .frame(width: 80)
                    }
                    .frame(height: 64)
                }
                
                VStack(spacing: 32) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundColor(AppColors.brandBlue)
                                .font(.title2)
                            Text("Display Name")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.primary)
                        }
                        
                        TextField("Enter your name", text: $tempDisplayName)
                            .font(.body)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                            )
                    }
                    
                    Button(action: {
                        displayName = tempDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
                        showEditNameSheet = false
                    }) {
                        Text("Save Changes")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(tempDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(.systemGray4) : AppColors.brandBlack)
                            )
                    }
                    .disabled(tempDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    Spacer()
                }
                .padding(.horizontal, AppPaddings.section)
                .padding(.top, 24)
                .background(AppColors.background)
            }
            .toolbar { EmptyView() }
        }
    }
    
    // MARK: - Currency Picker Sheet
    private var currencyPickerSheet: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Sheet Header
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
                        Button(action: { showCurrencyPicker = false }) {
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
                        
                        Text("Select Currency")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Color.clear
                            .frame(width: 80)
                    }
                    .frame(height: 64)
                }
                
                List {
                    ForEach(currencies, id: \.self) { currency in
                        Button(action: {
                            selectedCurrency = currency
                            showCurrencyPicker = false
                        }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(selectedCurrency == currency ? AppColors.brandGreen : Color(.systemGray6))
                                        .frame(width: 24, height: 24)
                                    
                                    if selectedCurrency == currency {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                Text(currency)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .listStyle(.plain)
                .background(AppColors.background)
            }
            .toolbar { EmptyView() }
        }
    }
    
    // MARK: - Clear All Data Function
    private func clearAllData() {
        // Clear all transactions
        transactions.removeAll()
        
        // Clear all goals
        goals.removeAll()
        
        // Reset baseline balance
        baselineBalance = 0.0
        
        // Reset user preferences to defaults
        displayName = "User Name"
        selectedCurrency = "USD (US Dollar)"
        notificationsEnabled = true
        hapticsEnabled = true
        
        // Show baseline balance sheet
        showBaselineBalanceSheet = true
    }
    
    // MARK: - Baseline Balance Sheet
    private var baselineBalanceSheet: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Sheet Header
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
                        Spacer()
                        
                        Text("Set New Balance")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .frame(height: 64)
                }
                
                VStack(spacing: 32) {
                    // Success message
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppColors.brandGreen.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(AppColors.brandGreen)
                        }
                        
                        Text("Data Cleared Successfully")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.primary)
                        
                        Text("All your previous data has been permanently deleted. You can now start fresh with a new baseline balance.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Baseline balance input
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(AppColors.brandGreen)
                                .font(.title2)
                            Text("New Baseline Balance")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.primary)
                        }
                        
                        let preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD (US Dollar)"
                        let currencyCode = preferredCurrency.components(separatedBy: " ").first ?? "USD"
                        let currencySymbol = Locale.availableIdentifiers.compactMap { Locale(identifier: $0) }
                            .first(where: { $0.currency?.identifier == currencyCode })?.currencySymbol ?? "$"
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                            
                            HStack(spacing: 12) {
                                Text(currencySymbol)
                                    .font(.title.weight(.bold))
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 20)
                                
                                TextField("0.00", text: $newBaselineBalance)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.vertical, 20)
                        }
                        .frame(height: 72)
                        
                        Text("Enter your current account balance to start fresh, or leave as 0.00 to begin with no balance.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            if let balance = Double(newBaselineBalance) {
                                baselineBalance = balance
                            }
                            showBaselineBalanceSheet = false
                        }) {
                            Text("Set Balance & Continue")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppColors.brandGreen)
                                )
                        }
                        
                        Button(action: {
                            showBaselineBalanceSheet = false
                        }) {
                            Text("Continue with 0.00")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(AppColors.brandGreen)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.brandGreen, lineWidth: 2)
                                )
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, AppPaddings.section)
                .padding(.top, 24)
                .background(AppColors.background)
            }
            .toolbar { EmptyView() }
        }
    }
    
    // MARK: - Export Preview Sheet
    private var exportPreviewSheet: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Sheet Header
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
                        Button(action: { showExportPreview = false }) {
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
                        
                        Text("Export Data Preview")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Color.clear
                            .frame(width: 80)
                    }
                    .frame(height: 64)
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Summary section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Data Summary")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 20) {
                                summaryCard(title: "Transactions", count: transactions.count, icon: "text.rectangle.page", color: AppColors.brandBlue)
                                summaryCard(title: "Goals", count: goals.count, icon: "target", color: AppColors.brandGreen)
                            }
                        }
                        .padding(.horizontal, AppPaddings.section)
                        
                        // Transactions table preview
                        if !transactions.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Transactions Preview")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, AppPaddings.section)
                                
                                VStack(spacing: 0) {
                                    // Table header
                                    HStack(spacing: 0) {
                                        Text("Title")
                                            .font(.caption.weight(.semibold))
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color(.systemGray6))
                                        
                                        Text("Amount")
                                            .font(.caption.weight(.semibold))
                                            .foregroundColor(.secondary)
                                            .frame(width: 80, alignment: .trailing)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color(.systemGray6))
                                        
                                        Text("Type")
                                            .font(.caption.weight(.semibold))
                                            .foregroundColor(.secondary)
                                            .frame(width: 70, alignment: .center)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 8)
                                            .background(Color(.systemGray6))
                                    }
                                    
                                    // Table rows (show first 5)
                                    ForEach(Array(transactions.prefix(5).enumerated()), id: \.element.id) { index, transaction in
                                        HStack(spacing: 0) {
                                            Text(transaction.title)
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .lineLimit(1)
                                            
                                            Text(transaction.amount, format: .currency(code: selectedCurrency.components(separatedBy: " ").first ?? "USD"))
                                                .font(.caption)
                                                .foregroundColor(transaction.isIncome ? AppColors.brandGreen : AppColors.brandRed)
                                                .frame(width: 80, alignment: .trailing)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                            
                                            Text(transaction.isIncome ? "Income" : "Expense")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .frame(width: 70, alignment: .center)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 8)
                                        }
                                        .background(index % 2 == 0 ? Color.white : Color(.systemGray6).opacity(0.3))
                                        
                                        if index < min(4, transactions.count - 1) {
                                            Rectangle()
                                                .fill(Color(.systemGray5))
                                                .frame(height: 0.5)
                                        }
                                    }
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                                )
                                .padding(.horizontal, AppPaddings.section)
                                
                                if transactions.count > 5 {
                                    Text("... and \(transactions.count - 5) more transactions")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, AppPaddings.section)
                                }
                            }
                        }
                        
                        // Goals table preview
                        if !goals.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Goals Preview")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, AppPaddings.section)
                                
                                VStack(spacing: 0) {
                                    // Table header
                                    HStack(spacing: 0) {
                                        Text("Name")
                                            .font(.caption.weight(.semibold))
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color(.systemGray6))
                                        
                                        Text("Target")
                                            .font(.caption.weight(.semibold))
                                            .foregroundColor(.secondary)
                                            .frame(width: 80, alignment: .trailing)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color(.systemGray6))
                                        
                                        Text("Saved")
                                            .font(.caption.weight(.semibold))
                                            .foregroundColor(.secondary)
                                            .frame(width: 80, alignment: .trailing)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color(.systemGray6))
                                    }
                                    
                                    // Table rows (show first 3)
                                    ForEach(Array(goals.prefix(3).enumerated()), id: \.element.name) { index, goal in
                                        HStack(spacing: 0) {
                                            Text(goal.name)
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .lineLimit(1)
                                            
                                            Text(goal.targetAmount, format: .currency(code: selectedCurrency.components(separatedBy: " ").first ?? "USD"))
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                                .frame(width: 80, alignment: .trailing)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                            
                                            Text(goal.savedAmount, format: .currency(code: selectedCurrency.components(separatedBy: " ").first ?? "USD"))
                                                .font(.caption)
                                                .foregroundColor(AppColors.brandGreen)
                                                .frame(width: 80, alignment: .trailing)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                        }
                                        .background(index % 2 == 0 ? Color.white : Color(.systemGray6).opacity(0.3))
                                        
                                        if index < min(2, goals.count - 1) {
                                            Rectangle()
                                                .fill(Color(.systemGray5))
                                                .frame(height: 0.5)
                                        }
                                    }
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                                )
                                .padding(.horizontal, AppPaddings.section)
                                
                                if goals.count > 3 {
                                    Text("... and \(goals.count - 3) more goals")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, AppPaddings.section)
                                }
                            }
                        }
                        
                        // Export button
                        VStack(spacing: 16) {
                            Button(action: exportData) {
                                HStack(spacing: 12) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title2)
                                    Text("Export to CSV")
                                        .font(.headline.weight(.semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppColors.brandGreen)
                                )
                            }
                            
                            Text("The exported file will contain all your transactions and goals data in CSV format, suitable for import into spreadsheet applications.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppPaddings.section)
                        }
                        .padding(.horizontal, AppPaddings.section)
                        .padding(.top, 16)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 24)
                }
                .background(AppColors.background)
            }
            .toolbar { EmptyView() }
        }
    }
    
    // MARK: - Helper Views for Export Preview
    private func summaryCard(title: String, count: Int, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
            }
            
            Text("\(count)")
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        )
    }
    
    // MARK: - CSV Export Function
    private func exportData() {
        let csvContent = generateCSV()
        
        // Create a temporary file with a unique name
        let tempDir = FileManager.default.temporaryDirectory
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm"
        let timestamp = dateFormatter.string(from: Date())
        let fileName = "ABC_Budgeting_Export_\(timestamp).csv"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try csvContent.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Create and present the share sheet
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            
            // Configure the share sheet
            activityVC.excludedActivityTypes = [
                .assignToContact,
                .addToReadingList,
                .openInIBooks,
                .markupAsPDF
            ]
            
            // Present the share sheet
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                
                // Find the topmost presented view controller
                var topController = rootViewController
                while let presentedController = topController.presentedViewController {
                    topController = presentedController
                }
                
                // Present the share sheet
                topController.present(activityVC, animated: true) {
                    // Dismiss the export preview after sharing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showExportPreview = false
                    }
                }
            }
        } catch {
            print("Error exporting data: \(error)")
            // In a real app, you'd show an alert to the user
        }
    }
    
    private func generateCSV() -> String {
        var csv = "ABC Budgeting Data Export\n"
        csv += "Generated on: \(Date().formatted(date: .abbreviated, time: .omitted))\n\n"
        
        // Transactions CSV
        csv += "TRANSACTIONS\n"
        csv += "Title,Subtitle,Amount,Category,Type,Date,Linked Goal\n"
        
        for transaction in transactions {
            let title = transaction.title.replacingOccurrences(of: ",", with: ";")
            let subtitle = transaction.subtitle.replacingOccurrences(of: ",", with: ";")
            let category = transaction.category.label
            let type = transaction.isIncome ? "Income" : "Expense"
            let date = transaction.date.formatted(date: .abbreviated, time: .omitted)
            let linkedGoal = transaction.linkedGoalName ?? "None"
            
            csv += "\(title),\(subtitle),\(transaction.amount),\(category),\(type),\(date),\(linkedGoal)\n"
        }
        
        csv += "\n"
        
        // Goals CSV
        csv += "SAVINGS GOALS\n"
        csv += "Name,Subtitle,Target Amount,Saved Amount,Target Date,Notes,Icon\n"
        
        for goal in goals {
            let name = goal.name.replacingOccurrences(of: ",", with: ";")
            let subtitle = goal.subtitle?.replacingOccurrences(of: ",", with: ";") ?? ""
            let notes = goal.notes?.replacingOccurrences(of: ",", with: ";") ?? ""
            
            csv += "\(name),\(subtitle),\(goal.targetAmount),\(goal.savedAmount),\(goal.targetDate.formatted(date: .abbreviated, time: .omitted)),\(notes),\(goal.iconName)\n"
        }
        
        // User settings
        csv += "\n"
        csv += "USER SETTINGS\n"
        csv += "Display Name,Preferred Currency,Baseline Balance,Notifications Enabled,Haptics Enabled\n"
        csv += "\(displayName),\(selectedCurrency),\(baselineBalance),\(notificationsEnabled),\(hapticsEnabled)\n"
        
        return csv
    }
    
    // MARK: - Import Preview Struct
    struct ImportPreview {
        let transactions: [Transaction]
        let goals: [GoalFormData]
        let userSettings: UserSettingsImport
        
        struct UserSettingsImport {
            let displayName: String
            let preferredCurrency: String
            let baselineBalance: Double
            let notificationsEnabled: Bool
            let hapticsEnabled: Bool
        }
    }
    
    // MARK: - Import Sheet
    private var importSheet: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Sheet Header
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
                        Button(action: { 
                            showImportSheet = false
                            resetImportState()
                        }) {
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
                        
                        Text("Import Data")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Color.clear
                            .frame(width: 80)
                    }
                    .frame(height: 64)
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Instructions section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("CSV Format Requirements")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                instructionRow(
                                    icon: "doc.text",
                                    title: "File Format",
                                    description: "Must be a CSV file exported from this app or formatted exactly the same way"
                                )
                                
                                instructionRow(
                                    icon: "tablecells",
                                    title: "Required Columns",
                                    description: "Transactions: Title, Subtitle, Amount, Category, Type, Date, Linked Goal"
                                )
                                
                                instructionRow(
                                    icon: "target",
                                    title: "Goals Format",
                                    description: "Goals: Name, Subtitle, Target Amount, Saved Amount, Target Date, Notes, Icon"
                                )
                                
                                instructionRow(
                                    icon: "gear",
                                    title: "Settings Format",
                                    description: "Settings: Display Name, Preferred Currency, Baseline Balance, Notifications, Haptics"
                                )
                            }
                        }
                        .padding(.horizontal, AppPaddings.section)
                        
                        // CSV input section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Paste CSV Content")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.primary)
                            
                            TextEditor(text: $importText)
                                .font(.system(.body, design: .monospaced))
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemGray6))
                                )
                                .frame(minHeight: 120)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(importError != nil ? AppColors.brandRed : Color.clear, lineWidth: 2)
                                )
                            
                            if let error = importError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(AppColors.brandRed)
                            }
                            
                            HStack(spacing: 12) {
                                Button(action: parseCSV) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "doc.text.magnifyingglass")
                                            .font(.title2)
                                        Text("Parse & Preview")
                                            .font(.headline.weight(.semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(importText.isEmpty ? Color(.systemGray4) : AppColors.brandBlue)
                                    )
                                }
                                .disabled(importText.isEmpty)
                                
                                Button(action: loadSampleCSV) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "doc.text")
                                            .font(.title2)
                                        Text("Sample")
                                            .font(.body.weight(.medium))
                                    }
                                    .foregroundColor(AppColors.brandBlue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.brandBlue, lineWidth: 2)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, AppPaddings.section)
                        
                        // Import preview section
                        if let preview = importPreview {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Import Preview")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, AppPaddings.section)
                                
                                VStack(spacing: 12) {
                                    previewCard(
                                        title: "Transactions",
                                        count: preview.transactions.count,
                                        icon: "text.rectangle.page",
                                        color: AppColors.brandBlue
                                    )
                                    
                                    previewCard(
                                        title: "Goals",
                                        count: preview.goals.count,
                                        icon: "target",
                                        color: AppColors.brandGreen
                                    )
                                    
                                    previewCard(
                                        title: "Settings",
                                        count: 1,
                                        icon: "gear",
                                        color: AppColors.brandPurple
                                    )
                                }
                                .padding(.horizontal, AppPaddings.section)
                                
                                // Import button
                                Button(action: performImport) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "square.and.arrow.down")
                                            .font(.title2)
                                        Text("Import Data")
                                        .font(.headline.weight(.semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(AppColors.brandGreen)
                                    )
                                }
                                .padding(.horizontal, AppPaddings.section)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 24)
                }
                .background(AppColors.background)
            }
            .toolbar { EmptyView() }
        }
    }
    
    // MARK: - Helper Views for Import
    private func instructionRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppColors.brandBlue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
    
    private func previewCard(title: String, count: Int, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.primary)
                
                Text("\(count) item\(count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
        )
    }
    
    // MARK: - Import Functions
    private func resetImportState() {
        importText = ""
        importError = nil
        importPreview = nil
    }
    
    private func loadSampleCSV() {
        let sampleCSV = """
        TRANSACTIONS
        Title,Subtitle,Amount,Category,Type,Date,Linked Goal
        Grocery Shopping,Weekly groceries,125.50,Essentials,Expense,Jan 15, 2024,None
        Salary Deposit,Monthly salary,3500.00,Income,Income,Jan 1, 2024,None
        Coffee,Morning coffee,4.75,Essentials,Expense,Jan 15, 2024,None
        
        SAVINGS GOALS
        Name,Subtitle,Target Amount,Saved Amount,Target Date,Notes,Icon
        Vacation Fund,Summer vacation,5000.00,1250.00,Jun 1, 2024,Save for beach trip,airplane
        Emergency Fund,Financial safety net,10000.00,3500.00,Dec 31, 2024,3 months expenses,shield
        
        USER SETTINGS
        Display Name,Preferred Currency,Baseline Balance,Notifications Enabled,Haptics Enabled
        John Doe,USD,5000.00,true,true
        """
        
        importText = sampleCSV
        importError = nil
        importPreview = nil
    }
    
    private func parseCSV() {
        importError = nil
        importPreview = nil
        
        let lines = importText.components(separatedBy: .newlines)
        guard !lines.isEmpty else {
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
        var transactions: [Transaction] = []
        var goals: [GoalFormData] = []
        var userSettings: ImportPreview.UserSettingsImport?
        
        var currentSection: String = ""
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.isEmpty { continue }
            
            if trimmedLine.hasPrefix("TRANSACTIONS") {
                currentSection = "transactions"
                continue
            } else if trimmedLine.hasPrefix("SAVINGS GOALS") {
                currentSection = "goals"
                continue
            } else if trimmedLine.hasPrefix("USER SETTINGS") {
                currentSection = "settings"
                continue
            }
            
            if trimmedLine.contains(",") {
                let components = trimmedLine.components(separatedBy: ",")
                
                switch currentSection {
                case "transactions":
                    if components.count >= 6 && !components[0].contains("Title") {
                        let transaction = try parseTransaction(from: components)
                        transactions.append(transaction)
                    }
                case "goals":
                    if components.count >= 7 && !components[0].contains("Name") {
                        let goal = try parseGoal(from: components)
                        goals.append(goal)
                    }
                case "settings":
                    if components.count >= 5 && !components[0].contains("Display Name") {
                        userSettings = try parseUserSettings(from: components)
                    }
                default:
                    break
                }
            }
        }
        
        // Use default settings if none found
        let finalSettings = userSettings ?? ImportPreview.UserSettingsImport(
            displayName: displayName,
            preferredCurrency: selectedCurrency,
            baselineBalance: baselineBalance,
            notificationsEnabled: notificationsEnabled,
            hapticsEnabled: hapticsEnabled
        )
        
        return ImportPreview(
            transactions: transactions,
            goals: goals,
            userSettings: finalSettings
        )
    }
    
    private func parseTransaction(from components: [String]) throws -> Transaction {
        guard components.count >= 6 else {
            throw ImportError.invalidFormat("Transaction requires at least 6 columns")
        }
        
        let title = components[0].trimmingCharacters(in: .whitespaces)
        let subtitle = components[1].trimmingCharacters(in: .whitespaces)
        let amount = Double(components[2].trimmingCharacters(in: .whitespaces)) ?? 0.0
        let categoryString = components[3].trimmingCharacters(in: .whitespaces)
        let category = TransactionCategory.allCases.first { $0.label == categoryString } ?? .essentials
        
        // Parse type
        let typeString = components[4].trimmingCharacters(in: .whitespaces)
        let isIncome = typeString.lowercased() == "income"
        
        // Parse date
        let dateString = components[5].trimmingCharacters(in: .whitespaces)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let date = dateFormatter.date(from: dateString) ?? Date()
        
        // Parse linked goal
        let linkedGoal = components.count > 6 ? components[6].trimmingCharacters(in: .whitespaces) : nil
        
        // Create transaction
        return Transaction(
            id: UUID(),
            title: title,
            subtitle: subtitle,
            amount: amount,
            iconName: category.symbol,
            iconColorName: category.color.toHex(),
            iconBackgroundName: category.color.toHex() + ".opacity15",
            category: category,
            isIncome: isIncome,
            linkedGoalName: linkedGoal == "None" ? nil : linkedGoal,
            date: date
        )
    }
    
    private func parseGoal(from components: [String]) throws -> GoalFormData {
        guard components.count >= 7 else {
            throw ImportError.invalidFormat("Goal requires at least 7 columns")
        }
        
        let name = components[0].trimmingCharacters(in: .whitespaces)
        let subtitle = components[1].trimmingCharacters(in: .whitespaces)
        let targetAmount = Double(components[2].trimmingCharacters(in: .whitespaces)) ?? 0.0
        let savedAmount = Double(components[3].trimmingCharacters(in: .whitespaces)) ?? 0.0
        let targetDateString = components[4].trimmingCharacters(in: .whitespaces)
        let notes = components[5].trimmingCharacters(in: .whitespaces)
        let iconName = components[6].trimmingCharacters(in: .whitespaces)
        
        // Parse date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let targetDate = dateFormatter.date(from: targetDateString) ?? Date()
        
        // Create goal
        return GoalFormData(
            name: name,
            subtitle: subtitle.isEmpty ? nil : subtitle,
            targetAmount: targetAmount,
            savedAmount: savedAmount,
            targetDate: targetDate,
            notes: notes.isEmpty ? nil : notes,
            iconName: iconName,
            iconColorName: TransactionCategory.savings.color.toHex()
        )
    }
    
    private func parseUserSettings(from components: [String]) throws -> ImportPreview.UserSettingsImport {
        guard components.count >= 5 else {
            throw ImportError.invalidFormat("User settings require at least 5 columns")
        }
        
        let displayName = components[0].trimmingCharacters(in: .whitespaces)
        let preferredCurrency = components[1].trimmingCharacters(in: .whitespaces)
        let baselineBalance = Double(components[2].trimmingCharacters(in: .whitespaces)) ?? 0.0
        let notificationsEnabled = components[3].trimmingCharacters(in: .whitespaces).lowercased() == "true"
        let hapticsEnabled = components[4].trimmingCharacters(in: .whitespaces).lowercased() == "true"
        
        return ImportPreview.UserSettingsImport(
            displayName: displayName,
            preferredCurrency: preferredCurrency,
            baselineBalance: baselineBalance,
            notificationsEnabled: notificationsEnabled,
            hapticsEnabled: hapticsEnabled
        )
    }
    
    private func performImport() {
        guard let preview = importPreview else { return }
        
        // Import transactions
        transactions = preview.transactions
        
        // Import goals
        goals = preview.goals
        
        // Import user settings
        displayName = preview.userSettings.displayName
        selectedCurrency = preview.userSettings.preferredCurrency
        baselineBalance = preview.userSettings.baselineBalance
        notificationsEnabled = preview.userSettings.notificationsEnabled
        hapticsEnabled = preview.userSettings.hapticsEnabled
        
        // Reset import state and close sheet
        resetImportState()
        showImportSheet = false
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
}

// MARK: - About View
struct AboutView: View {
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // App Icon
                ZStack {
                    Circle()
                        .fill(AppColors.brandBlack.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 60, weight: .medium))
                        .foregroundColor(AppColors.brandBlack)
                }
                
                VStack(spacing: 16) {
                    Text("ABC Budgeting")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.primary)
                    
                    Text("Smart financial planning made simple")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 24) {
                    infoRow(icon: "info.circle", title: "Version", value: "1.0.0")
                    infoRow(icon: "calendar", title: "Released", value: "2024")
                    infoRow(icon: "building.2", title: "Developer", value: "Spookers")
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 12, y: 4)
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
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(AppColors.brandBlue)
                .frame(width: 24)
            
            Text(title)
                .font(.body.weight(.medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
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
