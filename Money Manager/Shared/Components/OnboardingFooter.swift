import SwiftUI

struct OnboardingFooter: View {
    let buttonTitle: String
    let buttonIcon: String
    let currentPage: Int
    let totalPages: Int
    let buttonAction: () -> Void
    let secondaryButtonTitle: String?
    let secondaryButtonAction: (() -> Void)?
    
    init(
        buttonTitle: String,
        buttonIcon: String = "arrow.right",
        currentPage: Int,
        totalPages: Int,
        buttonAction: @escaping () -> Void,
        secondaryButtonTitle: String? = nil,
        secondaryButtonAction: (() -> Void)? = nil
    ) {
        self.buttonTitle = buttonTitle
        self.buttonIcon = buttonIcon
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.buttonAction = buttonAction
        self.secondaryButtonTitle = secondaryButtonTitle
        self.secondaryButtonAction = secondaryButtonAction
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer() // Push content to bottom
                
                // Secondary button (if provided)
                if let secondaryTitle = secondaryButtonTitle, let secondaryAction = secondaryButtonAction {
                    Button(action: secondaryAction) {
                        Text(secondaryTitle)
                            .font(TrapFontUtility.trapFont(size: 16, weight: .medium))
                            .foregroundColor(Constants.Colors.textSecondary)
                            .underline()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
                
                // Continue button
                Button(action: buttonAction) {
                    HStack(spacing: 8) {
                        Image(systemName: buttonIcon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(buttonTitle)
                            .font(TrapFontUtility.trapFont(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.black)
                    .cornerRadius(Constants.UI.CornerRadius.primary)
                }
                .accessibilityLabel(buttonTitle)
                .accessibilityHint("Tap to continue")
                .accessibilityAddTraits(.isButton)
                .padding(.horizontal, 20)
                
                // Fixed spacing between button and indicators
                Spacer()
                    .frame(height: 20)
                
                // Carousel indicators
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        if index == currentPage {
                            // Active indicator (rectangle) - BLACK
                            RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                                .fill(Color.black)
                                .frame(width: 40, height: 8)
                                .accessibilityLabel("Page \(index + 1) of \(totalPages), current page")
                        } else {
                            // Inactive indicator (rounded square) - PINK
                            RoundedRectangle(cornerRadius: Constants.UI.CornerRadius.tertiary)
                                .fill(Color(hex: "#FFB6C8"))
                                .frame(width: 8, height: 8)
                                .accessibilityLabel("Page \(index + 1) of \(totalPages)")
                        }
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Page \(currentPage + 1) of \(totalPages)")
                .padding(.bottom, 10) // 10px from bottom of device screen
            }
        }
    }
}

#Preview {
    OnboardingFooter(
        buttonTitle: "Continue",
        buttonIcon: "arrow.right",
        currentPage: 1,
        totalPages: 5,
        buttonAction: {}
    )
}
