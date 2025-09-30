import Foundation
import SwiftUI

@MainActor
class OverviewViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        // Initialize overview data
    }
    
    func loadOverviewData() {
        // TODO: Implement data loading logic
        // This will be implemented when we add real data functionality
    }
}
