import SwiftUI

struct GoalCard: View {
    let iconName: String
    let iconColorName: String
    let title: String
    let subtitle: String?
    let savedAmount: Double
    let goalAmount: Double
    let progress: Double // 0.0...1.0

    var iconColor: Color { Color.fromName(iconColorName) }

    var body: some View {
        VStack(alignment: .leading, spacing: AppPaddings.small) {
            HStack(alignment: .center, spacing: AppPaddings.small) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.18))
                        .frame(width: 40, height: 40)
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
            }
            ProgressView(value: progress)
                .accentColor(iconColor)
                .frame(height: 8)
                .clipShape(Capsule())
            HStack {
                Text("$\(Int(savedAmount)) saved")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
                Spacer()
                Text("Goal: $\(Int(goalAmount))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(AppPaddings.card)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Goal: \(title), \(Int(savedAmount)) saved of \(Int(goalAmount))")
    }
}

#if DEBUG
struct GoalCard_Previews: PreviewProvider {
    static var previews: some View {
        GoalCard(
            iconName: "target",
            iconColorName: "blue",
            title: "Vacation",
            subtitle: "Trip to Italy",
            savedAmount: 1200,
            goalAmount: 3000,
            progress: 0.4
        )
        .padding()
        .background(AppColors.background)
        .previewLayout(.sizeThatFits)
    }
}
#endif 