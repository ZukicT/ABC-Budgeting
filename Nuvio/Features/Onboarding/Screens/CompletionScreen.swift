//
//  CompletionScreen.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Final onboarding screen celebrating user completion with multi-colored
//  headline, encouraging message, and navigation to main app. Features
//  brand-consistent design, proper state management, and accessibility compliance.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct CompletionScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var imageLoadError = false
    
    var body: some View {
        SimpleOnboardingTemplate(
            illustration: AnyView(
                Group {
                    if imageLoadError {
                        // Fallback content when image fails to load
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(Constants.Typography.H1.font)
                                .foregroundColor(Constants.Onboarding.pinkHex)
                            
                            Text(contentManager.localizedString("onboarding.welcome_completion"))
                                .font(Constants.Typography.H3.font)
                                .foregroundColor(Constants.Colors.textPrimary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Image("All-Set-Hero-Image")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 290)
                            .onAppear {
                                // Verify image exists
                                if UIImage(named: "All-Set-Hero-Image") == nil {
                                    imageLoadError = true
                                }
                            }
                    }
                }
            ),
            headline: "You're All Set!",
            headlineColors: [
                Constants.Onboarding.primaryBlueHex  // "You're All Set!" - entire hero text in brand blue
            ],
            bodyText: "Welcome to the Nuvio community! You're now ready to take control of your finances and achieve your financial goals.",
            buttonTitle: "Continue",
            buttonIcon: "sparkles",
            currentPage: 5,
            totalPages: OnboardingStep.allCases.count,
            buttonAction: {
                viewModel.completeOnboarding()
            }
        )
    }
}
