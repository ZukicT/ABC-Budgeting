import SwiftUI

struct WelcomeScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        SimpleOnboardingTemplate(
            illustration: AnyView(OnboardingIllustration()),
            headline: "Get your money right and your life tight",
            headlineColors: [
                Constants.Onboarding.primaryBlueHex  // "Get your money right and your life tight" - entire hero text in primary blue
            ],
            bodyText: "Take charge of your finances with smart budgeting, expense tracking, and financial insights that help you build wealth and achieve your money goals.",
            buttonTitle: "Get Started",
            buttonIcon: "hand.wave",
            currentPage: 0,
            totalPages: OnboardingStep.allCases.count,
            buttonAction: {
                print("DEBUG: Get Started button tapped!")
                print("DEBUG: Current step before nextStep: \(viewModel.currentStep)")
                viewModel.nextStep()
                print("DEBUG: Current step after nextStep: \(viewModel.currentStep)")
            }
        )
    }
}