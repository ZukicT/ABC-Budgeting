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
        #if DEBUG
        print("🎯 OnboardingManager.completeOnboarding() called")
        #endif
        userDefaults.set(true, forKey: onboardingCompletedKey)
        #if DEBUG
        print("🎯 UserDefaults set: onboarding_completed = true")
        #endif
        shouldShowOnboarding = false
        #if DEBUG
        print("🎯 shouldShowOnboarding set to: \(shouldShowOnboarding)")
        print("🎯 Navigation should now switch to ContentView")
        #endif
    }
    
    func resetOnboarding() {
        userDefaults.set(false, forKey: onboardingCompletedKey)
        shouldShowOnboarding = true
    }
}
