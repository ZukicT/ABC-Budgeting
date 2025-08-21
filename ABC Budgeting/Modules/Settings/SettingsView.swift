import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("preferredCurrency") private var selectedCurrency: String = "USD"
    @AppStorage("displayName") private var displayName: String = "User Name"
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @State private var showClearDataAlert = false
    @State private var showEditNameSheet = false
    @State private var tempDisplayName: String = ""
    let currencies = CurrencyList.all
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    // Section Title
                    Text("Settings")
                        .font(.title.bold())
                        .foregroundColor(.primary)
                        .padding(.top, AppPaddings.sectionTitleTop)
                        .padding(.bottom, AppPaddings.sectionTitleBottom)
                        .padding(.horizontal, AppPaddings.section)
                    List {
                        AccountSection(displayName: displayName, onEdit: {
                            tempDisplayName = displayName
                            showEditNameSheet = true
                        })
                        .listRowInsets(EdgeInsets(top: 0, leading: AppPaddings.section, bottom: 0, trailing: AppPaddings.section))
                        .clipShape(RoundedRectangle(cornerRadius: AppPaddings.cardRadius, style: .continuous))
                        PreferencesSection(selectedCurrency: $selectedCurrency, notificationsEnabled: $notificationsEnabled, hapticsEnabled: $hapticsEnabled, currencies: currencies)
                        .listRowInsets(EdgeInsets(top: 0, leading: AppPaddings.section, bottom: 0, trailing: AppPaddings.section))
                        .clipShape(RoundedRectangle(cornerRadius: AppPaddings.cardRadius, style: .continuous))
                        DataSection(showClearDataAlert: $showClearDataAlert)
                        .listRowInsets(EdgeInsets(top: 0, leading: AppPaddings.section, bottom: 0, trailing: AppPaddings.section))
                        .clipShape(RoundedRectangle(cornerRadius: AppPaddings.cardRadius, style: .continuous))
                        AboutSection()
                        .listRowInsets(EdgeInsets(top: 0, leading: AppPaddings.section, bottom: 0, trailing: AppPaddings.section))
                        .clipShape(RoundedRectangle(cornerRadius: AppPaddings.cardRadius, style: .continuous))
                    }
                    .listStyle(.plain)
                    .alert("Are you sure you want to clear all data? This action cannot be undone.", isPresented: $showClearDataAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Clear All Data", role: .destructive) {
                            // TODO: Implement clear data logic
                        }
                    }
                    .sheet(isPresented: $showEditNameSheet) {
                        NavigationView {
                            VStack(spacing: 24) {
                                Text("Edit Display Name")
                                    .font(.title2.bold())
                                    .padding(.top, 32)
                                TextField("Display Name", text: $tempDisplayName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Spacer()
                            }
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("Cancel") { showEditNameSheet = false }
                                }
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Save") {
                                        displayName = tempDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
                                        showEditNameSheet = false
                                    }.disabled(tempDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Account Section
private struct AccountSection: View {
    let displayName: String
    let onEdit: () -> Void
    var body: some View {
        Section {
            Button(action: onEdit) {
                HStack {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 40)
                        .foregroundColor(.gray)
                    Text(displayName)
                        .font(.headline)
                    Spacer(minLength: 0)
                    Image(systemName: "pencil")
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preferences Section
private struct PreferencesSection: View {
    @Binding var selectedCurrency: String
    @Binding var notificationsEnabled: Bool
    @Binding var hapticsEnabled: Bool
    let currencies: [String]
    var body: some View {
        Section(header: Text("Preferences")) {
            Picker("Currency", selection: $selectedCurrency) {
                ForEach(currencies, id: \.self) { currency in
                    Text(currency)
                }
            }
            Toggle(isOn: $notificationsEnabled) {
                Text("Enable Notifications")
            }
            .tint(AppColors.brandGreen)
            Toggle(isOn: $hapticsEnabled) {
                Text("Enable Haptic Feedback")
            }
            .tint(AppColors.brandGreen)
        }
    }
}

// MARK: - Data Section
private struct DataSection: View {
    @Binding var showClearDataAlert: Bool
    var body: some View {
        Section(header: Text("Data")) {
            Button(action: { /* TODO: Implement import */ }) {
                Label("Import Data", systemImage: "square.and.arrow.down")
            }
            Button(action: { /* TODO: Implement export */ }) {
                Label("Export Data", systemImage: "square.and.arrow.up")
            }
            Button(role: .destructive, action: { showClearDataAlert = true }) {
                Label("Clear All Data", systemImage: "trash")
            }
        }
    }
}

// MARK: - About Section
private struct AboutSection: View {
    var body: some View {
        Section(
            content: {
                NavigationLink(destination: AboutView()) {
                    Text("About")
                }
            },
            footer: {
                Text("App Version 1.0.0")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        )
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "info.circle")
                .resizable()
                .frame(height: 60)
                .foregroundColor(.blue)
            Text("ABC Budgeting")
                .font(.title2.bold())
            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("© 2024 Spookers. All rights reserved.")
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer(minLength: 0)
        }
        .padding()
        .navigationTitle("About")
        .background(AppColors.background.ignoresSafeArea())
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
