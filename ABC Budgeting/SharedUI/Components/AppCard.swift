import SwiftUI

// MARK: - App Card System
struct AppCard<Content: View>: View {
    let content: Content
    let style: CardStyle
    let padding: CardPadding
    let action: (() -> Void)?
    
    @State private var isPressed = false
    
    init(
        style: CardStyle = .default,
        padding: CardPadding = .medium,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    cardContent
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: AppAnimations.fast), value: isPressed)
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    isPressed = pressing
                }, perform: {})
            } else {
                cardContent
            }
        }
    }
    
    private var cardContent: some View {
        content
            .padding(cardPadding)
            .background(cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: cardRadius)
                    .stroke(cardBorderColor, lineWidth: cardBorderWidth)
            )
            .shadow(color: cardShadowColor, radius: cardShadowRadius, x: 0, y: cardShadowOffset)
    }
    
    // MARK: - Computed Properties
    private var cardPadding: CGFloat {
        switch padding {
        case .small:
            return AppPaddings.cardSmall
        case .medium:
            return AppPaddings.card
        case .large:
            return AppPaddings.cardLarge
        }
    }
    
    private var cardRadius: CGFloat {
        switch style {
        case .default:
            return AppRadius.card
        case .rounded:
            return AppRadius.cardLarge
        case .square:
            return AppRadius.sm
        case .secondary:
            return AppRadius.card
        case .highlighted:
            return AppRadius.card
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: cardRadius)
            .fill(backgroundColor)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .default, .rounded, .square:
            return AppColors.card
        case .secondary:
            return AppColors.cardSecondary
        case .highlighted:
            return AppColors.primary.opacity(0.05)
        }
    }
    
    private var cardBorderColor: Color {
        switch style {
        case .default, .rounded, .square, .secondary:
            return AppColors.border
        case .highlighted:
            return AppColors.primary.opacity(0.2)
        }
    }
    
    private var cardBorderWidth: CGFloat {
        switch style {
        case .default, .rounded, .square, .secondary:
            return 1
        case .highlighted:
            return 2
        }
    }
    
    private var cardShadowColor: Color {
        switch style {
        case .default, .rounded, .square, .secondary:
            return AppColors.shadow
        case .highlighted:
            return AppColors.primary.opacity(0.1)
        }
    }
    
    private var cardShadowRadius: CGFloat {
        switch style {
        case .default, .rounded, .square, .secondary:
            return AppShadows.card
        case .highlighted:
            return AppShadows.md
        }
    }
    
    private var cardShadowOffset: CGFloat {
        switch style {
        case .default, .rounded, .square, .secondary:
            return 1
        case .highlighted:
            return 2
        }
    }
}

// MARK: - Card Styles
extension AppCard {
    enum CardStyle {
        case `default`
        case rounded
        case square
        case secondary
        case highlighted
    }
    
    enum CardPadding {
        case small
        case medium
        case large
    }
}

// MARK: - Card Header
struct AppCardHeader: View {
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(
        title: String,
        subtitle: String? = nil,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.actionTitle = actionTitle
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppPaddings.xs) {
                Text(title)
                    .font(.h4)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer()
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.labelSmall)
                        .foregroundColor(AppColors.primary)
                }
            }
        }
    }
}

// MARK: - Card Footer
struct AppCardFooter<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.top, AppPaddings.md)
    }
}

// MARK: - Stat Card
struct AppStatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String?
    let color: Color
    let trend: TrendDirection?
    let trendValue: String?
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String? = nil,
        color: Color = AppColors.primary,
        trend: TrendDirection? = nil,
        trendValue: String? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.trend = trend
        self.trendValue = trendValue
    }
    
    var body: some View {
        AppCard(style: .default, padding: .medium) {
            VStack(alignment: .leading, spacing: AppPaddings.md) {
                // Header
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(color)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(color.opacity(0.1))
                            )
                    }
                    
                    Spacer()
                    
                    if let trend = trend, let trendValue = trendValue {
                        HStack(spacing: AppPaddings.xs) {
                            Image(systemName: trend.icon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(trend.color)
                            
                            Text(trendValue)
                                .font(.labelSmall)
                                .foregroundColor(trend.color)
                        }
                        .padding(.horizontal, AppPaddings.sm)
                        .padding(.vertical, AppPaddings.xs)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.sm)
                                .fill(trend.color.opacity(0.1))
                        )
                    }
                }
                
                // Content
                VStack(alignment: .leading, spacing: AppPaddings.xs) {
                    Text(title)
                        .font(.label)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(value)
                        .font(.h2)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.bodySmall)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
        }
    }
}

// MARK: - Trend Direction
extension AppStatCard {
    enum TrendDirection {
        case up
        case down
        case neutral
        
        var icon: String {
            switch self {
            case .up:
                return "arrow.up"
            case .down:
                return "arrow.down"
            case .neutral:
                return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up:
                return AppColors.success
            case .down:
                return AppColors.error
            case .neutral:
                return AppColors.textTertiary
            }
        }
    }
}

// MARK: - List Card
struct AppListCard: View {
    let items: [ListItem]
    let title: String?
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(
        items: [ListItem],
        title: String? = nil,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        self.items = items
        self.title = title
        self.action = action
        self.actionTitle = actionTitle
    }
    
    var body: some View {
        AppCard(style: .default, padding: .medium) {
            VStack(alignment: .leading, spacing: AppPaddings.md) {
                // Header
                if let title = title {
                    HStack {
                        Text(title)
                            .font(.h4)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        if let action = action, let actionTitle = actionTitle {
                            Button(action: action) {
                                Text(actionTitle)
                                    .font(.labelSmall)
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                }
                
                // Items
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        HStack(spacing: AppPaddings.md) {
                            if let icon = item.icon {
                                Image(systemName: icon)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(item.iconColor ?? AppColors.textSecondary)
                                    .frame(width: 24, height: 24)
                            }
                            
                            VStack(alignment: .leading, spacing: AppPaddings.xs) {
                                Text(item.title)
                                    .font(.body)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                if let subtitle = item.subtitle {
                                    Text(subtitle)
                                        .font(.bodySmall)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            if let value = item.value {
                                Text(value)
                                    .font(.body)
                                    .foregroundColor(item.valueColor ?? AppColors.textPrimary)
                            }
                            
                            if let trailingIcon = item.trailingIcon {
                                Image(systemName: trailingIcon)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                        .padding(.vertical, AppPaddings.sm)
                        
                        if index < items.count - 1 {
                            Divider()
                                .background(AppColors.divider)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - List Item
struct ListItem {
    let title: String
    let subtitle: String?
    let value: String?
    let valueColor: Color?
    let icon: String?
    let iconColor: Color?
    let trailingIcon: String?
    
    init(
        title: String,
        subtitle: String? = nil,
        value: String? = nil,
        valueColor: Color? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        trailingIcon: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.valueColor = valueColor
        self.icon = icon
        self.iconColor = iconColor
        self.trailingIcon = trailingIcon
    }
}

// MARK: - Preview
struct AppCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: AppPaddings.lg) {
                // Basic Cards
                VStack(spacing: AppPaddings.md) {
                    AppCard(style: .default) {
                        Text("Default Card")
                            .font(.h4)
                    }
                    
                    AppCard(style: .secondary) {
                        Text("Secondary Card")
                            .font(.h4)
                    }
                    
                    AppCard(style: .highlighted) {
                        Text("Highlighted Card")
                            .font(.h4)
                    }
                }
                
                // Stat Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: AppPaddings.md) {
                    AppStatCard(
                        title: "Total Balance",
                        value: "$12,345.67",
                        subtitle: "This month",
                        icon: "dollarsign.circle",
                        color: AppColors.success,
                        trend: .up,
                        trendValue: "+12%"
                    )
                    
                    AppStatCard(
                        title: "Expenses",
                        value: "$3,456.78",
                        subtitle: "This month",
                        icon: "arrow.down.circle",
                        color: AppColors.error,
                        trend: .down,
                        trendValue: "-5%"
                    )
                }
                
                // List Card
                AppListCard(
                    items: [
                        ListItem(
                            title: "Groceries",
                            subtitle: "Yesterday",
                            value: "$45.67",
                            valueColor: AppColors.error,
                            icon: "cart",
                            iconColor: AppColors.categoryFood
                        ),
                        ListItem(
                            title: "Salary",
                            subtitle: "Today",
                            value: "$3,000.00",
                            valueColor: AppColors.success,
                            icon: "dollarsign.circle",
                            iconColor: AppColors.success
                        ),
                        ListItem(
                            title: "Rent",
                            subtitle: "Due in 3 days",
                            value: "$1,200.00",
                            valueColor: AppColors.error,
                            icon: "house",
                            iconColor: AppColors.categoryBills
                        )
                    ],
                    title: "Recent Transactions",
                    action: { },
                    actionTitle: "View All"
                )
            }
            .padding()
        }
        .background(AppColors.background)
    }
}
