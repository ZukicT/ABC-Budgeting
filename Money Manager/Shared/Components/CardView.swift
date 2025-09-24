import SwiftUI

// MARK: - Card View
struct CardView<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let backgroundColor: Color
    let borderColor: Color
    let shadowRadius: CGFloat
    
    init(
        padding: CGFloat = Constants.UI.Spacing.medium,
        cornerRadius: CGFloat = Constants.UI.cornerRadius,
        backgroundColor: Color = Constants.Colors.backgroundSecondary,
        borderColor: Color = Constants.Colors.borderPrimary,
        shadowRadius: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.shadowRadius = shadowRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .liquidGlass(.card)
    }
}

// MARK: - Info Card
struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let action: (() -> Void)?
    
    init(
        title: String,
        value: String,
        icon: String,
        color: Color = Constants.Colors.info,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        CardView {
            HStack(spacing: Constants.UI.Spacing.medium) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Text(value)
                        .font(Constants.Typography.H2.font)
                        .foregroundColor(Constants.Colors.textPrimary)
                }
                
                Spacer()
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.textTertiary)
                        .accessibilityHidden(true)
                }
            }
        }
        .onTapGesture {
            action?()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
        .accessibilityAddTraits(action != nil ? .isButton : [])
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let trend: TrendDirection?
    let color: Color
    
    enum TrendDirection {
        case up, down, neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return Constants.Colors.success
            case .down: return Constants.Colors.error
            case .neutral: return Constants.Colors.textTertiary
            }
        }
    }
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        trend: TrendDirection? = nil,
        color: Color = Constants.Colors.info
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.trend = trend
        self.color = color
    }
    
    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: Constants.UI.Spacing.small) {
                HStack {
                    Text(title)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textSecondary)
                    
                    Spacer()
                    
                    if let trend = trend {
                        HStack(spacing: 4) {
                            Image(systemName: trend.icon)
                                .font(.caption2)
                            Text("5.2%")
                                .font(.caption2)
                        }
                        .foregroundColor(trend.color)
                        .accessibilityLabel("Trend: \(trend == .up ? "up" : trend == .down ? "down" : "neutral")")
                    }
                }
                
                Text(value)
                    .font(Constants.Typography.H1.font)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(Constants.Typography.Caption.font)
                        .foregroundColor(Constants.Colors.textTertiary)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}
