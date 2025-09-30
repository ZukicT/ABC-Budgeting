//
//  SettingsModalViews.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Settings modal views providing comprehensive app configuration including
//  text-to-speech management, accessibility settings, and user preferences.
//  Features multilingual support and accessibility compliance.
//
//  Review Date: September 29, 2025
//

import SwiftUI
import AVFoundation

@MainActor
class TextToSpeechManager: NSObject, ObservableObject {
    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var selectedSpeed: SpeechSpeed = .normal
    @Published var selectedLanguage: String = "en-US"
    
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    private let contentManager = MultilingualContentManager.shared
    
    override init() {
        super.init()
        synthesizer.delegate = self
        selectedLanguage = UserDefaults.standard.string(forKey: "selected_language") ?? "en-US"
        contentManager.updateLanguage(selectedLanguage)
    }
    
    func speak(_ text: String) {
        // Stop any current speech
        stop()
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = selectedSpeed.rate
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0
        
        // Use the selected language voice
        if let voice = AVSpeechSynthesisVoice(language: selectedLanguage) {
            utterance.voice = voice
        } else {
            // Fallback to English if selected language is not available
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        currentUtterance = utterance
        synthesizer.speak(utterance)
        isPlaying = true
        isPaused = false
    }
    
    func updateLanguage(_ language: String) {
        selectedLanguage = language
        UserDefaults.standard.set(language, forKey: "selected_language")
        contentManager.updateLanguage(language)
        
        // If currently playing, restart with new language
        if isPlaying {
            let wasPaused = isPaused
            stop()
            if !wasPaused {
                // Restart with new language after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let utterance = self.currentUtterance {
                        if let voice = AVSpeechSynthesisVoice(language: language) {
                            utterance.voice = voice
                        }
                        self.synthesizer.speak(utterance)
                        self.isPlaying = true
                        self.isPaused = false
                    }
                }
            }
        }
    }
    
    func pause() {
        if isPlaying && !isPaused {
            synthesizer.pauseSpeaking(at: .immediate)
            isPaused = true
        }
    }
    
    func resume() {
        if isPaused {
            synthesizer.continueSpeaking()
            isPaused = false
        }
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isPlaying = false
        isPaused = false
        currentUtterance = nil
    }
    
    func togglePlayPause(_ text: String) {
        if isPlaying {
            if isPaused {
                resume()
            } else {
                pause()
            }
        } else {
            speak(text)
        }
    }
    
    func changeSpeed(_ speed: SpeechSpeed) {
        selectedSpeed = speed
        // If currently playing, restart with new speed
        if isPlaying {
            let wasPaused = isPaused
            stop()
            if !wasPaused {
                // Restart with new speed after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if let utterance = self.currentUtterance {
                        utterance.rate = speed.rate
                        self.synthesizer.speak(utterance)
                        self.isPlaying = true
                        self.isPaused = false
                    }
                }
            }
        }
    }
}

// MARK: - Speech Speed Enum
enum SpeechSpeed: String, CaseIterable {
    case slow = "0.8x"
    case normal = "1x"
    case fast = "1.2x"
    case faster = "1.5x"
    case fastest = "2x"
    
    var rate: Float {
        switch self {
        case .slow: return AVSpeechUtteranceDefaultSpeechRate * 0.8
        case .normal: return AVSpeechUtteranceDefaultSpeechRate
        case .fast: return AVSpeechUtteranceDefaultSpeechRate * 1.2
        case .faster: return AVSpeechUtteranceDefaultSpeechRate * 1.5
        case .fastest: return AVSpeechUtteranceDefaultSpeechRate * 2.0
        }
    }
    
    var displayName: String {
        return rawValue
    }
}

extension TextToSpeechManager: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPlaying = false
            isPaused = false
            currentUtterance = nil
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPlaying = false
            isPaused = false
            currentUtterance = nil
        }
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speechManager = TextToSpeechManager()
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    private var fullText: String {
        """
        PRIVACY POLICY
        
        Last Updated: January 26, 2025
        
        SECTION 1: ABSOLUTE DATA PRIVACY GUARANTEE
        
        Nuvio operates under a ZERO DATA COLLECTION POLICY. We do not collect, store, transmit, process, analyze, monitor, track, or have access to ANY personal information, financial data, usage patterns, or device information whatsoever. All data remains exclusively on your device.
        
        SECTION 2: COMPREHENSIVE PRIVACY PROTECTION
        
        • NO DATA TRANSMISSION: Zero data is sent over any network connection
        • NO SERVER STORAGE: No data is stored on any external servers
        • NO ANALYTICS: No usage tracking, metrics, or behavioral analysis
        • NO THIRD-PARTY INTEGRATION: No external services or APIs
        • NO CLOUD BACKUP: No automatic cloud synchronization
        • NO COOKIES OR TRACKING: No tracking technologies whatsoever
        
        SECTION 3: LOCAL STORAGE EXCLUSIVELY
        
        All financial data including transactions, budgets, loans, settings, and preferences are stored locally on your device using Core Data. This data is never accessible to us or any third parties under any circumstances.
        
        SECTION 4: USER DATA CONTROL
        
        You maintain complete and absolute control over your data. You may export, modify, delete, or manage your data at any time through the app's built-in tools. We have no ability to access, modify, or delete your data.
        
        SECTION 5: CHILDREN'S PRIVACY COMPLIANCE
        
        This app complies with all children's privacy regulations. Since we collect no data from anyone, including children under 13, no parental consent is required and no privacy concerns exist.
        
        SECTION 6: POLICY MODIFICATIONS
        
        Any updates to this privacy policy will be reflected in the app. Since no data collection occurs, policy changes do not affect existing data or user privacy.
        
        SECTION 7: LEGAL COMPLIANCE
        
        This privacy policy complies with GDPR, CCPA, COPPA, and all applicable privacy regulations. Our zero-data-collection model exceeds all privacy requirements.
        
        SECTION 8: FINAL PRIVACY STATEMENT
        
        Your privacy is absolutely protected. We cannot and do not access any of your information under any circumstances. Your financial data remains completely private and secure on your device only.
        """
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.large) {
                    VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
                        Text(contentManager.getPrivacyPolicyTitle())
                            .font(Constants.Typography.H1.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .textSelection(.enabled)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text(contentManager.localizedString("version.last_updated"))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                            .textSelection(.enabled)
                            .accessibilityLabel("Last updated on January 26, 2025")
                    }
                    
                    VStack(alignment: .leading, spacing: Constants.UI.Spacing.large) {
                        Text(contentManager.getPrivacyPolicyContent())
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .textSelection(.enabled)
                    }
                }
                .padding(Constants.UI.Padding.screenMargin)
            }
            .navigationTitle(contentManager.localizedString("nav.privacy_policy"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: Constants.UI.Spacing.small) {
                        Button(action: {
                            speechManager.togglePlayPause(contentManager.getVersionHistoryContent())
                        }) {
                            Image(systemName: speechManager.isPlaying ? (speechManager.isPaused ? "play.circle.fill" : "pause.circle.fill") : "play.circle.fill")
                                .font(Constants.Typography.H3.font)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        }
                        .accessibilityLabel(speechManager.isPlaying ? (speechManager.isPaused ? contentManager.localizedString("accessibility.resume_reading") : contentManager.localizedString("accessibility.pause_reading")) : contentManager.localizedString("accessibility.start_reading"))
                        
                        // Speed Control
                        Menu {
                            ForEach(SpeechSpeed.allCases, id: \.self) { speed in
                                Button(action: {
                                    speechManager.changeSpeed(speed)
                                }) {
                                    HStack {
                                        Text(speed.displayName)
                                        if speechManager.selectedSpeed == speed {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text(speechManager.selectedSpeed.displayName)
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(Constants.Colors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Constants.Colors.textPrimary.opacity(0.1))
                                .cornerRadius(Constants.UI.CornerRadius.tertiary)
                        }
                        .accessibilityLabel("Speech speed: \(speechManager.selectedSpeed.displayName)")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(contentManager.localizedString("button.done")) {
                        speechManager.stop()
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                }
            }
        }
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speechManager = TextToSpeechManager()
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    private var fullText: String {
        """
        TERMS OF SERVICE
        
        Last Updated: January 26, 2025
        
        SECTION 1: BINDING AGREEMENT
        
        By accessing, downloading, installing, or using Nuvio ('the App'), you irrevocably agree to be bound by these Terms of Service ('Terms'). This constitutes a legally binding agreement. Continued use constitutes acceptance of all terms herein.
        
        SECTION 2: SERVICE DESCRIPTION
        
        Nuvio is a personal finance management tool that operates exclusively on your device. The App provides local data storage and management capabilities without requiring internet connectivity or external services.
        
        SECTION 3: COMPLETE USER RESPONSIBILITY
        
        You assume FULL RESPONSIBILITY for:
        • Accuracy of all data entered into the App
        • All financial decisions made using the App
        • Consequences of any financial actions taken
        • Data backup and security measures
        • Compliance with applicable laws and regulations
        
        SECTION 4: ABSOLUTE LIABILITY DISCLAIMER
        
        TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE HEREBY DISCLAIM ALL LIABILITY FOR:
        • ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES
        • LOSS OF PROFITS, DATA, REVENUE, OR BUSINESS OPPORTUNITIES
        • FINANCIAL LOSSES OR INVESTMENT DECISIONS
        • DATA CORRUPTION, LOSS, OR DELETION
        • APP MALFUNCTION OR TECHNICAL ISSUES
        • THIRD-PARTY ACTIONS OR OMISSIONS
        
        SECTION 5: NO WARRANTIES WHATSOEVER
        
        THE APP IS PROVIDED 'AS IS' WITHOUT ANY WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO:
        • WARRANTIES OF MERCHANTABILITY
        • WARRANTIES OF FITNESS FOR A PARTICULAR PURPOSE
        • WARRANTIES OF NON-INFRINGEMENT
        • WARRANTIES OF ACCURACY OR RELIABILITY
        • WARRANTIES OF CONTINUOUS OPERATION
        
        SECTION 6: PROFESSIONAL ADVICE DISCLAIMER
        
        THIS APP IS NOT PROFESSIONAL FINANCIAL ADVICE. WE ARE NOT:
        • Licensed financial advisors
        • Certified public accountants
        • Tax professionals
        • Investment advisors
        • Legal counsel
        
        CONSULT QUALIFIED PROFESSIONALS FOR ALL FINANCIAL DECISIONS.
        
        SECTION 7: USE AT YOUR OWN RISK
        
        You acknowledge and agree that:
        • Use of the App is entirely at your own risk
        • We make no guarantees about App performance or accuracy
        • You are solely responsible for all outcomes
        • No liability attaches to us for any reason
        
        SECTION 8: DATA AND PRIVACY
        
        All data remains on your device. We do not collect, store, or access any information. You are solely responsible for data security, backup, and management.
        
        SECTION 9: MODIFICATION RIGHTS
        
        We reserve the absolute right to modify these Terms at any time without notice. Continued use constitutes acceptance of modified Terms.
        
        SECTION 10: TERMINATION
        
        Either party may terminate this agreement at any time. We may discontinue the App or its features without notice or liability.
        
        SECTION 11: GOVERNING LAW AND JURISDICTION
        
        These Terms are governed by applicable law. Any disputes shall be resolved in accordance with local jurisdiction requirements.
        
        SECTION 12: SEVERABILITY
        
        If any provision of these Terms is deemed invalid, the remaining provisions shall remain in full force and effect.
        
        SECTION 13: ENTIRE AGREEMENT
        
        These Terms constitute the entire agreement between you and us regarding the App and supersede all prior agreements.
        
        SECTION 14: ACKNOWLEDGMENT
        
        By using this App, you acknowledge that you have read, understood, and agree to be bound by these Terms in their entirety.
        """
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.large) {
                    VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
                        Text(contentManager.getTermsOfServiceTitle())
                            .font(Constants.Typography.H1.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .textSelection(.enabled)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text(contentManager.localizedString("version.last_updated"))
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                            .textSelection(.enabled)
                            .accessibilityLabel("Last updated on January 26, 2025")
                    }
                    
                    VStack(alignment: .leading, spacing: Constants.UI.Spacing.large) {
                        Text(contentManager.getTermsOfServiceContent())
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .textSelection(.enabled)
                    }
                }
                .padding(Constants.UI.Padding.screenMargin)
            }
            .navigationTitle(contentManager.localizedString("nav.terms_of_service"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: Constants.UI.Spacing.small) {
                        Button(action: {
                            speechManager.togglePlayPause(contentManager.getVersionHistoryContent())
                        }) {
                            Image(systemName: speechManager.isPlaying ? (speechManager.isPaused ? "play.circle.fill" : "pause.circle.fill") : "play.circle.fill")
                                .font(Constants.Typography.H3.font)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        }
                        .accessibilityLabel(speechManager.isPlaying ? (speechManager.isPaused ? contentManager.localizedString("accessibility.resume_reading") : contentManager.localizedString("accessibility.pause_reading")) : contentManager.localizedString("accessibility.start_reading"))
                        
                        // Speed Control
                        Menu {
                            ForEach(SpeechSpeed.allCases, id: \.self) { speed in
                                Button(action: {
                                    speechManager.changeSpeed(speed)
                                }) {
                                    HStack {
                                        Text(speed.displayName)
                                        if speechManager.selectedSpeed == speed {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text(speechManager.selectedSpeed.displayName)
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(Constants.Colors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Constants.Colors.textPrimary.opacity(0.1))
                                .cornerRadius(Constants.UI.CornerRadius.tertiary)
                        }
                        .accessibilityLabel("Speech speed: \(speechManager.selectedSpeed.displayName)")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(contentManager.localizedString("button.done")) {
                        speechManager.stop()
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                }
            }
        }
    }
}

// MARK: - Font Licensing View
struct FontLicensingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speechManager = TextToSpeechManager()
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    private var fullText: String {
        """
        Font Licensing
        
        Arvo Font Family Licensing Information
        
        Font Family Used
        
        Nuvio uses the Arvo font family, designed by Anton Koovit. The Arvo font family is an open-source slab serif typeface that provides excellent readability and professional appearance for financial applications.
        
        Designer Credit
        
        The Arvo font family was designed by Anton Koovit, a talented type designer who created this versatile slab serif typeface. Arvo is known for its excellent readability and modern design, making it perfect for both digital and print applications.
        
        Usage Rights
        
        The Arvo font family is used in Nuvio under the SIL Open Font License (OFL). This open-source license allows for free use, modification, and distribution of the font family.
        
        Open Font License
        
        Arvo is licensed under the SIL Open Font License, which is a free, libre and open source license specifically designed for fonts and related software. This license ensures that the font remains freely available for use in commercial and non-commercial projects.
        
        Restrictions
        
        Users of Nuvio may not extract, copy, or redistribute the Arvo font family for separate use outside of the app, as it is embedded within the application. However, the original Arvo font files are freely available for download from the official repository.
        
        Commercial Use
        
        The Arvo font family is used in Nuvio for commercial purposes under the SIL Open Font License. This license allows for commercial use without additional fees or restrictions.
        
        Copyright Notice
        
        The Arvo font family is copyright Anton Koovit. The font is released under the SIL Open Font License, which allows for free use, modification, and distribution.
        
        License Compliance
        
        Nuvio complies with all applicable font licensing terms and copyright laws. The use of the Arvo font family is properly authorized under the SIL Open Font License and does not infringe on any intellectual property rights.
        
        Contact Information
        
        For questions about font licensing or usage, please contact Font Bureau directly. Nuvio users should not attempt to extract or use the font family outside of the application.
        """
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.large) {
                    VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
                        Text(contentManager.getFontLicensingTitle())
                            .font(Constants.Typography.H1.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .textSelection(.enabled)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text(contentManager.localizedString("font.licensing_title"))
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                            .textSelection(.enabled)
                            .accessibilityLabel("Arvo Font Family Licensing Information")
                    }
                    
                    VStack(alignment: .leading, spacing: Constants.UI.Spacing.large) {
                        Text(contentManager.getFontLicensingContent())
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .textSelection(.enabled)
                    }
                }
                .padding(Constants.UI.Padding.screenMargin)
            }
            .navigationTitle(contentManager.localizedString("nav.font_licensing"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: Constants.UI.Spacing.small) {
                        Button(action: {
                            speechManager.togglePlayPause(contentManager.getVersionHistoryContent())
                        }) {
                            Image(systemName: speechManager.isPlaying ? (speechManager.isPaused ? "play.circle.fill" : "pause.circle.fill") : "play.circle.fill")
                                .font(Constants.Typography.H3.font)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        }
                        .accessibilityLabel(speechManager.isPlaying ? (speechManager.isPaused ? contentManager.localizedString("accessibility.resume_reading") : contentManager.localizedString("accessibility.pause_reading")) : contentManager.localizedString("accessibility.start_reading"))
                        
                        // Speed Control
                        Menu {
                            ForEach(SpeechSpeed.allCases, id: \.self) { speed in
                                Button(action: {
                                    speechManager.changeSpeed(speed)
                                }) {
                                    HStack {
                                        Text(speed.displayName)
                                        if speechManager.selectedSpeed == speed {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text(speechManager.selectedSpeed.displayName)
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(Constants.Colors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Constants.Colors.textPrimary.opacity(0.1))
                                .cornerRadius(Constants.UI.CornerRadius.tertiary)
                        }
                        .accessibilityLabel("Speech speed: \(speechManager.selectedSpeed.displayName)")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(contentManager.localizedString("button.done")) {
                        speechManager.stop()
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                }
            }
        }
    }
}

// MARK: - Version History View
struct VersionHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var speechManager = TextToSpeechManager()
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    private var fullText: String {
        """
        Version History
        
        Track the evolution of Nuvio
        
        Version 1.0.0 - January 26, 2025
        
        Initial release of Nuvio
        Complete transaction management system
        Budget tracking and monitoring
        Loan management and payment tracking
        Comprehensive financial overview dashboard
        Data export functionality
        Privacy-focused design with local data storage
        Accessibility features including text-to-speech
        Professional flat design aesthetic
        Support for multiple currencies
        Offline functionality
        
        Version 0.9.0 - January 20, 2025
        
        Beta release with core functionality
        Transaction recording and editing
        Basic budget management
        Initial loan tracking
        Settings and preferences
        Data persistence with Core Data
        User interface refinements
        Performance optimizations
        
        Version 0.8.0 - January 15, 2025
        
        Alpha release
        Transaction recording and editing
        Category management system
        Basic financial calculations
        Navigation structure
        Core Data integration
        Initial user interface
        
        Version 0.7.0 - January 10, 2025
        
        Development release
        Project foundation
        Basic app structure
        Initial design system
        Core Data models
        Basic navigation
        """
    }
    
    private let versionHistory = [
        VersionEntry(version: "1.0.0", date: "January 26, 2025", features: [
            "Initial release of Nuvio",
            "Complete transaction tracking system",
            "Budget management with progress tracking",
            "Loan management and payment tracking",
            "Comprehensive settings and data management",
            "Professional flat design following Apple HIG",
            "Full accessibility support with VoiceOver",
            "Dark mode and Dynamic Type support"
        ]),
        VersionEntry(version: "0.9.0", date: "January 20, 2025", features: [
            "Beta testing phase",
            "Core functionality implementation",
            "UI/UX refinements",
            "Performance optimizations",
            "Bug fixes and stability improvements"
        ]),
        VersionEntry(version: "0.8.0", date: "January 15, 2025", features: [
            "Settings implementation",
            "Data export functionality",
            "Enhanced security features",
            "Accessibility improvements",
            "Code architecture refactoring"
        ]),
        VersionEntry(version: "0.7.0", date: "January 10, 2025", features: [
            "Loan management system",
            "Payment tracking features",
            "Financial insights dashboard",
            "Chart visualizations",
            "Data persistence improvements"
        ])
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.large) {
                    VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
                        Text(contentManager.getVersionHistoryTitle())
                            .font(Constants.Typography.H1.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .textSelection(.enabled)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text(contentManager.localizedString("version.track_evolution"))
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                            .textSelection(.enabled)
                            .accessibilityLabel("Track the evolution of Nuvio")
                    }
                    
                    VStack(alignment: .leading, spacing: Constants.UI.Spacing.large) {
                        Text(contentManager.getVersionHistoryContent())
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .textSelection(.enabled)
                    }
                    .padding(.leading, Constants.UI.Spacing.small)
                }
                .padding(Constants.UI.Padding.screenMargin)
            }
            .navigationTitle(contentManager.localizedString("nav.version_history"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: Constants.UI.Spacing.small) {
                        Button(action: {
                            speechManager.togglePlayPause(contentManager.getVersionHistoryContent())
                        }) {
                            Image(systemName: speechManager.isPlaying ? (speechManager.isPaused ? "play.circle.fill" : "pause.circle.fill") : "play.circle.fill")
                                .font(Constants.Typography.H3.font)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        }
                        .accessibilityLabel(speechManager.isPlaying ? (speechManager.isPaused ? contentManager.localizedString("accessibility.resume_reading") : contentManager.localizedString("accessibility.pause_reading")) : contentManager.localizedString("accessibility.start_reading"))
                        
                        // Speed Control
                        Menu {
                            ForEach(SpeechSpeed.allCases, id: \.self) { speed in
                                Button(action: {
                                    speechManager.changeSpeed(speed)
                                }) {
                                    HStack {
                                        Text(speed.displayName)
                                        if speechManager.selectedSpeed == speed {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text(speechManager.selectedSpeed.displayName)
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(Constants.Colors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Constants.Colors.textPrimary.opacity(0.1))
                                .cornerRadius(Constants.UI.CornerRadius.tertiary)
                        }
                        .accessibilityLabel("Speech speed: \(speechManager.selectedSpeed.displayName)")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(contentManager.localizedString("button.done")) {
                        speechManager.stop()
                        dismiss()
                    }
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                }
            }
        }
    }
}

// MARK: - Supporting Views

private struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
            Text(title)
                .font(Constants.Typography.H3.font)
                .foregroundColor(Constants.Colors.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityHeading(.h3)
            
            Text(content)
                .font(Constants.Typography.Body.font)
                .foregroundColor(Constants.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
                .accessibilityLabel(content)
                .accessibilityElement(children: .combine)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(title). \(content)")
    }
}

private struct GitStyleVersionCard: View {
    let version: VersionEntry
    let isFirst: Bool
    let isLast: Bool
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        HStack(alignment: .top, spacing: Constants.UI.Spacing.medium) {
            // Git-style timeline indicator
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Constants.Colors.textSecondary.opacity(0.4))
                        .frame(width: 2, height: 28)
                        .cornerRadius(1)
                }
                
                Circle()
                    .fill(isFirst ? Constants.Colors.success : Constants.Colors.textSecondary.opacity(0.7))
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .stroke(Constants.Colors.backgroundPrimary, lineWidth: 3)
                    )
                    .shadow(color: Constants.Colors.textSecondary.opacity(0.2), radius: 2, x: 0, y: 1)
                
                if !isLast {
                    Rectangle()
                        .fill(Constants.Colors.textSecondary.opacity(0.4))
                        .frame(width: 2, height: 28)
                        .cornerRadius(1)
                }
            }
            .padding(.top, isFirst ? 0 : 0)
            
            // Version content
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(contentManager.localizedString("version.version")) \(version.version)")
                            .font(Constants.Typography.H3.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .textSelection(.enabled)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityHeading(.h3)
                        
                        Text(version.date)
                            .font(Constants.Typography.Caption.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                            .textSelection(.enabled)
                            .accessibilityLabel("Released on \(version.date)")
                    }
                    
                    Spacer()
                    
                    if isFirst {
                        Image(systemName: "star.fill")
                            .font(Constants.Typography.H3.font)
                            .foregroundColor(Constants.Colors.warning)
                            .accessibilityLabel(contentManager.localizedString("accessibility.latest_version"))
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(Constants.Typography.H3.font)
                            .foregroundColor(Constants.Colors.success)
                            .accessibilityLabel(contentManager.localizedString("accessibility.completed_version"))
                    }
                }
                
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    ForEach(version.features, id: \.self) { feature in
                        HStack(alignment: .top, spacing: Constants.UI.Spacing.small) {
                            Image(systemName: "checkmark")
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(Constants.Colors.success)
                                .padding(.top, 2)
                                .accessibilityHidden(true)
                            
                            Text(feature)
                                .font(Constants.Typography.BodySmall.font)
                                .foregroundColor(Constants.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .textSelection(.enabled)
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Features: \(version.features.joined(separator: ", "))")
            }
            .padding(Constants.UI.Padding.cardInternal)
            .background(Constants.Colors.textPrimary.opacity(0.05))
            .cornerRadius(Constants.UI.CornerRadius.secondary)
        }
        .padding(.vertical, Constants.UI.Spacing.small)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Version \(version.version), released \(version.date). Features: \(version.features.joined(separator: ", "))")
    }
}

// MARK: - Data Models

private struct VersionEntry {
    let version: String
    let date: String
    let features: [String]
}

#Preview("Privacy Policy") {
    PrivacyPolicyView()
}

#Preview("Terms of Service") {
    TermsOfServiceView()
}

#Preview("Version History") {
    VersionHistoryView()
}

// MARK: - Reusable Components

private struct PrivacySection: View {
    let title: String
    let icon: String
    let content: String
    var isImportant: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
            HStack(spacing: Constants.UI.Spacing.small) {
                Image(systemName: icon)
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(isImportant ? Constants.Colors.error : Constants.Colors.primaryBlue)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .fontWeight(.semibold)
            }
            
            Text(content)
                .font(Constants.Typography.Body.font)
                .foregroundColor(Constants.Colors.textSecondary)
                .lineSpacing(4)
                .textSelection(.enabled)
        }
        .padding(Constants.UI.Padding.cardInternal)
        .background(Constants.Colors.textPrimary.opacity(0.03))
        .cornerRadius(Constants.UI.CornerRadius.secondary)
    }
}

private struct TermsSection: View {
    let number: String
    let title: String
    let content: String
    var isImportant: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.UI.Spacing.medium) {
            HStack(spacing: Constants.UI.Spacing.small) {
                Text(number)
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.primaryBlue)
                    .fontWeight(.bold)
                    .frame(width: 24, height: 24)
                    .background(Constants.Colors.primaryBlue.opacity(0.1))
                    .cornerRadius(Constants.UI.CornerRadius.quaternary)
                
                Text(title)
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .fontWeight(.semibold)
            }
            
            Text(content)
                .font(Constants.Typography.Body.font)
                .foregroundColor(Constants.Colors.textSecondary)
                .lineSpacing(4)
                .textSelection(.enabled)
        }
        .padding(Constants.UI.Padding.cardInternal)
        .background(Constants.Colors.textPrimary.opacity(0.03))
        .cornerRadius(Constants.UI.CornerRadius.secondary)
    }
}
