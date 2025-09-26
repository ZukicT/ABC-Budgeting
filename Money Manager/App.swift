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
                // Test font loading
                print("🚀 App launched - checking fonts...")
                TrapFontUtility.listAllAvailableFonts()
                TrapFontUtility.verifyFontsLoaded()
            }
        }
    }
}
