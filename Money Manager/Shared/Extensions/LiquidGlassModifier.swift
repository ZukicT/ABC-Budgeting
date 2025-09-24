import SwiftUI

// MARK: - Liquid Glass View Modifier
struct LiquidGlassModifier: ViewModifier {
    let style: LiquidGlassStyle
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    func body(content: Content) -> some View {
        if reduceTransparency {
            // Fallback to solid colors when transparency is reduced
            content
                .background(style.solidBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: style.cornerRadius)
                        .stroke(style.borderColor, lineWidth: style.borderWidth)
                )
        } else {
            // Liquid Glass effect
            content
                .background(
                    ZStack {
                        // Base background
                        RoundedRectangle(cornerRadius: style.cornerRadius)
                            .fill(style.background)
                        
                        // Blur effect
                        RoundedRectangle(cornerRadius: style.cornerRadius)
                            .fill(.ultraThinMaterial)
                            .opacity(style.materialOpacity)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: style.cornerRadius)
                        .stroke(style.borderColor, lineWidth: style.borderWidth)
                )
                .shadow(
                    color: .black.opacity(style.shadowOpacity),
                    radius: style.shadowRadius,
                    x: 0,
                    y: style.shadowOffset
                )
                .saturation(style.saturation)
                .brightness(style.brightness)
                .animation(
                    reduceMotion ? .none : .easeInOut(duration: 0.3),
                    value: style.isInteractive
                )
        }
    }
}

// MARK: - Liquid Glass Style
struct LiquidGlassStyle {
    let background: Color
    let solidBackground: Color
    let borderColor: Color
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let materialOpacity: Double
    let shadowRadius: CGFloat
    let shadowOpacity: Double
    let shadowOffset: CGFloat
    let saturation: Double
    let brightness: Double
    let isInteractive: Bool
    
    static let navigationToolbar = LiquidGlassStyle(
        background: Constants.MinimalistDesign.backgroundPrimary,
        solidBackground: Constants.Colors.cardBackground,
        borderColor: Constants.MinimalistDesign.borderPrimary,
        cornerRadius: Constants.MinimalistDesign.cornerRadius,
        borderWidth: Constants.MinimalistDesign.borderWidth,
        materialOpacity: 0.8,
        shadowRadius: Constants.MinimalistDesign.shadowRadius,
        shadowOpacity: Constants.MinimalistDesign.shadowOpacity,
        shadowOffset: 2,
        saturation: Constants.MinimalistDesign.saturation,
        brightness: Constants.MinimalistDesign.brightness,
        isInteractive: true
    )
    
    static let searchBar = LiquidGlassStyle(
        background: Constants.MinimalistDesign.backgroundSecondary,
        solidBackground: Constants.Colors.cardBackground,
        borderColor: Constants.MinimalistDesign.borderPrimary,
        cornerRadius: Constants.UI.cornerRadius,
        borderWidth: Constants.MinimalistDesign.borderWidth,
        materialOpacity: 0.6,
        shadowRadius: 4,
        shadowOpacity: 0.05,
        shadowOffset: 1,
        saturation: 1.0,
        brightness: 0.0,
        isInteractive: true
    )
    
    static let button = LiquidGlassStyle(
        background: Constants.MinimalistDesign.backgroundTertiary,
        solidBackground: Constants.Colors.backgroundTertiary,
        borderColor: Constants.MinimalistDesign.borderPrimary,
        cornerRadius: Constants.UI.cornerRadius,
        borderWidth: Constants.MinimalistDesign.borderWidth,
        materialOpacity: 0.5,
        shadowRadius: 2,
        shadowOpacity: 0.03,
        shadowOffset: 0.5,
        saturation: 1.0,
        brightness: 0.0,
        isInteractive: true
    )
    
    static let card = LiquidGlassStyle(
        background: Constants.MinimalistDesign.backgroundSecondary,
        solidBackground: Constants.Colors.cardBackground,
        borderColor: Constants.MinimalistDesign.borderPrimary,
        cornerRadius: Constants.UI.cornerRadius,
        borderWidth: Constants.MinimalistDesign.borderWidth,
        materialOpacity: 0.7,
        shadowRadius: 8,
        shadowOpacity: 0.08,
        shadowOffset: 1,
        saturation: 1.0,
        brightness: 0.0,
        isInteractive: false
    )
}

// MARK: - View Extension
extension View {
    func liquidGlass(_ style: LiquidGlassStyle = .navigationToolbar) -> some View {
        modifier(LiquidGlassModifier(style: style))
    }
}

// MARK: - Accessibility Environment Keys
extension EnvironmentValues {
    var accessibilityReduceTransparency: Bool {
        get { self[ReduceTransparencyKey.self] }
        set { self[ReduceTransparencyKey.self] = newValue }
    }
    
    var accessibilityReduceMotion: Bool {
        get { self[ReduceMotionKey.self] }
        set { self[ReduceMotionKey.self] = newValue }
    }
}

private struct ReduceTransparencyKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct ReduceMotionKey: EnvironmentKey {
    static let defaultValue: Bool = false
}
