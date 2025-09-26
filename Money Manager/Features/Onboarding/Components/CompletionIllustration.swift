import SwiftUI

struct CompletionIllustration: View {
    @State private var animateElements = false
    
    var body: some View {
        ZStack {
            // Light blue background with diagonal cut
            LightBlueBackground()
                .frame(height: 300)
            
            // Main illustration content
            ZStack {
                // Celebration elements floating around
                FloatingCelebrationElement(emoji: "🎉", offset: CGPoint(x: -80, y: -20), delay: 0.1)
                FloatingCelebrationElement(emoji: "✨", offset: CGPoint(x: 80, y: -30), delay: 0.2)
                FloatingCelebrationElement(emoji: "🎊", offset: CGPoint(x: -60, y: 20), delay: 0.3)
                FloatingCelebrationElement(emoji: "🌟", offset: CGPoint(x: 70, y: 10), delay: 0.4)
                
                // Central success icon
                CentralSuccessIcon()
                    .offset(y: -10)
                    .scaleEffect(animateElements ? 1.0 : 0.8)
                    .opacity(animateElements ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8).delay(0.5), value: animateElements)
                
                // Decorative elements
                DecorativeElements()
                    .opacity(animateElements ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.6).delay(0.6), value: animateElements)
            }
        }
        .onAppear {
            withAnimation {
                animateElements = true
            }
        }
    }
}

struct FloatingCelebrationElement: View {
    let emoji: String
    let offset: CGPoint
    let delay: Double
    @State private var animate = false
    
    var body: some View {
        Text(emoji)
            .font(.system(size: 20))
            .offset(x: offset.x, y: offset.y)
            .scaleEffect(animate ? 1.0 : 0.5)
            .opacity(animate ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.6).delay(delay), value: animate)
            .onAppear {
                withAnimation {
                    animate = true
                }
            }
    }
}

struct CentralSuccessIcon: View {
    var body: some View {
        ZStack {
            // Main circle
            Circle()
                .stroke(Color.black, lineWidth: 2)
                .frame(width: 50, height: 50)
            
            // Checkmark
            Image(systemName: "checkmark")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.black)
            
            // Success stars
            ForEach(0..<6, id: \.self) { index in
                Text("⭐")
                    .font(.system(size: 12))
                    .offset(
                        x: cos(Double(index) * .pi / 3) * 35,
                        y: sin(Double(index) * .pi / 3) * 35
                    )
            }
        }
    }
}

#Preview {
    CompletionIllustration()
        .frame(height: 300)
}
