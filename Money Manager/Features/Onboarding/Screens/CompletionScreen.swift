import SwiftUI

/**
 * CompletionScreen
 *
 * Final onboarding screen celebrating user completion with multi-colored
 * headline, encouraging message, and navigation to main app. Features
 * brand-consistent design and proper state management.
 *
 * Features:
 * - Multi-colored headline with brand colors
 * - Completion celebration messaging
 * - Proper onboarding completion flow
 * - Asset-based illustration with error handling
 * - Accessibility compliance
 *
 * Last Review: 2025-01-26
 * Status: Production Ready
 */

struct CompletionScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var imageLoadError = false
    
    var body: some View {
        SimpleOnboardingTemplate(
            illustration: AnyView(
                Group {
                    if imageLoadError {
                        // Fallback content when image fails to load
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Constants.Onboarding.pinkHex)
                            
                            Text("Welcome!")
                                .font(TrapFontUtility.trapFont(size: 24, weight: .bold))
                                .foregroundColor(Constants.Colors.textPrimary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Image("Hero-Illustartion_Final")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .onAppear {
                                // Verify image exists
                                if UIImage(named: "Hero-Illustartion_Final") == nil {
                                    imageLoadError = true
                                }
                            }
                    }
                }
            ),
            headline: "You're All Set!",
            headlineColors: [
                Constants.Onboarding.pinkHex,  // "You're "
                Constants.Onboarding.primaryBlueHex,   // "All "
                Constants.Onboarding.yellowHex // "Set!"
            ],
            bodyText: "Welcome to the Money Manager community! You're now ready to take control of your finances and achieve your financial goals.",
            buttonTitle: "Start Your Journey",
            buttonIcon: "sparkles",
            currentPage: 4,
            totalPages: OnboardingStep.allCases.count,
            buttonAction: {
                viewModel.completeOnboarding()
            }
        )
    }
}
