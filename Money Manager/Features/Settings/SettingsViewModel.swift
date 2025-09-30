//
//  SettingsViewModel.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  ViewModel for managing all app settings and user preferences. Handles
//  notification settings, currency selection, theme preferences, and data
//  management with proper persistence and state management.
//
//  Review Date: September 29, 2025
//

import Foundation
import SwiftUI
import UserNotifications

class SettingsViewModel: ObservableObject {
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notifications_enabled")
            updateNotificationSettings()
        }
    }
    
    @Published var budgetAlertsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(budgetAlertsEnabled, forKey: "budget_alerts_enabled")
            updateNotificationSettings()
        }
    }
    
    @Published var selectedCurrency: String {
        didSet {
            UserDefaults.standard.set(selectedCurrency, forKey: "selected_currency")
            CurrencyUtility.setCurrency(CurrencyUtility.Currency(rawValue: selectedCurrency) ?? .usd)
        }
    }
    
    @Published var budgetPeriod: String {
        didSet {
            UserDefaults.standard.set(budgetPeriod, forKey: "budget_period")
        }
    }
    
    // Language Settings
    @Published var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: "selected_language")
        }
    }
    
    // App Information
    @Published var appVersion: String = Constants.appVersion
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Initialization
    
    init() {
        // Load settings from UserDefaults with defaults
        self.notificationsEnabled = userDefaults.object(forKey: "notifications_enabled") as? Bool ?? true
        self.budgetAlertsEnabled = userDefaults.object(forKey: "budget_alerts_enabled") as? Bool ?? true
        self.selectedCurrency = userDefaults.string(forKey: "selected_currency") ?? "USD"
        self.budgetPeriod = userDefaults.string(forKey: "budget_period") ?? "Monthly"
        self.selectedLanguage = userDefaults.string(forKey: "selected_language") ?? "en-US"
        
        // Request notification permissions on first launch
        requestNotificationPermissions()
    }
    
    // MARK: - Notification Management
    
    /// Requests notification permissions from the user
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Notification permission error: \(error.localizedDescription)")
                } else {
                    print("✅ Notification permission granted: \(granted)")
                }
            }
        }
    }
    
    /// Updates notification settings based on user preferences
    private func updateNotificationSettings() {
        if notificationsEnabled {
            requestNotificationPermissions()
        }
    }
    
    // MARK: - Settings Actions
    
    /// Opens the app's privacy policy
    func openPrivacyPolicy() {
        // For now, show an alert. In production, this would open a web view or Safari
        print("📄 Opening Privacy Policy")
        // TODO: Implement web view or Safari opening
    }
    
    /// Opens the app's terms of service
    func openTermsOfService() {
        // For now, show an alert. In production, this would open a web view or Safari
        print("📋 Opening Terms of Service")
        // TODO: Implement web view or Safari opening
    }
    
    /// Shows version history information
    func showVersionHistory() {
        print("📱 Showing Version History")
        // TODO: Implement version history modal
    }
    
    /// Resets all settings to default values
    func resetToDefaults() {
        notificationsEnabled = true
        budgetAlertsEnabled = true
        selectedCurrency = "USD"
        budgetPeriod = "Monthly"
        selectedLanguage = "en-US"
        
        print("🔄 Settings reset to defaults")
    }
    
    // MARK: - Data Management
    
    /// Exports user data (placeholder for future implementation)
    func exportData() {
        print("📤 Exporting user data")
        // TODO: Implement CSV export functionality
    }
    
    /// Clears all user data (handled by DataClearingService)
    func clearAllData() {
        print("🗑️ Clearing all user data")
        // This is handled by DataClearingService
    }
}

// MARK: - Settings Data Models

/// Represents different budget periods
enum BudgetPeriod: String, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case yearly = "Yearly"
    
    var displayName: String {
        return rawValue
    }
}

/// Represents different notification types for settings
enum SettingsNotificationType: String, CaseIterable {
    case budgetAlerts = "budget_alerts"
    case paymentReminders = "payment_reminders"
    case goalUpdates = "goal_updates"
    
    var displayName: String {
        switch self {
        case .budgetAlerts:
            return "Budget Alerts"
        case .paymentReminders:
            return "Payment Reminders"
        case .goalUpdates:
            return "Goal Updates"
        }
    }
}

/// Represents different languages for text-to-speech
enum SpeechLanguage: String, CaseIterable {
    case englishUS = "en-US"
    case chinese = "zh-CN"
    case japanese = "ja-JP"
    
    var displayName: String {
        switch self {
        case .englishUS: return "English"
        case .chinese: return "Chinese (中文)"
        case .japanese: return "Japanese (日本語)"
        }
    }
    
    var languageCode: String {
        return rawValue
    }
}

// MARK: - Settings Constants

extension SettingsViewModel {
    
    /// Available currencies for selection
    static let availableCurrencies = [
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
    
    /// Available budget periods
    static let availableBudgetPeriods = BudgetPeriod.allCases.map { $0.displayName }
    
    /// Available languages for text-to-speech
    static let availableLanguages = SpeechLanguage.allCases.map { $0.displayName }
    
    /// Language display names mapping
    static let languageDisplayNames: [String: String] = Dictionary(uniqueKeysWithValues: SpeechLanguage.allCases.map { ($0.languageCode, $0.displayName) })
    
    /// Currency display names mapping
    static let currencyDisplayNames: [String: String] = [
        // Major Global Currencies
        "USD": "US Dollar", "EUR": "Euro", "GBP": "British Pound", "JPY": "Japanese Yen", "CHF": "Swiss Franc", "CAD": "Canadian Dollar", "AUD": "Australian Dollar", "NZD": "New Zealand Dollar",
        // Asian Currencies
        "CNY": "Chinese Yuan", "HKD": "Hong Kong Dollar", "SGD": "Singapore Dollar", "KRW": "South Korean Won", "THB": "Thai Baht", "MYR": "Malaysian Ringgit", "PHP": "Philippine Peso", "IDR": "Indonesian Rupiah", "VND": "Vietnamese Dong", "INR": "Indian Rupee", "PKR": "Pakistani Rupee", "BDT": "Bangladeshi Taka", "LKR": "Sri Lankan Rupee", "NPR": "Nepalese Rupee", "MMK": "Myanmar Kyat", "KHR": "Cambodian Riel", "LAK": "Lao Kip", "BND": "Brunei Dollar", "TWD": "Taiwan Dollar", "MOP": "Macanese Pataca",
        // European Currencies
        "SEK": "Swedish Krona", "NOK": "Norwegian Krone", "DKK": "Danish Krona", "PLN": "Polish Złoty", "CZK": "Czech Koruna", "HUF": "Hungarian Forint", "RON": "Romanian Leu", "BGN": "Bulgarian Lev", "HRK": "Croatian Kuna", "RSD": "Serbian Dinar", "UAH": "Ukrainian Hryvnia", "RUB": "Russian Ruble", "TRY": "Turkish Lira", "ISK": "Icelandic Króna",
        // Middle East & Africa
        "AED": "UAE Dirham", "SAR": "Saudi Riyal", "QAR": "Qatari Riyal", "KWD": "Kuwaiti Dinar", "BHD": "Bahraini Dinar", "OMR": "Omani Rial", "JOD": "Jordanian Dinar", "ILS": "Israeli Shekel", "EGP": "Egyptian Pound", "ZAR": "South African Rand", "NGN": "Nigerian Naira", "KES": "Kenyan Shilling", "GHS": "Ghanaian Cedi", "MAD": "Moroccan Dirham", "TND": "Tunisian Dinar", "DZD": "Algerian Dinar",
        // Americas
        "BRL": "Brazilian Real", "MXN": "Mexican Peso", "ARS": "Argentine Peso", "CLP": "Chilean Peso", "COP": "Colombian Peso", "PEN": "Peruvian Sol", "UYU": "Uruguayan Peso", "BOB": "Bolivian Boliviano", "PYG": "Paraguayan Guarani", "VES": "Venezuelan Bolívar", "GTQ": "Guatemalan Quetzal", "HNL": "Honduran Lempira", "NIO": "Nicaraguan Córdoba", "CRC": "Costa Rican Colón", "PAB": "Panamanian Balboa", "DOP": "Dominican Peso", "JMD": "Jamaican Dollar", "TTD": "Trinidad and Tobago Dollar", "BBD": "Barbadian Dollar", "XCD": "East Caribbean Dollar"
    ]
}
