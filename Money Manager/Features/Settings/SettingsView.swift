import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var biometricEnabled = true
    @State private var currency = "USD"
    @State private var budgetPeriod = "Monthly"
    
    private let currencies = [
        // Major Global Currencies
        "USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "NZD",
        // Asian Currencies
        "CNY", "HKD", "SGD", "KRW", "THB", "MYR", "PHP", "IDR", "VND", "INR", "PKR", "BDT", "LKR", "NPR", "MMK", "KHR", "LAK", "BND", "TWD", "MOP",
        // European Currencies
        "SEK", "NOK", "DKK", "PLN", "CZK", "HUF", "RON", "BGN", "HRK", "RSD", "UAH", "RUB", "TRY", "ISK",
        // Middle East & Africa
        "AED", "SAR", "QAR", "KWD", "BHD", "OMR", "JOD", "ILS", "EGP", "ZAR", "NGN", "KES", "GHS", "MAD", "TND", "DZD",
        // Americas
        "BRL", "MXN", "ARS", "CLP", "COP", "PEN", "UYU", "BOB", "PYG", "VES", "GTQ", "HNL", "NIO", "CRC", "PAB", "DOP", "JMD", "TTD", "BBD", "XCD",
        // Other Major Currencies
        "RUB", "ZAR", "BRL", "MXN", "INR", "CNY", "KRW", "SGD", "HKD", "TWD"
    ]
    private let budgetPeriods = ["Weekly", "Monthly", "Yearly"]
    
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
                                    isOn: $notificationsEnabled
                                )
                                
                                SettingsToggle(
                                    title: "Budget Alerts",
                                    subtitle: "Get notified when approaching budget limits",
                                    isOn: $notificationsEnabled
                                )
                            }
                        }
                        
                        // Security Section
                        SettingsSection(title: "Security", icon: "lock.fill") {
                            VStack(spacing: Constants.UI.Spacing.medium) {
                                SettingsToggle(
                                    title: "Biometric Authentication",
                                    subtitle: "Use Face ID or Touch ID to secure the app",
                                    isOn: $biometricEnabled
                                )
                                
                                SettingsButton(
                                    title: "Change Passcode",
                                    subtitle: "Update your app passcode",
                                    action: {
                                        // TODO: Implement change passcode
                                    }
                                )
                            }
                        }
                        
                        // Appearance Section
                        SettingsSection(title: "Appearance", icon: "paintbrush.fill") {
                            VStack(spacing: Constants.UI.Spacing.medium) {
                                SettingsToggle(
                                    title: "Dark Mode",
                                    subtitle: "Switch between light and dark themes",
                                    isOn: $darkModeEnabled
                                )
                            }
                        }
                        
                        // Budget Settings Section
                        SettingsSection(title: "Budget Settings", icon: "chart.bar.fill") {
                            VStack(spacing: Constants.UI.Spacing.medium) {
                                SettingsCurrencyPicker(
                                    title: "Default Currency",
                                    subtitle: "Choose your preferred currency",
                                    selection: $currency
                                )
                                
                                SettingsPicker(
                                    title: "Budget Period",
                                    subtitle: "Set your default budget timeframe",
                                    selection: $budgetPeriod,
                                    options: budgetPeriods
                                )
                            }
                        }
                        
                        // Data & Privacy Section
                        SettingsSection(title: "Data & Privacy", icon: "shield.fill") {
                            VStack(spacing: Constants.UI.Spacing.medium) {
                                SettingsButton(
                                    title: "Export Data",
                                    subtitle: "Download your budget data",
                                    action: {
                                        // TODO: Implement export data
                                    }
                                )
                                
                                SettingsButton(
                                    title: "Clear All Data",
                                    subtitle: "Remove all transactions and budgets",
                                    action: {
                                        // TODO: Implement clear data
                                    }
                                )
                            }
                        }
                        
                        // About Section
                        SettingsSection(title: "About", icon: "info.circle.fill") {
                            VStack(spacing: Constants.UI.Spacing.medium) {
                                SettingsAboutItem(
                                    title: "App Version",
                                    value: "1.0.0"
                                )
                                
                                SettingsButton(
                                    title: "Version History",
                                    subtitle: "View recent updates and changes",
                                    action: {
                                        // TODO: Implement version history
                                    }
                                )
                                
                                SettingsButton(
                                    title: "Privacy Policy",
                                    subtitle: "Read our privacy policy",
                                    action: {
                                        // TODO: Implement privacy policy
                                    }
                                )
                                
                                SettingsButton(
                                    title: "Terms of Service",
                                    subtitle: "Read our terms of service",
                                    action: {
                                        // TODO: Implement terms of service
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
        }
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

// MARK: - Settings Currency Picker
private struct SettingsCurrencyPicker: View {
    let title: String
    let subtitle: String
    @Binding var selection: String
    
    private let currencyNames: [String: String] = [
        // Major Global Currencies
        "USD": "US Dollar", "EUR": "Euro", "GBP": "British Pound", "JPY": "Japanese Yen", "CHF": "Swiss Franc", "CAD": "Canadian Dollar", "AUD": "Australian Dollar", "NZD": "New Zealand Dollar",
        // Asian Currencies
        "CNY": "Chinese Yuan", "HKD": "Hong Kong Dollar", "SGD": "Singapore Dollar", "KRW": "South Korean Won", "THB": "Thai Baht", "MYR": "Malaysian Ringgit", "PHP": "Philippine Peso", "IDR": "Indonesian Rupiah", "VND": "Vietnamese Dong", "INR": "Indian Rupee", "PKR": "Pakistani Rupee", "BDT": "Bangladeshi Taka", "LKR": "Sri Lankan Rupee", "NPR": "Nepalese Rupee", "MMK": "Myanmar Kyat", "KHR": "Cambodian Riel", "LAK": "Lao Kip", "BND": "Brunei Dollar", "TWD": "Taiwan Dollar", "MOP": "Macanese Pataca",
        // European Currencies
        "SEK": "Swedish Krona", "NOK": "Norwegian Krone", "DKK": "Danish Krone", "PLN": "Polish Złoty", "CZK": "Czech Koruna", "HUF": "Hungarian Forint", "RON": "Romanian Leu", "BGN": "Bulgarian Lev", "HRK": "Croatian Kuna", "RSD": "Serbian Dinar", "UAH": "Ukrainian Hryvnia", "RUB": "Russian Ruble", "TRY": "Turkish Lira", "ISK": "Icelandic Króna",
        // Middle East & Africa
        "AED": "UAE Dirham", "SAR": "Saudi Riyal", "QAR": "Qatari Riyal", "KWD": "Kuwaiti Dinar", "BHD": "Bahraini Dinar", "OMR": "Omani Rial", "JOD": "Jordanian Dinar", "ILS": "Israeli Shekel", "EGP": "Egyptian Pound", "ZAR": "South African Rand", "NGN": "Nigerian Naira", "KES": "Kenyan Shilling", "GHS": "Ghanaian Cedi", "MAD": "Moroccan Dirham", "TND": "Tunisian Dinar", "DZD": "Algerian Dinar",
        // Americas
        "BRL": "Brazilian Real", "MXN": "Mexican Peso", "ARS": "Argentine Peso", "CLP": "Chilean Peso", "COP": "Colombian Peso", "PEN": "Peruvian Sol", "UYU": "Uruguayan Peso", "BOB": "Bolivian Boliviano", "PYG": "Paraguayan Guarani", "VES": "Venezuelan Bolívar", "GTQ": "Guatemalan Quetzal", "HNL": "Honduran Lempira", "NIO": "Nicaraguan Córdoba", "CRC": "Costa Rican Colón", "PAB": "Panamanian Balboa", "DOP": "Dominican Peso", "JMD": "Jamaican Dollar", "TTD": "Trinidad and Tobago Dollar", "BBD": "Barbadian Dollar", "XCD": "East Caribbean Dollar"
    ]
    
    private let currencies = [
        // Major Global Currencies
        "USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "NZD",
        // Asian Currencies
        "CNY", "HKD", "SGD", "KRW", "THB", "MYR", "PHP", "IDR", "VND", "INR", "PKR", "BDT", "LKR", "NPR", "MMK", "KHR", "LAK", "BND", "TWD", "MOP",
        // European Currencies
        "SEK", "NOK", "DKK", "PLN", "CZK", "HUF", "RON", "BGN", "HRK", "RSD", "UAH", "RUB", "TRY", "ISK",
        // Middle East & Africa
        "AED", "SAR", "QAR", "KWD", "BHD", "OMR", "JOD", "ILS", "EGP", "ZAR", "NGN", "KES", "GHS", "MAD", "TND", "DZD",
        // Americas
        "BRL", "MXN", "ARS", "CLP", "COP", "PEN", "UYU", "BOB", "PYG", "VES", "GTQ", "HNL", "NIO", "CRC", "PAB", "DOP", "JMD", "TTD", "BBD", "XCD"
    ]
    
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
    SettingsView()
}
