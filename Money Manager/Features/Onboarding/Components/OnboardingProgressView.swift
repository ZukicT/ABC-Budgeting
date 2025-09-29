import SwiftUI

struct OnboardingProgressView: View {
    let currentStep: OnboardingStep
    
    private var progress: Double {
        Double(currentStep.rawValue + 1) / Double(OnboardingStep.allCases.count)
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.small) {
            // Progress Bar
            HStack(spacing: Constants.UI.Spacing.micro) {
                ForEach(0..<OnboardingStep.allCases.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.quaternary)
                        .fill(index <= currentStep.rawValue ? 
                              Constants.Colors.accentColor : 
                              Constants.Colors.textTertiary.opacity(0.2))
                        .frame(height: 4)
                        .frame(maxWidth: .infinity)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .padding(.horizontal, Constants.UI.Padding.screenMargin)
            
            // Step Counter
            Text("Step \(currentStep.rawValue + 1) of \(OnboardingStep.allCases.count)")
                .font(Constants.Typography.Caption.font)
                .foregroundColor(Constants.Colors.textTertiary)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        OnboardingProgressView(currentStep: .welcome)
        OnboardingProgressView(currentStep: .currency)
        OnboardingProgressView(currentStep: .startingBalance)
        OnboardingProgressView(currentStep: .notifications)
        OnboardingProgressView(currentStep: .completion)
    }
    .padding()
    .background(Constants.Colors.backgroundPrimary)
}


















