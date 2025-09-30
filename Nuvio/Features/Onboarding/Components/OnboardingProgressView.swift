//
//  OnboardingProgressView.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Progress indicator component for onboarding flow displaying current step
//  progress with animated progress bar and step counter. Provides visual
//  feedback for user progress through onboarding steps.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct OnboardingProgressView: View {
    let currentStep: OnboardingStep
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    
    private var progress: Double {
        Double(currentStep.rawValue + 1) / Double(OnboardingStep.allCases.count)
    }
    
    var body: some View {
        VStack(spacing: Constants.UI.Spacing.small) {
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
            
            Text("\(contentManager.localizedString("onboarding.step_counter")) \(currentStep.rawValue + 1) \(contentManager.localizedString("onboarding.of")) \(OnboardingStep.allCases.count)")
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


















