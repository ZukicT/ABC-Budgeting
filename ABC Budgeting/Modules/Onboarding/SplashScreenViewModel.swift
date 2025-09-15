import SwiftUI
import Foundation

class SplashScreenViewModel: ObservableObject {
    private var splashTimer: Timer?
    
    func startSplashTimer(duration: TimeInterval, completion: @escaping () -> Void) {
        splashTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func stopSplashTimer() {
        splashTimer?.invalidate()
        splashTimer = nil
    }
    
    deinit {
        stopSplashTimer()
    }
}
