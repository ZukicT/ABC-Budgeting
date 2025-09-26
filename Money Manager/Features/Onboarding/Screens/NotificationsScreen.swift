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
            headline: "Stay on track",
            headlineColors: [
                Constants.Onboarding.pinkHex  // "Stay on track" - entire hero text in brand pink
            ],
            bodyText: "Get smart reminders about your spending goals, bill due dates, and financial insights to help you stay in control of your money",
            buttonTitle: "Enable Notifications",
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
            secondaryButtonTitle: "No thanks, I'm good",
            secondaryButtonAction: {
                UserDefaults.standard.set(false, forKey: notificationPermissionKey)
                print("⚠️ User skipped notifications")
                viewModel.nextStep()
            }
        )
        .alert(alertTitle, isPresented: $showPermissionAlert) {
            Button("OK") {
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
            alertTitle = "Success!"
            alertMessage = "Notifications enabled. You'll receive helpful reminders about your financial goals."
            showPermissionAlert = true
            
        case .denied:
            UserDefaults.standard.set(false, forKey: notificationPermissionKey)
            alertTitle = "Notifications Disabled"
            alertMessage = "You can enable notifications later in Settings to receive helpful reminders."
            showPermissionAlert = true
            
        case .error:
            UserDefaults.standard.set(false, forKey: notificationPermissionKey)
            alertTitle = "Permission Error"
            alertMessage = "There was an error requesting notification permission. Please try again."
            showPermissionAlert = true
        }
    }
    
    private func handleAlertDismissal() {
        if alertTitle == "Success!" {
            viewModel.nextStep()
        }
    }
}
