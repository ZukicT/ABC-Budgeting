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
        print("🎯 OnboardingManager.completeOnboarding() called")
        userDefaults.set(true, forKey: onboardingCompletedKey)
        print("🎯 UserDefaults set: onboarding_completed = true")
        shouldShowOnboarding = false
        print("🎯 shouldShowOnboarding set to: \(shouldShowOnboarding)")
        print("🎯 Navigation should now switch to ContentView")
    }
    
    func resetOnboarding() {
        userDefaults.set(false, forKey: onboardingCompletedKey)
        shouldShowOnboarding = true
    }
}
