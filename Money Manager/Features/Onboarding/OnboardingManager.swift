//
//  OnboardingManager.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Manages onboarding flow state and completion tracking. Handles user
//  onboarding completion status using UserDefaults and controls whether
//  to show onboarding or main app interface.
//
//  Review Date: September 29, 2025
//

import Foundation
import SwiftUI

class OnboardingManager: ObservableObject {
    @Published var shouldShowOnboarding: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let onboardingCompletedKey = "onboarding_completed"
    
    init() {
        checkOnboardingStatus()
    }
    
    private func checkOnboardingStatus() {
        let hasCompletedOnboarding = userDefaults.bool(forKey: onboardingCompletedKey)
        shouldShowOnboarding = !hasCompletedOnboarding
    }
    
    func completeOnboarding() {
        userDefaults.set(true, forKey: onboardingCompletedKey)
        shouldShowOnboarding = false
    }
    
    func resetOnboarding() {
        userDefaults.set(false, forKey: onboardingCompletedKey)
        shouldShowOnboarding = true
    }
}
