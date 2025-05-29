import SwiftUI
import Foundation

struct NewSavingGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var goalName: String = ""
    @State private var subtitle: String = ""
    @State private var targetAmount: String = ""
    @State private var savedAmount: String = ""
    @State private var targetDate: Date = Date()
    @State private var notes: String = ""
    @State private var iconName: String = TransactionCategory.essentials.symbol
    @State private var iconColorName: String = TransactionCategory.essentials.color.toHex()
    @State private var selectedCategory: TransactionCategory = .essentials
    @State private var notifyMe: Bool = false
    @State private var reminderFrequency: RecurringFrequency = .monthly
    var onSave: (GoalFormData) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Sheet Header with brandBlack background and rounded top corners
                ZStack(alignment: .topLeading) {
                    AppColors.brandBlack
                        .clipShape(
                            RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                        )
                        .edgesIgnoringSafeArea(.top)
                        .frame(height: 56)
                    HStack {
                        Button("Cancel") { dismiss() }
                            .foregroundColor(.white)
                            .font(.body.weight(.semibold))
                            .padding(.leading, AppPaddings.section)
                        Spacer()
                    }
                    .frame(height: 56)
                }
                .accessibilityElement(children: .combine)
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerSection
                        goalNameSection
                        subtitleSection
                        targetAmountSection
                        savedAmountSection
                        targetDateSection
                        notesSection
                        iconSection
                        reminderSection
                        saveButtonSection
                    }
                    .padding(.horizontal, AppPaddings.section)
                    .padding(.bottom, AppPaddings.large)
                }
                .onTapGesture { hideKeyboard() }
            }
            .background(AppColors.background)
            .toolbar { EmptyView() } // Remove default toolbar
        }
    }

    private var headerSection: some View {
        Text("New Saving & Goal")
            .font(.largeTitle.bold())
            .padding(.top, AppPaddings.sectionTitleTop)
    }
    private var goalNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Goal Name").font(.headline)
            TextField("e.g. Vacation", text: $goalName)
                .padding(AppPaddings.inputField)
                .background(Color.white)
                .cornerRadius(12)
        }
    }
    private var subtitleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Subtitle").font(.headline)
            TextField("e.g. Trip to Italy", text: $subtitle)
                .padding(AppPaddings.inputField)
                .background(Color.white)
                .cornerRadius(12)
        }
    }
    private var targetAmountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target Amount").font(.headline)
            TextField("e.g. 3000", text: $targetAmount)
                .keyboardType(.decimalPad)
                .padding(AppPaddings.inputField)
                .background(Color.white)
                .cornerRadius(12)
                .onChange(of: targetAmount) { _, newValue in
                    let formatted = newValue.currencyInputFormatting(currencyCode: UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD")
                    if formatted != newValue {
                        targetAmount = formatted
                    }
                }
        }
    }
    private var savedAmountSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Saved").font(.headline)
            TextField("e.g. 1200", text: $savedAmount)
                .keyboardType(.decimalPad)
                .padding(AppPaddings.inputField)
                .background(Color.white)
                .cornerRadius(12)
                .onChange(of: savedAmount) { _, newValue in
                    let formatted = newValue.currencyInputFormatting(currencyCode: UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD")
                    if formatted != newValue {
                        savedAmount = formatted
                    }
                }
        }
    }
    private var targetDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Target Date").font(.headline)
            DatePicker("", selection: $targetDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
        }
    }
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes").font(.headline)
            TextField("Add a note...", text: $notes, axis: .vertical)
                .padding(AppPaddings.inputField)
                .background(Color.white)
                .cornerRadius(12)
        }
    }
    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Icon").font(.headline)
            // Category row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppPaddings.small) {
                    ForEach(TransactionCategory.allCases) { cat in
                        Button(action: {
                            selectedCategory = cat
                            // Optionally reset icon selection to default for new category
                            iconName = cat.symbol
                            iconColorName = cat.color.toHex()
                        }) {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .fill(cat.color.opacity(0.18))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: cat.symbol)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(selectedCategory == cat ? .white : cat.color)
                                }
                                Text(cat.label)
                                    .font(.caption)
                                    .foregroundColor(selectedCategory == cat ? .white : .primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .frame(width: 72, height: 72)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(selectedCategory == cat ? cat.color : Color.clear)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(cat.label)
                        .accessibilityAddTraits(selectedCategory == cat ? .isSelected : .isButton)
                    }
                }
            }
            // Icon row for selected category
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppPaddings.small) {
                    ForEach(selectedCategory.icons, id: \.self) { icon in
                        Button(action: {
                            iconName = icon
                            iconColorName = selectedCategory.color.toHex()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(selectedCategory.color.opacity(0.18))
                                    .frame(width: iconName == icon ? 56 : 48, height: iconName == icon ? 56 : 48)
                                Image(systemName: icon)
                                    .font(.system(size: iconName == icon ? 24 : 22, weight: .semibold))
                                    .foregroundColor(iconName == icon ? .white : selectedCategory.color)
                            }
                            .frame(width: iconName == icon ? 56 : 64, height: iconName == icon ? 56 : 64)
                            .background(
                                Circle()
                                    .fill(iconName == icon ? selectedCategory.color : Color.clear)
                            )
                            .overlay(
                                Circle()
                                    .stroke(selectedCategory.color, lineWidth: iconName == icon ? 2 : 0)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(icon)
                        .accessibilityAddTraits(iconName == icon ? .isSelected : .isButton)
                    }
                }
                .padding(.top, 4)
                .padding(.vertical, 8)
            }
        }
    }
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $notifyMe) {
                Text("Remind Me").font(.headline)
            }
            .tint(AppColors.brandGreen)
            if notifyMe {
                HStack {
                    Text("Frequency:").font(.subheadline)
                    BrandSegmentedPicker(selection: $reminderFrequency, options: RecurringFrequency.allCases, accessibilityLabel: "Reminder Frequency")
                }
            }
        }
    }
    private var saveButtonSection: some View {
        Button(action: save) {
            Text("Save Goal")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(goalName.isEmpty || targetAmount.isEmpty ? Color(.systemGray4) : AppColors.brandBlack)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(goalName.isEmpty || targetAmount.isEmpty)
        .padding(.top, 8)
    }

    private func save() {
        if let target = Double(targetAmount), let saved = Double(savedAmount) {
            onSave(GoalFormData(
                name: goalName,
                subtitle: subtitle.isEmpty ? nil : subtitle,
                targetAmount: target,
                savedAmount: saved,
                targetDate: targetDate,
                notes: notes.isEmpty ? nil : notes,
                iconName: iconName,
                iconColorName: iconColorName
            ))
            dismiss()
        }
    }
}

// You can reuse GoalFormData from GoalFormView 