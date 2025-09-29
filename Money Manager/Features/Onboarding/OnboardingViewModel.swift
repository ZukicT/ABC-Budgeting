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
    
    func checkFirstTimeUser() {
        // This is now handled by OnboardingManager
    }
    
    func nextStep() {
        #if DEBUG
        print("DEBUG: nextStep() called. Current step: \(currentStep)")
        #endif
        guard let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) else {
            #if DEBUG
            print("DEBUG: No next step available, completing onboarding")
            #endif
            completeOnboarding()
            return
        }
        #if DEBUG
        print("DEBUG: Moving to next step: \(nextStep)")
        #endif
        currentStep = nextStep
        #if DEBUG
        print("DEBUG: Current step updated to: \(currentStep)")
        #endif
    }
    
    func previousStep() {
        guard let previousStep = OnboardingStep(rawValue: currentStep.rawValue - 1) else {
            return
        }
        currentStep = previousStep
    }
    
    
    func completeOnboarding() {
        #if DEBUG
        print("🎯 OnboardingViewModel.completeOnboarding() called")
        #endif
        isCompleted = true
        #if DEBUG
        print("🎯 Calling onboardingManager?.completeOnboarding()")
        #endif
        onboardingManager?.completeOnboarding()
        #if DEBUG
        print("🎯 Onboarding completion flow initiated")
        #endif
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
    case currency = 1
    case startingBalance = 2
    case notifications = 3
    case completion = 4
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome"
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
