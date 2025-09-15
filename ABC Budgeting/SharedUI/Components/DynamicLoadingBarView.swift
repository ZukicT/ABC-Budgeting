import SwiftUI

struct DynamicLoadingBarView: View {
    let progress: CGFloat
    @State private var animatedProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                // Progress bar
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * animatedProgress, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: animatedProgress)
            }
        }
        .onChange(of: progress) { _, newValue in
            animatedProgress = newValue
        }
        .onAppear {
            animatedProgress = progress
        }
    }
}
