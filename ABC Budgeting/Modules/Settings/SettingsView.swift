import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("preferredCountry") private var selectedCountry: String = "United States"
    @AppStorage("preferredCurrency") private var selectedCurrency: String = "USD"
    @AppStorage("displayName") private var displayName: String = "User Name"
    @State private var showClearDataAlert = false
    let countries = ["United States", "Canada", "United Kingdom", "Australia", "Germany"]
    let currencies = ["USD", "CAD", "GBP", "EUR", "AUD"]
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                        Text(displayName)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "pencil")
                            .foregroundColor(.secondary)
                    }
                }
                Section(header: Text("Preferences")) {
                    Picker("Country", selection: $selectedCountry) {
                        ForEach(countries, id: \.self) { country in
                            Text(country)
                        }
                    }
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }
                    Toggle(isOn: $notificationsEnabled) {
                        Text("Enable Notifications")
                    }
                    .tint(AppColors.brandGreen)
                }
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
                Section {
                    NavigationLink(destination: AboutView()) {
                        Text("About")
                    }
                } footer: {
                    Text("App Version 1.0.0")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .listStyle(.insetGrouped)
            .alert("Are you sure you want to clear all data? This action cannot be undone.", isPresented: $showClearDataAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear All Data", role: .destructive) {
                    // TODO: Implement clear data logic
                }
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "info.circle")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
            Text("ABC Budgeting")
                .font(.title2.bold())
            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("© 2024 Spookers. All rights reserved.")
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .navigationTitle("About")
        .background(AppColors.background.ignoresSafeArea())
    }
}
