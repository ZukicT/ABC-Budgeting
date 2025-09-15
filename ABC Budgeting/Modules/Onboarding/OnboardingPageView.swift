import SwiftUI

struct OnboardingPageView: View {
    let illustration: AnyView
    let title: String
    let description: String
    
    init(illustration: AnyView, title: String, description: String) {
        self.illustration = illustration
        self.title = title
        self.description = description
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Illustration
            illustration
                .frame(maxWidth: .infinity, maxHeight: 300)
            
            // Content
            VStack(spacing: 16) {
                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

struct SingleShapeIllustration: View {
    let assetName: String
    let height: CGFloat
    
    init(assetName: String, height: CGFloat = 200) {
        self.assetName = assetName
        self.height = height
    }
    
    var body: some View {
        Image(assetName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: height)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
