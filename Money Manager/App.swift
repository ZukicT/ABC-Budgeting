//
//  App.swift
//  Money Manager
//
//  Created by Development Team
//  Copyright © 2025 Money Manager. All rights reserved.
//
//  Code Summary:
//  Main app entry point that manages onboarding flow and initial app setup.
//  Handles font loading verification and determines whether to show onboarding
//  or main content view based on user's onboarding completion status.
//
//  Review Date: September 29, 2025
//

import SwiftUI

@main
struct MoneyManagerApp: App {
    @StateObject private var onboardingManager = OnboardingManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingManager.shouldShowOnboarding {
                    OnboardingView()
                        .environmentObject(onboardingManager)
                } else {
                    ContentView()
                }
            }
            .onAppear {
                DebugLogger.info("Money Manager app launched with iOS system fonts", category: "AppLaunch")
            }
        }
    }
    
}
