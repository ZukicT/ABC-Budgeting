import SwiftUI

struct OnboardingIllustration: View {
    @State private var imageLoadError = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if imageLoadError {
                    // Fallback content when image fails to load
                    FallbackIllustration()
                } else {
                    // Hero illustration asset with error handling
                    Image("hero-illustrations")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            // Verify image exists
                            if UIImage(named: "hero-illustrations") == nil {
                                imageLoadError = true
                            }
                        }
                }
            }
            .frame(height: geometry.size.height)
        }
        .accessibilityLabel("Onboarding illustration")
        .accessibilityHint("Decorative illustration showing community and movement")
    }
}

struct LightBlueBackground: View {
    var body: some View {
        ZStack {
            // Base light blue color
            Constants.Onboarding.primaryBlueHex
                .ignoresSafeArea()

            // Diagonal cut effect
            Path { path in
                let width = UIScreen.main.bounds.width
                let height: CGFloat = 300

                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: width, y: 0))
                path.addLine(to: CGPoint(x: width * 0.7, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
            }
            .fill(Constants.Onboarding.primaryBlueHex)

            // Subtle texture overlay
            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
        }
    }
}

struct DecorativeElements: View {
    var body: some View {
        ZStack {
            // Floating circles
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(Constants.Onboarding.yellowHex.opacity(0.3))
                    .frame(width: CGFloat.random(in: 8...16))
                    .offset(
                        x: CGFloat.random(in: -100...100),
                        y: CGFloat.random(in: -50...50)
                    )
            }
            
            // Floating stars
            ForEach(0..<4, id: \.self) { index in
                FourPointedStar()
                    .fill(Constants.Onboarding.pinkHex.opacity(0.4))
                    .frame(width: 12, height: 12)
                    .offset(
                        x: CGFloat.random(in: -80...80),
                        y: CGFloat.random(in: -40...40)
                    )
            }
        }
    }
}

struct FourPointedStar: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        // Create a 4-pointed star
        for i in 0..<8 {
            let angle = Double(i) * .pi / 4
            let currentRadius = i % 2 == 0 ? radius : radius * 0.4
            let x = center.x + currentRadius * cos(angle)
            let y = center.y + currentRadius * sin(angle)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}

struct FallbackIllustration: View {
    var body: some View {
        ZStack {
            // Simple geometric fallback
            VStack(spacing: 20) {
                Circle()
                    .fill(Constants.Onboarding.primaryBlueHex)
                    .frame(width: 60, height: 60)
                
                HStack(spacing: 20) {
                    Rectangle()
                        .fill(Constants.Onboarding.yellowHex)
                        .frame(width: 40, height: 40)
                        .cornerRadius(Constants.UI.CornerRadius.tertiary)
                    
                    Rectangle()
                        .fill(Constants.Onboarding.primaryBlueHex)
                        .frame(width: 40, height: 40)
                        .cornerRadius(Constants.UI.CornerRadius.tertiary)
                }
            }
        }
    }
}

#Preview {
    OnboardingIllustration()
        .frame(height: 300)
}