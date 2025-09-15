import SwiftUI

struct SplashScreenView: View {
    let onComplete: () -> Void
    @StateObject private var viewModel = SplashScreenViewModel()
    @State private var progress: CGFloat = 0
    @State private var isAnimating = false
    @State private var fadeIn: Bool = false
    @State private var centralShapeIndex: Int = 0
    @State private var centralShapeTimer: Timer? = nil
    @State private var orbitingShapeAppear: [Bool] = Array(repeating: false, count: 9)

    private let loadingDuration: TimeInterval = 5.0
    private let shapeAssets = [
        "PinkCornerCurve", "redCornerCurve", "GreenCornerCurve", "YellowSquare",
        "GreenCircle", "YellowSquare", "BlueCorner", "BlueCircle", "PurpleCircle 1"
    ]
    private let shapeCount = 9
    private let centralShapeChangeInterval: TimeInterval = 1.0
    private let orbitDuration: TimeInterval = 6.0 // seconds for a full rotation

    var body: some View {
        ZStack {
            AppColors.black.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                // MARK: - Spinning Shapes in a Circle (Perfectly Centered)
                TimelineView(.animation) { timeline in
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    let progress = now.truncatingRemainder(dividingBy: orbitDuration) / orbitDuration
                    let orbitAngle = progress * 2 * .pi
                    GeometryReader { geo in
                        let size = min(geo.size.width, geo.size.height)
                        ZStack {
                            // Central Shape with animated transition
                            ZStack {
                                Image(shapeAssets[centralShapeIndex])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: size * 0.36, height: size * 0.36)
                                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                                    .id(centralShapeIndex)
                                    .transition(
                                        .asymmetric(
                                            insertion: .scale.combined(with: .opacity),
                                            removal: .scale(scale: 0.7).combined(with: .opacity)
                                        )
                                    )
                                    .animation(.spring(response: 0.45, dampingFraction: 0.7), value: centralShapeIndex)
                            }
                            // Orbiting Shapes with staggered entrance
                            ForEach(0..<shapeCount, id: \.self) { i in
                                let angle = angleForShape(at: i, orbitAngle: orbitAngle)
                                let radius = size * 0.38
                                let x = CGFloat(cos(angle)) * radius
                                let y = CGFloat(sin(angle)) * radius
                                Image(shapeAssets[i])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: size * 0.22, height: size * 0.22)
                                    .offset(x: x, y: y)
                                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                                    .opacity(orbitingShapeAppear[i] ? 1 : 0)
                                    .scaleEffect(orbitingShapeAppear[i] ? 1 : 0.7)
                                    .animation(
                                        .spring(response: 0.6, dampingFraction: 0.8)
                                            .delay(0.08 * Double(i)),
                                        value: orbitingShapeAppear[i]
                                    )
                            }
                        }
                        .frame(width: size, height: size)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        .opacity(fadeIn ? 1 : 0)
                        .scaleEffect(fadeIn ? 1 : 0.92)
                        .animation(.spring(response: 0.7, dampingFraction: 0.7), value: fadeIn)
                    }
                    .frame(height: 240)
                }
                // MARK: - Logo
                Image("ABC_Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 48)
                    .padding(.top, 24)
                    .opacity(fadeIn ? 1 : 0)
                    .animation(.easeIn(duration: 0.5).delay(0.2), value: fadeIn)
                // MARK: - Loading Bar
                DynamicLoadingBarView(progress: progress)
                    .frame(height: 8)
                    .padding(.horizontal, 40)
                    .padding(.top, 36)
                    .opacity(fadeIn ? 1 : 0)
                    .animation(.easeIn(duration: 0.5).delay(0.3), value: fadeIn)
                Spacer()
            }
        }
        .onAppear {
            fadeIn = true
            isAnimating = true
            withAnimation(.linear(duration: loadingDuration)) {
                progress = 1.0
            }
            // Staggered entrance for orbiting shapes
            for i in 0..<shapeCount {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08 * Double(i)) {
                    withAnimation {
                        orbitingShapeAppear[i] = true
                    }
                }
            }
            startCentralShapeTimer()
            viewModel.startSplashTimer(duration: loadingDuration) {
                withAnimation(.easeOut(duration: 0.25)) {
                    fadeIn = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    isAnimating = false
                    stopCentralShapeTimer()
                    onComplete()
                }
            }
        }
        .onDisappear {
            stopCentralShapeTimer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("ABC Budgeting is loading")
    }

    private func startCentralShapeTimer() {
        stopCentralShapeTimer()
        centralShapeTimer = Timer.scheduledTimer(withTimeInterval: centralShapeChangeInterval, repeats: true) { _ in
            centralShapeIndex = (centralShapeIndex + 1) % shapeAssets.count
        }
    }

    private func stopCentralShapeTimer() {
        centralShapeTimer?.invalidate()
        centralShapeTimer = nil
    }

    // MARK: - Orbiting Shapes Helper
    private func orbitingShapes(size: CGFloat, orbitAngle: Double) -> some View {
        ForEach(0..<shapeCount, id: \.self) { i in
            let angle = angleForShape(at: i, orbitAngle: orbitAngle)
            let radius = size * 0.38
            let x = CGFloat(cos(angle)) * radius
            let y = CGFloat(sin(angle)) * radius
            Image(shapeAssets[i])
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 0.22, height: size * 0.22)
                .offset(x: x, y: y)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
    }

    private func angleForShape(at index: Int, orbitAngle: Double) -> Double {
        let base = Double(index) / Double(shapeCount) * 2 * .pi
        return base + orbitAngle
    }
}


 