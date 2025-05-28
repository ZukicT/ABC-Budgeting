import SwiftUI

struct MainHeaderView: View {
    let userName: String
    let showNotificationDot: Bool

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning!"
        case 12..<18:
            return "Good Afternoon!"
        default:
            return "Good Evening!"
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Fill the safe area behind the notch
                Color.white.ignoresSafeArea(edges: .top)
                // The visible card with rounded corners, starting below the safe area
                VStack {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(greeting)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(userName)
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(.primary)
                                .alignmentGuide(.firstTextBaseline) { d in d[.top] }
                            if showNotificationDot {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                                    .offset(x: -1, y: 2)
                            }
                        }
                        .accessibilityLabel("Notifications")
                        .accessibilityAddTraits(.isButton)
                    }
                    .padding(.top, -60)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .frame(maxWidth: .infinity)
                .background(
                    Color.white
                        .cornerRadius(28, corners: [.topLeft, .topRight])
                )
                .padding(.top, geometry.safeAreaInsets.top)
            }
        }
        .frame(height: 8 + 12 + 8 + 28) // Adjust as needed for your header
    }
}

#if DEBUG
struct MainHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        MainHeaderView(userName: "C Muthu Krishnan", showNotificationDot: true)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif 