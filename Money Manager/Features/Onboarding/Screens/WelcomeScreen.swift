import SwiftUI

struct WelcomeScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        SimpleOnboardingTemplate(
            illustration: AnyView(OnboardingIllustration()),
            headline: contentManager.localizedString("onboarding.welcome_headline"),
            headlineColors: [
                Constants.Onboarding.primaryBlueHex  // "Get your money right and your life tight" - entire hero text in primary blue
            ],
            bodyText: contentManager.localizedString("onboarding.welcome_body"),
            buttonTitle: contentManager.localizedString("onboarding.get_started"),
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