import SwiftUI

public struct FloatingActionButton: View {
    public let action: () -> Void
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    public var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(AppColors.brandBlue)
                    .frame(width: 64, height: 64)
                    .shadow(color: AppColors.brandBlue.opacity(0.18), radius: 8, y: 4)
                Image(systemName: "plus")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .accessibilityLabel("Add")
    }
} 