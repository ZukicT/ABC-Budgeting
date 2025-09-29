import SwiftUI
import AVFoundation

// MARK: - Text-to-Speech Manager
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
        
        // Load language from UserDefaults
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
    @StateObject private var contentManager = MultilingualContentManager.shared
    
    private var fullText: String {
        """
        Privacy Policy
        
        Last updated: January 26, 2025
        
        1. Your Data Stays on Your Device
        
        IMPORTANT: All your financial information stays on your phone/device. We don't collect anything. We don't store anything on our servers. We don't send your data anywhere. Your transactions, budgets, loans, and all financial details remain private and secure on your device only.
        
        2. No Data Collection
        
        We do not collect, store, or transmit any personal information. We do not track your usage. We do not gather analytics. We do not know what you do with the app. Your privacy is completely protected.
        
        3. No Internet Connection Required
        
        This app works entirely offline. It does not require an internet connection to function. All your data remains on your device and is never sent over the internet.
        
        4. No Third-Party Services
        
        We do not use any third-party services, analytics, or tracking tools. We do not integrate with external APIs. We do not share data with anyone.
        
        5. Local Storage Only
        
        All your financial data is stored locally on your device using Core Data. This includes transactions, budgets, loans, and settings. Nothing is backed up to the cloud unless you explicitly choose to do so through your device's backup settings.
        
        6. Your Control
        
        You have complete control over your data. You can export it, delete it, or modify it at any time. The app provides tools to manage your data as you see fit.
        
        7. No Cookies or Tracking
        
        This app does not use cookies, tracking pixels, or any other tracking technologies. We do not monitor your behavior or collect usage statistics.
        
        8. Children's Privacy
        
        This app does not collect any information from anyone, including children. If you are under 13, you can use this app without any privacy concerns.
        
        9. Changes to This Policy
        
        If we update this privacy policy, we will notify you through the app. Since we don't collect any data, changes to this policy won't affect your existing data.
        
        10. Contact Us
        
        If you have questions about this privacy policy, you can contact us through the app settings. Remember, we don't collect any data, so we can't track or identify you.
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
                        
                        Text("Last updated: January 26, 2025")
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
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: Constants.UI.Spacing.small) {
                        Button(action: {
                            speechManager.togglePlayPause(contentManager.getVersionHistoryContent())
                        }) {
                            Image(systemName: speechManager.isPlaying ? (speechManager.isPaused ? "play.circle.fill" : "pause.circle.fill") : "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        }
                        .accessibilityLabel(speechManager.isPlaying ? (speechManager.isPaused ? "Resume reading" : "Pause reading") : "Start reading")
                        
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
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Constants.Colors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Constants.Colors.textPrimary.opacity(0.1))
                                .cornerRadius(6)
                        }
                        .accessibilityLabel("Speech speed: \(speechManager.selectedSpeed.displayName)")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
    @StateObject private var contentManager = MultilingualContentManager.shared
    
    private var fullText: String {
        """
        Terms of Service
        
        Last updated: January 26, 2025
        
        1. Acceptance of Terms
        
        By downloading, installing, accessing, or using Money Manager ('the App'), you acknowledge that you have read, understood, and agree to be bound by these Terms of Service ('Terms'). If you do not agree to these Terms, you may not use the App.
        
        2. Description of Service
        
        Money Manager is a personal finance management application that helps you track transactions, manage budgets, and monitor loans. The App operates entirely on your device and does not require an internet connection.
        
        3. User Responsibilities
        
        You are responsible for maintaining the accuracy of your financial data. You must ensure that all information entered into the App is correct and up-to-date. You are solely responsible for your financial decisions and the consequences thereof.
        
        4. Data Storage and Privacy
        
        All your financial data is stored locally on your device. We do not collect, store, or have access to any of your personal or financial information. Your data remains private and secure on your device only.
        
        5. IMPORTANT LEGAL DISCLAIMER
        
        THE APP IS PROVIDED 'AS IS' WITHOUT WARRANTY OF ANY KIND. WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
        
        6. Complete Legal Protection
        
        TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE SHALL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING BUT NOT LIMITED TO LOSS OF PROFITS, DATA, OR USE, ARISING OUT OF OR RELATING TO YOUR USE OF THE APP.
        
        7. CRITICAL DISCLAIMER
        
        THIS APP IS NOT A SUBSTITUTE FOR PROFESSIONAL FINANCIAL ADVICE. WE ARE NOT FINANCIAL ADVISORS, ACCOUNTANTS, OR TAX PROFESSIONALS. YOU SHOULD CONSULT WITH QUALIFIED PROFESSIONALS FOR FINANCIAL ADVICE.
        
        8. Use at Your Own Risk
        
        You acknowledge and agree that your use of the App is at your own risk. We make no representations or warranties about the accuracy, reliability, or completeness of the App's functionality.
        
        9. Data Loss Disclaimer
        
        We are not responsible for any data loss, corruption, or deletion that may occur. You are responsible for backing up your data and ensuring its security.
        
        10. Modifications to Terms
        
        We reserve the right to modify these Terms at any time. Continued use of the App after such modifications constitutes acceptance of the updated Terms.
        
        11. Termination
        
        You may stop using the App at any time. We may discontinue the App or its features at any time without notice.
        
        12. Governing Law
        
        These Terms are governed by the laws of the jurisdiction in which you reside, without regard to conflict of law principles.
        
        13. Severability
        
        If any provision of these Terms is found to be unenforceable, the remaining provisions will remain in full force and effect.
        
        14. Entire Agreement
        
        These Terms constitute the entire agreement between you and us regarding the use of the App.
        
        15. Contact Information
        
        For questions about these Terms, please contact us through the app settings.
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
                        
                        Text("Last updated: January 26, 2025")
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
            .navigationTitle("Terms of Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: Constants.UI.Spacing.small) {
                        Button(action: {
                            speechManager.togglePlayPause(contentManager.getVersionHistoryContent())
                        }) {
                            Image(systemName: speechManager.isPlaying ? (speechManager.isPaused ? "play.circle.fill" : "pause.circle.fill") : "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        }
                        .accessibilityLabel(speechManager.isPlaying ? (speechManager.isPaused ? "Resume reading" : "Pause reading") : "Start reading")
                        
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
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Constants.Colors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Constants.Colors.textPrimary.opacity(0.1))
                                .cornerRadius(6)
                        }
                        .accessibilityLabel("Speech speed: \(speechManager.selectedSpeed.displayName)")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
    @StateObject private var contentManager = MultilingualContentManager.shared
    
    private var fullText: String {
        """
        Font Licensing
        
        Trap Font Family Licensing Information
        
        Font Family Used
        
        Money Manager uses the Trap font family, designed by Tobias Frere-Jones and published by Font Bureau. The Trap font family provides excellent readability and professional appearance for financial applications.
        
        Designer Credit
        
        The Trap font family was designed by Tobias Frere-Jones, a renowned type designer known for creating high-quality, professional typefaces. His work has been used in numerous commercial applications and publications.
        
        Usage Rights
        
        The Trap font family is used in Money Manager under appropriate licensing terms. The font is used solely for display purposes within the application and is not redistributed or made available for download by users.
        
        Font Bureau License
        
        This font family is licensed from Font Bureau, a respected type foundry that specializes in professional typeface design and licensing. Font Bureau maintains high standards for typography and provides quality fonts for commercial use.
        
        Restrictions
        
        Users of Money Manager may not extract, copy, or redistribute the Trap font family. The font is embedded within the application and is not available for separate use outside of the app.
        
        Commercial Use
        
        The Trap font family is used in Money Manager for commercial purposes under a valid commercial license from Font Bureau. This ensures compliance with all applicable licensing terms and copyright laws.
        
        Copyright Notice
        
        The Trap font family is copyright Font Bureau and Tobias Frere-Jones. All rights reserved. The font family is used in Money Manager with proper authorization and licensing.
        
        License Compliance
        
        Money Manager complies with all applicable font licensing terms and copyright laws. The use of the Trap font family is properly authorized and does not infringe on any intellectual property rights.
        
        Contact Information
        
        For questions about font licensing or usage, please contact Font Bureau directly. Money Manager users should not attempt to extract or use the font family outside of the application.
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
                        
                        Text("Trap Font Family Licensing Information")
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                            .textSelection(.enabled)
                            .accessibilityLabel("Trap Font Family Licensing Information")
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
            .navigationTitle("Font Licensing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: Constants.UI.Spacing.small) {
                        Button(action: {
                            speechManager.togglePlayPause(contentManager.getVersionHistoryContent())
                        }) {
                            Image(systemName: speechManager.isPlaying ? (speechManager.isPaused ? "play.circle.fill" : "pause.circle.fill") : "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        }
                        .accessibilityLabel(speechManager.isPlaying ? (speechManager.isPaused ? "Resume reading" : "Pause reading") : "Start reading")
                        
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
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Constants.Colors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Constants.Colors.textPrimary.opacity(0.1))
                                .cornerRadius(6)
                        }
                        .accessibilityLabel("Speech speed: \(speechManager.selectedSpeed.displayName)")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
    @StateObject private var contentManager = MultilingualContentManager.shared
    
    private var fullText: String {
        """
        Version History
        
        Track the evolution of Money Manager
        
        Version 1.0.0 - January 26, 2025
        
        Initial release of Money Manager
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
            "Initial release of Money Manager",
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
                        
                        Text("Track the evolution of Money Manager")
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textSecondary)
                            .textSelection(.enabled)
                            .accessibilityLabel("Track the evolution of Money Manager")
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
            .navigationTitle("Version History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: Constants.UI.Spacing.small) {
                        Button(action: {
                            speechManager.togglePlayPause(contentManager.getVersionHistoryContent())
                        }) {
                            Image(systemName: speechManager.isPlaying ? (speechManager.isPaused ? "play.circle.fill" : "pause.circle.fill") : "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(Constants.Colors.primaryBlue)
                        }
                        .accessibilityLabel(speechManager.isPlaying ? (speechManager.isPaused ? "Resume reading" : "Pause reading") : "Start reading")
                        
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
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(Constants.Colors.textSecondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Constants.Colors.textPrimary.opacity(0.1))
                                .cornerRadius(6)
                        }
                        .accessibilityLabel("Speech speed: \(speechManager.selectedSpeed.displayName)")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
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
                .fontWeight(.semibold)
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
                        Text("Version \(version.version)")
                            .font(Constants.Typography.H3.font)
                            .fontWeight(.semibold)
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
                            .font(.title3)
                            .foregroundColor(Constants.Colors.warning)
                            .accessibilityLabel("Latest version")
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(Constants.Colors.success)
                            .accessibilityLabel("Completed version")
                    }
                }
                
                VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                    ForEach(version.features, id: \.self) { feature in
                        HStack(alignment: .top, spacing: Constants.UI.Spacing.small) {
                            Image(systemName: "checkmark")
                                .font(.caption)
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
