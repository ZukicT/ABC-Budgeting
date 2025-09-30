import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var dataClearingService: DataClearingService
    @StateObject private var settingsViewModel = SettingsViewModel()
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var showClearDataConfirmation = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var showVersionHistory = false
    @State private var showFontLicensing = false
    @State private var showExportData = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Header Section
                VStack(spacing: Constants.UI.Spacing.medium) {
                    HStack(alignment: .center) {
                        Text(contentManager.localizedString("nav.settings"))
                            .font(Constants.Typography.H1.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                        
                        Spacer()
                    }
                    .padding(.top, -Constants.UI.Spacing.medium)
                }
                .padding(Constants.UI.Padding.screenMargin)
                .background(Constants.Colors.backgroundPrimary)
                
                ScrollView {
                    VStack(spacing: Constants.UI.Spacing.large) {
                        // Settings Sections
                        VStack(spacing: Constants.UI.Spacing.large) {
                            // Notifications Section
                            SettingsSection(title: contentManager.localizedString("settings.notifications"), icon: "bell.fill") {
                                VStack(spacing: Constants.UI.Spacing.medium) {
                                    SettingsToggle(
                                        title: contentManager.localizedString("settings.push_notifications"),
                                        subtitle: contentManager.localizedString("settings.subtitle.push_notifications"),
                                        isOn: $settingsViewModel.notificationsEnabled
                                    )
                                    
                                    SettingsToggle(
                                        title: contentManager.localizedString("settings.budget_alerts"),
                                        subtitle: contentManager.localizedString("settings.subtitle.budget_alerts"),
                                        isOn: $settingsViewModel.budgetAlertsEnabled
                                    )
                                }
                            }
                            
                            // Budget Settings Section
                            SettingsSection(title: contentManager.localizedString("settings.budget_settings"), icon: "chart.bar.fill") {
                                VStack(spacing: Constants.UI.Spacing.medium) {
                                    SettingsCurrencyPicker(
                                        title: contentManager.localizedString("settings.default_currency"),
                                        subtitle: contentManager.localizedString("settings.subtitle.default_currency"),
                                        selection: $settingsViewModel.selectedCurrency,
                                        currencies: SettingsViewModel.availableCurrencies,
                                        currencyNames: SettingsViewModel.currencyDisplayNames
                                    )
                                    
                                    SettingsPicker(
                                        title: contentManager.localizedString("settings.budget_period"),
                                        subtitle: contentManager.localizedString("settings.subtitle.budget_period"),
                                        selection: $settingsViewModel.budgetPeriod,
                                        options: SettingsViewModel.availableBudgetPeriods
                                    )
                                }
                            }
                            
                            // Language Settings Section
                            SettingsSection(title: contentManager.localizedString("settings.language"), icon: "globe") {
                                VStack(spacing: Constants.UI.Spacing.medium) {
                                    SettingsLanguagePicker(
                                        title: contentManager.localizedString("settings.text_to_speech_language"),
                                        subtitle: contentManager.localizedString("settings.subtitle.text_to_speech_language"),
                                        selection: $settingsViewModel.selectedLanguage,
                                        languages: SettingsViewModel.availableLanguages,
                                        languageNames: SettingsViewModel.languageDisplayNames
                                    )
                                }
                            }
                            
                            // Data & Privacy Section
                            SettingsSection(title: contentManager.localizedString("settings.data_privacy"), icon: "shield.fill") {
                                VStack(spacing: Constants.UI.Spacing.medium) {
                                    SettingsButton(
                                        title: contentManager.localizedString("settings.export_data"),
                                        subtitle: contentManager.localizedString("settings.subtitle.export_data"),
                                        action: {
                                            showExportData = true
                                        }
                                    )
                                    
                                    SettingsDestructiveButton(
                                        title: contentManager.localizedString("settings.clear_all_data"),
                                        subtitle: contentManager.localizedString("settings.subtitle.clear_all_data"),
                                        action: {
                                            showClearDataConfirmation = true
                                        }
                                    )
                                }
                            }
                            
                            // Test Data Section removed for production
                            
                            // About Section
                            SettingsSection(title: contentManager.localizedString("settings.about"), icon: "info.circle.fill") {
                                VStack(spacing: Constants.UI.Spacing.medium) {
                                    SettingsAboutItem(
                                        title: contentManager.localizedString("settings.version"),
                                        value: settingsViewModel.appVersion
                                    )
                                    
                                    SettingsButton(
                                        title: contentManager.localizedString("settings.version_history"),
                                        subtitle: contentManager.localizedString("settings.subtitle.version_history"),
                                        action: {
                                            showVersionHistory = true
                                        }
                                    )
                                    
                                    SettingsButton(
                                        title: contentManager.localizedString("settings.privacy_policy"),
                                        subtitle: contentManager.localizedString("settings.subtitle.privacy_policy"),
                                        action: {
                                            showPrivacyPolicy = true
                                        }
                                    )
                                    
                                    SettingsButton(
                                        title: contentManager.localizedString("settings.terms_of_service"),
                                        subtitle: contentManager.localizedString("settings.subtitle.terms_of_service"),
                                        action: {
                                            showTermsOfService = true
                                        }
                                    )
                                    
                                    SettingsButton(
                                        title: contentManager.localizedString("settings.font_licensing"),
                                        subtitle: contentManager.localizedString("settings.subtitle.font_licensing"),
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
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(contentManager.localizedString("button.done")) {
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                }
            }
            .alert("Clear All Data", isPresented: $showClearDataConfirmation) {
                Button(contentManager.localizedString("button.cancel"), role: .cancel) { }
                Button(contentManager.localizedString("button.clear_all_data"), role: .destructive) {
                    dataClearingService.clearAllData()
                }
            } message: {
                Text(contentManager.localizedString("clear_data.warning"))
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
        .onChange(of: settingsViewModel.selectedLanguage) { _, newLanguage in
            contentManager.updateLanguage(newLanguage)
        }
    }
    
    // MARK: - Test Data Functions
    
    // Test data functionality removed for production
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
                .tint(Constants.Colors.accentColor)
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
            .tint(Constants.Colors.accentColor)
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
            .tint(Constants.Colors.accentColor)
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
            .tint(Constants.Colors.accentColor)
        }
        .padding(Constants.UI.Padding.cardInternal)
    }
}

#Preview {
    SettingsView(dataClearingService: DataClearingService())
}
