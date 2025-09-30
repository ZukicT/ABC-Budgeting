//
//  WelcomeScreen.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Welcome screen for onboarding flow featuring branded illustration,
//  multi-colored headline, and navigation to next onboarding step.
//  Provides initial user introduction with accessibility support.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct WelcomeScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    var body: some View {
        SimpleOnboardingTemplate(
            illustration: AnyView(OnboardingIllustration()),
            headline: contentManager.localizedString("onboarding.welcome_headline"),
            headlineColors: [
                Constants.Onboarding.primaryBlueHex
            ],
            bodyText: contentManager.localizedString("onboarding.welcome_body"),
            buttonTitle: "Continue",
            buttonIcon: "hand.wave",
            currentPage: 0,
            totalPages: OnboardingStep.allCases.count,
            buttonAction: {
                viewModel.nextStep()
            }
        )
    }
}