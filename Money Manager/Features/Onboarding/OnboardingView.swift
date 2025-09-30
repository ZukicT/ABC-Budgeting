//
//  OnboardingView.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Main onboarding flow view managing user setup process. Handles step-by-step
//  onboarding including welcome, currency selection, starting balance, notifications,
//  and completion with smooth transitions and user guidance.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @StateObject private var viewModel: OnboardingViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    init() {
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
            case .language:
                LanguageScreen(viewModel: viewModel)
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
