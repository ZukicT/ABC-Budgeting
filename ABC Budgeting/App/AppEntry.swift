import SwiftUI
import UIKit

@main
struct ABCBudgetingApp: App {
    init() {
        // Configure TabBar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        
        // Configure SegmentedControl appearance
        configureSegmentedControlAppearance()
    }
    
    private func configureSegmentedControlAppearance() {
        // Set the selected segment background color to primary green
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(RobinhoodColors.primary)
        
        // Configure text colors for accessibility and Apple HIG compliance
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        
        UISegmentedControl.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
    }
    var body: some Scene {
        WindowGroup {
            LaunchCoordinator()
                .injectDependencies()
        }
    }
}

struct LaunchCoordinator: View {
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete: Bool = false
    @State private var showSplash = true
    @State private var showOnboarding = false

    var body: some View {
        Group {
            if showSplash {
                SplashScreenView(onComplete: {
                    if isOnboardingComplete {
                        showSplash = false
                    } else {
                        showSplash = false
                        showOnboarding = true
                    }
                })
            } else if showOnboarding {
                OnboardingView(onComplete: {
                    isOnboardingComplete = true
                    showOnboarding = false
                })
            } else {
                MainView()
            }
        }
        .onAppear {
            // Only show splash on cold launch
            if !isOnboardingComplete {
                showSplash = true
            } else {
                showSplash = false
            }
        }
    }
}

