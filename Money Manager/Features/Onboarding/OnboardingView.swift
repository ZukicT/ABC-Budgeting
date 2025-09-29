import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @StateObject private var viewModel: OnboardingViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    init() {
        // Create a temporary OnboardingManager to pass to the view model
        // The actual onboardingManager will be injected via environmentObject
        _viewModel = StateObject(wrappedValue: OnboardingViewModel())
    }
    
    var body: some View {
        ZStack {
            // Background
            Constants.Colors.backgroundPrimary
                .ignoresSafeArea()
            
            // Content based on current step
            switch viewModel.currentStep {
            case .welcome:
                WelcomeScreen(viewModel: viewModel)
            case .currency:
                CurrencyScreen(viewModel: viewModel)
            case .startingBalance:
                StartingBalanceScreen(viewModel: viewModel)
            case .notifications:
                NotificationsScreen(viewModel: viewModel)
            case .completion:
                CompletionScreen(viewModel: viewModel)
            }
        }
        .onAppear {
            // Connect the view model to the onboarding manager
            print("🎯 OnboardingView.onAppear - connecting viewModel to onboardingManager")
            viewModel.setOnboardingManager(onboardingManager)
            print("🎯 OnboardingManager connection established")
        }
    }
}

#Preview {
    OnboardingView()
}
