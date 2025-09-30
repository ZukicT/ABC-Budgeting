//
//  OnboardingViewModel.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  ViewModel for managing onboarding flow state and step progression.
//  Handles step navigation, completion tracking, and user data collection
//  throughout the onboarding process with proper state management.
//
//  Review Date: September 29, 2025
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var isCompleted: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let onboardingCompletedKey = "onboarding_completed"
    private weak var onboardingManager: OnboardingManager?
    
    init(onboardingManager: OnboardingManager? = nil) {
        self.onboardingManager = onboardingManager
    }
    
    func checkFirstTimeUser() {}
    
    func nextStep() {
        guard let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) else {
            completeOnboarding()
            return
        }
        currentStep = nextStep
    }
    
    func previousStep() {
        guard let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) else {
            return
        }
        currentStep = previousStep
    }
    
    
    func completeOnboarding() {
        isCompleted = true
        onboardingManager?.completeOnboarding()
    }
    
    func setOnboardingManager(_ manager: OnboardingManager) {
        self.onboardingManager = manager
    }
    
    func resetOnboarding() {
        isCompleted = false
        currentStep = .welcome
        userDefaults.set(false, forKey: onboardingCompletedKey)
    }
}

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case language = 1
    case currency = 2
    case startingBalance = 3
    case notifications = 4
    case completion = 5
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome"
        case .language:
            return "Language"
        case .currency:
            return "Currency"
        case .startingBalance:
            return "Starting Balance"
        case .notifications:
            return "Notifications"
        case .completion:
            return "You're All Set!"
        }
    }
    
    var progressText: String {
        return "\(rawValue + 1)/\(OnboardingStep.allCases.count)"
    }
}
