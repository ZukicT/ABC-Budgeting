import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var dataClearingService: DataClearingService
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var showClearDataConfirmation = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var showVersionHistory = false
    @State private var showFontLicensing = false
    @State private var showExportData = false
    @State private var hasTestData = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Constants.UI.Spacing.large) {
                    // Settings Sections
                    VStack(spacing: Constants.UI.Spacing.large) {
                        // Notifications Section
                        SettingsSection(title: "Notifications", icon: "bell.fill") {
                            VStack(spacing: Constants.UI.Spacing.medium) {
                                SettingsToggle(
                                    title: "Push Notifications",
                                    subtitle: "Receive alerts for budget limits and payments",
                                    isOn: $settingsViewModel.notificationsEnabled
                                )
                                
                                SettingsToggle(
                                    title: "Budget Alerts",
                                    subtitle: "Get notified when approaching budget limits",
                                    isOn: $settingsViewModel.budgetAlertsEnabled
                                )
                            }
                        }
                        
                        // Budget Settings Section
                        SettingsSection(title: "Budget Settings", icon: "chart.bar.fill") {
                            VStack(spacing: Constants.UI.Spacing.medium) {
                                SettingsCurrencyPicker(
                                    title: "Default Currency",
                                    subtitle: "Choose your preferred currency",
                                    selection: $settingsViewModel.selectedCurrency,
                                    currencies: SettingsViewModel.availableCurrencies,
                                    currencyNames: SettingsViewModel.currencyDisplayNames
                                )
                                
                                SettingsPicker(
                                    title: "Budget Period",
                                    subtitle: "Set your default budget timeframe",
                                    selection: $settingsViewModel.budgetPeriod,
                                    options: SettingsViewModel.availableBudgetPeriods
                                )
                            }
                        }
                        
                        // Language Settings Section
                        SettingsSection(title: "Language", icon: "globe") {
                            VStack(spacing: Constants.UI.Spacing.medium) {
                                SettingsLanguagePicker(
                                    title: "Text-to-Speech Language",
                                    subtitle: "Choose language for reading policy documents",
                                    selection: $settingsViewModel.selectedLanguage,
                                    languages: SettingsViewModel.availableLanguages,
                                    languageNames: SettingsViewModel.languageDisplayNames
                                )
                            }
                        }
                        
                        // Data & Privacy Section
                        SettingsSection(title: "Data & Privacy", icon: "shield.fill") {
                            VStack(spacing: Constants.UI.Spacing.medium) {
                                SettingsButton(
                                    title: "Export Data",
                                    subtitle: "Download your financial data as CSV",
                                    action: {
                                        showExportData = true
                                    }
                                )
                                
                                SettingsDestructiveButton(
                                    title: "Clear All Data",
                                    subtitle: "Remove all transactions and budgets",
                                    action: {
                                        showClearDataConfirmation = true
                                    }
                                )
                            }
                        }
                        
                        // Test Data Section (Development Only)
                        SettingsSection(title: "Test Data", icon: "testtube.2") {
                            VStack(spacing: Constants.UI.Spacing.medium) {
                                if hasTestData {
                                    SettingsButton(
                                        title: "Remove Test Data",
                                        subtitle: "Clear all sample data",
                                        action: {
                                            removeTestData()
                                        }
                                    )
                                } else {
                                    SettingsButton(
                                        title: "Add Test Data",
                                        subtitle: "Add sample transactions, budgets, and loans",
                                        action: {
                                            addTestData()
                                        }
                                    )
                                }
                            }
                        }
                        
                        // About Section
                        SettingsSection(title: "About", icon: "info.circle.fill") {
                            VStack(spacing: Constants.UI.Spacing.medium) {
                                SettingsAboutItem(
                                    title: "App Version",
                                    value: settingsViewModel.appVersion
                                )
                                
                                SettingsButton(
                                    title: "Version History",
                                    subtitle: "View recent updates and changes",
                                    action: {
                                        showVersionHistory = true
                                    }
                                )
                                
                                SettingsButton(
                                    title: "Privacy Policy",
                                    subtitle: "Read our privacy policy",
                                    action: {
                                        showPrivacyPolicy = true
                                    }
                                )
                                
                                SettingsButton(
                                    title: "Terms of Service",
                                    subtitle: "Read our terms of service",
                                    action: {
                                        showTermsOfService = true
                                    }
                                )
                                
                                SettingsButton(
                                    title: "Font Licensing",
                                    subtitle: "Trap font family licensing information",
                                    action: {
                                        showFontLicensing = true
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, Constants.UI.Padding.screenMargin)
                    .padding(.top, Constants.UI.Spacing.medium)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                }
            }
            .alert("Clear All Data", isPresented: $showClearDataConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All Data", role: .destructive) {
                    dataClearingService.clearAllData()
                }
            } message: {
                Text("This will permanently delete all your transactions, budgets, and loans. This action cannot be undone. You will be asked to set a new starting balance.")
            }
            .fullScreenCover(isPresented: $dataClearingService.showStartingBalancePrompt) {
                StartingBalancePromptView(dataClearingService: dataClearingService)
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showTermsOfService) {
                TermsOfServiceView()
            }
            .sheet(isPresented: $showVersionHistory) {
                VersionHistoryView()
            }
            .sheet(isPresented: $showFontLicensing) {
                FontLicensingView()
            }
            .sheet(isPresented: $showExportData) {
                ExportDataView(
                    transactionViewModel: dataClearingService.transactionViewModel ?? TransactionViewModel(),
                    budgetViewModel: dataClearingService.budgetViewModel ?? BudgetViewModel(),
                    loanViewModel: dataClearingService.loanViewModel ?? LoanViewModel()
                )
            }
        }
    }
    
    // MARK: - Test Data Functions
    
    private func addTestData() {
        guard let transactionViewModel = dataClearingService.transactionViewModel,
              let budgetViewModel = dataClearingService.budgetViewModel,
              let loanViewModel = dataClearingService.loanViewModel else {
            return
        }
        
        TestDataService.addTestData(
            transactionViewModel: transactionViewModel,
            budgetViewModel: budgetViewModel,
            loanViewModel: loanViewModel
        )
        
        hasTestData = true
    }
    
    private func removeTestData() {
        guard let transactionViewModel = dataClearingService.transactionViewModel,
              let budgetViewModel = dataClearingService.budgetViewModel,
              let loanViewModel = dataClearingService.loanViewModel else {
            return
        }
        
        TestDataService.clearTestData(
            transactionViewModel: transactionViewModel,
            budgetViewModel: budgetViewModel,
            loanViewModel: loanViewModel
        )
        
        hasTestData = false
    }
}

// MARK: - Settings Section
private struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
            // Section Header
            HStack(spacing: Constants.UI.Spacing.small) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Text(title)
                    .font(Constants.Typography.H3.font)
                    .fontWeight(.semibold)
                    .foregroundColor(Constants.Colors.textPrimary)
            }
            
            // Section Content
            VStack(spacing: 0) {
                content
            }
            .background(Constants.Colors.textPrimary.opacity(0.05))
            .cornerRadius(Constants.UI.cardCornerRadius)
        }
    }
}

// MARK: - Settings Toggle
private struct SettingsToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: Constants.UI.Spacing.medium) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Text(subtitle)
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(Constants.UI.Padding.cardInternal)
    }
}

// MARK: - Settings Button
private struct SettingsButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.UI.Spacing.medium) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.medium)
                        .foregroundColor(Constants.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Constants.Colors.textTertiary)
            }
            .padding(Constants.UI.Padding.cardInternal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Destructive Button
private struct SettingsDestructiveButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.UI.Spacing.medium) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Constants.Typography.Body.font)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "#FE3A01"))
                    
                    Text(subtitle)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            .padding(Constants.UI.Padding.cardInternal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Currency Picker
private struct SettingsCurrencyPicker: View {
    let title: String
    let subtitle: String
    @Binding var selection: String
    let currencies: [String]
    let currencyNames: [String: String]
    
    var body: some View {
        HStack(spacing: Constants.UI.Spacing.medium) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Text(subtitle)
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            
            Spacer()
            
            Picker("", selection: $selection) {
                ForEach(currencies, id: \.self) { currency in
                    HStack {
                        Text(currency)
                            .fontWeight(.semibold)
                        Text(currencyNames[currency] ?? "")
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                    .tag(currency)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .labelsHidden()
        }
        .padding(Constants.UI.Padding.cardInternal)
    }
}

// MARK: - Settings Language Picker
private struct SettingsLanguagePicker: View {
    let title: String
    let subtitle: String
    @Binding var selection: String
    let languages: [String]
    let languageNames: [String: String]
    
    var body: some View {
        HStack(spacing: Constants.UI.Spacing.medium) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Text(subtitle)
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            
            Spacer()
            
            Picker("", selection: $selection) {
                ForEach(SpeechLanguage.allCases, id: \.languageCode) { language in
                    Text(language.displayName)
                        .tag(language.languageCode)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .labelsHidden()
        }
        .padding(Constants.UI.Padding.cardInternal)
    }
}

// MARK: - Settings About Item
private struct SettingsAboutItem: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: Constants.UI.Spacing.medium) {
            Text(title)
                .font(Constants.Typography.Body.font)
                .fontWeight(.medium)
                .foregroundColor(Constants.Colors.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(Constants.Typography.Body.font)
                .foregroundColor(Constants.Colors.textSecondary)
        }
        .padding(Constants.UI.Padding.cardInternal)
    }
}

// MARK: - Settings Picker
private struct SettingsPicker: View {
    let title: String
    let subtitle: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        HStack(spacing: Constants.UI.Spacing.medium) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Constants.Typography.Body.font)
                    .fontWeight(.medium)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Text(subtitle)
                    .font(Constants.Typography.Caption.font)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            
            Spacer()
            
            Picker("", selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .labelsHidden()
        }
        .padding(Constants.UI.Padding.cardInternal)
    }
}

#Preview {
    SettingsView(dataClearingService: DataClearingService())
}
