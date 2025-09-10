# Settings Module - Draft Specification

## Overview

The Settings Module is a comprehensive configuration and management interface for the ABC Budgeting app. It provides users with control over their account settings, app preferences, data management, and app information. The module follows the established MVVM-C architecture and maintains visual consistency with the Overview tab design patterns.

## Current Implementation Analysis

### Existing Features
- **Account Management**: Display name, starting balance, currency selection
- **Preferences**: Notifications, haptic feedback toggles
- **Data Management**: Import/export functionality, data clearing
- **About Section**: App information and version details

### Architecture
- **View**: `SettingsView.swift` - Main settings interface
- **State Management**: Uses `@AppStorage` for persistence
- **Navigation**: Modal sheets for detailed configuration
- **Data Binding**: Direct binding to transaction and goal arrays

## Enhanced Settings Module Specification

### 1. Account Section

#### 1.1 User Profile Management
**Current State**: Basic display name editing
**Enhancement**: Comprehensive profile management

**Features:**
- Display name with validation (2-50 characters)
- Profile picture selection (optional)
- Account creation date display
- Last sync timestamp
- Account status indicator

**UI Components:**
```swift
// Profile Header Card
VStack(spacing: 16) {
    // Profile Picture
    Circle()
        .fill(AppColors.primary.opacity(0.1))
        .frame(width: 80, height: 80)
        .overlay(
            Image(systemName: "person.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(AppColors.primary)
        )
    
    // User Info
    VStack(spacing: 4) {
        Text(displayName)
            .font(.title2.weight(.semibold))
        Text("Member since \(accountCreationDate)")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
```

#### 1.2 Financial Settings
**Current State**: Basic starting balance and currency
**Enhancement**: Comprehensive financial configuration

**Features:**
- Starting balance with currency formatting
- Currency selection with live preview
- Financial year settings
- Tax settings (optional)
- Budget cycle configuration (monthly/weekly)

**UI Components:**
```swift
// Financial Settings Card
VStack(spacing: 12) {
    SettingRow(
        icon: "dollarsign.circle",
        title: "Starting Balance",
        value: "$\(baselineBalance, specifier: "%.2f")",
        action: { showBaselineBalanceSheet = true }
    )
    
    SettingRow(
        icon: "globe",
        title: "Currency",
        value: selectedCurrency,
        action: { showCurrencyPicker = true }
    )
    
    SettingRow(
        icon: "calendar",
        title: "Budget Cycle",
        value: budgetCycle.rawValue,
        action: { showBudgetCyclePicker = true }
    )
}
```

### 2. Preferences Section

#### 2.1 App Behavior
**Current State**: Notifications and haptics
**Enhancement**: Comprehensive app behavior settings

**Features:**
- Notification preferences (all, important only, off)
- Haptic feedback intensity (off, light, medium, strong)
- Sound effects toggle
- Auto-lock timeout
- Theme preferences (system, light, dark)
- Language selection

**UI Components:**
```swift
// App Behavior Card
VStack(spacing: 12) {
    ToggleSettingRow(
        icon: "bell",
        title: "Notifications",
        subtitle: "Transaction reminders and alerts",
        isOn: $notificationsEnabled
    )
    
    PickerSettingRow(
        icon: "hand.tap",
        title: "Haptic Feedback",
        subtitle: "Touch feedback intensity",
        selection: $hapticIntensity,
        options: HapticIntensity.allCases
    )
    
    ToggleSettingRow(
        icon: "speaker.wave.2",
        title: "Sound Effects",
        subtitle: "Audio feedback for actions",
        isOn: $soundEffectsEnabled
    )
}
```

#### 2.2 Display Preferences
**New Feature**: Visual customization options

**Features:**
- Font size adjustment (small, medium, large)
- Color scheme selection
- Chart style preferences
- Number format preferences
- Date format preferences

**UI Components:**
```swift
// Display Preferences Card
VStack(spacing: 12) {
    PickerSettingRow(
        icon: "textformat.size",
        title: "Font Size",
        subtitle: "Adjust text size for readability",
        selection: $fontSize,
        options: FontSize.allCases
    )
    
    PickerSettingRow(
        icon: "paintbrush",
        title: "Color Scheme",
        subtitle: "Choose your preferred colors",
        selection: $colorScheme,
        options: ColorScheme.allCases
    )
}
```

### 3. Data Management Section

#### 3.1 Data Operations
**Current State**: Basic import/export and clear data
**Enhancement**: Comprehensive data management

**Features:**
- Data export (CSV, JSON, PDF)
- Data import with validation
- Data backup to iCloud
- Data restore from backup
- Data synchronization status
- Storage usage information

**UI Components:**
```swift
// Data Management Card
VStack(spacing: 12) {
    ActionSettingRow(
        icon: "square.and.arrow.up",
        title: "Export Data",
        subtitle: "Download your financial data",
        action: { showExportOptions = true }
    )
    
    ActionSettingRow(
        icon: "square.and.arrow.down",
        title: "Import Data",
        subtitle: "Restore from backup file",
        action: { showImportOptions = true }
    )
    
    InfoSettingRow(
        icon: "icloud",
        title: "iCloud Backup",
        subtitle: "Last backup: \(lastBackupDate)",
        status: backupStatus
    )
    
    ActionSettingRow(
        icon: "trash",
        title: "Clear All Data",
        subtitle: "Permanently delete all data",
        action: { showClearDataAlert = true },
        isDestructive: true
    )
}
```

#### 3.2 Privacy & Security
**New Feature**: Privacy and security settings

**Features:**
- Biometric authentication toggle
- App lock timeout
- Data encryption status
- Privacy policy access
- Terms of service access
- Data retention settings

**UI Components:**
```swift
// Privacy & Security Card
VStack(spacing: 12) {
    ToggleSettingRow(
        icon: "faceid",
        title: "Biometric Lock",
        subtitle: "Use Face ID or Touch ID",
        isOn: $biometricLockEnabled
    )
    
    PickerSettingRow(
        icon: "lock",
        title: "Auto Lock",
        subtitle: "Lock app after inactivity",
        selection: $autoLockTimeout,
        options: AutoLockTimeout.allCases
    )
    
    ActionSettingRow(
        icon: "doc.text",
        title: "Privacy Policy",
        subtitle: "View our privacy policy",
        action: { showPrivacyPolicy = true }
    )
}
```

### 4. Advanced Settings Section

#### 4.1 Financial Tools
**New Feature**: Advanced financial management tools

**Features:**
- Recurring transaction management
- Budget alerts configuration
- Goal reminder settings
- Financial reporting preferences
- Tax category management

**UI Components:**
```swift
// Financial Tools Card
VStack(spacing: 12) {
    ActionSettingRow(
        icon: "repeat",
        title: "Recurring Transactions",
        subtitle: "Manage automatic transactions",
        action: { showRecurringTransactions = true }
    )
    
    ActionSettingRow(
        icon: "target",
        title: "Goal Reminders",
        subtitle: "Configure savings goal alerts",
        action: { showGoalReminders = true }
    )
    
    ActionSettingRow(
        icon: "chart.bar",
        title: "Financial Reports",
        subtitle: "Customize reporting options",
        action: { showReportSettings = true }
    )
}
```

#### 4.2 Integration Settings
**New Feature**: Third-party integrations

**Features:**
- Bank account connections (future)
- Calendar integration
- Widget configuration
- Siri shortcuts
- Apple Watch settings

**UI Components:**
```swift
// Integration Settings Card
VStack(spacing: 12) {
    ToggleSettingRow(
        icon: "calendar",
        title: "Calendar Integration",
        subtitle: "Sync with your calendar",
        isOn: $calendarIntegrationEnabled
    )
    
    ActionSettingRow(
        icon: "applewatch",
        title: "Apple Watch",
        subtitle: "Configure watch app settings",
        action: { showWatchSettings = true }
    )
    
    ActionSettingRow(
        icon: "mic",
        title: "Siri Shortcuts",
        subtitle: "Set up voice commands",
        action: { showSiriShortcuts = true }
    )
}
```

### 5. About Section

#### 5.1 App Information
**Current State**: Basic app info
**Enhancement**: Comprehensive app information

**Features:**
- App version with build number
- Release notes access
- Feature request submission
- Bug report submission
- App rating prompt
- Developer contact

**UI Components:**
```swift
// App Information Card
VStack(spacing: 12) {
    InfoSettingRow(
        icon: "info.circle",
        title: "Version",
        subtitle: "\(appVersion) (\(buildNumber))",
        action: { showReleaseNotes = true }
    )
    
    ActionSettingRow(
        icon: "star",
        title: "Rate App",
        subtitle: "Help us improve",
        action: { requestAppRating() }
    )
    
    ActionSettingRow(
        icon: "envelope",
        title: "Contact Support",
        subtitle: "Get help with the app",
        action: { showContactSupport = true }
    )
    
    ActionSettingRow(
        icon: "doc.text",
        title: "Terms of Service",
        subtitle: "View terms and conditions",
        action: { showTermsOfService = true }
    )
}
```

### 6. Technical Implementation

#### 6.1 Data Models
```swift
// Settings Data Models
struct UserProfile {
    let displayName: String
    let profilePicture: Data?
    let accountCreationDate: Date
    let lastSyncDate: Date?
}

struct AppPreferences {
    let notificationsEnabled: Bool
    let hapticIntensity: HapticIntensity
    let soundEffectsEnabled: Bool
    let fontSize: FontSize
    let colorScheme: ColorScheme
    let budgetCycle: BudgetCycle
}

struct PrivacySettings {
    let biometricLockEnabled: Bool
    let autoLockTimeout: AutoLockTimeout
    let dataEncryptionEnabled: Bool
    let dataRetentionDays: Int
}
```

#### 6.2 Settings Manager
```swift
// Settings Management
@Observable
class SettingsManager {
    var userProfile: UserProfile
    var appPreferences: AppPreferences
    var privacySettings: PrivacySettings
    
    func saveSettings() async throws {
        // Save to Core Data
    }
    
    func resetToDefaults() {
        // Reset all settings
    }
    
    func exportSettings() -> Data {
        // Export settings as JSON
    }
    
    func importSettings(_ data: Data) throws {
        // Import settings from JSON
    }
}
```

#### 6.3 UI Components
```swift
// Reusable Settings Components
struct SettingRow<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String?
    let content: Content
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            content
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

struct ToggleSettingRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    
    var body: some View {
        SettingRow(icon: icon, title: title, subtitle: subtitle) {
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: AppColors.primary))
        }
    }
}
```

### 7. Navigation Flow

#### 7.1 Main Settings Flow
```
SettingsView
├── Account Section
│   ├── Profile Management
│   ├── Financial Settings
│   └── Currency Selection
├── Preferences Section
│   ├── App Behavior
│   ├── Display Preferences
│   └── Language Settings
├── Data Management Section
│   ├── Export Options
│   ├── Import Options
│   ├── Backup Settings
│   └── Privacy & Security
├── Advanced Settings Section
│   ├── Financial Tools
│   └── Integration Settings
└── About Section
    ├── App Information
    ├── Support Options
    └── Legal Information
```

#### 7.2 Modal Sheets
- Profile Edit Sheet
- Currency Picker Sheet
- Budget Cycle Picker Sheet
- Export Options Sheet
- Import Options Sheet
- Privacy Policy Sheet
- Terms of Service Sheet
- Contact Support Sheet

### 8. Accessibility Features

#### 8.1 VoiceOver Support
- All settings have descriptive labels
- Navigation hints for complex interactions
- VoiceOver announcements for state changes

#### 8.2 Dynamic Type Support
- All text scales with system font size
- Layout adapts to larger text sizes
- Maintains usability at all font sizes

#### 8.3 Color Accessibility
- High contrast mode support
- Color-blind friendly color schemes
- Sufficient color contrast ratios

### 9. Performance Considerations

#### 9.1 Lazy Loading
- Settings sections load on demand
- Heavy operations run in background
- Efficient state management

#### 9.2 Memory Management
- Proper cleanup of modal sheets
- Efficient image handling
- Minimal memory footprint

#### 9.3 Data Persistence
- Settings saved immediately on change
- Backup operations don't block UI
- Error handling for failed saves

### 10. Testing Strategy

#### 10.1 Unit Tests
- Settings manager functionality
- Data validation logic
- State management

#### 10.2 Integration Tests
- Core Data integration
- UserDefaults persistence
- Navigation flow

#### 10.3 UI Tests
- Settings navigation
- Modal sheet interactions
- Accessibility features

### 11. Future Enhancements

#### 11.1 Advanced Features
- Cloud sync for settings
- Settings profiles
- Advanced customization
- Theme editor

#### 11.2 Integrations
- Third-party app connections
- API integrations
- Widget configuration
- Shortcuts app integration

## Conclusion

The enhanced Settings Module provides a comprehensive configuration interface that maintains the app's design consistency while offering powerful customization options. The modular architecture ensures maintainability and extensibility for future enhancements.

**Key Benefits:**
- Consistent user experience across all settings
- Comprehensive configuration options
- Maintainable and extensible architecture
- Accessibility and performance optimized
- Future-ready design patterns

**Implementation Priority:**
1. Core settings functionality (P0)
2. UI consistency improvements (P1)
3. Advanced features (P2)
4. Future enhancements (P3)
