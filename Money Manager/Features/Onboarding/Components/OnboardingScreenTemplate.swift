//
//  OnboardingScreenTemplate.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Generic template for onboarding screens providing consistent layout and
//  styling. Features illustration support, customizable headlines, body text,
//  and action buttons with progress indicators.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct OnboardingScreenTemplate<Content: View>: View {
    let illustration: AnyView?
    let headline: String
    let headlineColors: [Color]
    let bodyText: String
    let buttonTitle: String
    let buttonIcon: String?
    let currentPage: Int
    let totalPages: Int
    let buttonAction: () -> Void
    let content: Content
    
    init(
        illustration: AnyView? = nil,
        headline: String,
        headlineColors: [Color] = [Constants.Colors.textPrimary],
        bodyText: String,
        buttonTitle: String,
        buttonIcon: String? = nil,
        currentPage: Int,
        totalPages: Int,
        buttonAction: @escaping () -> Void,
        content: Content
    ) {
        self.illustration = illustration
        self.headline = headline
        self.headlineColors = headlineColors
        self.bodyText = bodyText
        self.buttonTitle = buttonTitle
        self.buttonIcon = buttonIcon
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.buttonAction = buttonAction
        self.content = content
    }
    
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Clean white background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top illustration section (45% of screen)
                if let illustration = illustration {
                    illustration
                        .frame(height: UIScreen.main.bounds.height * 0.45)
                        .padding(.top, 20) // Add top padding to image
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.8), value: showContent)
                } else {
                    // Default illustration space
                    Rectangle()
                        .fill(Constants.Colors.primaryLightBlue)
                        .frame(height: UIScreen.main.bounds.height * 0.45)
                        .padding(.top, 20) // Add top padding to default space
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.8), value: showContent)
                }
                
                // Content section (55% of screen)
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    
                    // Headline text
                    VStack(alignment: .leading, spacing: 16) {
                        // Multi-colored headline
                        if headlineColors.count == 1 {
                            Text(headline)
                                .font(Constants.Typography.H1.font)
                                .foregroundColor(headlineColors[0])
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 20)
                                .animation(.easeInOut(duration: 0.6).delay(0.2), value: showContent)
                        } else {
                            // Multi-colored headline
                            MultiColorText(
                                text: headline,
                                colors: headlineColors
                            )
                            .font(Constants.Typography.H1.font)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                            .frame(maxWidth: .infinity, alignment: .leading) // Use full available width
                            .padding(.horizontal, 20) // Add padding to hero text
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeInOut(duration: 0.6).delay(0.2), value: showContent)
                        }
                        
                        // Body text with proper typography and line spacing
                        Text(bodyText)
                            .font(Constants.Typography.Body.font)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .lineSpacing(8) // Proper line spacing for readability
                            .frame(maxWidth: .infinity, alignment: .leading) // Use full available width
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeInOut(duration: 0.6).delay(0.4), value: showContent)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 32)
                    
                    // Custom content area
                    content
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeInOut(duration: 0.6).delay(0.5), value: showContent)
                    
                    // CTA Button and Page Indicators - positioned at bottom
                    VStack(spacing: 0) {
                        Spacer() // Push content to bottom
                        
                        // Continue button
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                buttonAction()
                            }
                        }) {
                            Text(buttonTitle)
                                .font(Constants.Typography.Button.font)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Constants.Colors.textPrimary)
                                .cornerRadius(Constants.UI.CornerRadius.primary)
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeInOut(duration: 0.6).delay(0.6), value: showContent)
                        .padding(.horizontal, 20)
                        
                        // Fixed spacing between button and indicators
                        Spacer()
                            .frame(height: 20)
                        
                        // Page indicators
                        HStack(spacing: 8) {
                            ForEach(0..<totalPages, id: \.self) { index in
                                if index == currentPage {
                                    // Active indicator (rectangle) - BLACK
                                    RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                                        .fill(Constants.Colors.textPrimary)
                                        .frame(width: 40, height: 8)
                                } else {
                                    // Inactive indicator (rounded square) - PINK
                                    RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                                        .fill(Color(hex: "#FF6584"))
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6).delay(0.8), value: showContent)
                        .padding(.bottom, 10) // 10px from bottom of device screen
                    }
                }
            }
        }
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }
}

// Helper view for multi-colored text

#Preview {
    SimpleOnboardingTemplate(
        illustration: AnyView(OnboardingIllustration()),
        headline: "Start moving to improve your mental game",
        headlineColors: [Constants.Colors.primaryBlue, Constants.Colors.textPrimary, Constants.Colors.primaryOrange],
        bodyText: "Level up your fitness, mental game and social game by getting active with others in your community and organising trial walks.",
        buttonTitle: "Comprende",
        buttonIcon: "hand.wave",
        currentPage: 0,
        totalPages: 3,
        buttonAction: {
            // Preview action
        }
    )
}
