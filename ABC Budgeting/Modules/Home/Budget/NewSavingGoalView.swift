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
    @State private var iconName: String = TransactionCategoryType.essentials.symbol
    @State private var iconColorName: String = TransactionCategoryType.essentials.color.toHex()
    @State private var selectedCategory: TransactionCategoryType = .essentials
    @State private var notifyMe: Bool = false
    @State private var reminderFrequency: RecurringFrequency = .monthly
    var onSave: (GoalFormItem) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Enhanced Sheet Header with gradient background
                ZStack(alignment: .topLeading) {
                    LinearGradient(
                        colors: [AppColors.black, AppColors.black.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(
                        RoundedCorner(radius: 28, corners: [.topLeft, .topRight])
                    )
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: 64)
                    
                    HStack {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Cancel")
                                    .font(.body.weight(.semibold))
                            }
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.15))
                            )
                        }
                        .padding(.leading, AppPaddings.section)
                        
                        Spacer()
                        
                        Text("New Saving Goal")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Placeholder for balance
                        Color.clear
                            .frame(width: 80)
                    }
                    .frame(height: 64)
                }
                .accessibilityElement(children: .combine)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        goalNameSection
                        subtitleSection
                        targetAmountSection
                        savedAmountSection
                        targetDateSection
                        iconPickerSection
                        reminderSection
                        notesSection
                        saveButtonSection
                    }
                    .padding(.horizontal, AppPaddings.section)
                    .padding(.bottom, AppPaddings.lg)
                }
                .background(AppColors.background)
                .contentShape(Rectangle())
                .simultaneousGesture(TapGesture().onEnded { UIApplication.shared.endEditing() })
            }
            .toolbar { EmptyView() } // Remove default toolbar
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Goal Details")
                .font(.title2.weight(.bold))
                .foregroundColor(RobinhoodColors.primary)
            Text("Fill in the details below to create your saving goal")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }
    
    private var goalNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "textformat")
                    .foregroundColor(AppColors.primary)
                    .font(.title2)
                Text("Goal Name")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(RobinhoodColors.primary)
            }
            
            TextField("e.g. Vacation, New Car, Emergency Fund", text: $goalName)
                .font(.body)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                )
        }
    }
    
    private var subtitleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.badge.plus")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                Text("Description")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(RobinhoodColors.primary)
            }
            
            TextField("e.g. Trip to Italy, Tesla Model 3", text: $subtitle)
                .font(.body)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                )
        }
    }
    
    private var targetAmountSection: some View {
        let preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD (US Dollar)"
        let currencyCode = preferredCurrency.components(separatedBy: " ").first ?? "USD"
        let currencySymbol = Locale.availableIdentifiers.compactMap { Locale(identifier: $0) }
            .first(where: { $0.currency?.identifier == currencyCode })?.currencySymbol ?? "$"
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                Text("Target Amount")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(RobinhoodColors.primary)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                
                HStack(spacing: 12) {
                    Text(currencySymbol)
                        .font(.title.weight(.bold))
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)
                    
                    TextField("0.00", text: $targetAmount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(RobinhoodColors.primary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 20)
            }
            .frame(height: 72)
        }
    }
    
    private var savedAmountSection: some View {
        let preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD (US Dollar)"
        let currencyCode = preferredCurrency.components(separatedBy: " ").first ?? "USD"
        let currencySymbol = Locale.availableIdentifiers.compactMap { Locale(identifier: $0) }
            .first(where: { $0.currency?.identifier == currencyCode })?.currencySymbol ?? "$"
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "banknote")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                Text("Current Saved")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(RobinhoodColors.primary)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                
                HStack(spacing: 12) {
                    Text(currencySymbol)
                        .font(.title.weight(.bold))
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)
                    
                    TextField("0.00", text: $savedAmount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(RobinhoodColors.primary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 20)
            }
            .frame(height: 72)
        }
    }
    
    private var targetDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                Text("Target Date")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(RobinhoodColors.primary)
            }
            
            DatePicker("", selection: $targetDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
        }
    }
    
    private var iconPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "paintbrush.circle.fill")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                Text("Icon & Category")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(RobinhoodColors.primary)
            }
            
            // Category row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppPaddings.sm) {
                    ForEach(TransactionCategoryType.allCases) { cat in
                        Button(action: {
                            selectedCategory = cat
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
                                    .foregroundColor(selectedCategory == cat ? .white : RobinhoodColors.primary)
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
                HStack(spacing: AppPaddings.sm) {
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell.circle.fill")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                Text("Reminders")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(RobinhoodColors.primary)
            }
            
            Toggle(isOn: $notifyMe) {
                Text("Remind Me")
                    .font(.body)
                    .foregroundColor(RobinhoodColors.primary)
            }
            .tint(AppColors.secondary)
            
            if notifyMe {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Frequency")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Picker("Frequency", selection: $reminderFrequency) {
                        ForEach(RecurringFrequency.allCases) { frequency in
                            Text(frequency.label).tag(frequency)
                        }
                    }
                    .pickerStyle(.segmented)
                        .padding(.horizontal, 4)
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                Text("Notes")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(RobinhoodColors.primary)
            }
            
            TextField("Add a note about this goal...", text: $notes, axis: .vertical)
                .font(.body)
                .lineLimit(3...6)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                )
        }
    }
    
    private var saveButtonSection: some View {
        Button(action: save) {
            Text("Save Goal")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(goalName.isEmpty || targetAmount.isEmpty ? Color(.systemGray4) : AppColors.black)
                )
        }
        .disabled(goalName.isEmpty || targetAmount.isEmpty)
        .padding(.top, 8)
    }

    private func save() {
        if let target = Double(targetAmount), let saved = Double(savedAmount) {
            onSave(GoalFormItem(
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
// You can reuse GoalFormItem from GoalFormView 