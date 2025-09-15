import SwiftUI

// MARK: - Button Enums
enum AppButtonStyle {
    case primary
    case secondary
    case destructive
    case ghost
}

enum AppButtonSize {
    case small
    case medium
    case large
}

// MARK: - App Button System
struct AppButton: View {
    let title: String
    let style: AppButtonStyle
    let size: AppButtonSize
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        _ title: String,
        style: AppButtonStyle = .primary,
        size: AppButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppPaddings.sm) {
                Text(title)
                    .font(buttonFont)
                    .foregroundColor(buttonTextColor)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .padding(.horizontal, horizontalPadding)
            .background(buttonBackground)
            .overlay(
                RoundedRectangle(cornerRadius: buttonRadius)
                    .stroke(buttonBorderColor, lineWidth: buttonBorderWidth)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: AppAnimations.fast), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    // MARK: - Computed Properties
    private var buttonFont: Font {
        switch size {
        case .small:
            return .buttonSmall
        case .medium:
            return .button
        case .large:
            return .buttonLarge
        }
    }
    
    private var buttonHeight: CGFloat {
        switch size {
        case .small:
            return AppSizes.buttonHeightSmall
        case .medium:
            return AppSizes.buttonHeight
        case .large:
            return AppSizes.buttonHeightLarge
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .small:
            return AppPaddings.buttonSmall
        case .medium:
            return AppPaddings.button
        case .large:
            return AppPaddings.buttonLarge
        }
    }
    
    private var buttonRadius: CGFloat {
        switch size {
        case .small:
            return AppRadius.buttonSmall
        case .medium:
            return AppRadius.button
        case .large:
            return AppRadius.buttonLarge
        }
    }
    
    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: buttonRadius)
            .fill(backgroundColor)
    }
    
    private var backgroundColor: Color {
        if isPressed {
            return pressedBackgroundColor
        }
        
        switch style {
        case .primary:
            return AppColors.buttonPrimary
        case .secondary:
            return AppColors.buttonSecondary
        case .destructive:
            return AppColors.buttonDestructive
        case .ghost:
            return Color.clear
        }
    }
    
    private var pressedBackgroundColor: Color {
        switch style {
        case .primary:
            return AppColors.buttonPrimaryPressed
        case .secondary:
            return AppColors.buttonSecondaryPressed
        case .destructive:
            return AppColors.buttonDestructivePressed
        case .ghost:
            return AppColors.backgroundSecondary
        }
    }
    
    private var buttonTextColor: Color {
        switch style {
        case .primary, .destructive:
            return AppColors.textInverse
        case .secondary, .ghost:
            return AppColors.textPrimary
        }
    }
    
    private var buttonBorderColor: Color {
        switch style {
        case .primary, .destructive:
            return Color.clear
        case .secondary:
            return AppColors.border
        case .ghost:
            return AppColors.border
        }
    }
    
    private var buttonBorderWidth: CGFloat {
        switch style {
        case .primary, .destructive:
            return 0
        case .secondary, .ghost:
            return 1
        }
    }
}


// MARK: - Icon Button
struct AppIconButton: View {
    let icon: String
    let style: AppButtonStyle
    let size: AppButtonSize
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(
        icon: String,
        style: AppButtonStyle = .primary,
        size: AppButtonSize = .medium,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(iconFont)
                .foregroundColor(buttonTextColor)
                .frame(width: buttonSize, height: buttonSize)
                .background(buttonBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: buttonRadius)
                        .stroke(buttonBorderColor, lineWidth: buttonBorderWidth)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: AppAnimations.fast), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    // MARK: - Computed Properties
    private var iconFont: Font {
        switch size {
        case .small:
            return .system(size: 16, weight: .medium)
        case .medium:
            return .system(size: 20, weight: .medium)
        case .large:
            return .system(size: 24, weight: .medium)
        }
    }
    
    private var buttonSize: CGFloat {
        switch size {
        case .small:
            return 32
        case .medium:
            return 40
        case .large:
            return 48
        }
    }
    
    private var buttonRadius: CGFloat {
        switch size {
        case .small:
            return AppRadius.buttonSmall
        case .medium:
            return AppRadius.button
        case .large:
            return AppRadius.buttonLarge
        }
    }
    
    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: buttonRadius)
            .fill(backgroundColor)
    }
    
    private var backgroundColor: Color {
        if isPressed {
            return pressedBackgroundColor
        }
        
        switch style {
        case .primary:
            return AppColors.buttonPrimary
        case .secondary:
            return AppColors.buttonSecondary
        case .destructive:
            return AppColors.buttonDestructive
        case .ghost:
            return Color.clear
        }
    }
    
    private var pressedBackgroundColor: Color {
        switch style {
        case .primary:
            return AppColors.buttonPrimaryPressed
        case .secondary:
            return AppColors.buttonSecondaryPressed
        case .destructive:
            return AppColors.buttonDestructivePressed
        case .ghost:
            return AppColors.backgroundSecondary
        }
    }
    
    private var buttonTextColor: Color {
        switch style {
        case .primary, .destructive:
            return AppColors.textInverse
        case .secondary, .ghost:
            return AppColors.textPrimary
        }
    }
    
    private var buttonBorderColor: Color {
        switch style {
        case .primary, .destructive:
            return Color.clear
        case .secondary:
            return AppColors.border
        case .ghost:
            return AppColors.border
        }
    }
    
    private var buttonBorderWidth: CGFloat {
        switch style {
        case .primary, .destructive:
            return 0
        case .secondary, .ghost:
            return 1
        }
    }
}

// MARK: - Floating Action Button
struct AppFloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(icon: String, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(AppColors.textInverse)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(AppColors.primary)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: AppAnimations.fast), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
        .shadow(color: AppColors.shadow, radius: AppShadows.lg, x: 0, y: 4)
    }
}

// MARK: - Preview
struct AppButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppPaddings.lg) {
            // Primary Buttons
            VStack(spacing: AppPaddings.md) {
                AppButton("Primary Button", style: .primary, size: .small) { }
                AppButton("Primary Button", style: .primary, size: .medium) { }
                AppButton("Primary Button", style: .primary, size: .large) { }
            }
            
            // Secondary Buttons
            VStack(spacing: AppPaddings.md) {
                AppButton("Secondary Button", style: .secondary, size: .small) { }
                AppButton("Secondary Button", style: .secondary, size: .medium) { }
                AppButton("Secondary Button", style: .secondary, size: .large) { }
            }
            
            // Destructive Buttons
            VStack(spacing: AppPaddings.md) {
                AppButton("Destructive Button", style: .destructive, size: .small) { }
                AppButton("Destructive Button", style: .destructive, size: .medium) { }
                AppButton("Destructive Button", style: .destructive, size: .large) { }
            }
            
            // Ghost Buttons
            VStack(spacing: AppPaddings.md) {
                AppButton("Ghost Button", style: .ghost, size: .small) { }
                AppButton("Ghost Button", style: .ghost, size: .medium) { }
                AppButton("Ghost Button", style: .ghost, size: .large) { }
            }
            
            // Icon Buttons
            HStack(spacing: AppPaddings.md) {
                AppIconButton(icon: "plus", style: .primary, size: .small) { }
                AppIconButton(icon: "minus", style: .secondary, size: .medium) { }
                AppIconButton(icon: "trash", style: .destructive, size: .large) { }
            }
            
            // Floating Action Button
            AppFloatingActionButton(icon: "plus") { }
        }
        .padding()
        .background(AppColors.background)
    }
}
