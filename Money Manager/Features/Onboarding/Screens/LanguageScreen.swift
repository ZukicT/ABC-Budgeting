//
//  LanguageScreen.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Language selection screen for onboarding flow allowing users to choose
//  their preferred app language. Features language options with native names
//  and a note about ongoing language additions.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct LanguageScreen: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    @State private var selectedLanguage: String = "en-US"
    
    private let supportedLanguages = [
        ("en-US", "English", "English"),
        ("zh-CN", "中文", "Chinese (Simplified)"),
        ("ja-JP", "日本語", "Japanese")
    ]
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Back button - positioned at top of safe area
                HStack {
                    Button(action: {
                        viewModel.previousStep()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(.white)
                            
                            Text(contentManager.localizedString("onboarding.back"))
                                .font(Constants.Typography.Caption.font)
                                .foregroundColor(.white)
                        }
                        .frame(height: 40)
                        .padding(.horizontal, 16)
                        .background(Constants.Colors.textPrimary)
                        .cornerRadius(Constants.UI.CornerRadius.primary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Header section with reduced spacing
                VStack(spacing: 12) {
                    // Hero image - reduced height to match other screens
                    Image("Language-hero-image")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 180)
                        .clipped()
                        .accessibilityLabel("Language selection illustration")
                    
                    Text(contentManager.localizedString("onboarding.choose_language"))
                        .font(Constants.Typography.H1.font)
                        .foregroundColor(Constants.Onboarding.primaryBlueHex)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(contentManager.localizedString("onboarding.language_description"))
                        .font(Constants.Typography.Body.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .lineSpacing(6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // Language list - increased height for better visibility
                LanguageListView(
                    supportedLanguages: supportedLanguages,
                    selectedLanguage: $selectedLanguage
                )
                .frame(height: 200)
                
                Spacer()
                
                // Footer with button and carousel indicators
                OnboardingFooter(
                    buttonTitle: "Continue",
                    buttonIcon: "arrow.right",
                    currentPage: 1,
                    totalPages: OnboardingStep.allCases.count,
                    buttonAction: {
                        viewModel.nextStep()
                    }
                )
            }
        }
        .onAppear {
            selectedLanguage = contentManager.currentLanguage
        }
    }
    
    private struct LanguageListView: View {
        let supportedLanguages: [(String, String, String)]
        @Binding var selectedLanguage: String
        @ObservedObject private var contentManager = MultilingualContentManager.shared

        var body: some View {
            ScrollView {
                LazyVStack(spacing: Constants.UI.Spacing.medium) {
                    ForEach(supportedLanguages, id: \.0) { language in
                        LanguageOptionView(
                            languageCode: language.0,
                            nativeName: language.1,
                            englishName: language.2,
                            isSelected: selectedLanguage == language.0,
                            action: {
                                selectedLanguage = language.0
                                contentManager.updateLanguage(language.0)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, Constants.UI.Spacing.small)
            }
            .background(Color.white)
            .cornerRadius(Constants.UI.CornerRadius.secondary)
        }
    }
}

struct LanguageOptionView: View {
    let languageCode: String
    let nativeName: String
    let englishName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Language Flag/Icon
            Text(String(nativeName.prefix(1)))
                .font(Constants.Typography.H3.font)
                .foregroundColor(Constants.Colors.textPrimary)
                .frame(width: 40, height: 40)
                .background(Constants.Colors.textPrimary.opacity(0.05))
                .cornerRadius(Constants.UI.CornerRadius.tertiary)
            
            // Language Names
            VStack(alignment: .leading, spacing: 2) {
                Text(nativeName)
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Text(englishName)
                    .font(Constants.Typography.Body.font)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            
            Spacer()
            
            // Selection Indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.textPrimary)
            } else {
                Image(systemName: "circle")
                    .font(Constants.Typography.H3.font)
                    .foregroundColor(Constants.Colors.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isSelected ? Constants.Colors.textPrimary.opacity(0.05) : Color.clear)
        .onTapGesture(perform: action)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel("Select \(nativeName)")
        .accessibilityHint(isSelected ? "Currently selected language" : "Tap to select \(nativeName)")
    }
}

#Preview {
    LanguageScreen(viewModel: OnboardingViewModel())
}
