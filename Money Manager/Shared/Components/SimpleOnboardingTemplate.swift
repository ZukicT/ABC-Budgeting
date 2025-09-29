import SwiftUI

/**
 * SimpleOnboardingTemplate
 * 
 * A reusable SwiftUI template for onboarding screens with illustration, multi-colored headline,
 * body text, custom content, and navigation controls. Supports back button functionality and
 * accessibility features.
 * 
 * Features:
 * - Responsive layout using GeometryReader
 * - Multi-colored headline support
 * - Custom illustration and content areas
 * - Accessibility compliance (VoiceOver, Dynamic Type)
 * - Optional back button functionality
 * 
 * Last Review: 2025-01-26
 * Status: Production Ready
 */

struct SimpleOnboardingTemplate: View {
    let illustration: AnyView
    let headline: String
    let headlineColors: [Color]
    let bodyText: String
    let buttonTitle: String
    let buttonIcon: String
    let currentPage: Int
    let totalPages: Int
    let buttonAction: () -> Void
    let customContent: AnyView?
    let showBackButton: Bool
    let backButtonAction: (() -> Void)?
    let secondaryButtonTitle: String?
    @ObservedObject private var contentManager = MultilingualContentManager.shared
    let secondaryButtonAction: (() -> Void)?
    
    init(
        illustration: AnyView,
        headline: String,
        headlineColors: [Color],
        bodyText: String,
        buttonTitle: String,
        buttonIcon: String = "arrow.right",
        currentPage: Int,
        totalPages: Int,
        buttonAction: @escaping () -> Void,
        customContent: AnyView? = nil,
        showBackButton: Bool = false,
        backButtonAction: (() -> Void)? = nil,
        secondaryButtonTitle: String? = nil,
        secondaryButtonAction: (() -> Void)? = nil
    ) {
        self.illustration = illustration
        self.headline = headline
        self.headlineColors = headlineColors
        self.bodyText = bodyText
        self.buttonTitle = buttonTitle
        self.buttonIcon = buttonIcon
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.buttonAction = buttonAction
        self.customContent = customContent
        self.showBackButton = showBackButton
        self.backButtonAction = backButtonAction
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonAction = secondaryButtonAction
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // White background
                Color.white
                    .ignoresSafeArea()
                
                ZStack(alignment: .top) {
                    if showBackButton, let backAction = backButtonAction {
                        HStack {
                            Button(action: backAction) {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text(contentManager.localizedString("onboarding.back"))
                                        .font(TrapFontUtility.trapFont(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .frame(height: 40)
                                .padding(.horizontal, 16)
                                .background(Color.black)
                                .cornerRadius(Constants.UI.CornerRadius.primary)
                            }
                            .padding(.top, 20)
                            .padding(.leading, 20)
                            
                            Spacer()
                        }
                    }
                    
                    illustration
                        .frame(height: geometry.size.height * Constants.Onboarding.illustrationHeightRatio)
                        .clipped()
                        .padding(.top, 60) // Move image down to avoid back button overlap
                        .accessibilityElement(children: .combine)
                    
                    // Text Content Section - positioned at Y: 520 (original position)
                    VStack(alignment: .leading, spacing: 20) {
                        MultiColorText(
                            text: headline,
                            colors: headlineColors
                        )
                        .frame(maxWidth: min(350, geometry.size.width - 0))
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(headline)
                        .accessibilityAddTraits(.isHeader)
                        
                        // Body text with Dynamic Type support
                        Text(bodyText)
                            .font(TrapFontUtility.trapFont(size: 14, weight: .regular))
                            .foregroundColor(Color.black)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .frame(maxWidth: geometry.size.width - 0)
                            .lineSpacing(6)
                            .accessibilityLabel(bodyText)
                            .accessibilityAddTraits(.isStaticText)
                        
                        if let customContent = customContent {
                            customContent
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .position(x: geometry.size.width / 2, y: 535)
                    
                    OnboardingFooter(
                        buttonTitle: buttonTitle,
                        buttonIcon: buttonIcon,
                        currentPage: currentPage,
                        totalPages: totalPages,
                        buttonAction: buttonAction,
                        secondaryButtonTitle: secondaryButtonTitle,
                        secondaryButtonAction: secondaryButtonAction
                    )
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Onboarding screen")
    }
}

struct MultiColorText: View {
    let text: String
    let colors: [Color]
    
    var body: some View {
        let attributedText = createAttributedText(from: text)
        
        Text(attributedText)
            .font(TrapFontUtility.trapFont(size: 38, weight: .black))
            .multilineTextAlignment(.leading)
            .lineLimit(nil)
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(text)
    }
    
    private func createAttributedText(from text: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        if colors.count == 1 {
            // Single color - apply to entire text
            attributedString.foregroundColor = colors[0]
        } else if colors.count > 1 {
            // Multiple colors - cycle through colors for each word
            let words = text.components(separatedBy: .whitespaces)
            var currentColorIndex = 0
            
            for word in words {
                let wordRange = attributedString.range(of: word)
                if let range = wordRange {
                    attributedString[range].foregroundColor = colors[currentColorIndex % colors.count]
                    currentColorIndex += 1
                }
            }
        } else {
            // Fallback to default color
            attributedString.foregroundColor = Constants.Onboarding.primaryBlueHex
        }
        
        return attributedString
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: result.positions[index], proposal: ProposedViewSize(result.sizes[index]))
        }
    }
}

struct FlowResult {
    let size: CGSize
    let positions: [CGPoint]
    let sizes: [CGSize]
    
    init(in maxWidth: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
        var currentPosition = CGPoint.zero
        var lineHeight: CGFloat = 0
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        
        for subview in subviews {
            let subviewSize = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            
            if currentPosition.x + subviewSize.width > maxWidth && currentPosition.x > 0 {
                currentPosition.x = 0
                currentPosition.y += lineHeight + spacing
                lineHeight = 0
            }
            
            positions.append(currentPosition)
            sizes.append(subviewSize)
            
            currentPosition.x += subviewSize.width
            lineHeight = max(lineHeight, subviewSize.height)
        }
        
        self.size = CGSize(
            width: maxWidth,
            height: currentPosition.y + lineHeight
        )
        self.positions = positions
        self.sizes = sizes
    }
}

#Preview {
    SimpleOnboardingTemplate(
        illustration: AnyView(
            Image("hero-illustrations")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        ),
        headline: "Start moving to improve your mental game",
        headlineColors: [
            Color(red: 0.341, green: 0.455, blue: 0.804), // Blue
            .black,                                        // Black
            Color(red: 0.996, green: 0.643, blue: 0.098)  // Orange
        ],
        bodyText: "Level up your fitness, mental game and social game by getting active with others in your community and organising trial walks.",
        buttonTitle: "Comprende",
        buttonIcon: "hand.wave",
        currentPage: 0,
        totalPages: 5,
        buttonAction: {}
    )
}
