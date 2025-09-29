import SwiftUI
import UserNotifications

/**
 * NotificationsScreen
 *
 * Notification permission request screen for onboarding with proper
 * permission handling, state management, and user feedback. Features
 * back navigation and brand-consistent design.
 *
 * Features:
 * - Notification permission request with proper error handling
 * - Back navigation support
 * - Permission status persistence using UserDefaults
 * - Brand-consistent design with pink accent color
 * - Async-safe UI updates with DispatchQueue.main.async
 *
 * Last Review: 2025-01-26
 * Status: Production Ready
 */

struct NotificationsScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showPermissionAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    // MARK: - Constants
    private let notificationPermissionKey = "notification_permission_granted"
    
    // MARK: - Permission Result Enum
    private enum PermissionResult {
        case granted, denied, error
    }
    
    var body: some View {
        SimpleOnboardingTemplate(
            illustration: AnyView(
                Image("Hero-Illustration_Notifications")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            ),
            headline: contentManager.localizedString("onboarding.notifications.headline"),
            headlineColors: [
                Constants.Onboarding.pinkHex  // "Stay on track" - entire hero text in brand pink
            ],
            bodyText: contentManager.localizedString("onboarding.notifications.body"),
            buttonTitle: contentManager.localizedString("onboarding.notifications.enable_button"),
            buttonIcon: "bell.fill",
            currentPage: 3,
            totalPages: OnboardingStep.allCases.count,
            buttonAction: {
                requestNotificationPermission()
            },
            showBackButton: true,
            backButtonAction: {
                viewModel.previousStep()
            },
            secondaryButtonTitle: contentManager.localizedString("onboarding.notifications.skip_button"),
            secondaryButtonAction: {
                UserDefaults.standard.set(false, forKey: notificationPermissionKey)
                print("⚠️ User skipped notifications")
                viewModel.nextStep()
            }
        )
        .alert(alertTitle, isPresented: $showPermissionAlert) {
            Button(contentManager.localizedString("button.ok")) {
                handleAlertDismissal()
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Private Methods
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                let result: PermissionResult
                if granted {
                    result = .granted
                } else if let error = error {
                    result = .error
                    print("❌ Notification permission error: \(error.localizedDescription)")
                } else {
                    result = .denied
                    print("⚠️ Notification permission denied by user")
                }
                
                handlePermissionResult(result)
            }
        }
    }
    
    private func handlePermissionResult(_ result: PermissionResult) {
        switch result {
        case .granted:
            print("✅ Notification permission granted")
            UserDefaults.standard.set(true, forKey: notificationPermissionKey)
            alertTitle = contentManager.localizedString("notification.success_title")
            alertMessage = contentManager.localizedString("notification.success_message")
            showPermissionAlert = true
            
        case .denied:
            UserDefaults.standard.set(false, forKey: notificationPermissionKey)
            alertTitle = contentManager.localizedString("notification.disabled_title")
            alertMessage = contentManager.localizedString("notification.disabled_message")
            showPermissionAlert = true
            
        case .error:
            UserDefaults.standard.set(false, forKey: notificationPermissionKey)
            alertTitle = contentManager.localizedString("notification.error_title")
            alertMessage = contentManager.localizedString("notification.error_message")
            showPermissionAlert = true
        }
    }
    
    private func handleAlertDismissal() {
        if alertTitle == contentManager.localizedString("notification.success_title") {
            viewModel.nextStep()
        }
    }
}
