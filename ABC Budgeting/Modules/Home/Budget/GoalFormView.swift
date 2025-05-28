import SwiftUI

struct GoalFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var subtitle: String = ""
    @State private var targetAmount: String = ""
    @State private var savedAmount: String = ""
    @State private var targetDate: Date = Date()
    @State private var notes: String = ""
    @State private var iconName: String = "target"
    @State private var iconColor: Color = .blue
    var onSave: (GoalFormData) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.primary)
                        .font(.body.weight(.semibold))
                    Spacer()
                    Button("Save") {
                        if let target = Double(targetAmount), let saved = Double(savedAmount) {
                            onSave(GoalFormData(
                                name: name,
                                subtitle: subtitle.isEmpty ? nil : subtitle,
                                targetAmount: target,
                                savedAmount: saved,
                                targetDate: targetDate,
                                notes: notes.isEmpty ? nil : notes,
                                iconName: iconName,
                                iconColorName: iconColor.toHex()
                            ))
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty || targetAmount.isEmpty)
                    .foregroundColor(.accentColor)
                    .font(.body.weight(.semibold))
                }
                .padding(.horizontal, AppPaddings.section)
                .padding(.top, AppPaddings.sectionTitleTop)
                ScrollView {
                    VStack(alignment: .leading, spacing: AppPaddings.medium) {
                        Group {
                            Text("Goal Name").font(.headline)
                            TextField("e.g. Vacation", text: $name)
                                .padding(AppPaddings.inputField)
                                .background(Color.white)
                                .cornerRadius(12)
                            Text("Subtitle").font(.headline)
                            TextField("e.g. Trip to Italy", text: $subtitle)
                                .padding(AppPaddings.inputField)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        Group {
                            Text("Target Amount").font(.headline)
                            TextField("e.g. 3000", text: $targetAmount)
                                .keyboardType(.decimalPad)
                                .padding(AppPaddings.inputField)
                                .background(Color.white)
                                .cornerRadius(12)
                            Text("Current Saved").font(.headline)
                            TextField("e.g. 1200", text: $savedAmount)
                                .keyboardType(.decimalPad)
                                .padding(AppPaddings.inputField)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        Group {
                            Text("Target Date").font(.headline)
                            DatePicker("", selection: $targetDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                        Group {
                            Text("Notes").font(.headline)
                            TextField("Add a note...", text: $notes, axis: .vertical)
                                .padding(AppPaddings.inputField)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        Group {
                            Text("Icon").font(.headline)
                            HStack(spacing: AppPaddings.small) {
                                Image(systemName: iconName)
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(iconColor)
                                    .padding(8)
                                    .background(iconColor.opacity(0.18))
                                    .clipShape(Circle())
                                TextField("SF Symbol name", text: $iconName)
                                    .padding(AppPaddings.inputField)
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                            Text("Color").font(.headline)
                            ColorPicker("Pick a color", selection: $iconColor, supportsOpacity: false)
                                .labelsHidden()
                        }
                    }
                    .padding(.horizontal, AppPaddings.section)
                    .padding(.bottom, AppPaddings.large)
                    .padding(.top, AppPaddings.sectionTitleTop)
                }
            }
            .background(AppColors.background)
        }
    }
}

struct GoalFormData: Hashable {
    let name: String
    let subtitle: String?
    let targetAmount: Double
    let savedAmount: Double
    let targetDate: Date
    let notes: String?
    let iconName: String
    let iconColorName: String
    var iconColor: Color { Color.fromName(iconColorName) }
}

extension Color {
    func toHex() -> String {
        // This is a simple mapping for system colors. Expand as needed for your palette.
        switch self {
        case .orange: return "orange"
        case .purple: return "purple"
        case .green: return "green"
        case .mint: return "mint"
        case .red: return "red"
        case .gray: return "gray"
        case .blue: return "blue"
        default: return "gray"
        }
    }
}

#if DEBUG
struct GoalFormView_Previews: PreviewProvider {
    static var previews: some View {
        GoalFormView { _ in }
            .background(AppColors.background)
    }
}
#endif 