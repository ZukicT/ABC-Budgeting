import SwiftUI
import Foundation

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
                // Enhanced Sheet Header with gradient background - matching AddTransactionView
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
                        
                        Text("New Savings Goal")
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
                        currentSavedSection
                        targetDateSection
                        iconSection
                        colorSection
                        notesSection
                        saveButtonSection
                    }
                    .padding(.horizontal, AppPaddings.section)
                    .padding(.bottom, AppPaddings.large)
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
            Text("Savings Goal Details")
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
            Text("Create a new savings goal to track your progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }
    
    private var goalNameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(AppColors.primary)
                    .font(.title2)
                Text("Goal Name")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            TextField("e.g. Vacation, New Car, Emergency Fund", text: $name)
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
                Image(systemName: "textformat")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                Text("Description")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            TextField("e.g. Trip to Italy, Down payment for house", text: $subtitle)
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
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                Text("Target Amount")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
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
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 20)
            }
            .frame(height: 72)
            
            if let doubleValue = Double(targetAmount), doubleValue > 0 {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.secondary)
                        .font(.caption)
                    Text(doubleValue, format: .currency(code: currencyCode))
                        .font(.caption.weight(.medium))
                        .foregroundColor(AppColors.secondary)
                }
                .padding(.leading, 4)
            }
        }
    }
    
    private var currentSavedSection: some View {
        let preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD (US Dollar)"
        let currencyCode = preferredCurrency.components(separatedBy: " ").first ?? "USD"
        let currencySymbol = Locale.availableIdentifiers.compactMap { Locale(identifier: $0) }
            .first(where: { $0.currency?.identifier == currencyCode })?.currencySymbol ?? "$"
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "banknote")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                Text("Currently Saved")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                
                HStack(spacing: 12) {
                    Text(currencySymbol)
                        .font(.title2.weight(.bold))
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)
                    
                    TextField("0.00", text: $savedAmount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 16)
            }
            .frame(height: 56)
            
            if let doubleValue = Double(savedAmount), doubleValue > 0 {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.secondary)
                        .font(.caption)
                    Text(doubleValue, format: .currency(code: currencyCode))
                        .font(.caption.weight(.medium))
                        .foregroundColor(AppColors.secondary)
                }
                .padding(.leading, 4)
            }
        }
    }
    
    private var targetDateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                Text("Target Date")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            DatePicker("", selection: $targetDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                )
            
            // Progress indicator
            if let target = Double(targetAmount), let saved = Double(savedAmount), target > 0 {
                let progress = min(saved / target, 1.0)
                VStack(spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.caption.weight(.bold))
                            .foregroundColor(AppColors.secondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.secondary)
                                .frame(width: geometry.size.width * progress, height: 8)
                                .animation(.easeInOut(duration: 0.5), value: progress)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                Text("Goal Icon")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            // Icon selection grid - matching AddTransactionView style
            VStack(spacing: 12) {
                Text("Choose an Icon")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(goalIcons, id: \.self) { icon in
                        Button(action: {
                            iconName = icon
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(iconName == icon ? iconColor : iconColor.opacity(0.15))
                                        .frame(width: 48, height: 48)
                                    
                                    Image(systemName: icon)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(iconName == icon ? .white : iconColor)
                                }
                                
                                Text(icon)
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(iconName == icon ? iconColor : .primary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(iconName == icon ? iconColor.opacity(0.1) : Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(iconName == icon ? iconColor : Color.clear, lineWidth: 2)
                                    )
                            )
                            .shadow(color: iconName == icon ? iconColor.opacity(0.2) : Color.black.opacity(0.05), radius: 8, y: 2)
                        }
                        .buttonStyle(.plain)
                        .scaleEffect(iconName == icon ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: iconName == icon)
                        .accessibilityLabel(icon)
                        .accessibilityAddTraits(iconName == icon ? .isSelected : .isButton)
                    }
                }
            }
            
            // Custom icon input - matching AddTransactionView style
            if !selectedCategory.icons.isEmpty {
                VStack(spacing: 12) {
                    Text("Or enter custom SF Symbol name")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                    
                    TextField("e.g. airplane, car, house", text: $iconName)
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
        }
    }
    
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "paintpalette.fill")
                    .foregroundColor(AppColors.secondary)
                    .font(.title2)
                Text("Icon Color")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 16) {
                // Color picker
                ColorPicker("Pick a color", selection: $iconColor, supportsOpacity: false)
                    .labelsHidden()
                    .scaleEffect(1.2)
                
                // Quick color presets - matching AddTransactionView style
                VStack(spacing: 8) {
                    Text("Quick Colors")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 6), spacing: 8) {
                        ForEach(quickColors, id: \.self) { color in
                            Button(action: {
                                iconColor = color
                            }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(iconColor == color ? Color.white : Color.clear, lineWidth: 3)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                            .scaleEffect(iconColor == color ? 1.1 : 1.0)
                            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: iconColor == color)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
            )
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
                    .foregroundColor(.primary)
            }
            
            TextField("Add notes about your goal...", text: $notes, axis: .vertical)
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
        VStack(spacing: 16) {
            Button(action: save) {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                    Text("Create Savings Goal")
                        .font(.headline.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(canSave ? AppColors.black : Color(.systemGray4))
                        .shadow(color: canSave ? AppColors.black.opacity(0.3) : Color.clear, radius: 8, y: 4)
                )
                .foregroundColor(.white)
            }
            .disabled(!canSave)
            .scaleEffect(canSave ? 1.0 : 0.98)
            .animation(.easeInOut(duration: 0.2), value: canSave)
            
            if !canSave {
                Text("Please fill in the goal name and target amount to continue")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 8)
    }
    
    private var canSave: Bool {
        !name.isEmpty && !targetAmount.isEmpty && Double(targetAmount) != nil
    }
    
    private var goalIcons: [String] {
        [
            "target", "airplane", "car", "house", "laptopcomputer", "gift", "creditcard", "cart",
            "bag", "gamecontroller", "music.note", "camera", "book", "graduationcap", "heart", "star"
        ]
    }
    
    private var quickColors: [Color] {
        [
            .blue, .green, .orange, .red, .purple, .pink,
            .mint, .teal, .indigo, .yellow, .brown, .gray
        ]
    }
    
    // Mock selectedCategory for icon section compatibility
    private var selectedCategory: TransactionCategory {
        .savings // Default to savings category for goals
    }

    private func save() {
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
}



#if DEBUG
struct GoalFormView_Previews: PreviewProvider {
    static var previews: some View {
        GoalFormView { _ in }
            .background(AppColors.background)
    }
}
#endif 