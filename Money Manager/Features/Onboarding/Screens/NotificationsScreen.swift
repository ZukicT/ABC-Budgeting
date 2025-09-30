//
//  NotificationsScreen.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Notification permission request screen for onboarding with proper
//  permission handling, state management, and user feedback. Features
//  back navigation, permission status persistence, and brand-consistent design.
//
//  Review Date: September 29, 2025
//

import SwiftUI
import UserNotifications

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
                Image("Notifications-Hero-Image")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 290)
            ),
            headline: contentManager.localizedString("onboarding.notifications.headline"),
            headlineColors: [
                Constants.Onboarding.primaryBlueHex  // "Stay on track" - entire hero text in brand blue
            ],
            bodyText: contentManager.localizedString("onboarding.notifications.body"),
            buttonTitle: "Continue",
            buttonIcon: "bell.fill",
            currentPage: 4,
            totalPages: OnboardingStep.allCases.count,
            buttonAction: {
                requestNotificationPermission()
            },
            showBackButton: true,
            backButtonAction: {
                viewModel.previousStep()
            },
            secondaryButtonTitle: "No thank you",
            secondaryButtonAction: {
                UserDefaults.standard.set(false, forKey: notificationPermissionKey)
                viewModel.nextStep()
            }
        )
        .alert(alertTitle, isPresented: $showPermissionAlert) {
            Button(contentManager.localizedString("button.ok")) {
                handleAlertDismissal()
            }
        } message: {
            Text(alertMessage)
                .font(Constants.Typography.Body.font)
        }
    }
    
    // MARK: - Private Methods
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                let result: PermissionResult
                if granted {
                    result = .granted
                } else if error != nil {
                    result = .error
                } else {
                    result = .denied
                }
                
                handlePermissionResult(result)
            }
        }
    }
    
    private func handlePermissionResult(_ result: PermissionResult) {
        switch result {
        case .granted:
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
