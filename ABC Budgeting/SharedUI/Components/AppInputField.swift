import SwiftUI

// MARK: - App Input Field System
struct AppInputField: View {
    let title: String
    let placeholder: String
    let text: Binding<String>
    let style: InputStyle
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    let errorMessage: String?
    let helperText: String?
    let leadingIcon: String?
    let trailingIcon: String?
    let onTrailingIconTap: (() -> Void)?
    let isDisabled: Bool
    let maxLength: Int?
    
    @State private var isFocused = false
    @FocusState private var isTextFieldFocused: Bool
    
    init(
        title: String,
        placeholder: String = "",
        text: Binding<String>,
        style: InputStyle = .default,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        errorMessage: String? = nil,
        helperText: String? = nil,
        leadingIcon: String? = nil,
        trailingIcon: String? = nil,
        onTrailingIconTap: (() -> Void)? = nil,
        isDisabled: Bool = false,
        maxLength: Int? = nil
    ) {
        self.title = title
        self.placeholder = placeholder
        self.text = text
        self.style = style
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.errorMessage = errorMessage
        self.helperText = helperText
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.onTrailingIconTap = onTrailingIconTap
        self.isDisabled = isDisabled
        self.maxLength = maxLength
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppPaddings.sm) {
            // Title
            Text(title)
                .font(.label)
                .foregroundColor(titleColor)
            
            // Input Field
            HStack(spacing: AppPaddings.sm) {
                // Leading Icon
                if let leadingIcon = leadingIcon {
                    Image(systemName: leadingIcon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(iconColor)
                        .frame(width: 20, height: 20)
                }
                
                // Text Field
                Group {
                    if isSecure {
                        SecureField(placeholder, text: text)
                    } else {
                        TextField(placeholder, text: text)
                    }
                }
                .font(.body)
                .foregroundColor(textColor)
                .keyboardType(keyboardType)
                .focused($isTextFieldFocused)
                .disabled(isDisabled)
                .onChange(of: text.wrappedValue) { _, newValue in
                    if let maxLength = maxLength, newValue.count > maxLength {
                        text.wrappedValue = String(newValue.prefix(maxLength))
                    }
                }
                
                // Trailing Icon
                if let trailingIcon = trailingIcon {
                    Button(action: onTrailingIconTap ?? {}) {
                        Image(systemName: trailingIcon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(iconColor)
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .frame(height: inputHeight)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: inputRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .onChange(of: isTextFieldFocused) { _, focused in
                withAnimation(.easeInOut(duration: AppAnimations.fast)) {
                    isFocused = focused
                }
            }
            
            // Helper Text or Error Message
            if let errorMessage = errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.bodySmall)
                    .foregroundColor(AppColors.error)
            } else if let helperText = helperText, !helperText.isEmpty {
                Text(helperText)
                    .font(.bodySmall)
                    .foregroundColor(AppColors.textTertiary)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var inputHeight: CGFloat {
        switch style {
        case .default, .search:
            return AppSizes.inputFieldHeight
        case .large:
            return AppSizes.inputFieldHeightLarge
        case .small:
            return AppSizes.inputFieldHeightSmall
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch style {
        case .default, .search:
            return AppPaddings.inputField
        case .large:
            return AppPaddings.inputFieldLarge
        case .small:
            return AppPaddings.inputFieldSmall
        }
    }
    
    private var verticalPadding: CGFloat {
        switch style {
        case .default, .search:
            return AppPaddings.sm
        case .large:
            return AppPaddings.md
        case .small:
            return AppPaddings.xs
        }
    }
    
    private var inputRadius: CGFloat {
        switch style {
        case .default, .search:
            return AppRadius.inputField
        case .large:
            return AppRadius.inputFieldLarge
        case .small:
            return AppRadius.inputFieldSmall
        }
    }
    
    private var titleColor: Color {
        if isDisabled {
            return AppColors.textTertiary
        } else if errorMessage != nil {
            return AppColors.error
        } else {
            return AppColors.textPrimary
        }
    }
    
    private var textColor: Color {
        if isDisabled {
            return AppColors.textTertiary
        } else {
            return AppColors.textPrimary
        }
    }
    
    private var iconColor: Color {
        if isDisabled {
            return AppColors.textTertiary
        } else if errorMessage != nil {
            return AppColors.error
        } else if isFocused {
            return AppColors.primary
        } else {
            return AppColors.textSecondary
        }
    }
    
    private var backgroundColor: Color {
        if isDisabled {
            return AppColors.backgroundSecondary
        } else {
            return AppColors.card
        }
    }
    
    private var borderColor: Color {
        if isDisabled {
            return AppColors.border
        } else if errorMessage != nil {
            return AppColors.error
        } else if isFocused {
            return AppColors.primary
        } else {
            return AppColors.border
        }
    }
    
    private var borderWidth: CGFloat {
        if isFocused || errorMessage != nil {
            return 2
        } else {
            return 1
        }
    }
}

// MARK: - Input Styles
extension AppInputField {
    enum InputStyle {
        case `default`
        case large
        case small
        case search
    }
}

// MARK: - Search Field
struct AppSearchField: View {
    let placeholder: String
    let text: Binding<String>
    let onSearch: (() -> Void)?
    let onClear: (() -> Void)?
    
    @State private var isFocused = false
    @FocusState private var isTextFieldFocused: Bool
    
    init(
        placeholder: String = "Search...",
        text: Binding<String>,
        onSearch: (() -> Void)? = nil,
        onClear: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self.text = text
        self.onSearch = onSearch
        self.onClear = onClear
    }
    
    var body: some View {
        HStack(spacing: AppPaddings.sm) {
            // Search Icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isFocused ? AppColors.primary : AppColors.textSecondary)
            
            // Text Field
            TextField(placeholder, text: text)
                .font(.body)
                .foregroundColor(AppColors.textPrimary)
                .focused($isTextFieldFocused)
                .onSubmit {
                    onSearch?()
                }
                .onChange(of: isTextFieldFocused) { _, focused in
                    withAnimation(.easeInOut(duration: AppAnimations.fast)) {
                        isFocused = focused
                    }
                }
            
            // Clear Button
            if !text.wrappedValue.isEmpty {
                Button(action: {
                    text.wrappedValue = ""
                    onClear?()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textTertiary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, AppPaddings.inputField)
        .padding(.vertical, AppPaddings.sm)
        .frame(height: AppSizes.inputFieldHeight)
        .background(AppColors.card)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.inputField)
                .stroke(isFocused ? AppColors.primary : AppColors.border, lineWidth: isFocused ? 2 : 1)
        )
    }
}

// MARK: - Text Area
struct AppTextArea: View {
    let title: String
    let placeholder: String
    let text: Binding<String>
    let errorMessage: String?
    let helperText: String?
    let maxLength: Int?
    let minHeight: CGFloat
    
    @State private var isFocused = false
    @FocusState private var isTextFieldFocused: Bool
    
    init(
        title: String,
        placeholder: String = "",
        text: Binding<String>,
        errorMessage: String? = nil,
        helperText: String? = nil,
        maxLength: Int? = nil,
        minHeight: CGFloat = 100
    ) {
        self.title = title
        self.placeholder = placeholder
        self.text = text
        self.errorMessage = errorMessage
        self.helperText = helperText
        self.maxLength = maxLength
        self.minHeight = minHeight
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppPaddings.sm) {
            // Title
            Text(title)
                .font(.label)
                .foregroundColor(titleColor)
            
            // Text Area
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: AppRadius.inputField)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.inputField)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
                
                TextEditor(text: text)
                    .font(.body)
                    .foregroundColor(textColor)
                    .focused($isTextFieldFocused)
                    .padding(AppPaddings.inputField)
                    .onChange(of: text.wrappedValue) { _, newValue in
                        if let maxLength = maxLength, newValue.count > maxLength {
                            text.wrappedValue = String(newValue.prefix(maxLength))
                        }
                    }
                    .onChange(of: isTextFieldFocused) { _, focused in
                        withAnimation(.easeInOut(duration: AppAnimations.fast)) {
                            isFocused = focused
                        }
                    }
                
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.body)
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.horizontal, AppPaddings.inputField)
                        .padding(.vertical, AppPaddings.inputField + 4)
                        .allowsHitTesting(false)
                }
            }
            .frame(minHeight: minHeight)
            
            // Character Count
            if let maxLength = maxLength {
                HStack {
                    Spacer()
                    Text("\(text.wrappedValue.count)/\(maxLength)")
                        .font(.bodySmall)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            
            // Helper Text or Error Message
            if let errorMessage = errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.bodySmall)
                    .foregroundColor(AppColors.error)
            } else if let helperText = helperText, !helperText.isEmpty {
                Text(helperText)
                    .font(.bodySmall)
                    .foregroundColor(AppColors.textTertiary)
            }
        }
    }
    
    // MARK: - Computed Properties
    private var titleColor: Color {
        if errorMessage != nil {
            return AppColors.error
        } else {
            return AppColors.textPrimary
        }
    }
    
    private var textColor: Color {
        return AppColors.textPrimary
    }
    
    private var backgroundColor: Color {
        return AppColors.card
    }
    
    private var borderColor: Color {
        if errorMessage != nil {
            return AppColors.error
        } else if isFocused {
            return AppColors.primary
        } else {
            return AppColors.border
        }
    }
    
    private var borderWidth: CGFloat {
        if isFocused || errorMessage != nil {
            return 2
        } else {
            return 1
        }
    }
}

// MARK: - Preview
struct AppInputField_Previews: PreviewProvider {
    @State static private var text = ""
    @State static private var searchText = ""
    @State static private var textAreaText = ""
    
    static var previews: some View {
        ScrollView {
            VStack(spacing: AppPaddings.lg) {
                // Basic Input Fields
                VStack(spacing: AppPaddings.md) {
                    AppInputField(
                        title: "Email",
                        placeholder: "Enter your email",
                        text: $text
                    )
                    
                    AppInputField(
                        title: "Password",
                        placeholder: "Enter your password",
                        text: $text,
                        isSecure: true,
                        errorMessage: "Password is required"
                    )
                    
                    AppInputField(
                        title: "Phone",
                        placeholder: "Enter your phone number",
                        text: $text,
                        keyboardType: .phonePad,
                        helperText: "Include country code",
                        leadingIcon: "phone"
                    )
                }
                
                // Search Field
                AppSearchField(
                    placeholder: "Search transactions...",
                    text: $searchText
                )
                
                // Text Area
                AppTextArea(
                    title: "Description",
                    placeholder: "Enter a description...",
                    text: $textAreaText,
                    maxLength: 200
                )
                
                // Disabled Field
                AppInputField(
                    title: "Disabled Field",
                    placeholder: "This field is disabled",
                    text: $text,
                    isDisabled: true
                )
            }
            .padding()
        }
        .background(AppColors.background)
    }
}
