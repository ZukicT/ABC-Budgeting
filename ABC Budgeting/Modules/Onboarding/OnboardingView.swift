import SwiftUI
import UserNotifications
import Foundation

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage: Int = 0
    private let totalPages = 5
    @State private var username: String = ""
    @State private var balanceRaw: String = ""
    @State private var balance: String = ""
    @State private var currency: String = "USD (US Dollar)"
    @State private var notificationsEnabled: Bool = false
    @State private var showNotificationAlert = false
    private let currencies = CurrencyList.all

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                // Feature 1: Group_Shape
                OnboardingPageView(
                    illustration: SingleShapeIllustration(assetName: "Group_Shape", height: 240),
                    title: "Track Your Spending",
                    description: "Easily monitor your expenses and stay on top of your finances."
                )
                .tag(0)
                
                // Feature 2: PinkCornerCurve
                OnboardingPageView(
                    illustration: SingleShapeIllustration(assetName: "PinkCornerCurve"),
                    title: "Set Budgets & Goals",
                    description: "Create budgets and savings goals to reach your financial dreams."
                )
                .tag(1)
                
                // Feature 3: GreenCircle
                OnboardingPageView(
                    illustration: SingleShapeIllustration(assetName: "GreenCircle"),
                    title: "See Insights & Trends",
                    description: "Visualize your spending patterns and make smarter decisions."
                )
                .tag(2)
                
                // Welcome / Get Started: ABC_Logo
                OnboardingPageView(
                    illustration: SingleShapeIllustration(assetName: "ABC_Logo", height: 120),
                    title: "Welcome to ABC Budgeting!",
                    description: "Let's start by filling out some basic info to personalize your experience."
                )
                .tag(3)
                
                // Form Page
                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 32)
                    // Title & Subtitle
                    Text("Tell us about you")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 4)
                    Text("we will use this to personalize your expences.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.bottom, 32)

                    // Form Fields
                    Group {
                        FormField(label: "Display Name") {
                            TextField("Username", text: $username)
                                .textContentType(.name)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(16)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .padding(.bottom, 20)

                        FormField(label: "Current Total Balance") {
                            TextField("$0.00", text: $balanceRaw)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(16)
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .onChange(of: balanceRaw) { _, newValue in
                                    let currencyCode = currency.components(separatedBy: " ").first ?? "USD"
                                    let cleaned = newValue.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                                    if let cents = Int(cleaned) {
                                        let doubleValue = Double(cents) / 100.0
                                        balance = String(format: "%.2f", doubleValue)
                                        let formatter = NumberFormatter()
                                        formatter.numberStyle = .currency
                                        formatter.currencyCode = currencyCode
                                        formatter.maximumFractionDigits = 2
                                        balanceRaw = formatter.string(from: NSNumber(value: doubleValue)) ?? "$0.00"
                                    } else {
                                        balance = "0.00"
                                        let formatter = NumberFormatter()
                                        formatter.numberStyle = .currency
                                        formatter.currencyCode = currencyCode
                                        formatter.maximumFractionDigits = 2
                                        balanceRaw = formatter.string(from: NSNumber(value: 0.0)) ?? "$0.00"
                                    }
                                }
                        }
                        .padding(.bottom, 20)

                        FormField(label: "Preferred Currency") {
                            Picker("", selection: $currency) {
                                ForEach(currencies, id: \.self) { currency in
                                    Text(currency).tag(currency)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                            .font(.body)
                            .foregroundColor(.primary)
                        }
                        .padding(.bottom, 20)

                        FormField(label: "Enable Notifications") {
                            Toggle("", isOn: $notificationsEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: AppColors.brandGreen))
                                .labelsHidden()
                        }
                    }
                    .padding(.horizontal, 0)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 500)
                .tag(4)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            Spacer(minLength: 0)
            
            HStack(alignment: .bottom) {
                // Carousel dots left-aligned
                HStack(spacing: 10) {
                    ForEach(0..<totalPages, id: \.self) { i in
                        Circle()
                            .fill(i == currentPage ? AppColors.brandWhite : AppColors.brandWhite.opacity(0.3))
                            .frame(width: 10, height: 10)
                            .scaleEffect(i == currentPage ? 1.2 : 1)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPage)
                    }
                }
                .padding(.leading, AppPaddings.section)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    if currentPage < totalPages - 1 {
                        withAnimation { currentPage += 1 }
                    } else {
                        UserDefaults.standard.set(username, forKey: "displayName")
                        let balanceValue = Double(balance) ?? 0
                        UserDefaults.standard.set(balanceValue, forKey: "startingBalance")
                        UserDefaults.standard.set(currency, forKey: "preferredCurrency")
                        if notificationsEnabled {
                            showNotificationAlert = true
                        } else {
                            onComplete()
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.brandWhite)
                            .frame(width: 56, height: 56)
                            .shadow(radius: 4, y: 2)
                        Image(systemName: currentPage < totalPages - 1 ? "arrow.right" : "checkmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                .accessibilityLabel(currentPage < totalPages - 1 ? "Next" : "Get Started")
                .padding(.trailing, AppPaddings.section)
                .disabled(showNotificationAlert)
            }
            .padding(.bottom, AppPaddings.large)
        }
        .background(AppColors.brandBlack.ignoresSafeArea())
        .onTapGesture { self.hideKeyboard() }
        .alert(isPresented: $showNotificationAlert) {
            Alert(
                title: Text("Enable Notifications?"),
                message: Text("ABC Budgeting will use notifications to remind you about budgets, savings goals, and important account activity. Would you like to allow notifications?"),
                primaryButton: .default(Text("Allow"), action: {
                    showNotificationAlert = false
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                        DispatchQueue.main.async {
                            onComplete()
                        }
                    }
                }),
                secondaryButton: .cancel(Text("Not Now"), action: {
                    showNotificationAlert = false
                    onComplete()
                })
            )
        }
    }
}

private struct OnboardingPageView: View {
    let illustration: AnyView
    let title: String
    let description: String
    init<Content: View>(illustration: Content, title: String, description: String) {
        self.illustration = AnyView(illustration)
        self.title = title
        self.description = description
    }
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer(minLength: geo.size.height * 0.08)
                illustration
                    .frame(maxWidth: .infinity)
                Spacer(minLength: AppPaddings.large)
                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundColor(AppColors.brandWhite)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppPaddings.section)
                Spacer(minLength: AppPaddings.small)
                Text(description)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppColors.brandWhite.opacity(0.7))
                    .padding(.horizontal, AppPaddings.large)
                Spacer()
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

private struct SingleShapeIllustration: View {
    let assetName: String
    var height: CGFloat = 180
    var body: some View {
        Image(assetName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: height)
            .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 4)
            .padding(.vertical, 16)
    }
}

// MARK: - Modern Form Components

private struct ModernTextField: View {
    @Binding var text: String
    let placeholder: String
    let accessibilityLabel: String
    var body: some View {
        TextField(placeholder, text: $text)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.separator), lineWidth: 1)
            )
            .font(.body)
            .foregroundColor(.primary)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint(placeholder)
    }
}

private struct ModernPicker: View {
    @Binding var selection: String
    let options: [String]
    let placeholder: String
    let accessibilityLabel: String
    var body: some View {
        Picker(selection: $selection, label: HStack {
            Text(selection.isEmpty ? placeholder : selection)
                .foregroundColor(selection.isEmpty ? .secondary : .primary)
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )) {
            ForEach(options, id: \.self) { option in
                Text(option).tag(option)
            }
        }
        .pickerStyle(.menu)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(selection.isEmpty ? "Not selected" : selection)
        .accessibilityHint(placeholder)
    }
}

private struct ModernDatePicker: View {
    @Binding var date: Date
    let accessibilityLabel: String
    var body: some View {
        DatePicker(
            "",
            selection: $date,
            displayedComponents: .date
        )
        .datePickerStyle(.compact)
        .labelsHidden()
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(date.formatted(date: .long, time: .omitted))
    }
}

private struct FormSection<Content: View>: View {
    let title: String
    let content: Content
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.primary)
                .accessibilityAddTraits(.isHeader)
            content
        }
        .accessibilityElement(children: .combine)
    }
}

private struct FormField<Content: View>: View {
    let label: String
    let content: Content
    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
            content
        }
    }
}

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(onComplete: {})
    }
}
#endif

