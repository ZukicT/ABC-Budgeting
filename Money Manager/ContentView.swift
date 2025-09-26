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
