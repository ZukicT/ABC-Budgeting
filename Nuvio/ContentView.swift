//
//  ContentView.swift
//  Nuvio
//
//  Created by Development Team
//  Copyright © 2025 Nuvio. All rights reserved.
//
//  Code Summary:
//  Root content view that determines whether to display onboarding flow
//  or main application interface based on user's onboarding completion status.
//
//  Review Date: September 29, 2025
//

import SwiftUI

struct ContentView: View {
    @StateObject private var onboardingManager = OnboardingManager()
    
    var body: some View {
        if onboardingManager.shouldShowOnboarding {
            OnboardingView()
                .environmentObject(onboardingManager)
        } else {
            MainTabView()
        }
    }
}

#Preview {
    ContentView()
}
